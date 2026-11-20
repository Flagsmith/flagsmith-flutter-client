import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

Map<String, dynamic> _flag(String name, Object? value, String? reason) => {
      'id': name.hashCode,
      'feature': {'id': name.hashCode, 'name': name},
      'feature_state_value': value,
      'enabled': true,
      'reason': reason,
    };

Map<String, String?> _reasons(List<Flag> flags) =>
    {for (final flag in flags) flag.feature.name: flag.reason};

void main() {
  group('[Reasons]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(StorageType.inMemory, caches: true);
      await fs.clearStore();
    });
    tearDown(() {
      fs.close();
    });

    test('When environment flags are fetched, then each carries its reason',
        () async {
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(
            config.flagsURI,
            (server) => server.reply(200, [
                  _flag('banner', 'welcome', 'STATIC'),
                  _flag('max_items', 42, 'STATIC'),
                ]));
      });

      final flags = await fs.getFeatureFlags();
      expect(_reasons(flags), {'banner': 'STATIC', 'max_items': 'STATIC'});
      expect(_reasons(await fs.getFeatureFlags(reload: false)),
          {'banner': 'STATIC', 'max_items': 'STATIC'});
    });

    test('When identity flags are fetched, then each carries its reason',
        () async {
      final user = Identity(identifier: 'user_123');
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onPost(
            config.identitiesURI,
            (server) => server.reply(200, {
                  'flags': [
                    _flag('banner', 'hello premium user',
                        'TARGETING_MATCH; segment=premium_users'),
                    _flag('max_items', 10, 'STATIC'),
                  ],
                  'traits': [],
                }),
            data: user.toJson());
      });

      final flags = await fs.getFeatureFlags(user: user);
      expect(_reasons(flags), {
        'banner': 'TARGETING_MATCH; segment=premium_users',
        'max_items': 'STATIC',
      });
      expect(fs.cachedFlags['banner']?.reason,
          'TARGETING_MATCH; segment=premium_users');
    });

    test('When a reason changes on refresh, then the new reason is served',
        () async {
      final user = Identity(identifier: 'user_123');
      void reply(String reason) => setupEmptyAdapter(fs, cb: (config, adapter) {
            adapter.onPost(
                config.identitiesURI,
                (server) => server.reply(200, {
                      'flags': [_flag('banner', 'hello', reason)],
                      'traits': [],
                    }),
                data: user.toJson());
          });

      reply('TARGETING_MATCH; segment=premium_users');
      await fs.getFeatureFlags(user: user);
      reply('DEFAULT');
      final flags = await fs.getFeatureFlags(user: user);

      expect(_reasons(flags), {'banner': 'DEFAULT'});
      expect(_reasons(await fs.getFeatureFlags(reload: false)),
          {'banner': 'DEFAULT'});
    });

    test('When the server omits reasons, then reasons are null', () async {
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(
            config.flagsURI,
            (server) => server.reply(200, [
                  {
                    'id': 1,
                    'feature': {'id': 1, 'name': 'banner'},
                    'feature_state_value': 'welcome',
                    'enabled': true,
                  },
                ]));
      });

      expect(_reasons(await fs.getFeatureFlags()), {'banner': null});
    });
  });
}
