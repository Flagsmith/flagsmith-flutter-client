import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/core/events/event_processor.dart';
import 'package:flagsmith/src/version.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
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

/// Answers each events request with the next scripted response: a status
/// code, [reset] (the connection drops) or [hang] (no answer until cancelled).
/// Requests beyond the script get a 202.
class ScriptedAdapter implements HttpClientAdapter {
  static const reset = 'reset';
  static const hang = 'hang';

  ScriptedAdapter(this.script);

  final List<Object> script;
  final List<Duration> cancelledAfter = [];
  Completer<void>? gate;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final response = script.isEmpty ? 202 : script.removeAt(0);
    await gate?.future;
    if (response == reset) {
      throw const SocketException('Connection reset by peer');
    }
    if (response == hang) {
      final watch = Stopwatch()..start();
      await cancelFuture;
      cancelledAfter.add(watch.elapsed);
      throw StateError('cancelled');
    }
    return ResponseBody.fromString('{}', response as int,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
  }

  @override
  void close({bool force = false}) {}
}

/// Always picks the longest wait, and records the bounds it was given.
class MaxRandom implements Random {
  final List<int> bounds = [];

  @override
  int nextInt(int max) {
    bounds.add(max);
    return max - 1;
  }

  @override
  double nextDouble() => 1;

  @override
  bool nextBool() => true;
}

Future<(FlagsmithClient, EventsCapture)> buildClient({
  bool enableEvents = true,
  int flushInterval = 60000,
  int maxBuffer = 1000,
  bool eventsRejected = false,
  Duration eventsDelay = Duration.zero,
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
      if (eventsRejected) {
        server.reply(400, <String, dynamic>{});
        return;
      }
      server.reply(200, <String, dynamic>{}, delay: eventsDelay);
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

    test('When identity is enrolled with traits, then exposure carries them',
        () async {
      // Given
      final traits = [
        Trait(key: 'plan', value: 'premium'),
        Trait(key: 'age', value: 30),
      ];

      // When
      await fs.getExperimentFlag(experimentFeatureName,
          user: user, traits: traits);
      await fs.flushEvents();

      // Then
      final event = capture.events.single;
      expect(event['event'], r'$flag_exposure');
      expect(event['identifier'], user.identifier);
      expect(event['value'], experimentVariant);
      expect(event['traits'], {'plan': 'premium', 'age': 30});
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

    test('When user param is given, then its flags are fetched and it wins',
        () async {
      // other_user gets a different variant from the server than user_42.
      final identityPosts = <String>[];
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          final id = (o.data as Map)['identifier'] as String;
          identityPosts.add(id);
          if (id == 'other_user') {
            final body = jsonDecode(identitiesResponseData);
            for (final f in body['flags'] as List) {
              if (f['feature']['name'] == experimentFeatureName) {
                f['variant'] = 'treatment-b';
              }
            }
            h.resolve(Response(requestOptions: o, statusCode: 200, data: body));
            return;
          }
        }
        h.next(o);
      }));

      final flag = await fs.getExperimentFlag(experimentFeatureName,
          user: const Identity(identifier: 'other_user'));

      expect(identityPosts, ['other_user'],
          reason: 'must fetch B, not reuse A');
      expect(flag!.variant, 'treatment-b');
      final event = fs.eventProcessor!.buffer.single;
      expect(event['identifier'], 'other_user');
      expect(event['value'], 'treatment-b');
      expect(fs.cachedUser?.identifier, 'other_user');
    });

    test('When user param is given with reload false, then storage is used',
        () async {
      final flag = await fs.getExperimentFlag(experimentFeatureName,
          user: const Identity(identifier: 'other_user'), reload: false);
      expect(flag!.variant, experimentVariant);
      expect(fs.eventProcessor!.buffer.single['identifier'], 'other_user');
    });

    test('When user matches the stored flags, then no request is made',
        () async {
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      final flag =
          await fs.getExperimentFlag(experimentFeatureName, user: user);

      expect(posts, 0, reason: 'storage already holds this identity');
      expect(flag!.variant, experimentVariant);
      expect(fs.eventProcessor!.buffer.single['identifier'], user.identifier);
    });

    test('When storage holds environment flags, then identity is fetched',
        () async {
      await fs.getFeatureFlags();
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      await fs.getExperimentFlag(experimentFeatureName);

      expect(posts, 1, reason: 'cachedUser flags are no longer in storage');
    });

    test('When hasFeatureFlag is called for another identity, then it fetches',
        () async {
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      await fs.hasFeatureFlag(experimentFeatureName, user: user);
      expect(posts, 0);
      await fs.hasFeatureFlag(experimentFeatureName,
          user: const Identity(identifier: 'other_user'));
      expect(posts, 1);
      await fs.hasFeatureFlag(experimentFeatureName,
          user: const Identity(identifier: 'other_user'));
      expect(posts, 1, reason: 'other_user is now the stored identity');
    });

    test('When traits are given for the stored identity, then it fetches',
        () async {
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      await fs.getExperimentFlag(experimentFeatureName,
          user: user, traits: [Trait(key: 'plan', value: 'pro')]);

      expect(posts, 1, reason: 'traits must reach the server');
    });

    test('When a flag is read without a user, then the identity is kept',
        () async {
      await fs.hasFeatureFlag(experimentFeatureName);

      expect(fs.cachedUser, user);
      await fs.getExperimentFlag(experimentFeatureName);
      expect(fs.eventProcessor!.buffer.single['identifier'], user.identifier);
    });

    test('When storage is cleared, then the identity is fetched again',
        () async {
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      await fs.clearStore();
      await fs.hasFeatureFlag(experimentFeatureName, user: user);
      expect(posts, 1);

      await fs.initStore(clear: true, seeds: seeds);
      await fs.hasFeatureFlag(experimentFeatureName, user: user);
      expect(posts, 2);
    });

    test(
        'When the identity was evaluated as transient, then a plain read fetches',
        () async {
      var posts = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        if (o.path == fs.config.identitiesURI) {
          posts++;
        }
        h.next(o);
      }));

      await fs.getFeatureFlags(
          user: Identity(identifier: user.identifier, transient: true));
      expect(posts, 1);
      await fs.hasFeatureFlag(experimentFeatureName, user: user);
      expect(posts, 2, reason: 'transient flags are not a baseline');
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

    test('When client is closed, then pending buffer is still flushed',
        () async {
      final (fs, capture) = await buildClient();
      fs.trackEvent('purchase');
      fs.close();

      await expectLater(fs.flushEvents(), completes);
      expect(capture.requests.length, 1);
      expect(capture.events.single['event'], 'purchase');
      expect(fs.eventProcessor!.buffer, isEmpty);
    });

    test('When close is awaited, then it returns after the final POST',
        () async {
      final (fs, capture) =
          await buildClient(eventsDelay: const Duration(milliseconds: 50));
      var responses = 0;
      fs.client.interceptors.add(InterceptorsWrapper(onResponse: (r, h) {
        responses++;
        h.next(r);
      }));
      fs.trackEvent('purchase');

      await fs.close();

      expect(capture.events.single['event'], 'purchase');
      expect(responses, 1);
    });

    test('When final POST outlasts the timeout, then close returns anyway',
        () async {
      final (fs, capture) =
          await buildClient(eventsDelay: const Duration(seconds: 2));
      fs.trackEvent('purchase');
      final watch = Stopwatch()..start();

      await fs.close(timeout: const Duration(milliseconds: 50));

      expect(watch.elapsedMilliseconds, lessThan(1000));
      expect(capture.requests.length, 1, reason: 'POST was started');
    });

    test('When client is closed, then later events are dropped', () async {
      final (fs, capture) = await buildClient();
      fs.close();

      fs.trackEvent('purchase');
      fs.trackExposureEvent(experimentFeatureName, value: 'treatment-a');
      final flag =
          await fs.getExperimentFlag(experimentFeatureName, reload: false);

      expect(flag, isNotNull);
      expect(fs.eventProcessor!.buffer, isEmpty);
      await fs.flushEvents();
      expect(capture.requests, isEmpty);
    });

    test('When POST is rejected, then flushEvents does not throw, drops batch',
        () async {
      final (fs, capture) = await buildClient(eventsRejected: true);
      fs.trackEvent('purchase');

      await expectLater(fs.flushEvents(), completes);
      expect(capture.requests.length, 1, reason: 'a rejection is final');
      expect(fs.eventProcessor!.buffer, isEmpty);
      fs.close();
    });
  });

  group('[Experiments] app lifecycle', () {
    late TestWidgetsFlutterBinding binding;
    setUpAll(() => binding = TestWidgetsFlutterBinding.ensureInitialized());
    tearDown(() =>
        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      test('When app becomes ${state.name}, then buffered events are flushed',
          () async {
        final (fs, capture) = await buildClient();
        addTearDown(fs.close);
        fs.trackEvent('purchase');

        binding.handleAppLifecycleStateChanged(state);

        expect(fs.eventProcessor!.buffer, isEmpty);
        await fs.flushEvents();
        expect(capture.events.single['event'], 'purchase');
      });
    }

    test('When app becomes inactive, then events stay buffered', () async {
      final (fs, capture) = await buildClient();
      addTearDown(fs.close);
      fs.trackEvent('purchase');

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

      expect(fs.eventProcessor!.buffer.length, 1);
      expect(capture.requests, isEmpty);
    });

    test('When client is closed, then backgrounding no longer flushes',
        () async {
      final (fs, _) = await buildClient();
      await fs.close();
      // Restart the processor so a leaked listener would show as a flush.
      final processor = fs.eventProcessor!..start();
      addTearDown(processor.stop);
      fs.trackEvent('purchase');

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

      expect(processor.buffer.length, 1);
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

    EventProcessor processor(
            {int retryBackoff = 10,
            int flushInterval = 0,
            int maxBuffer = 1000,
            int requestTimeout = 3000,
            Random? random}) =>
        EventProcessor(
          api: dio,
          apiKey: apiKey,
          eventsURI: 'https://events.api.flagsmith.com',
          retryBackoff: retryBackoff,
          flushInterval: flushInterval,
          maxBuffer: maxBuffer,
          requestTimeout: requestTimeout,
          log: logs.add,
          random: random,
        );

    ScriptedAdapter script(List<Object> responses) =>
        dio.httpClientAdapter = ScriptedAdapter(responses);

    List<List<Object?>> sentBatches() => [
          for (final request in capture.requests)
            [for (final e in request.data['events'] as List) e['event']],
        ];

    test('When eventsURI lacks trailing slash, then endpoint is normalised',
        () {
      expect(processor().endpoint, eventsEndpoint);
    });

    test('When every attempt gets a 500, then 3 attempts and dropped',
        () async {
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(500, <String, dynamic>{});
      }, data: Matchers.any);

      final p = processor();
      p.trackEvent(event: 'purchase', identifier: 'u1');
      await p.flush();

      expect(capture.requests.length, EventProcessor.maxAttempts);
      expect(p.buffer, isEmpty);
      expect(logs.where((l) => l.contains('retrying')).length, 2);
      expect(logs.where((l) => l.contains('dropping')).length, 1);
    });

    test('When transient failures precede success, then batch is delivered',
        () async {
      script([503, ScriptedAdapter.reset]);

      final p = processor();
      p.trackEvent(event: 'checkout');
      await p.flush();

      expect(sentBatches(), [
        ['checkout'],
        ['checkout'],
        ['checkout'],
      ]);
      expect(p.buffer, isEmpty);
    });

    for (final status in [408, 429, 502, 503, 504]) {
      test('When every attempt gets a $status, then batch is kept', () async {
        script([status, status, status]);

        final p = processor();
        p.trackEvent(event: 'purchase');
        await p.flush();

        expect(capture.requests.length, EventProcessor.maxAttempts);
        expect(p.buffer.single['event'], 'purchase');
      });
    }

    test('When a kept batch is flushed again, then it goes ahead of new events',
        () async {
      script([503, 503, 503]);

      final p = processor();
      p.trackEvent(event: 'add_to_cart');
      await p.flush();
      p.trackEvent(event: 'checkout');
      await p.flush();

      expect(sentBatches(), [
        ['add_to_cart'],
        ['add_to_cart'],
        ['add_to_cart'],
        ['add_to_cart', 'checkout'],
      ]);
      expect(p.buffer, isEmpty);
    });

    test('When the last attempt gets a 500, then batch is dropped', () async {
      script([503, 503, 500]);

      final p = processor();
      p.trackEvent(event: 'add_to_cart');
      await p.flush();
      p.trackEvent(event: 'checkout');
      await p.flush();

      expect(sentBatches().last, ['checkout']);
      expect(capture.requests.length, 4);
    });

    test('When the last attempt fails transiently after 500s, then kept',
        () async {
      script([500, 500, 503]);

      final p = processor();
      p.trackEvent(event: 'add_to_cart');
      await p.flush();

      expect(capture.requests.length, 3);
      expect(p.buffer.single['event'], 'add_to_cart');
    });

    test('When POST is rejected with 400, then dropped without retry',
        () async {
      script([400]);

      final p = processor();
      p.trackEvent(event: 'add_to_cart');
      await p.flush();
      p.trackEvent(event: 'checkout');
      await p.flush();

      expect(sentBatches(), [
        ['add_to_cart'],
        ['checkout'],
      ]);
    });

    for (final status in [401, 403]) {
      test(
          'When the environment key is refused with $status, then tracking '
          'stops', () async {
        script([status]);

        final p = processor();
        p.trackEvent(event: 'add_to_cart');
        p.trackEvent(event: 'pending');
        final flushing = p.flush();
        p.trackEvent(event: 'during_send');
        await flushing;
        p.trackEvent(event: 'checkout');
        await p.flush();

        expect(sentBatches(), [
          ['add_to_cart', 'pending'],
        ]);
        expect(p.unauthorised, isTrue);
        expect(p.buffer, isEmpty);
        expect(
            logs,
            contains('Events: environment key refused, dropping '
                '"checkout"'));
      });
    }

    test('When a request is not answered, then it times out and is retried',
        () async {
      final scripted = script([ScriptedAdapter.hang]);

      final p = processor(requestTimeout: 100);
      p.trackEvent(event: 'checkout');
      await p.flush();

      expect(scripted.cancelledAfter.single.inMilliseconds,
          inInclusiveRange(90, 500));
      expect(sentBatches(), [
        ['checkout'],
        ['checkout'],
      ]);
      expect(p.buffer, isEmpty);
    });

    test('When retrying, then the wait is jittered up to a doubling backoff',
        () async {
      script([503, 503, 503]);
      final random = MaxRandom();

      final p = processor(retryBackoff: 10, random: random);
      p.trackEvent(event: 'purchase');
      await p.flush();

      // nextInt is exclusive: a wait of up to 10 ms, then up to 20 ms.
      expect(random.bounds, [11, 21]);
    });

    test('When the buffer is full, then the oldest event is dropped', () async {
      // Hold the batch the full buffer flushes in flight, so the buffer
      // fills up again behind it.
      final scripted = script([])..gate = Completer<void>();

      final p = processor(maxBuffer: 3);
      for (var i = 1; i <= 3; i++) {
        p.trackEvent(event: 'in_flight_$i');
      }
      expect(p.buffer, isEmpty, reason: 'max buffer triggered a flush');
      for (var i = 1; i <= 4; i++) {
        p.trackEvent(event: 'event_$i');
      }

      expect(
          p.buffer.map((e) => e['event']), ['event_2', 'event_3', 'event_4']);
      scripted.gate!.complete();
      await p.flush();
      expect(sentBatches().last, ['event_2', 'event_3', 'event_4']);
    });

    test('When a kept batch overflows the buffer, then the oldest are dropped',
        () async {
      final scripted = script([503, 503, 503])..gate = Completer<void>();

      final p = processor(maxBuffer: 3);
      p.trackEvent(event: 'kept_1');
      p.trackEvent(event: 'kept_2');
      final flushing = p.flush();
      p.trackEvent(event: 'new_1');
      p.trackEvent(event: 'new_2');
      scripted.gate!.complete();
      await flushing;

      expect(p.buffer.map((e) => e['event']), ['kept_2', 'new_1', 'new_2']);
    });

    test('When max buffer is 0, then each event is sent on its own', () async {
      final p = processor(maxBuffer: 0);
      script([]);

      p.trackEvent(event: 'purchase');
      p.trackExposureEvent(featureName: 'banner', identifier: 'u1');
      await p.flush();

      expect(p.maxBuffer, 1);
      expect(sentBatches(), [
        ['purchase'],
        [EventProcessor.flagExposureEvent],
      ]);
    });

    test('When a batch cannot be encoded, then it is dropped at once',
        () async {
      script([]);

      final p = processor();
      p.trackEvent(event: 'bad', metadata: {'at': DateTime(2026)});
      await p.flush();
      p.trackEvent(event: 'good');
      await p.flush();

      expect(p.buffer, isEmpty);
      expect(capture.requests.length, 2, reason: 'no retry of the bad batch');
      expect(sentBatches().last, ['good']);
    });

    test('When a kept batch fills the buffer, then tracking does not resend it',
        () async {
      script([503, 503, 503]);

      final p = processor(maxBuffer: 2);
      p.trackEvent(event: 'a');
      p.trackEvent(event: 'b');
      await p.flush();
      expect(capture.requests.length, 3);
      expect(p.buffer.length, 2, reason: 'the batch is kept');

      p.trackEvent(event: 'c');
      p.trackEvent(event: 'd');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(capture.requests.length, 3, reason: 'held until the next flush');

      await p.flush();
      expect(sentBatches().last, ['c', 'd']);
    });

    test('When a kept batch fills the buffer, then the next tick sends it',
        () async {
      script([503, 503, 503]);

      final p = processor(maxBuffer: 1, flushInterval: 100)..start();
      addTearDown(p.stop);
      p.trackEvent(event: 'a');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(capture.requests.length, 3);
      p.trackEvent(event: 'b');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(capture.requests.length, 3, reason: 'held until the tick');

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(sentBatches().last, ['b']);
    });

    test('When the buffer fills during a send, then it is sent after it',
        () async {
      final scripted = script([])..gate = Completer<void>();

      final p = processor(maxBuffer: 2);
      p.trackEvent(event: 'a');
      p.trackEvent(event: 'b');
      p.trackEvent(event: 'c');
      p.trackEvent(event: 'd');
      scripted.gate!.complete();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(sentBatches(), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(p.buffer, isEmpty);
    });

    test('When an exposure is evicted, then it can be tracked again', () async {
      final scripted = script([])..gate = Completer<void>();

      final p = processor(maxBuffer: 2);
      p.trackEvent(event: 'a');
      p.trackEvent(event: 'b');
      p.trackExposureEvent(featureName: 'banner', identifier: 'u1');
      p.trackEvent(event: 'c');
      p.trackEvent(event: 'd');
      expect(p.buffer.map((e) => e['event']), ['c', 'd'], reason: 'evicted');

      p.trackExposureEvent(featureName: 'banner', identifier: 'u1');

      expect(p.buffer.map((e) => e['event']),
          ['d', EventProcessor.flagExposureEvent]);
      scripted.gate!.complete();
      await p.flush();
    });

    test('When a batch is in flight, then the next one waits for it', () async {
      final scripted = script([503])..gate = Completer<void>();

      final p = processor();
      p.trackEvent(event: 'first');
      final first = p.flush();
      p.trackEvent(event: 'second');
      final second = p.flush();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(capture.requests.length, 1, reason: 'one batch in flight');

      scripted.gate!.complete();
      await Future.wait([first, second]);

      expect(sentBatches(), [
        ['first'],
        ['first'],
        ['second'],
      ]);
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

      // The longest jittered wait, so the swap below lands within it.
      final p = processor(retryBackoff: 100, random: MaxRandom());
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

    test('When max-buffer flush is in flight, then flush awaits its POST',
        () async {
      var responses = 0;
      dio.interceptors.add(InterceptorsWrapper(onResponse: (r, h) {
        responses++;
        h.next(r);
      }));
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(200, <String, dynamic>{},
            delay: const Duration(milliseconds: 80));
      }, data: Matchers.any);

      final p = EventProcessor(
          api: dio,
          apiKey: apiKey,
          eventsURI: 'https://events.api.flagsmith.com',
          maxBuffer: 1,
          flushInterval: 0);
      p.trackEvent(event: 'auto');
      expect(p.buffer, isEmpty, reason: 'max buffer triggered a flush');
      expect(responses, 0);

      await p.flush();

      expect(responses, 1, reason: 'flush must wait for the in-flight POST');
    });

    test('When timer flush is in flight, then flush awaits its POST', () async {
      var responses = 0;
      dio.interceptors.add(InterceptorsWrapper(onResponse: (r, h) {
        responses++;
        h.next(r);
      }));
      adapter.onPost(eventsEndpoint, (server) {
        server.reply(200, <String, dynamic>{},
            delay: const Duration(milliseconds: 80));
      }, data: Matchers.any);

      final p = processor(flushInterval: 20)..start();
      p.trackEvent(event: 'timed');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(p.buffer, isEmpty, reason: 'timer flushed the buffer');
      expect(responses, 0);

      p.stop();
      await p.flush();

      expect(responses, 1);
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

    test('When restarted after stop, then events are buffered again', () {
      final p = processor()..stop();
      p.trackEvent(event: 'stopped');
      expect(p.buffer, isEmpty);
      expect(logs, contains('Events: processor stopped, dropping "stopped"'));

      p.start();
      p.trackEvent(event: 'restarted');
      expect(p.buffer.single['event'], 'restarted');
    });
  });
}
