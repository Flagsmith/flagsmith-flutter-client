import '../flagsmith.dart';
import 'package:dio/dio.dart';

/// Default definition of connection to API
class FlagsmithConfig {
  final String baseURI;
  final String flagsURI;
  final String identitiesURI;
  final String traitsURI;

  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;

  final StoreType storeType;
  final String password;

  final bool isDebug;
  final bool caches;
  final bool isSelfSigned;

  /// Flagsmith config initialization
  /// change only if you have self-hosted Flagsmith
  /// [baseURI], [flagsURI], [identitiesURI], [traitsURI]
  ///
  /// Connection settings timeouts in milliseconds
  /// [connectionTimeout], [connectTimeout], [receiveTimeout], [sendTimeout]
  ///
  /// Storage
  ///
  /// default type of storage used by [FlagsmithClient] is [StoreType.inMemory].
  /// you can choose on of [StoreType.inMemory], [StoreType.persistant].
  ///
  /// if you want to see logs change [isDebug] to *true*
  /// for self hosted server without valid cert set [isSelfSigned] to *true*
  ///
  /// if you want to use caches [caches] to *true*

  const FlagsmithConfig(
      {this.baseURI = 'https://api.flagsmith.com/api/v1/',
      this.flagsURI = 'flags/',
      this.identitiesURI = 'identities/',
      this.traitsURI = 'traits/',
      this.connectTimeout = 10000,
      this.receiveTimeout = 20000,
      this.sendTimeout = 20000,
      this.storeType = StoreType.inMemory,
      this.password = 'flagsmith_sdk_secure',
      this.isDebug = false,
      this.caches = false,
      this.isSelfSigned = false});
      
  String get traitsBulkURI => '${traitsURI}bulk/';

  /// Client options from config
  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
}
