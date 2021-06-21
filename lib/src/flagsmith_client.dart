import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
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
  late StorageProvider storage;

  final Set<Flag> _flags = {};

  final StreamController<FlagsmithLoading> _loading =
      StreamController.broadcast();

  FlagsmithClient(
      {this.config = const FlagsmithConfig(),
      required this.apiKey,
      List<Flag> seeds = const <Flag>[],
      bool update = false}) {
    flagsmithDebug = config.isDebug;
    switch (config.storeType) {
      case StoreType.persistant:
        storage = StorageProvider(PersistantStore(), password: config.password);
        break;
      default:
        storage = StorageProvider(InMemoryStore(), password: config.password);
    }
    initStore(seeds: seeds).then((value) async {
      if (update) {
        await getFeatureFlags(reload: true);
      }
    });
  }

  /// Async initialization
  ///
  /// Returns [FlagsmithClient] after seeds are ready
  static Future<FlagsmithClient> init(
      {FlagsmithConfig config = const FlagsmithConfig(isDebug: true),
      required String apiKey,
      List<Flag> seeds = const <Flag>[],
      bool update = false}) async {
    final client = FlagsmithClient(
      config: config,
      apiKey: apiKey,
      seeds: seeds,
    );
    flagsmithDebug = config.isDebug;
    switch (config.storeType) {
      case StoreType.persistant:
        client.storage =
            StorageProvider(PersistantStore(), password: config.password);
        break;
      default:
        client.storage =
            StorageProvider(InMemoryStore(), password: config.password);
    }
    await client.initStore(seeds: seeds);

    if (update) {
      await client.getFeatureFlags(reload: true);
    }
    return client;
  }

  Future<bool> initStore(
      {List<Flag> seeds = const <Flag>[], bool clear = false}) async {
    if (clear) {
      await storage.clear();
    }
    await storage.seed(items: seeds);
    _updateCaches(list: seeds);
    return true;
  }

  /// Simple implementation of Http Client
  Dio _api() {
    var dio = Dio(config.clientOptions)
      ..options.headers[userAgentHeader] =
          'FlagsmithFlutterSDK(${Platform.operatingSystem}/${Platform.version})'
      ..options.headers[authHeader] = apiKey
      ..options.headers[acceptHeader] = 'application/json';

    if (config.isDebug) {
      dio.interceptors
          .add(LogInterceptor(requestHeader: false, responseBody: true));
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
      {Identity? user, bool reload = true}) async {
    if (!reload) {
      var result = await storage.getAll();

      if (result.isNotEmpty) {
        result.sort((a, b) => a.feature.name.compareTo(b.feature.name));
      }
      _updateCaches(list: result);
      return result;
    }
    _loading.add(FlagsmithLoading.loading);
    final list = user == null ? await _getFlags() : await _getUserFlags(user);
    _loading.add(FlagsmithLoading.loaded);
    return list;
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  Future<bool> hasFeatureFlag(String featureName, {Identity? user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features.firstWhereOrNull((element) =>
          element.feature.name == featureName && element.enabled == true);
      return feature != null;
    } on Exception catch (e) {
      log('Exception: hasFeatureFlag $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  ///
  /// Returns only if [caches] are enabled in config exception otherwise
  ///
  bool hasCachedFeatureFlag(String featureName, {Identity? user}) {
    if (!config.caches) {
      log('Exception: caches not enabled');
      throw FlagsmithException(FlagsmithExceptionType.cachesDisabled);
    }
    try {
      var feature = _flags.firstWhereOrNull((element) =>
          element.feature.name == featureName && element.enabled == true);
      return feature != null;
    } on Exception catch (e) {
      log('Exception: hasFeatureFlag $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, null otherwise
  Future<bool?> isFeatureFlagEnabled(String featureName,
      {Identity? user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features
          .firstWhereOrNull((element) => element.feature.name == featureName);
      return feature?.enabled;
    } on Exception catch (e) {
      log('Exception: isFeatureFlagEnabled $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Get feature flag value by [featureId] and optionally for a [user]
  /// Returns String value of Feature Flag
  Future<String?> getFeatureFlagValue(String featureId,
      {Identity? user}) async {
    try {
      var features = await getFeatureFlags(user: user, reload: false);
      var feature = features
          .firstWhereOrNull((element) => element.feature.name == featureId);
      return feature?.stateValue;
    } on DioError catch (e) {
      log('getFeatureFlagValue dioError: ${e.toString()}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: getFeatureFlagValue $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: getFeatureFlagValue $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Get user trait for [user] with by [key]
  Future<Trait?> getTrait(Identity user, String key) async {
    try {
      var result = await _getUserTraits(user);
      return result.firstWhereOrNull((element) => element.key == key);
    } on DioError catch (e) {
      log('getTrait dioError: ${e.error}');

      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: getTrait $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: getTrait $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  Future<List<Flag>> _getFlags() async {
    try {
      var response = await _api().get<List<dynamic>>(config.flagsURI);
      if (response.statusCode == 200) {
        var list = response.data!
            .map<Flag>((dynamic e) => Flag.fromMap(e as Map<String, dynamic>))
            .toList();
        await storage.saveAll(list);
        list.sort((a, b) => a.feature.name.compareTo(b.feature.name));
        _flags
          ..clear()
          ..addAll((list).toSet());
        return list;
      }
      _flags.clear();
      return [];
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  // Internal list of [user] flags
  Future<List<Flag>> _getUserFlags(Identity user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api().get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        if (response.data == null) {
          return [];
        }
        var data = FlagsAndTraits.fromMap(response.data!).flags ?? [];
        if (data.isNotEmpty) {
          data.sort((a, b) => a.feature.name.compareTo(b.feature.name));
        }
        await storage.saveAll(data);
        _flags
          ..clear()
          ..addAll((data).toSet());
        return data;
      }
      return [];
    } on DioError catch (e) {
      log('getUserTraits dioError: ${e.error}');

      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: _getUserFlags $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: _getUserFlags $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// TRAITS
  ///
  /// Get all `user` traits with `keys`
  Future<List<Trait>> getTraits(Identity user, {List<String>? keys}) async {
    try {
      var result = await _getUserTraits(user);
      if (keys == null) {
        return result;
      }

      return result
          .where((element) => keys.contains(element.key))
          .toList();
    } on DioError catch (e) {
      log('getTraits dioError: ${e.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: getTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: getTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Internal list of `user` traits
  Future<List<Trait>> _getUserTraits(Identity user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api().get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        if (response.data == null) {
          return [];
        }
        return FlagsAndTraits.fromMap(response.data!).traits ?? [];
      }
      return [];
    } on DioError catch (e) {
      log('getUserTraits dioError: ${e.error}');

      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: getUserTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: getUserTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  // Update trait for `user` with new value `traits`
  Future<TraitWithIdentity?> createTrait(
      {required TraitWithIdentity value}) async {
    try {
      var response =
          await _api().post<dynamic>(config.traitsURI, data: value.toMap());
      if (response.data == null) {
        return null;
      }
      return TraitWithIdentity.fromMap(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      log('createTrait dioError: ${e.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: createTrait $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: createTrait $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Bulk update of traits for `user` with list of `value`
  Future<List<TraitWithIdentity>?> updateTraits(
      {required List<TraitWithIdentity> value}) async {
    try {
      if (value.isEmpty) {
        return null;
      }
      final data = value.map((e) => e.toMap()).toList();
      var response = await _api().put<dynamic>(
        '${config.traitsURI}bulk/',
        data: data,
      );
      if (response.data == null) {
        return null;
      }
      final _data =
          List<Map<String, dynamic>>.from(response.data as List<dynamic>);
      return _data.map((e) => TraitWithIdentity.fromMap(e)).toList();
    } on DioError catch (e) {
      log('updateTraits dioError: ${e.error}');
      throw FlagsmithException(FlagsmithExceptionType.connectionSettings);
    } on FormatException catch (e) {
      log('Exception: updateTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.wrongFlagFormat);
    } on Exception catch (e) {
      log('Exception: updateTraits $e');
      throw FlagsmithException(FlagsmithExceptionType.genericError);
    }
  }

  /// Internal updadte caches from list of featurs
  void _updateCaches({List<Flag> list = const <Flag>[], bool clear = false}) {
    if (config.caches) {
      if (clear) {
        _flags.clear();
      } else {
        _flags.addAll(list.toSet());
      }
    }
  }

  /// clear all data from storage
  Future<bool> clearStore() async => storage.clear();

  /// stream for listener
  Stream<Flag>? stream(String key) => storage.stream(key);

  /// basic stream
  BehaviorSubject<Flag>? subject(String key) => storage.subject(key);

  // Loading from API
  Stream<FlagsmithLoading> get loading => _loading.stream;

  void close() {
    _loading.close();
  }

  /// test toggle feature
  ///
  Future<bool> testToggle(String featureName) =>
      storage.togggleFeature(featureName);
}
