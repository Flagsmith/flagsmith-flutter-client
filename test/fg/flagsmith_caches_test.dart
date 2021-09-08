import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, String>{});

  group('[Caches] disabled', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StoreType.inMemory, caches: false);
      setupAdapter(fs);
    });
    tearDown(() {
      fs.close();
    });
    test('When caches not enabled then fail', () async {
      expect(() async => await fs.hasCachedFeatureFlag(notImplmentedFeature),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });

  group('[Caches] enabled', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StoreType.inMemory, caches: true);
      setupAdapter(fs);
    });
    tearDown(() {
      fs.close();
    });
    test('When caches enabled then enabled', () async {
      await fs.getFeatureFlags();
      final _value = await fs.hasCachedFeatureFlag(notImplmentedFeature);
      expect(_value, false);
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

    test('When cache is not empty', () async {
      await fs.getFeatureFlags();
      expect(fs.cachedFlags, isNotEmpty);
    });
  });
}
