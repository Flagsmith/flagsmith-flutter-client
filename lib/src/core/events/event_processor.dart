import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../version.dart';

/// Batches experimentation events to `{eventsURI}v1/events`.
///
/// Flushes on a timer, at [maxBuffer], on [flush] and best-effort on [stop].
/// Exposures dedupe within a flush window; a failed POST retries once then drops.
class EventProcessor {
  static const String flagExposureEvent = r'$flag_exposure';
  static const String eventsPath = 'v1/events';
  static const String sdkUserAgentHeader = 'Flagsmith-SDK-User-Agent';
  static const String environmentKeyHeader = 'X-Environment-Key';
  static const String contentType = 'application/json; charset=utf-8';

  final Dio _api;
  final String _apiKey;
  final String endpoint;
  final int flushInterval;
  final int maxBuffer;
  final int retryBackoff;
  final void Function(String message) _log;

  final List<Map<String, dynamic>> _buffer = [];
  final Set<String> _dedupeKeys = {};
  Timer? _timer;

  EventProcessor({
    required Dio api,
    required String apiKey,
    required String eventsURI,
    this.flushInterval = 10000,
    this.maxBuffer = 1000,
    this.retryBackoff = 1000,
    void Function(String message)? log,
  })  : _api = api,
        _apiKey = apiKey,
        _log = log ?? _noopLog,
        endpoint =
            '${eventsURI.endsWith('/') ? eventsURI : '$eventsURI/'}$eventsPath';

  static void _noopLog(String _) {}

  List<Map<String, dynamic>> get buffer => List.unmodifiable(_buffer);

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
    final stringValue = value == null ? null : '$value';
    if (dedupe) {
      final key = jsonEncode([event, featureName, identifier, stringValue]);
      if (_dedupeKeys.contains(key)) {
        return;
      }
      _dedupeKeys.add(key);
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
    if (_buffer.length >= maxBuffer) {
      unawaited(flush());
    }
  }

  /// Never throws.
  Future<void> flush() async {
    if (_buffer.isEmpty) {
      return;
    }
    final events = List<Map<String, dynamic>>.from(_buffer);
    _buffer.clear();
    _dedupeKeys.clear();
    await _postBatch(events, 0);
  }

  void start() {
    _timer?.cancel();
    _timer = null;
    if (flushInterval > 0) {
      _timer = Timer.periodic(
          Duration(milliseconds: flushInterval), (_) => unawaited(flush()));
    }
  }

  /// Cancels the timer and flushes without awaiting; await [flush] for teardown.
  void stop() {
    _timer?.cancel();
    _timer = null;
    unawaited(flush());
  }

  Future<void> _postBatch(List<Map<String, dynamic>> events, int attempt) async {
    try {
      final response = await _api.post<dynamic>(
        endpoint,
        data: <String, dynamic>{'events': events},
        options: Options(
          contentType: contentType,
          headers: <String, dynamic>{
            environmentKeyHeader: _apiKey,
            sdkUserAgentHeader: getUserAgent(),
          },
        ),
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw StateError('unexpected status $status');
      }
      _log('Events: flush successful (${events.length} events)');
    } catch (e) {
      if (attempt < 1) {
        _log('Events: flush failed, retrying: $e');
        await Future<void>.delayed(Duration(milliseconds: retryBackoff));
        return _postBatch(events, attempt + 1);
      }
      _log('Events: flush failed, dropping ${events.length} events: $e');
    }
  }
}
