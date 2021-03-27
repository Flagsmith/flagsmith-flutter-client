import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:flagsmith/src/model/feature_user.dart';

import 'shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues(<String, String>{});
  FlagsmithClient fs;
  setUpAll(() async {
    fs = await FlagsmithClient.init(
        apiKey: apiKey,
        seeds: seeds,
        config: FlagsmithConfig(storeType: StoreType.persistant));
  });

  group('[Flagsmith: Persistent storage]', () {
    test('When test multiple init with seed', () async {
      fs = await FlagsmithClient.init(
        apiKey: apiKey,
        seeds: seeds,
        config: FlagsmithConfig(storeType: StoreType.persistant),
      );
      var result = await fs.initStore(seeds: seeds, clear: true);
      expect(result, true);

      var resultFF = await fs.getFeatureFlags(reload: false);
      expect(resultFF, isNotNull);
      expect(resultFF, isNotEmpty);
      expect(resultFF.length, seeds.length);

      var resultFF2 = await fs.getFeatureFlags(reload: false);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
      expect(resultFF2, isNotNull);
      expect(resultFF2, isNotEmpty);
      expect(resultFF2.length, seeds.length);
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

    test('When get Features then success', () async {
      var result = await fs.hasFeatureFlag('enabled_feature');
      expect(result, true);
    });

    test('When get Features for user then success', () async {
      var user = FeatureUser(identifier: 'test_sample_user');
      var result = await fs.getFeatureFlags(user: user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get User traits then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await fs.getTraits(user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var trait in result) {
        expect(trait, isNotNull);
      }
    });

    test('When get User traits for invalid user then return empty', () async {
      var user = FeatureUser(identifier: 'invalid_users_another_user');
      var result = await fs.getTraits(user);

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('When get User trait then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await fs.getTraits(user, keys: ['age']);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get User trait Update then Updated', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await fs.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result.value, isNotNull);

      var toUpdate = result.copyWith(value: '25');
      var updateResult = await fs.updateTrait(user, toUpdate);
      expect(updateResult, isNotNull);
      expect(updateResult.value, '25');
    });
  });
}
