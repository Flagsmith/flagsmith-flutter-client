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

  final bool usePersistantStorage;
  final String persistantDatabasePath;

  /// Bullet train config initialization
  /// change only if you have self-hosted bullet train
  /// [baseURI], [flagsURI], [identitiesURI], [traitsURI]
  ///
  /// Connection settings timeouts in milliseconds
  /// [connectionTimeout], [connectTimeout], [receiveTimeout], [sendTimeout]
  ///
  /// Persistent Storage
  ///
  /// if you want to use Persistent storage, change [usePersistantStorage] to true
  /// and add [persistantDatabasePath]

  const BulletTrainConfig(
      {this.baseURI = 'https://api.bullet-train.io/api/v1/',
      this.flagsURI = 'flags/',
      this.identitiesURI = 'identities/',
      this.traitsURI = 'traits/',
      this.connectTimeout = 2000,
      this.receiveTimeout = 5000,
      this.sendTimeout = 5000,
      this.usePersistantStorage = false,
      this.persistantDatabasePath});

  /// Client options from config
  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
}
