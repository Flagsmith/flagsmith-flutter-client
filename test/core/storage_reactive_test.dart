import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[Streams]', () {
    StorageProvider store = StorageProvider(InMemoryStorage(),
        password: 'pa5w0rD', logEnabled: true);
    setUp(() async {
      await store.seed(items: seeds);
    });
    tearDown(() {});

    test('Stream successfuly changed when flag was updated', () async {
      expect(
          store.stream(myFeatureName),
          emitsInOrder([
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeatureName is enabled', true),
            const TypeMatcher<Flag>().having(
                (s) => s.enabled, '$myFeatureName is not enabled', false),
          ]));
      final toggled = await store.togggleFeature(myFeatureName);
      expect(toggled, isTrue);
    });

    test('Subject value changed when flag was changed.', () async {
      await store.clear();
      await store.seed(items: seeds);
      final feature = await store.read(myFeatureName);
      expect(feature, isNotNull);
      expect(feature!.enabled, isTrue);
      expect(store.subject(myFeatureName)?.stream.valueOrNull?.enabled, true);

      expect(
          store.subject(myFeatureName)?.stream,
          emitsInOrder([
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeatureName is enabled', true)
                .having((s) => s.feature.name, 'feature name is $myFeatureName',
                    myFeatureName),
            const TypeMatcher<Flag>()
                .having(
                    (s) => s.enabled, '$myFeatureName is not enabled', false)
                .having((s) => s.feature.name, 'feature name is $myFeatureName',
                    myFeatureName),
          ]));
      store.subject(myFeatureName)?.add(Flag.named(
          feature: Feature.named(name: myFeatureName), enabled: false));
    });
  });
}
