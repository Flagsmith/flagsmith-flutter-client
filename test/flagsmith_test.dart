import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:flagsmith/src/model/identity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, String>{});
  late FlagsmithClient fs, fsPersistant;
  
  setUpAll(() async {
    fs = await FlagsmithClient.init(
        apiKey: apiKey,
        seeds: seeds,
        config: FlagsmithConfig(
        storeType: StoreType.inMemory,
      ),
    );
    fs.loading.listen((event) {
      log('loading: $event');
    });

    fsPersistant = await FlagsmithClient.init(
      apiKey: apiKey,
      seeds: seeds,
      config: FlagsmithConfig(
        storeType: StoreType.persistant,
      ),
    );
    fsPersistant.loading.listen((event) {
      log('loading: $event');
    });
  });

  group('[Flagsmith: InMemory storage]', () {
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

  });

  group('[Flagsmith: Persistent storage]', () {
    test('When test multiple init with seed', () async {
      fsPersistant = await FlagsmithClient.init(
        apiKey: apiKey,
        seeds: seeds,
        config: FlagsmithConfig(storeType: StoreType.persistant),
      );
      var result = await fsPersistant.initStore(seeds: seeds, clear: true);
      expect(result, true);

      var resultFF = await fsPersistant.getFeatureFlags(reload: false);
      expect(resultFF, isNotNull);
      expect(resultFF, isNotEmpty);
      expect(resultFF.length, seeds.length);

      var resultFF2 = await fsPersistant.getFeatureFlags(reload: false);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
    });
    test('When init remove all items and Save seeds', () async {
      await fsPersistant.clearStore();
      var result = await fsPersistant.getFeatureFlags(reload: false);
      expect(result, isEmpty);

      await fsPersistant.initStore(seeds: seeds, clear: true);
      var result2 = await fsPersistant.getFeatureFlags(reload: false);
      expect(result2, isNotEmpty);
    });
    test('When has seeded Features then success', () async {
      var result = await fsPersistant.getFeatureFlags(reload: false);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When has Feature then success', () async {
      var result = await fsPersistant.getFeatureFlags();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get Features then success', () async {
      var result = await fsPersistant.hasFeatureFlag('enabled_feature');
      expect(result, true);
    });

    test('When get Features for user then success', () async {
      var user = Identity(identifier: 'test_sample_user');
      var result = await fsPersistant.getFeatureFlags(user: user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
  });

  group('[Flagsmith: Traits]', () {

    test('When get User traits then success', () async {
        var user = Identity(identifier: 'test_another_user');
      var result = await fsPersistant.getTraits(user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var trait in result) {
        expect(trait, isNotNull);
      }
    });

    test('When get User traits for invalid user then return empty', () async {
        var user = Identity(identifier: 'invalid_users_another_user');
      var result = await fsPersistant.getTraits(user);

      expect(result, isNotNull);
        expect(result, isEmpty);
    });

    test('When get User trait then success', () async {
      var user = Identity(identifier: 'test_another_user');
      var result = await fsPersistant.getTraits(user, keys: ['age']);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get User trait Update then Updated', () async {
      var user = Identity(identifier: 'test_another_user');
      var result = await fsPersistant.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result?.traitValue, isNotNull);

      var updateResult = await fs.createTrait(
            value: TraitWithIdentity(
        identity: user,
        traitKey: 'age',
        traitValue: '25',
      ));
      expect(updateResult, isNotNull);
      expect(updateResult?.traitValue, '25');
    });

    test('When get User trait Update then bulk Updated', () async {
      var user = Identity(identifier: 'test_another_user');
      var result = await fsPersistant.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result?.traitValue, isNotNull);

      var updateResult = await fsPersistant.updateTraits(value: [
        TraitWithIdentity(
          identity: user,
          traitKey: 'age',
          traitValue: '21',
        ),
        TraitWithIdentity(
          identity: user,
          traitKey: 'age2',
          traitValue: '21',
        )
      ]);
      expect(updateResult, isNotNull);
      expect(updateResult, isNotEmpty);
    });

  });
}
