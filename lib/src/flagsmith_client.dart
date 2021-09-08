import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:rxdart/subjects.dart';

import 'extensions/compute_transformer.dart';
import 'extensions/self_signed_adapter.dart';
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
  late Dio _api;

  final Set<Flag> _flags = {};
  final List<Flag> seeds;
  Set<Flag> get cachedFlags => _flags;

  final StreamController<FlagsmithLoading> _loading =
      StreamController.broadcast();
  Dio get client => _api;

  FlagsmithClient({
    this.config = const FlagsmithConfig(),
    required this.apiKey,
    this.seeds = const <Flag>[],
  }) {
    flagsmithDebug = config.isDebug;
    _api = _apiClient();

    switch (config.storeType) {
      case StoreType.persistant:
        storage = StorageProvider(PersistantStore(), password: config.password);
        break;
      default:
        storage = StorageProvider(InMemoryStore(), password: config.password);
    }
  }

  /// Initialization throught custom init services
  ///
  ///
  Future<void> initialize() async {
    flagsmithDebug = config.isDebug;
    switch (config.storeType) {
      case StoreType.persistant:
        storage = StorageProvider(PersistantStore(), password: config.password);
        break;
      default:
        storage = StorageProvider(InMemoryStore(), password: config.password);
    }

    await initStore(seeds: seeds);
  }

  /// Async initialization
  ///
  /// Returns [FlagsmithClient] after seeds are ready
  static Future<FlagsmithClient> init({
    FlagsmithConfig config = const FlagsmithConfig(isDebug: true),
    required String apiKey,
    List<Flag> seeds = const <Flag>[],
  }) async {
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
    return client;
  }

  Future<bool> initStore(
      {List<Flag> seeds = const <Flag>[], bool clear = false}) async {
    if (clear) {
      await storage.clear();
    }
    await storage.seed(items: seeds);
    final _items = await storage.getAll();
    _updateCaches(list: _items);
    return true;
  }

  /// Reset
  ///
  /// reseting storage and re-seed defalt values
  Future<bool> reset() async {
    await storage.clear();
    await storage.seed(items: seeds);
    _updateCaches(list: seeds, clear: true);
    return true;
  }

  /// Simple implementation of Http Client
  Dio _apiClient() {
    var dio = Dio(config.clientOptions)
      ..options.headers[userAgentHeader] =
          'FlagsmithFlutterSDK(${Platform.operatingSystem}/${Platform.version})'
      ..options.headers[authHeader] = apiKey
      ..options.headers[acceptHeader] = 'application/json'
      ..options.followRedirects = true
      ..transformer = ComputeTransformer();

    if (config.isDebug) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ));
    }
    if (config.isSelfSigned) {
      dio.httpClientAdapter = SelfSignedHttpClientAdapter();
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
    var features = await getFeatureFlags(user: user, reload: false);
    var feature = features.firstWhereOrNull((element) =>
        element.feature.name == featureName && element.enabled == true);
    return feature != null;
  }

  /// Check if Feature flag exist and is enabled in cache
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  ///
  /// Returns only if [caches] are enabled in config exception otherwise
  ///
  bool hasCachedFeatureFlag(String featureName, {Identity? user}) {
    if (!config.caches) {
      log('Exception: caches are NOT enabled!');
      throw FlagsmithConfigException(Exception('caches are NOT enabled!'));
    }

    var feature = _flags.firstWhereOrNull((element) =>
        element.feature.name == featureName && element.enabled == true);
    return feature != null;
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureName] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, null otherwise
  Future<bool> isFeatureFlagEnabled(String featureName,
      {Identity? user}) async {
    var features = await getFeatureFlags(user: user, reload: false);
    var feature = features
        .firstWhereOrNull((element) => element.feature.name == featureName);
    return feature?.enabled ?? false;
  }

  /// Get feature flag value by [featureId] and optionally for a [user]
  /// Returns String value of Feature Flag
  Future<String?> getFeatureFlagValue(String featureId,
      {Identity? user}) async {
    var features = await getFeatureFlags(user: user, reload: false);
    var feature = features
        .firstWhereOrNull((element) => element.feature.name == featureId);
    return feature?.stateValue;
  }

  Future<bool> removeFeatureFlag(String featureName) async {
    var result = await storage.delete(featureName);
    if (config.caches) {
      _flags.removeWhere((element) => element.feature.name == featureName);
    }
    return result;
  }

  /// Get user trait for [user] with by [key]
  Future<Trait?> getTrait(Identity user, String key) async {
    var result = await _getUserTraits(user);
    return result.firstWhereOrNull((element) => element.key == key);
  }

  Future<List<Flag>> _getFlags() async {
    try {
      var response = await _api.get<List<dynamic>>(config.flagsURI);
      if (response.statusCode == 200) {
        var list = response.data!
            .map<Flag>((dynamic e) => Flag.fromJson(e as Map<String, dynamic>))
            .toList();
        await storage.saveAll(list);
        final _saved = await storage.getAll()
          ..sort((a, b) => a.feature.name.compareTo(b.feature.name));
        _updateCaches(clear: true, list: _saved);
        return list;
      }
      return [];
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithApiException(e);
    } catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(e);
    }
  }

  // Internal list of [user] flags
  Future<List<Flag>> _getUserFlags(Identity user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api.get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        if (response.data == null) {
          return [];
        }
        var data = FlagsAndTraits.fromJson(response.data!).flags ?? [];
        if (data.isNotEmpty) {
          data.sort((a, b) => a.feature.name.compareTo(b.feature.name));
        }
        await storage.saveAll(data);
        final _saved = await storage.getAll()
          ..sort((a, b) => a.feature.name.compareTo(b.feature.name));
        _updateCaches(clear: true, list: _saved);
        return data;
      }
      return [];
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithApiException(e);
    } catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(e);
    }
  }

  /// TRAITS
  ///
  /// Get all `user` traits with `keys`
  Future<List<Trait>> getTraits(Identity user, {List<String>? keys}) async {
    var result = await _getUserTraits(user);
    if (keys == null) {
      return result;
    }
    return result.where((element) => keys.contains(element.key)).toList();
  }

  /// Internal list of `user` traits
  Future<List<Trait>> _getUserTraits(Identity user) async {
    try {
      var params = {'identifier': user.identifier};
      var response = await _api.get<Map<String, dynamic>>(
          '${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        if (response.data == null) {
          return [];
        }
        return FlagsAndTraits.fromJson(response.data!).traits ?? [];
      }
      return [];
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithApiException(e);
    } catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(e);
    }
  }

  // Update trait for `user` with new value `traits`
  Future<TraitWithIdentity?> createTrait(
      {required TraitWithIdentity value}) async {
    try {
      var response =
          await _api.post<dynamic>(config.traitsURI, data: value.toJson());
      if (response.data == null) {
        return null;
      }
      return TraitWithIdentity.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithApiException(e);
    } catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(e);
    }
  }

  /// Bulk update of traits for `user` with list of `value`
  Future<List<TraitWithIdentity>?> updateTraits(
      {required List<TraitWithIdentity> value}) async {
    try {
      if (value.isEmpty) {
        return null;
      }
      final data = value.map((e) => e.toJson()).toList();
      var response = await _api.put<dynamic>(
        config.traitsBulkURI,
        data: data,
      );
      if (response.data == null) {
        return null;
      }
      final _data =
          List<Map<String, dynamic>>.from(response.data as List<dynamic>);
      return _data.map((e) => TraitWithIdentity.fromJson(e)).toList();
    } on DioError catch (e) {
      log('_getFlags dioError: ${e.error}');
      throw FlagsmithApiException(e);
    } catch (e) {
      log('Exception: _getFlags $e');
      throw FlagsmithException(e);
    }
  }

  /// Internal updadte caches from list of featurs
  void _updateCaches({List<Flag> list = const <Flag>[], bool clear = false}) {
    if (config.caches) {
      if (clear) {
        _flags.clear();
      }
      _flags.addAll(list.toSet());
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
  Future<bool> testToggle(String featureName) async {
    final _result = await storage.togggleFeature(featureName);
    final _value = await storage.read(featureName);
    if (config.caches) {
      _flags.removeWhere((element) => element.feature.name == featureName);
      if (_value != null) {
        _flags.add(_value);
      }
    }
    return _result;
  }
}
