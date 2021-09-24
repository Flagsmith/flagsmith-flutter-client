import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:test/test.dart';
import 'package:flagsmith_core/flagsmith_core.dart';
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
      expect(() => fs.hasCachedFeatureFlag(notImplmentedFeature),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });
  group('[Init] streams', () {
    final _flag =
        Flag.named(feature: Feature.named(name: myFeature), enabled: false);

    setUp(() async {
      fs = setupSyncClientAdapter(
        StorageType.inMemory,
        isDebug: true,
      );
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(config.flagsURI, (server) => server.reply(200, [_flag]));
      });
      await fs.initialize();
    });
    tearDown(() {
      fs.close();
    });
    test('When change flag value, stream is updated', () async {
      final _updated = _flag.copyWith(enabled: true);
      expect(fs.stream(myFeature), emitsInOrder(<Flag>[_flag, _updated]));
      await fs.getFeatureFlags(reload: true);
      await fs.testToggle(myFeature);
    });
  }, skip: true);
}
