import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';
import '../shared.dart';

void main() {
  late FlagsmithClient fs;
  group('[Init] in memory sync', () {
    setUp(() async {
      fs = setupSyncClientAdapter(
        StorageType.inMemory,
      );
      setupAdapter(fs);
      await fs.initialize();
      await fs.getFeatureFlags();
    });
    tearDown(() {
      fs.close();
    });
    test('When caches not enabled then fail', () async {
      expect(() => fs.hasCachedFeatureFlag(notImplementedFeatureName),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });
  group('[Init] streams', () {
    final flag =
        Flag.named(feature: Feature.named(name: myFeatureName), enabled: false);

    setUp(() async {
      fs = setupSyncClientAdapter(
        StorageType.inMemory,
        isDebug: true,
      );
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(config.flagsURI, (server) => server.reply(200, [flag]));
      });
      await fs.initialize();
    });
    tearDown(() {
      fs.close();
    });
    test('When change flag value, stream is updated', () async {
      final updated = flag.copyWith(enabled: true);
      expect(fs.stream(myFeatureName), emitsInOrder(<Flag>[flag, updated]));
      await fs.getFeatureFlags(reload: true);
      await fs.testToggle(myFeatureName);
    });
  }, skip: true);
}
