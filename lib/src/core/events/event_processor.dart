import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../version.dart';

/// Batches experimentation events to `{eventsURI}v1/events`.
///
/// Flushes on a timer, at [maxBuffer], on [flush] and on [stop].
/// Exposures dedupe within a flush window.
///
/// Delivery follows the Flagsmith SDK spec:
/// - One batch is in flight at a time, and each request times out after
///   [requestTimeout] ms.
/// - Network errors, timeouts and 408, 429, 502, 503 and 504 are transient,
///   and other 5xx are server errors: both are retried, up to [maxAttempts]
///   attempts, waiting a random time up to [retryBackoff] ms, doubling.
///   A batch whose last attempt fails transiently is kept, ahead of newer
///   events, for the next flush; any other failed batch is dropped.
/// - Any other status, such as 400, drops the batch at once.
/// - 401 and 403 drop the buffer and stop event tracking for good.
/// - The buffer holds [maxBuffer] events and drops the oldest when full.
class EventProcessor {
  static const String flagExposureEvent = r'$flag_exposure';
  static const String eventsPath = 'v1/events';
  static const String sdkUserAgentHeader = 'Flagsmith-SDK-User-Agent';
  static const String environmentKeyHeader = 'X-Environment-Key';
  static const String contentType = 'application/json; charset=utf-8';
  static const int maxAttempts = 3;
  static const List<int> transientStatuses = [408, 429, 502, 503, 504];

  final Dio _api;
  final String _apiKey;
  final String endpoint;
  final int flushInterval;
  final int maxBuffer;
  final int retryBackoff;
  final int requestTimeout;
  final void Function(String message) _log;
  final Random _random;

  final List<Map<String, dynamic>> _buffer = [];
  final Set<String> _dedupeKeys = {};
  Future<void>? _inFlight;
  Timer? _timer;
  bool _stopped = false;
  bool _unauthorised = false;

  EventProcessor({
    required Dio api,
    required String apiKey,
    required String eventsURI,
    this.flushInterval = 10000,
    this.maxBuffer = 1000,
    this.retryBackoff = 1000,
    this.requestTimeout = 3000,
    void Function(String message)? log,
    Random? random,
  })  : _api = api,
        _apiKey = apiKey,
        _log = log ?? _noopLog,
        _random = random ?? Random(),
        endpoint =
            '${eventsURI.endsWith('/') ? eventsURI : '$eventsURI/'}$eventsPath';

  static void _noopLog(String _) {}

  List<Map<String, dynamic>> get buffer => List.unmodifiable(_buffer);

  /// Whether the events API refused the environment key (401 or 403), which
  /// stops event tracking for the lifetime of this processor.
  bool get unauthorised => _unauthorised;

  void trackEvent({
    required String event,
    String? identifier,
    Object? value,
    Map<String, dynamic>? traits,
    Map<String, dynamic>? metadata,
  }) {
    _bufferEvent(
      event: event,
      featureName: null,
      identifier: identifier,
      value: value,
      traits: traits,
      metadata: metadata,
      dedupe: false,
    );
  }

  void trackExposureEvent({
    required String featureName,
    required String identifier,
    Object? value,
    Map<String, dynamic>? traits,
    Map<String, dynamic>? metadata,
  }) {
    _bufferEvent(
      event: flagExposureEvent,
      featureName: featureName,
      identifier: identifier,
      value: value,
      traits: traits,
      metadata: metadata,
      dedupe: true,
    );
  }

  void _bufferEvent({
    required String event,
    required String? featureName,
    required String? identifier,
    required Object? value,
    required Map<String, dynamic>? traits,
    required Map<String, dynamic>? metadata,
    required bool dedupe,
  }) {
    if (_unauthorised) {
      _log('Events: environment key refused, dropping "$event"');
      return;
    }
    if (_stopped) {
      _log('Events: processor stopped, dropping "$event"');
      return;
    }
    final stringValue = value == null ? null : '$value';
    if (dedupe) {
      // Experiment id is part of the key so a new experiment on the same flag
      // and variant within one flush window still records its own exposure.
      final key = jsonEncode([
        event,
        featureName,
        identifier,
        stringValue,
        metadata?['experiment_id']
      ]);
      if (_dedupeKeys.contains(key)) {
        return;
      }
      _dedupeKeys.add(key);
    }
    if (_buffer.length >= maxBuffer) {
      _buffer.removeAt(0);
      _log('Events: buffer full, dropping the oldest event');
    }
    _buffer.add(<String, dynamic>{
      'event': event,
      'feature_name': featureName,
      'identifier': identifier,
      'value': stringValue,
      'traits': traits,
      'metadata': <String, dynamic>{
        ...?metadata,
        'sdk_version': sdkVersion,
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    // A full buffer is already on its way unless a batch is in flight; it
    // goes with the next flush then.
    if (_buffer.length >= maxBuffer && _inFlight == null) {
      unawaited(flush());
    }
  }

  /// Posts the events buffered when it is called, retries included, after
  /// the batch in flight, if any, so that awaiting it at teardown means the
  /// POSTs have completed. A batch kept after failing while in flight waits
  /// for the next flush. Never throws.
  Future<void> flush() async {
    final hasEvents = _buffer.isNotEmpty;
    while (_inFlight != null) {
      await _inFlight;
    }
    if (!hasEvents || _buffer.isEmpty) {
      return;
    }
    final events = List<Map<String, dynamic>>.from(_buffer);
    _buffer.clear();
    _dedupeKeys.clear();
    final sending = _sendBatch(events);
    _inFlight = sending;
    try {
      await sending;
    } finally {
      if (identical(_inFlight, sending)) {
        _inFlight = null;
      }
    }
  }

  void start() {
    _stopped = false;
    _timer?.cancel();
    _timer = null;
    if (flushInterval > 0) {
      _timer = Timer.periodic(
          Duration(milliseconds: flushInterval), (_) => unawaited(flush()));
    }
  }

  /// Cancels the timer and flushes. The returned future completes once every
  /// upload in flight has finished, and never throws.
  /// Events tracked after this are dropped until [start] is called again.
  Future<void> stop() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    return flush();
  }

  Future<void> _sendBatch(List<Map<String, dynamic>> events) async {
    var outcome = _Outcome.transient;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      outcome = await _postBatch(events);
      switch (outcome) {
        case _Outcome.delivered:
          _log('Events: flush successful (${events.length} events)');
          return;
        case _Outcome.unauthorised:
          _unauthorised = true;
          _timer?.cancel();
          _timer = null;
          _buffer.clear();
          _dedupeKeys.clear();
          _log('Events: environment key refused, dropping ${events.length} '
              'events and stopping event tracking');
          return;
        case _Outcome.rejected:
          _log('Events: batch rejected, dropping ${events.length} events');
          return;
        case _Outcome.transient:
        case _Outcome.serverError:
          if (attempt < maxAttempts) {
            // Full jitter: anything from none up to the doubling backoff.
            final backoff = retryBackoff * (1 << (attempt - 1));
            _log('Events: flush failed (${outcome.name}), retrying');
            await Future<void>.delayed(
                Duration(milliseconds: _random.nextInt(backoff + 1)));
          }
      }
    }
    if (outcome == _Outcome.transient) {
      _buffer.insertAll(0, events);
      final overflow = _buffer.length - maxBuffer;
      if (overflow > 0) {
        _buffer.removeRange(0, overflow);
        _log('Events: buffer full, dropping the $overflow oldest events');
      }
      _log('Events: flush failed, keeping ${events.length} events for the '
          'next flush');
    } else {
      _log('Events: flush failed, dropping ${events.length} events');
    }
  }

  Future<_Outcome> _postBatch(List<Map<String, dynamic>> events) async {
    // Cancelling aborts the request at any stage, closing its connection.
    final cancelToken = CancelToken();
    final deadline = Timer(Duration(milliseconds: requestTimeout),
        () => cancelToken.cancel('timed out after $requestTimeout ms'));
    try {
      final response = await _api.post<dynamic>(
        endpoint,
        data: <String, dynamic>{'events': events},
        cancelToken: cancelToken,
        options: Options(
          contentType: contentType,
          headers: <String, dynamic>{
            environmentKeyHeader: _apiKey,
            sdkUserAgentHeader: getUserAgent(),
          },
          validateStatus: (_) => true,
        ),
      );
      return _outcomeOf(response.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      _log('Events: request failed: ${e.message ?? e.type.name}');
      return status == null ? _Outcome.transient : _outcomeOf(status);
    } catch (e) {
      _log('Events: request failed: $e');
      return _Outcome.transient;
    } finally {
      deadline.cancel();
    }
  }

  static _Outcome _outcomeOf(int? status) {
    if (status == null) {
      return _Outcome.transient;
    }
    if (status >= 200 && status < 300) {
      return _Outcome.delivered;
    }
    if (status == 401 || status == 403) {
      return _Outcome.unauthorised;
    }
    if (transientStatuses.contains(status)) {
      return _Outcome.transient;
    }
    return status >= 500 ? _Outcome.serverError : _Outcome.rejected;
  }
}

/// How one attempt at sending a batch ended.
enum _Outcome { delivered, transient, serverError, rejected, unauthorised }
