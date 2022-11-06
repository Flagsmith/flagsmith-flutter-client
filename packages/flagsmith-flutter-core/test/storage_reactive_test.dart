import 'package:test/test.dart';
import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';

import 'shared.dart';

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
          store.stream(myFeature),
          emitsInOrder([
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is enabled', true),
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is not enabled', false),
          ]));
      final _toggled = await store.togggleFeature(myFeature);
      expect(_toggled, isTrue);
    });

    test('Subject value changed when flag was changed.', () async {
      await store.clear();
      await store.seed(items: seeds);
      final _feature = await store.read(myFeature);
      expect(_feature, isNotNull);
      expect(_feature!.enabled, isTrue);
      expect(store.subject(myFeature)?.stream.valueOrNull?.enabled, true);

      expect(
          store.subject(myFeature)?.stream,
          emitsInOrder([
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is enabled', true)
                .having((s) => s.feature.name, 'feature name is $myFeature',
                    myFeature),
            const TypeMatcher<Flag>()
                .having((s) => s.enabled, '$myFeature is not enabled', false)
                .having((s) => s.feature.name, 'feature name is $myFeature',
                    myFeature),
          ]));
      store.subject(myFeature)?.add(
          Flag.named(feature: Feature.named(name: myFeature), enabled: false));
    });
  });
}
