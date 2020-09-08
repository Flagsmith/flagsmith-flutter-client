import 'dart:io';

import 'package:bullet_train/src/bullet_train_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'model/feature_user.dart';
import 'model/flag.dart';
import 'model/flag_and_traits.dart';
import 'model/trait.dart';
import 'store/crud_store.dart';
import 'store/in_memory_store.dart';

/// Bullet train client initialization
///
/// [config] configuration for http client and endpoints
/// [apiKey] api key for your enviornment
class BulletTrainClient {
  static final String authHeader = 'X-Environment-Key';
  static final String acceptHeader = 'Accept';

  final String apiKey;
  final BulletTrainConfig config;
  final CrudStore store = InMemoryStore();

  BulletTrainClient(
      {this.config = const BulletTrainConfig(),
      @required this.apiKey,
      List<Flag> seeds})
      : assert(apiKey != null, 'Missing Bullet-train.io apiKey') {
    seeds?.map(store.create);
  }

  /// Simple implementation of Http Client
  Dio get _api => Dio(config.clientOptions)
    ..options.headers[authHeader] = apiKey
    ..options.headers[acceptHeader] = 'application/json'
    ..interceptors.add(!kReleaseMode
        ? PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            compact: false,
          )
        : null);

  /// Get a list of existing Features for the given environment and user
  ///
  /// [user] a user in context
  /// Returns a list of feature flags
  Future<List<Flag>> getFeatureFlags({FeatureUser user}) async {
    try {
      if (user == null) {
        var params = <String, dynamic>{'page': '1'};
        var response = await _api.get<List<dynamic>>(config.flagsURI,
            queryParameters: params);

        if (response.statusCode == 200) {
          var list = response.data
              .map<Flag>(
                  (dynamic e) => Flag.fromJson(e as Map<String, dynamic>))
              .toList();
          list.map(store.create);
          return list;
        } else {
          return store.getAll();
        }
      } else {
        var response = await _api
            .get<List<dynamic>>('${config.flagsURI}${'/${user.identifier}'}');

        if (response.statusCode == 200) {
          var list = response.data
              .map<Flag>(
                  (dynamic e) => Flag.fromJson(e as Map<String, dynamic>))
              .toList();
          list.map(store.create);
          return list;
        } else {
          return store.getAll();
        }
      }
    } on DioError catch (e) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    }

    return [];
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// [featureId] an identifier for the feature
  /// [user] an identifier for the user
  /// Returns true if feature flag exist and enabled, false otherwise
  Future<bool> hasFeatureFlag(String featureId, {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureId && element.enabled == true,
          orElse: () => null);
      return feature != null;
    } on DioError catch (e, _) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    }
    return false;
  }

  Future<String> getFeatureFlagValue(String featureId,
      {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureId && element.enabled == true,
          orElse: () => null);
      return feature?.stateValue;
    } on DioError catch (e, _) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    }
    return null;
  }

  Future<Trait> getTrait(FeatureUser user, String key) async {
    try {
      var result = await getUserTraits(user);
      return result.firstWhere((element) => element.key == key);
    } on DioError catch (e, _) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    }
    return null;
  }

  Future<List<Trait>> getTraits(FeatureUser user, {List<String> keys}) async {
    try {
      var result = await getUserTraits(user);
      if (keys == null) {
        return result;
      }
      if (keys.isEmpty) {
        return result;
      }
      return result.where((element) => keys.contains(element.key)).toList();
    } on DioError catch (e, _) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    }
    return [];
  }

  Future<List<Trait>> getUserTraits(FeatureUser user) async {
    var traitsList = <Trait>[];
    try {
      var params = {'identifier': user.identifier};
      var response = await _api.get<dynamic>('${config.identitiesURI}',
          queryParameters: params);

      if (response.statusCode == 200) {
        var data =
            FlagAndTraits.fromJson(response.data as Map<String, dynamic>);
        traitsList = data.traits ?? [];
      }
    } on DioError catch (e, _) {
      print(e.error);
    } on FormatException catch (e) {
      print(e.message);
    } on IOException catch (e) {
      print(e.toString());
    } finally {
      return traitsList;
    }
  }

  Future<Trait> updateTrait(FeatureUser user, Trait toUpdate) async {
    return postUserTraits(user, toUpdate);
  }

  Future<Trait> postUserTraits(FeatureUser user, Trait toUpdate) async {
    Trait updated;
    try {
      var trait = toUpdate.copyWith(identity: user);
      var response =
          await _api.post<dynamic>(config.traitsURI, data: trait.toJson());
      updated = Trait.fromJson(response.data as Map<String, dynamic>);
    } on DioError catch (e) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    } on IOException catch (e) {
      print(e);
    } finally {
      return updated;
    }
  }
}
