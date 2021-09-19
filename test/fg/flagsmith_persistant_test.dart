import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:flagsmith/src/model/identity.dart';
import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared.dart';

void main() {
  SharedPreferences.setMockInitialValues(<String, String>{});

  group('[Persistent storage]', () {
    late FlagsmithClient fs;

    setUp(() async {
      fs = await setupClientAdapter(StoreType.persistant);
      setupAdapter(fs);
    });

    tearDown(() {
      fs.close();
    });
    test('When test multiple init with seed', () async {
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
      var user = Identity(identifier: 'test_sample_user');
      var result = await fs.getFeatureFlags(user: user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
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
}
