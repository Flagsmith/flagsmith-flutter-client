import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:test/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared.dart';

void main() {
  SharedPreferences.setMockInitialValues(<String, String>{});
  late FlagsmithClient fs;
  group('[Init] in memory sync', () {
    setUp(() async {
      fs = setupSyncClientAdapter(
        StoreType.inMemory,
      );
      setupAdapter(fs);
      await fs.initialize();
      await fs.getFeatureFlags();
    });
    tearDown(() {
      fs.close();
    });
    test('When caches not enabled then fail', () async {
      expect(() async => await fs.hasCachedFeatureFlag(notImplmentedFeature),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });

  group('[Init] persistatnt sync', () {
    setUp(() async {
      fs = setupSyncClientAdapter(
        StoreType.persistant,
      );
      setupAdapter(fs, cb: (config, adapter) {});
      await fs.initialize();
      await fs.getFeatureFlags();
    });
    tearDown(() {
      fs.close();
    });
    test('When caches not enabled then fail', () async {
      expect(() async => await fs.hasCachedFeatureFlag(notImplmentedFeature),
          throwsA(isA<FlagsmithConfigException>()));
    });
  });
  group('[Init] streams', () {
    final _flag =
        Flag.named(feature: Feature.named(name: myFeature), enabled: false);
    // final _flagsResponse = jsonEncode([_flag]);
    setUp(() async {
      fs = setupSyncClientAdapter(
        StoreType.persistant,
      );
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(
            config.flagsURI,
            (server) =>
                server.reply(200, [_flag])); //jsonDecode(_flagsResponse)));
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
