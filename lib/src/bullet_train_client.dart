import 'package:bullet_train/src/bullet_train_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'model/feature_user.dart';
import 'model/flag.dart';
import 'model/trait.dart';
import 'store/crud_store.dart';
import 'store/in_memory_store.dart';

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
  /// @param user a user in context
  /// @return a list of feature flags
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
        }
      } else {
        var response = await _api
            .get<List<dynamic>>('${config.flagsURI}${'/${user.identifier}'}');

        if (response.statusCode == 200) {
          var list = response.data
              // ignore: lines_longer_than_80_chars
              .map<Flag>(
                  (dynamic e) => Flag.fromJson(e as Map<String, dynamic>))
              .toList();
          list.map(store.create);
          return list;
        }
        print(response);
      }
    } on DioError catch (e) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    }

    return [];
  }

  /// Check if Feature flag exist and is enabled
  ///
  /// @param featureId an identifier for the feature
  /// @return true if feature flag exist and enabled, false otherwise
  Future<bool> hasFeatureFlag(String featureId, {FeatureUser user}) async {
    try {
      var features = await getFeatureFlags(user: user);
      var feature = features.firstWhere(
          (element) =>
              element.feature.name == featureId && element.enabled == true,
          orElse: null);
      return feature != null;
    } on DioError catch (e, s) {} on FormatException catch (e) {
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
          orElse: null);
      return feature?.stateValue.toString();
    } on DioError catch (e, s) {} on FormatException catch (e) {
      print(e);
    }
    return null;
  }

  Future<Trait> getTrait(FeatureUser user, String key) async {
    try {
      var result = await getUserTraits(user);
      return result.firstWhere((element) => element.key == key);
    } on DioError catch (e, s) {} on FormatException catch (e) {
      print(e);
    }
    return null;
  }

  Future<List<Trait>> getTraits(FeatureUser user, List<String> keys) async {
    try {
      var result = await getUserTraits(user);
      if (keys.isEmpty) {
        return result;
      }
      return result.where((element) => keys.contains(element.key)).toList();
    } on DioError catch (e, s) {} on FormatException catch (e) {
      print(e);
    }
    return [];
  }

  Future<List<Trait>> getUserTraits(FeatureUser user) async {
    try {
      var response = await _api.get<List<dynamic>>(
          '${config.identitiesURI}${'/${user.identifier}'}');

      if (response.statusCode == 200) {
        var list = response.data
            .map<Trait>(
                (dynamic e) => Trait.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      print(response);
    } on DioError catch (e, s) {} on FormatException catch (e) {
      print(e);
    }
    return [];
  }

  Future<Trait> updateTrait(FeatureUser user, Trait toUpdate) async {
    return postUserTraits(user, toUpdate);
  }

  Future<Trait> postUserTraits(FeatureUser user, Trait toUpdate) async {
    try {
      var trait = toUpdate.copyWith(identity: user);
      var response =
          await _api.post<dynamic>(config.traitsURI, data: trait.toJson());
      print(response);
    } on DioError catch (e) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    }
    return null;
  }
}
