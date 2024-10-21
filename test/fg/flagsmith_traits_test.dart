import 'dart:convert';

import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[Flag manipulation]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = setupSyncClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        adapter = adapter;
        adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPost(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, data: jsonDecode(identitiesResponseData))
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
      expect(await fs.isFeatureFlagEnabled(myFeatureName), true);
      await fs.testToggle(myFeatureName);
      expect(await fs.isFeatureFlagEnabled(myFeatureName), false);
    });

    test('When change state of flag, then cache success', () async {
      fs = setupSyncClientAdapter(StorageType.inMemory, caches: true);
      setupAdapter(fs, cb: (config, adapter) {});
      await fs.getFeatureFlags();
      expect(await fs.isFeatureFlagEnabled(myFeatureName), true);
      await fs.testToggle(myFeatureName);
      expect(await fs.isFeatureFlagEnabled(myFeatureName), false);
    });
  });

  group('[Traits]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPost(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, data: jsonDecode(identitiesRequestData))
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

      // for int trait
      var result = await fs.getTraits(user, keys: ['age']);
      expect(result, isNotNull);
      expect(result.first.value, 25);

      // for double trait
      result = await fs.getTraits(user, keys: ['double_trait']);
      expect(result, isNotNull);
      expect(result.first.value, 10.1);

      // for string trait
      result = await fs.getTraits(user, keys: ['string_trait']);
      expect(result, isNotNull);
      expect(result.first.value, 'some-string');

      // for bool trait
      result = await fs.getTraits(user, keys: ['bool_trait']);
      expect(result, isNotNull);
      expect(result.first.value, true);
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
        value: 25,
      ));
      expect(updateResult, isNotNull);
      expect(updateResult?.value, 25);
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
          value: 21,
        ),
        TraitWithIdentity(
          identity: user,
          key: 'double_trait',
          value: 10.1,
        ),
        TraitWithIdentity(
          identity: user,
          key: 'string_trait',
          value: 'some-string',
        ),
        TraitWithIdentity(
          identity: user,
          key: 'bool_trait',
          value: true,
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
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, queryParameters: <String, dynamic>{
            'identifier': 'test_another_user'
          })
          ..onGet(fs.config.identitiesURI, (server) {
            return server.reply(200, null);
          }, queryParameters: <String, dynamic>{
            'identifier': 'invalid_users_another_user'
          })
          ..onPost(fs.config.identitiesURI, (server) {
            return server.reply(200, jsonDecode(identitiesResponseData));
          }, data: jsonDecode(identitiesResponseData)) // request
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
      var user = Identity(identifier: 'test_another_user');
      final data = TraitWithIdentity(identity: user, key: 'age', value: '25');
      fs = setupSyncClientAdapter(StorageType.inMemory);
      await fs.initialize();
      setupAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.traitsURI, (server) {
          return server.reply(200, null);
        }, data: data.toJson());
      });
      final result = await fs.createTrait(value: data);
      expect(result, isNull);
    });

    test('When get flags with traits request expected', () async {
      var user = Identity(identifier: 'test_another_user');
      var traits = [
        Trait(key: 'transient_trait', value: 'value', transient: true),
        Trait(key: 'normal_trait', value: 'value'),
      ];
      fs = await setupClientAdapter(StorageType.inMemory);
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.identitiesURI, (server) {
          return server.reply(200, jsonDecode(identitiesResponseData));
        }, data: jsonDecode(identitiesRequestWithTransientTraitData));
      });
      final result = await fs.getFeatureFlags(user: user, traits: traits);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get flags for transient identity request expected', () async {
      var user = Identity(identifier: 'test_another_user', transient: true);
      fs = await setupClientAdapter(StorageType.inMemory);
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onPost(fs.config.identitiesURI, (server) {
          return server.reply(200, jsonDecode(identitiesResponseData));
        }, data: user.toJson());
      });
      final result = await fs.getFeatureFlags(user: user);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });
  });
}
