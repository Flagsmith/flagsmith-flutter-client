import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[InMemory storage]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
      setupAdapter(fs, cb: (config, _adapter) {});
    });
    tearDown(() {
      fs.close();
    });
    test('When init remove all items and Save seeds', () async {
      await fs.clearStore();
      var result = await fs.getFeatureFlags(reload: false);
      expect(result, isEmpty);

      await fs.initStore(seeds: seeds, clear: true);
      var result2 = await fs.getFeatureFlags(reload: false);
      expect(result2, isNotEmpty);
    });
    test('When has seeded Features then success', () async {
      var result = await fs.getFeatureFlags(reload: false);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When has Feature then success', () async {
      var result = await fs.getFeatureFlags();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When has Feature then fail', () async {
      await fs.reset();
      var result = await fs.getFeatureFlags(reload: false);
      expect(result, isNotNull);
      expect(result.length, seeds.length);

      final value = fs.hasCachedFeatureFlag(notImplmentedFeature);
      expect(value, false);

      final value1 = await fs.hasFeatureFlag(notImplmentedFeature);
      expect(value1, false);
    });
    test('When get Features then success', () async {
      var result = await fs.hasFeatureFlag('enabled_feature');
      expect(result, true);
    });
    test('When get Features for user then success', () async {
      var user = Identity(identifier: 'test_sample_user');
      var result = await fs.getFeatureFlags(user: user);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When update Features then success', () async {
      var result = await fs.getFeatureFlags(reload: true);
      expect(result, isNotEmpty);

      var resultNext = await fs.getFeatureFlags(reload: true);
      expect(resultNext, isNotEmpty);
    });
    test('When flag is not presented then false', () async {
      var result = await fs.isFeatureFlagEnabled(notImplmentedFeature);
      expect(result, false);
    });
    test('When flag is presented then true', () async {
      var result = await fs.isFeatureFlagEnabled('my_feature');
      expect(result, isNotNull);
    });

    test('When flag is not presented then value is null', () async {
      var result = await fs.getFeatureFlagValue(notImplmentedFeature);
      expect(result, isNull);
    });

    test('When flag is presented then value is not null', () async {
      await fs.getFeatureFlags();
      var result = await fs.getFeatureFlagValue('my_feature');
      expect(result, isNotNull);
    });

    test('When feature flag remove then success', () async {
      final _featureName = 'my_feature';
      await fs.reset();

      final _current = await fs.hasFeatureFlag(_featureName);
      expect(_current, true);

      var result = await fs.removeFeatureFlag(_featureName);
      expect(result, true);

      final _removed = await fs.hasFeatureFlag(_featureName);
      expect(_removed, false);
    });
  });

  group('[InMemory storage] flags api failures', () {
    late FlagsmithClient fs;
    final _identity = Identity(identifier: 'invalid_users_another_user');
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
    });
    tearDown(() {
      fs.close();
    });
    test('When get flags then 404 error', () async {
      setupEmptyAdapter(fs, cb: (config, _adapter) {
        _adapter
          ..onGet(
            config.flagsURI,
            (server) => server.throws(
              404,
              DioException(
                requestOptions: RequestOptions(path: config.flagsURI),
              ),
            ),
          )
          ..onGet(fs.config.identitiesURI, (server) {
            return server.throws(
              404,
              DioException(
                requestOptions: RequestOptions(path: config.flagsURI),
              ),
            );
          }, queryParameters: _identity.toJson());
      });
      expect(() => fs.getFeatureFlags(), throwsA(isA<FlagsmithApiException>()));
      expect(fs.cachedFlags, isNotEmpty);
      expect(() => fs.getFeatureFlags(user: _identity),
          throwsA(isA<FlagsmithApiException>()));
    });
    test(
        'When get flags returns statusCode > 200 && < 300, then success but empty',
        () async {
      setupEmptyAdapter(fs, cb: (config, _adapter) {
        _adapter
          ..onGet(config.flagsURI,
              (server) => server.reply(201, jsonDecode('''[]''')))
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(201, null);
          }, queryParameters: _identity.toJson());
      });
      expect(await fs.getFeatureFlags(), isEmpty);
      expect(await fs.getFeatureFlags(user: _identity), isEmpty);
    });

    test('When get user flags returns null, then success but empty', () async {
      setupEmptyAdapter(fs, cb: (config, _adapter) {
        _adapter.onGet(fs.config.identitiesURI, (server) {
          return server.reply(200, null);
        }, queryParameters: _identity.toJson());
      });
      expect(await fs.getFeatureFlags(user: _identity), isEmpty);
    });
  });
}
