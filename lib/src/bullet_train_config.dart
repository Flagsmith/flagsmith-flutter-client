import '../bullet_train.dart';
import 'package:dio/dio.dart';

/// Default definition of connection to API
class BulletTrainConfig {
  final String baseURI;
  final String flagsURI;
  final String identitiesURI;
  final String traitsURI;

  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;

  final String storePath;
  final StoreType storeType;

  /// Bullet train config initialization
  /// change only if you have self-hosted bullet train
  /// [baseURI], [flagsURI], [identitiesURI], [traitsURI]
  ///
  /// Connection settings timeouts in milliseconds
  /// [connectionTimeout], [connectTimeout], [receiveTimeout], [sendTimeout]
  ///
  /// Storage
  ///
  /// default type of storage used by [BulletTrainClient] is [StoreType.inMemory].
  /// you can choose on of [StoreType.inMemory], [StoreType.prefs] and [StoreType.sembast].
  /// for [StoreType.sembast] must by defined [storePath] where should be db file stored.

  const BulletTrainConfig(
      {this.baseURI = 'https://api.bullet-train.io/api/v1/',
      this.flagsURI = 'flags/',
      this.identitiesURI = 'identities/',
      this.traitsURI = 'traits/',
      this.connectTimeout = 2000,
      this.receiveTimeout = 5000,
      this.sendTimeout = 5000,
      this.storeType = StoreType.inMemory,
      this.storePath = ''});

  /// Client options from config
  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
}
