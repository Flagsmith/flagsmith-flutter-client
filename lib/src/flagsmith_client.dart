import 'dart:io';
import 'package:meta/meta.dart';
import 'package:dio/adapter.dart';
import 'package:rxdart/subjects.dart';

import 'store/storage_provider.dart';
import 'package:dio/dio.dart';

import '../flagsmith.dart';
import 'flagsmith_config.dart';
import 'model/index.dart';
import 'store/storage/in_memory_store.dart';
import 'store/storage/persistant_store.dart';

/// Flagsmith client initialization
///
/// [config] configuration for http client and endpoints
/// [apiKey] api key for your enviornment
/// [seeds] default values before update from Flagsmith env.
///

class FlagsmithClient {
  static final String authHeader = 'X-Environment-Key';
  static final String acceptHeader = 'Accept';
  static final String userAgentHeader = 'User-Agent';

  final String apiKey;
  final FlagsmithConfig config;
  StorageProvider storage;

  FlagsmithClient(
      {this.config = const FlagsmithConfig(),
      @required this.apiKey,
      List<Flag> seeds})
      : assert(apiKey != null, 'Missing flagsmith.com apiKey') {
    flagsmithDebug = config.isDebug;
    switch (config.storeType) {
      case StoreType.persistant:
        storage = StorageProvider(PersistantStore(), password: config.password);
        break;
      default:
        storage = StorageProvider(InMemoryStore(), password: config.password);
    }
    initStore(seeds: seeds);
  }
  Future<bool> initStore({List<Flag> seeds, bool clear = false}) async {
    if (clear) {
      await storage.clear();
    }
    return await storage.seed(seeds);
  }

  /// Simple implementation of Http Client
  Dio _api() {
    var dio = Dio(config.clientOptions)
      ..options.headers[userAgentHeader] =
          'FlagsmithFlutterSDK(${Platform.operatingSystem}/${Platform.version})'
      ..options.headers[authHeader] = apiKey
      ..options.headers[acceptHeader] = 'application/json';

    if (config.isDebug) {
      dio.interceptors.add(config.isDebug
          ? LogInterceptor(requestHeader: false, responseBody: true)
          : null);
    }
    if (config.isSelfSigned) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
    return dio;
  }

  /// Get a list of existing Features for the given environment and user
  ///
  /// [user] a user in context
  /// Returns a list of feature flags
  Future<List<Flag>> getFeatureFlags(
      {FeatureUser user, bool reload = true}) async {
    if (!reload) {
      var result = await storage.getAll();
      result?.sort((a, b) => a.feature.name.compareTo(b.feature.name));
      return result;
    }
    return user == null ? await _getFlags() : await _getUserFlags(user);
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  Future<bool> hasFeatureFlag(String featureName, {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureName && element.enabled == true,
          orElse: () => null);
      return feature != null;
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  Future<bool> isFeatureFlagEnabled(String featureName,
      {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features.firstWhere(
          (element) => element.feature.name == featureName,
          orElse: () => null);
      return feature?.enabled;
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
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
    } on DioError catch (e) {
      log('getFeatureFlagValue dioError: ${e.toString()}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Get user trait for [user] with by [key]
  Future<Trait> getTrait(FeatureUser user, String key) async {
    try {
      var result = await _getUserTraits(user);
      return result.firstWhere((element) => element.key == key,
          orElse: () => null);
    } on DioError catch (e) {
      log('getTrait dioError: ${e?.error}');

      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Get all [user] traits with [keys]
  Future<List<Trait>> getTraits(FeatureUser user, {List<String> keys}) async {
    try {
      var result = await _getUserTraits(user);
      if (keys == null) {
        return result;
      }

      return result.where((element) => keys.contains(element.key)).toList();
    } on DioError catch (e) {
      log('getTraits dioError: ${e?.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  Future<List<Flag>> _getFlags() async {
    try {
      var response = await _api().get<List<dynamic>>(config.flagsURI);
      if (response.statusCode == 200) {
        var list = response.data
            .map<Flag>((dynamic e) => Flag.fromMap(e as Map<String, dynamic>))
            .toList();
        await storage.saveAll(list);
        list.sort((a, b) => a.feature.name.compareTo(b.feature.name));
        return list;
      }
      return [];
    } on DioError catch (e) {
      log('_getFlags dioError: ${e?.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  // Internal list of [user] flags
  Future<List<Flag>> _getUserFlags(FeatureUser user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api().get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        var data = FlagAndTraits.fromMap(response.data)?.flags ?? [];
        data.sort((a, b) => a.feature.name.compareTo(b.feature.name));
        await storage.saveAll(data);

        return data;
      }
      return [];
    } on DioError catch (e) {
      log('getUserTraits dioError: ${e?.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Internal list of [user] traits
  Future<List<Trait>> _getUserTraits(FeatureUser user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api().get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        return FlagAndTraits.fromMap(response.data)?.traits ?? [];
      }
      return [];
    } on DioError catch (e) {
      log('getUserTraits dioError: ${e?.error}');

      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
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
          await _api().post<dynamic>(config.traitsURI, data: trait.toJson());
      return Trait.fromMap(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      log('_postUserTraits dioError: ${e?.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (_) {
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// clear all data from storage
  Future<bool> clearStore() async => storage.clear();

  /// stream for listener
  Stream<Flag> stream(String key) => storage.stream(key);

  /// basic stream
  BehaviorSubject<Flag> subject(String key) => storage.subject(key);

  /// test toggle feature
  ///
  Future<bool> testToggle(String featureName) =>
      storage.togggleFeature(featureName);
}
