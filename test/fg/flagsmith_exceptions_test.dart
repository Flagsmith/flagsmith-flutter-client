import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, String>{});
  group('[Init] exceptions', () {
    test('When flag has wrong format, then fail', () async {
      expect(() => Mocked().wrongFlagFormat(message: 'wrong format'),
          throwsA(isA<FlagsmithFormatException>()));
    });
    test('When is missconfigured then fail', () async {
      expect(() => Mocked().configException(message: 'config error'),
          throwsA(isA<FlagsmithConfigException>()));
    });
    test('When flag has wrong format, then fail', () async {
      expect(() => Mocked().apiException(message: 'api error'),
          throwsA(isA<FlagsmithApiException>()));
    });
    test('When returns generic error, then fail', () async {
      expect(() => Mocked().genericError(message: 'generic error'),
          throwsA(isA<FlagsmithException>()));
    });
  });
  group('[Exceptions]', () {
    late FlagsmithClient fs;
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
    test(
        'When exception with description raised, then we are able to read error description',
        () async {
      final _description = 'generic error';
      expect(
          () => Mocked().genericError(message: _description),
          throwsA(TypeMatcher<FlagsmithException>().having(
              (s) => s.toString(),
              'correct error description',
              'FlagsmithException: $_description')));
    });

    test(
        'When exception without description raised, then we`ll see only type of exception',
        () async {
      final String? _description = null;
      expect(
          () => Mocked().genericError(message: _description),
          throwsA(TypeMatcher<FlagsmithException>().having((s) => s.toString(),
              'correct error description', 'FlagsmithException')));
    });

    test('When get user traits then exception', () async {
      final user = Identity(identifier: 'test_another_user');
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onGet(fs.config.identitiesURI, (server) {
            return server.throws(
              404,
              DioError(
                requestOptions: RequestOptions(path: fs.config.identitiesURI),
                error: Exception('404'),
              ),
            );
          }, queryParameters: user.toJson())
          ..onGet(fs.config.flagsURI, (server) {
            return server.throws(
              404,
              DioError(
                requestOptions: RequestOptions(path: fs.config.identitiesURI),
                error: Exception('404'),
              ),
            );
          }, queryParameters: user.toJson());
      });
      expect(() => fs.getTraits(user), throwsA(isA<FlagsmithApiException>()));
      expect(() => fs.getFeatureFlags(user: user),
          throwsA(isA<FlagsmithApiException>()));
    });
    test('When create trait return error', () async {
      var _user = Identity(identifier: 'test_another_user');
      final _data = TraitWithIdentity(identity: _user, key: 'age', value: '25');
      fs = await setupSyncClientAdapter(StoreType.inMemory);
      await fs.initialize();
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onPost(fs.config.traitsURI, (server) {
            return server.throws(
              404,
              DioError(
                requestOptions: RequestOptions(path: fs.config.identitiesURI),
                error: Exception('404'),
              ),
            );
          }, data: _data.toJson());
      });

      expect(() => fs.createTrait(value: _data),
          throwsA(isA<FlagsmithApiException>()));
    });
    test('When bulk update traits, then fail', () async {
      fs = await setupSyncClientAdapter(StoreType.inMemory);
      await fs.initialize();
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onPut(fs.config.traitsBulkURI, (server) {
            return server.throws(
              404,
              DioError(
                requestOptions: RequestOptions(path: fs.config.identitiesURI),
                error: Exception('404'),
              ),
            );
          }, data: jsonDecode(bulkTraitUpdateResponse));
      });
      final _user = Identity(identifier: 'test_another_user');
      final _data = [
        TraitWithIdentity(
          identity: _user,
          key: 'age',
          value: '21',
        ),
        TraitWithIdentity(
          identity: _user,
          key: 'age2',
          value: '21',
        )
      ];

      expect(() => fs.updateTraits(value: _data),
          throwsA(isA<FlagsmithApiException>()));
    });

    test('When bulk update list is empty then return null', () async {
      fs = await setupSyncClientAdapter(StoreType.inMemory);
      await fs.initialize();
      setupAdapter(fs, cb: (config, adapter) {
        adapter
          ..onPut(fs.config.traitsBulkURI, (server) {
            return server.reply(200, null);
          }, data: []);
      });
      final _response = await fs.updateTraits(value: <TraitWithIdentity>[]);
      expect(_response, isNull);
    });

    test('When fetch flags, but data are malformed, then fail', () async {
      fs = await setupSyncClientAdapter(StoreType.inMemory);
      final _flag =
          Flag.named(feature: Feature.named(name: myFeature), enabled: false);
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(config.flagsURI,
            (server) => server.reply(200, jsonEncode([_flag])));
      });

      expect(() => fs.getFeatureFlags(), throwsA(isA<FlagsmithApiException>()));
    });

    test('When fetch user flags, but data are malformed, then fail', () async {
      final _user = Identity(identifier: 'test_another_user');
      final _data = [
        TraitWithIdentity(
          identity: _user,
          key: 'age',
          value: '21',
        ),
        TraitWithIdentity(
          identity: _user,
          key: 'age2',
          value: '21',
        )
      ];

      fs = await setupSyncClientAdapter(StoreType.inMemory);
      setupEmptyAdapter(fs, cb: (config, adapter) {
        adapter.onGet(config.identitiesURI,
            (server) => server.reply(200, jsonDecode(jsonEncode([_data]))),
            queryParameters: _user.toJson());
      });

      expect(() => fs.getFeatureFlags(user: _user),
          throwsA(isA<FlagsmithApiException>()));
    });
  });
}
