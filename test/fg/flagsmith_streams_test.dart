import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:test/test.dart';
import 'package:flagsmith_core/flagsmith_core.dart';

import '../shared.dart';

void main() {
  group('[Streams]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
      setupAdapter(fs, cb: (config, _adapter) {});
    });
    tearDown(() {
      fs.close();
    });

    test('Loading state changing during reloading of flags', () async {
      expect(
          fs.loading,
          emitsInOrder(<FlagsmithLoading>[
            FlagsmithLoading.loading,
            FlagsmithLoading.loaded
          ]));
      await fs.getFeatureFlags(reload: true);
    });

    test('Stream successfuly changed when flag was updated', () async {
      await fs.reset();
      expect(await fs.isFeatureFlagEnabled(myFeature), true);
      expect(
          fs.stream(myFeature),
          emitsInOrder([
            TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is enabled', true),
            TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is not enabled', false),
          ]));
      await fs.testToggle(myFeature);
    });

    test('Subject value changed when flag was changed.', () async {
      await fs.reset();
      expect(await fs.isFeatureFlagEnabled(myFeature), true);
      expect(fs.subject(myFeature)?.stream.valueOrNull?.enabled, true);

      expect(
          fs.subject(myFeature)?.stream,
          emitsInOrder([
            TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is enabled', true)
                .having((s) => s.feature.name, 'feature name is $myFeature',
                    myFeature),
            TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is not enabled', false)
                .having((s) => s.feature.name, 'feature name is $myFeature',
                    myFeature),
          ]));
      fs.subject(myFeature)?.add(
          Flag.named(feature: Feature.named(name: myFeature), enabled: false));
    });
  });
}
