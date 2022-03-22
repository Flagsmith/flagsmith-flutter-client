import 'dart:convert';

import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:test/test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../shared.dart';

void main() {
  group('[Flag manipulation]', () {
    late FlagsmithClient fs;
    late DioAdapter _adapter;
    setUp(() async {
      fs = setupSyncClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        _adapter = adapter;
        _adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(fakeIdentitiesResponse));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPut(fs.config.traitsBulkURI, (server) {
            return server.reply(200, jsonDecode(bulkTraitUpdateResponse));
          }, data: jsonDecode(bulkTraitUpdateResponse))
          ..onPost(fs.config.traitsURI, (server) {
            return server.reply(200, jsonDecode(traitAge25));
          }, data: jsonDecode(traitAge25));
      });
      await fs.initialize();
      await fs.getFeatureFlags();
    });
    tearDown(() {
      fs.close();
    });
    test('When use delete all keys, flags are empty', () async {
      await fs.clearStore();
      var result = await fs.getFeatureFlags();
      for (final flag in result) {
        await fs.removeFeatureFlag(flag.key);
      }

      var resultNext = await fs.getFeatureFlags(reload: false);
      expect(resultNext, isEmpty);
    });
    test('When localy change state of flag, then success', () async {
      await fs.getFeatureFlags();
      expect(await fs.isFeatureFlagEnabled(myFeature), true);
      await fs.testToggle(myFeature);
      expect(await fs.isFeatureFlagEnabled(myFeature), false);
    });

    test('When change state of flag, then cache success', () async {
      fs = setupSyncClientAdapter(StorageType.inMemory, caches: true);
      setupAdapter(fs, cb: (config, adapter) {});
      await fs.getFeatureFlags();
      expect(await fs.isFeatureFlagEnabled(myFeature), true);
      await fs.testToggle(myFeature);
      expect(await fs.isFeatureFlagEnabled(myFeature), false);
    });
  });

  group('[Traits]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(fakeIdentitiesResponse));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPut(fs.config.traitsBulkURI, (server) {
            return server.reply(200, jsonDecode(bulkTraitUpdateResponse));
          }, data: jsonDecode(bulkTraitUpdateResponse))
          ..onPost(fs.config.traitsURI, (server) {
            return server.reply(200, jsonDecode(traitAge25));
          }, data: jsonDecode(traitAge25));
      });
    });
    tearDown(() {
      fs.close();
    });
    test('When get User traits then success', () async {
      var user = Identity(identifier: 'test_another_user');

      var result = await fs.getTraits(user);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var trait in result) {
        expect(trait, isNotNull);
      }
    });

    test('When get User traits for invalid user then return empty', () async {
      var user = Identity(identifier: 'invalid_users_another_user');

      var result = await fs.getTraits(user);

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('When get User trait then success', () async {
      var user = Identity(identifier: 'test_another_user');

      var result = await fs.getTraits(user, keys: ['age']);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get User trait Update then Updated', () async {
      var user = Identity(identifier: 'test_another_user');

      var result = await fs.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result?.value, isNotNull);

      var updateResult = await fs.createTrait(
          value: TraitWithIdentity(
        identity: user,
        key: 'age',
        value: '25',
      ));
      expect(updateResult, isNotNull);
      expect(updateResult?.value, '25');
    });

    test('When get User trait Update then bulk Updated', () async {
      var user = Identity(identifier: 'test_another_user');
      var result = await fs.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result?.value, isNotNull);

      var updateResult = await fs.updateTraits(value: [
        TraitWithIdentity(
          identity: user,
          key: 'age',
          value: '21',
        ),
        TraitWithIdentity(
          identity: user,
          key: 'age2',
          value: '21',
        )
      ]);
      expect(updateResult, isNotNull);
      expect(updateResult, isNotEmpty);
    });
  });

  group('[Users]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(fakeIdentitiesResponse));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPut(fs.config.traitsBulkURI, (server) {
            return server.reply(200, jsonDecode(bulkTraitUpdateResponse));
          }, data: jsonDecode(bulkTraitUpdateResponse))
          ..onPost(fs.config.traitsURI, (server) {
            return server.reply(200, jsonDecode(traitAge25));
          }, data: jsonDecode(traitAge25));
      });
    });
    tearDown(() {
      fs.close();
    });
    test('When get User traits and success and data null', () async {
      var user = Identity(identifier: 'test_another_user');
      setupAdapter(fs, cb: (config, adapter) {
        adapter.onGet(fs.config.identitiesURI, (server) {
          return server.reply(200, null);
        }, queryParameters: <String, dynamic>{
          'identifier': 'test_another_user'
        });
      });
      var result = await fs.getTraits(user);
      expect(result, isNotNull);
      expect(result, isEmpty);
    });
    test('When get User traits and success and data null', () async {
      var user = Identity(identifier: 'test_another_user');
      setupAdapter(fs, cb: (config, adapter) {
        adapter.onGet(fs.config.identitiesURI, (server) {
          return server.reply(201, null);
        }, queryParameters: <String, dynamic>{
          'identifier': 'test_another_user'
        });
      });
      var result = await fs.getTraits(user);
      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('When create trait return data null', () async {
      var _user = Identity(identifier: 'test_another_user');
      final _data = TraitWithIdentity(identity: _user, key: 'age', value: '25');
      fs = setupSyncClientAdapter(StorageType.inMemory);
      await fs.initialize();
      setupAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.traitsURI, (server) {
          return server.reply(200, null);
        }, data: _data.toJson());
      });
      final _result = await fs.createTrait(value: _data);
      expect(_result, isNull);
    });
  });
}
