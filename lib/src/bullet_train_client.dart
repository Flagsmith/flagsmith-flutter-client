import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../bullet_train.dart';
import 'bullet_train_config.dart';
import 'model/index.dart';
import 'store/crud_store.dart';
import 'store/in_memory_store.dart';
import 'store/persistant_store.dart';

/// Bullet train client initialization
///
/// [config] configuration for http client and endpoints
/// [apiKey] api key for your enviornment
class BulletTrainClient {
  static final String authHeader = 'X-Environment-Key';
  static final String acceptHeader = 'Accept';

  final String apiKey;
  final BulletTrainConfig config;
  CrudStore store = InMemoryStore();

  BulletTrainClient(
      {this.config = const BulletTrainConfig(),
      @required this.apiKey,
      List<Flag> seeds})
      : assert(apiKey != null, 'Missing Bullet-train.io apiKey')
  // ,assert(config.storeType == StoreType.sembast && config.storePath != '',
  //     'Store type sembast require [storePath]')
  {
    initStore(seeds: seeds);
  }
  Future<void> initStore({List<Flag> seeds, bool clear = false}) async {
    switch (config.storeType) {
      case StoreType.sembast:
        store = PersistantStore(databasePath: config.storePath);
        break;
      case StoreType.prefs:
        store = await SharedPrefsStore.getInstance();
        break;
      default:
        store = InMemoryStore();
    }
    await store.init();
    // if (clear) {
    //   await store.clear();
    // }
    await store.seed(seeds);
    return null;
  }

  /// Simple implementation of Http Client
  Dio get _api => Dio(config.clientOptions)
    ..options.headers[authHeader] = apiKey
    ..options.headers[acceptHeader] = 'application/json';

  /// Get a list of existing Features for the given environment and user
  ///
  /// [user] a user in context
  /// Returns a list of feature flags
  Future<List<Flag>> getFeatureFlags(
      {FeatureUser user, bool reload = true}) async {
    try {
      if (user == null) {
        if (!reload) {
          return await store.getAll();
        }

        var params = <String, dynamic>{'page': '1'};
        var response = await _api.get<List<dynamic>>(config.flagsURI,
            queryParameters: params);
        var returnList = <Flag>[];
        if (response.statusCode == 200) {
          var list = response.data
              .map<Flag>((dynamic e) => Flag.fromMap(e as Map<String, dynamic>))
              .toList();
          list.map(store.create);
          returnList = list;
        } else {
          returnList = await store.getAll();
        }
        return returnList;
      } else {
        if (!reload) {
          return await store.getAll();
        }
        var response = await _api
            .get<List<dynamic>>('${config.flagsURI}${'/${user.identifier}'}');
        var returnList = <Flag>[];
        if (response.statusCode == 200) {
          var list = response.data
              .map<Flag>((dynamic e) => Flag.fromMap(e as Map<String, dynamic>))
              .toList();
          list.map(store.create);
          returnList = list;
        } else {
          returnList = await store.getAll();
        }
        return returnList;
      }
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureId] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  Future<bool> hasFeatureFlag(String featureId, {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureId && element.enabled == true,
          orElse: () => null);
      return feature != null;
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Get feature flag value by [featureId] and optionally for a [user]
  /// Returns String value of Feature Flag
  Future<String> getFeatureFlagValue(String featureId,
      {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureId && element.enabled == true,
          orElse: () => null);
      return feature?.stateValue;
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Get user trait for [user] with by [key]
  Future<Trait> getTrait(FeatureUser user, String key) async {
    try {
      var result = await _getUserTraits(user);
      return result.firstWhere((element) => element.key == key,
          orElse: () => null);
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Get all [user] traits with [keys]
  Future<List<Trait>> getTraits(FeatureUser user, {List<String> keys}) async {
    try {
      var result = await _getUserTraits(user);
      if (keys == null || keys.isEmpty) {
        return result;
      }
      return result.where((element) => keys.contains(element.key)).toList();
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Internal list of [user] traits
  Future<List<Trait>> _getUserTraits(FeatureUser user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api.get<dynamic>('${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        var data = FlagAndTraits.fromMap(response.data as Map<String, dynamic>);
        return data.traits ?? [];
      }
      return [];
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  /// Update trait for [user] with new value [toUpdate]
  Future<Trait> updateTrait(FeatureUser user, Trait toUpdate) async {
    return _postUserTraits(user, toUpdate);
  }

  /// Internal post of user traits
  Future<Trait> _postUserTraits(FeatureUser user, Trait toUpdate) async {
    try {
      var trait = toUpdate.copyWith(identity: user);
      var response =
          await _api.post<dynamic>(config.traitsURI, data: trait.toJson());
      return Trait.fromMap(response.data as Map<String, dynamic>);
    } on DioError catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw BulletTrainException(BulletTrainExceptionType.genericError);
    }
  }

  Future<void> clearStore() async {
    await store.clear();
    return null;
  }
}
