import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[Analytics] Settings', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = setupSyncClientAdapter(StorageType.inMemory,
          caches: true, isDebug: true);
      setupAdapter(fs, cb: (config, adapter) {
        adapter = adapter;
        adapter.onPost(fs.config.analyticsURI, (server) {
          return server.reply(200, jsonDecode(analyticsData));
        }, data: jsonDecode(analyticsData));
      });
      await fs.initialize();
      await fs.getFeatureFlags();
    });
    tearDown(() {
      fs.close();
    });
    test('When starts client analytics are enabled as default', () async {
      expect(fs.config.enableAnalytics, true);
    });

    test('When starts client analytics are empty', () async {
      expect(fs.flagAnalytics, isEmpty);
    });

    test('When client check flag value, then increment value in map', () async {
      expect(fs.flagAnalytics, isEmpty);
      final flagValue = await fs.getFeatureFlagValue('fake_disabled_feature');
      expect(flagValue, isNull);
      expect(fs.flagAnalytics.length, 1);
      expect(fs.flagAnalytics.containsKey('fake_disabled_feature'), isTrue);
      expect(fs.flagAnalytics['fake_disabled_feature'], 1);

      await fs.getFeatureFlagValue('fake_disabled_feature');
      expect(fs.flagAnalytics.containsKey('fake_disabled_feature'), isTrue);
      expect(fs.flagAnalytics['fake_disabled_feature'], 2);
    });
  });
  group('[Analytics] Sync', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
    });
    tearDown(() {
      fs.close();
    });

    test('When analytics was sent, then current store is empty', () async {
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.analyticsURI, (server) {
          return server.reply(200, null);
        }, data: jsonDecode(analyticsData));
      });
      expect(fs.flagAnalytics, isEmpty);
      await fs.getFeatureFlagValue('my_feature');
      await fs.getFeatureFlagValue('my_feature');
      expect(fs.flagAnalytics.containsKey('my_feature'), isTrue);
      expect(fs.flagAnalytics['my_feature'], 2);
      final response = await fs.syncAnalyticsData();
      expect(response?.statusCode, 200);
      expect(fs.flagAnalytics.isEmpty, isTrue);
    });
    test('When analytics was sent and failed, then current store is not empty',
        () async {
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.analyticsURI, (server) {
          return server.throws(
            400,
            DioException(
              requestOptions: RequestOptions(path: config.analyticsURI),
            ),
          );
        }, data: jsonDecode(analyticsData));
      });
      expect(fs.flagAnalytics, isEmpty);
      await fs.getFeatureFlagValue('my_feature');
      await fs.getFeatureFlagValue('my_feature');
      expect(fs.flagAnalytics.containsKey('my_feature'), isTrue);
      expect(fs.flagAnalytics['my_feature'], 2);
      expect(
          () => fs.syncAnalyticsData(), throwsA(isA<FlagsmithApiException>()));

      expect(fs.flagAnalytics.isEmpty, isFalse);
    });
  });
}
