import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[Caches] disabled', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: false);
      setupAdapter(fs);
    });
    tearDown(() {
      fs.close();
    });
    test('When caches not enabled then fail', () async {
      expect(() => fs.hasCachedFeatureFlag(notImplementedFeatureName),
          throwsA(isA<FlagsmithConfigException>()));
    });

    test('When caches not enabled and get cached flag then fail', () async {
      expect(() => fs.getCachedFeatureFlagValue(notImplementedFeatureName),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });

  group('[Caches] enabled', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
      setupAdapter(fs);
    });
    tearDown(() {
      fs.close();
    });
    test('When caches enabled then enabled', () async {
      await fs.getFeatureFlags();
      final value = fs.hasCachedFeatureFlag(notImplementedFeatureName);
      expect(value, false);
    });

    test('When caches enabled then get value', () async {
      await fs.getFeatureFlags();
      final value = fs.hasCachedFeatureFlag(notImplementedFeatureName);
      expect(value, false);

      final flagValue = fs.getCachedFeatureFlagValue('min_version');
      expect(flagValue, '2.0.0');
    });

    test('When feature flag remove then success', () async {
      final featureName = 'my_feature';
      await fs.reset();

      final current = await fs.hasFeatureFlag(featureName);
      expect(current, true);

      var result = await fs.removeFeatureFlag(featureName);
      expect(result, true);
      expect(fs.cachedFlags.containsKey(featureName), false);

      final removed = await fs.hasFeatureFlag(featureName);
      expect(removed, false);
    });

    test('When cache is not empty', () async {
      await fs.getFeatureFlags();
      expect(fs.cachedFlags, isNotEmpty);
    });
  });
}
