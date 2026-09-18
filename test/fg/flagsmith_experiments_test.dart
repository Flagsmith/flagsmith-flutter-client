import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/version.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

import '../shared.dart';

const eventsEndpoint = 'https://events.api.flagsmith.com/v1/events';
const user = Identity(identifier: 'user_42');

/// Records every request Dio sends to the events endpoint.
class EventsCapture {
  final List<RequestOptions> requests = [];

  List<Map<String, dynamic>> get events => requests
      .expand((r) => (r.data['events'] as List).cast<Map<String, dynamic>>())
      .toList();

  Interceptor get interceptor => InterceptorsWrapper(onRequest: (options, h) {
        if (options.path == eventsEndpoint) {
          requests.add(options);
        }
        h.next(options);
      });
}

Future<(FlagsmithClient, EventsCapture)> buildClient({
  bool enableEvents = true,
  int flushInterval = 60000,
  int maxBuffer = 1000,
  bool eventsFail = false,
  bool loadUserFlags = true,
}) async {
  final fs = FlagsmithClient(
    apiKey: apiKey,
    seeds: seeds,
    config: FlagsmithConfig(
      baseURI: 'https://offline.net/',
      enableEvents: enableEvents,
      eventsFlushInterval: flushInterval,
      eventsMaxBuffer: maxBuffer,
    ),
  );
  final capture = EventsCapture();
  fs.client.interceptors.add(capture.interceptor);
  setupAdapter(fs, cb: (config, adapter) {
    adapter.onPost(config.identitiesURI, (server) {
      server.reply(200, jsonDecode(identitiesResponseData));
    }, data: Matchers.any);
    adapter.onPost(eventsEndpoint, (server) {
      if (eventsFail) {
        server.throws(500,
            DioException(requestOptions: RequestOptions(path: eventsEndpoint)));
        return;
      }
      server.reply(200, <String, dynamic>{});
    }, data: Matchers.any);
  });
  await fs.initialize();
  if (loadUserFlags) {
    await fs.getFeatureFlags(user: user);
  }
  return (fs, capture);
}

void main() {
  group('[Experiments] getExperimentFlag', () {
    late FlagsmithClient fs;
    late EventsCapture capture;
    setUp(() async {
      (fs, capture) = await buildClient();
    });
    tearDown(() => fs.close());

    test('When identity is enrolled, then flag is returned and exposure posted',
        () async {
      final flag = await fs.getExperimentFlag(experimentFeatureName);

      expect(flag, isNotNull);
      expect(flag!.enabled, isTrue);
      expect(flag.stateValue, 'buy-now');
      expect(flag.variant, experimentVariant);
      expect(flag.reason, 'SPLIT; weight=50');
      expect(flag.experiment!.id, experimentId);
      expect(flag.experiment!.inExperiment, isTrue);
      expect(fs.eventProcessor!.buffer.length, 1);

      await fs.flushEvents();

      expect(capture.requests.length, 1);
      final request = capture.requests.single;
      expect(request.method, 'POST');
      expect(request.contentType, 'application/json; charset=utf-8');
      expect(request.headers['X-Environment-Key'], apiKey);
      expect(request.headers['Flagsmith-SDK-User-Agent'],
          'flagsmith-flutter-sdk/$sdkVersion');

      final event = capture.events.single;
      expect(event['event'], r'$flag_exposure');
      expect(event['feature_name'], experimentFeatureName);
      expect(event['identifier'], user.identifier);
      expect(event['value'], experimentVariant);
      expect(event['traits'], isNull);
      expect(event['metadata'], {
        'experiment_id': experimentId,
        'sdk_version': sdkVersion,
      });
      expect(event['timestamp'], isA<int>());
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When identity is not enrolled, then no exposure', () async {
      final flag = await fs.getExperimentFlag(experimentNotEnrolledFeatureName);
      expect(flag!.variant, 'control');
      expect(flag.experiment!.inExperiment, isFalse);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When flag has no experiment metadata, then no exposure', () async {
      final flag = await fs.getExperimentFlag(experimentNoMetadataFeatureName);
      expect(flag!.variant, 'control');
      expect(flag.experiment, isNull);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When flag is disabled, then flag returned and no exposure', () async {
      final flag = await fs.getExperimentFlag(experimentDisabledFeatureName);
      expect(flag!.enabled, isFalse);
      expect(flag.experiment!.inExperiment, isTrue);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When flag is missing, then null and no exposure', () async {
      final flag = await fs.getExperimentFlag(notImplementedFeatureName);
      expect(flag, isNull);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When no identity is known, then flag returned and no exposure',
        () async {
      fs.cachedUser = null;
      final flag = await fs.getExperimentFlag(experimentFeatureName);
      expect(flag!.experiment!.inExperiment, isTrue);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When user param is given, then it wins over cachedUser', () async {
      await fs.getExperimentFlag(experimentFeatureName,
          user: const Identity(identifier: 'other_user'));
      expect(fs.eventProcessor!.buffer.single['identifier'], 'other_user');
      expect(fs.cachedUser?.identifier, 'other_user');
    });

    test('When called twice in a window, then exposure is deduped', () async {
      await fs.getExperimentFlag(experimentFeatureName);
      await fs.getExperimentFlag(experimentFeatureName);
      expect(fs.eventProcessor!.buffer.length, 1);

      await fs.flushEvents();
      await fs.getExperimentFlag(experimentFeatureName);
      expect(fs.eventProcessor!.buffer.length, 1);
    });

    test('When flag is read, then flag analytics are incremented', () async {
      await fs.getExperimentFlag(experimentFeatureName);
      await fs.getExperimentFlag(experimentNotEnrolledFeatureName);
      await fs.getExperimentFlag(experimentNotEnrolledFeatureName);
      expect(fs.flagAnalytics[experimentFeatureName], 1);
      expect(fs.flagAnalytics[experimentNotEnrolledFeatureName], 2);
    });

    test('When flag restored from storage, then it still gates', () async {
      await fs.getExperimentFlag(experimentFeatureName);
      await fs.flushEvents();
      final restored = await fs.storageProvider.read(experimentFeatureName);
      expect(restored!.experiment!.inExperiment, isTrue);
      expect(restored.variant, experimentVariant);
    });
  });

  group('[Experiments] events disabled', () {
    late FlagsmithClient fs;
    late EventsCapture capture;
    setUp(() async {
      (fs, capture) = await buildClient(enableEvents: false);
    });
    tearDown(() => fs.close());

    test('When events disabled, then plain read and nothing posted', () async {
      expect(fs.config.enableEvents, isFalse);
      expect(fs.eventProcessor, isNull);

      final flag = await fs.getExperimentFlag(experimentFeatureName);
      expect(flag!.experiment!.inExperiment, isTrue);

      fs.trackEvent('purchase', value: 1);
      fs.trackExposureEvent(experimentFeatureName, value: 'x');
      await fs.flushEvents();
      expect(capture.requests, isEmpty);
    });

    test('When events disabled, then reserved names still throw', () {
      expect(() => fs.trackEvent(r'$flag_exposure'), throwsArgumentError);
    });
  });

  group('[Experiments] trackEvent and trackExposureEvent', () {
    late FlagsmithClient fs;
    late EventsCapture capture;
    setUp(() async {
      (fs, capture) = await buildClient();
    });
    tearDown(() => fs.close());

    test('When event name starts with \$, then throws', () {
      expect(() => fs.trackEvent(r'$x'), throwsArgumentError);
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When conversion tracked, then buffered with stringified value',
        () async {
      fs.trackEvent('purchase', value: 99.5);
      final event = fs.eventProcessor!.buffer.single;
      expect(event['event'], 'purchase');
      expect(event['feature_name'], isNull);
      expect(event['identifier'], user.identifier);
      expect(event['value'], '99.5');
      expect(event['metadata'], {'sdk_version': sdkVersion});

      await fs.flushEvents();
      expect(capture.events.single['event'], 'purchase');
    });

    test('When conversion tracked twice, then never deduped', () {
      fs.trackEvent('purchase', value: 1);
      fs.trackEvent('purchase', value: 1);
      expect(fs.eventProcessor!.buffer.length, 2);
    });

    test('When traits, metadata and user given, then passed through', () {
      fs.trackEvent('signup',
          user: const Identity(identifier: 'u2'),
          traits: {'plan': 'premium'},
          metadata: {'source': 'qa'});
      final event = fs.eventProcessor!.buffer.single;
      expect(event['identifier'], 'u2');
      expect(event['traits'], {'plan': 'premium'});
      expect(event['metadata'], {'source': 'qa', 'sdk_version': sdkVersion});
      expect(event['value'], isNull);
    });

    test('When exposure tracked without identity, then dropped', () {
      fs.cachedUser = null;
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-a');
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When exposure tracked manually, then deduped per value', () {
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-a');
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-a');
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-b');
      fs.trackExposureEvent(experimentFeatureName,
          value: 'treatment-a', user: const Identity(identifier: 'u2'));
      expect(fs.eventProcessor!.buffer.length, 3);
      expect(fs.eventProcessor!.buffer.first['event'], r'$flag_exposure');
    });

    test(
        'When same variant is exposed under a new experiment, then not deduped',
        () {
      fs.trackExposureEvent(experimentFeatureName,
          value: 'treatment-a', metadata: {'experiment_id': 42});
      fs.trackExposureEvent(experimentFeatureName,
          value: 'treatment-a', metadata: {'experiment_id': 42});
      fs.trackExposureEvent(experimentFeatureName,
          value: 'treatment-a', metadata: {'experiment_id': 43});
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-a');
      expect(
          fs.eventProcessor!.buffer.map((e) => e['metadata']['experiment_id']),
          [42, 43, null]);
    });
  });

  group('[Experiments] flush', () {
    test('When flush interval elapses, then buffer is posted', () async {
      final (fs, capture) = await buildClient(flushInterval: 50);
      fs.trackEvent('purchase');
      expect(capture.requests, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(capture.requests.length, 1);
      expect(fs.eventProcessor!.buffer, isEmpty);
      fs.close();
    });

    test('When max buffer is reached, then buffer is posted', () async {
      final (fs, capture) = await buildClient(maxBuffer: 2);
      fs.trackEvent('one');
      expect(capture.requests, isEmpty);
      fs.trackEvent('two');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(capture.events.map((e) => e['event']), ['one', 'two']);
      expect(fs.eventProcessor!.buffer, isEmpty);
      fs.close();
    });

    test('When flushEvents called on empty buffer, then nothing posted',
        () async {
      final (fs, capture) = await buildClient();
      await fs.flushEvents();
      expect(capture.requests, isEmpty);
      fs.close();
    });

    test('When client is closed, then buffer is flushed', () async {
      final (fs, capture) = await buildClient();
      fs.trackEvent('purchase');
      fs.close();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(capture.events.single['event'], 'purchase');
    });

    test('When POST fails, then flushEvents does not throw and drops batch',
        () async {
      final (fs, capture) = await buildClient(eventsFail: true);
      fs.trackEvent('purchase');

      await expectLater(fs.flushEvents(), completes);
      expect(capture.requests.length, 2, reason: 'one retry then drop');
      expect(fs.eventProcessor!.buffer, isEmpty);
      fs.close();
    });
  });

  group('[Experiments] EventProcessor', () {
    late Dio dio;
    late DioAdapter adapter;
    late EventsCapture capture;
    late List<String> logs;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://offline.net/'));
      adapter = DioAdapter(dio: dio);
      capture = EventsCapture();
      dio.interceptors.add(capture.interceptor);
      logs = [];
    });

    EventProcessor processor({int retryBackoff = 10, int flushInterval = 0}) =>
        EventProcessor(
          api: dio,
          apiKey: apiKey,
          eventsURI: 'https://events.api.flagsmith.com',
          retryBackoff: retryBackoff,
          flushInterval: flushInterval,
          log: logs.add,
        );

    test('When eventsURI lacks trailing slash, then endpoint is normalised',
        () {
      expect(processor().endpoint, eventsEndpoint);
    });

    test('When POST returns non-2xx, then retried once and dropped', () async {
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(500, <String, dynamic>{});
      }, data: Matchers.any);

      final p = processor();
      p.trackEvent(event: 'purchase', identifier: 'u1');
      await p.flush();

      expect(capture.requests.length, 2);
      expect(p.buffer, isEmpty);
      expect(logs.where((l) => l.contains('retrying')).length, 1);
      expect(logs.where((l) => l.contains('dropping')).length, 1);
    });

    test('When POST fails once then succeeds, then batch is delivered',
        () async {
      adapter.onPost(eventsEndpoint, (server) {
        server.throws(
            0,
            DioException.connectionError(
                requestOptions: RequestOptions(path: eventsEndpoint),
                reason: 'offline'));
      }, data: Matchers.any);

      final p = processor(retryBackoff: 100);
      p.trackEvent(event: 'purchase', identifier: 'u1');
      final flushing = p.flush();

      // Last registered handler wins: swap to success during the backoff.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(200, <String, dynamic>{});
      }, data: Matchers.any);
      await flushing;

      expect(capture.requests.length, 2);
      expect(capture.events.map((e) => e['event']), ['purchase', 'purchase']);
      expect(logs.last, contains('flush successful'));
    });

    test('When events tracked during a flush, then they wait for the next one',
        () async {
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(200, <String, dynamic>{},
            delay: const Duration(milliseconds: 30));
      }, data: Matchers.any);

      final p = processor();
      p.trackEvent(event: 'first');
      final flushing = p.flush();
      p.trackEvent(event: 'second');
      await flushing;

      expect(capture.events.map((e) => e['event']), ['first']);
      expect(p.buffer.single['event'], 'second');
    });

    test('When stop is called, then timer cancelled and buffer flushed',
        () async {
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(200, <String, dynamic>{});
      }, data: Matchers.any);

      final p = processor(flushInterval: 20)..start();
      p.trackEvent(event: 'purchase');
      p.stop();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(capture.requests.length, 1);

      p.trackEvent(event: 'after_stop');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(capture.requests.length, 1, reason: 'timer must be cancelled');
    });
  });
}
