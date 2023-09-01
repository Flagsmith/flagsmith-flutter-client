import '../flagsmith.dart';
import 'package:dio/dio.dart';

/// Default definition of connection to API
class FlagsmithConfig {
  final String baseURI;
  final String flagsURI;
  final String identitiesURI;
  final String traitsURI;
  final String analyticsURI;

  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;

  final StorageType storageType;
  final String password;

  final bool isDebug;
  final bool caches;
  final bool enableAnalytics;
  final int analyticsInterval;

  final bool enableRealtimeUpdates;
  final String realtimeUpdatesBaseURI;
  final int reconnectToSSEInterval;

  /// Flagsmith config initialization
  /// change only if you have self-hosted Flagsmith
  /// [baseURI], [flagsURI], [identitiesURI], [traitsURI], [analyticsURI]
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
  /// for self hosted server without valid cert use [Proxy](https://github.com/flutterchina/dio/blob/ee4d55d6fdb3d0658246460fe59567645a287ce4/README.md#using-proxy)
  ///
  /// if you want to use caches [caches] to *true*
  ///
  /// Analytics is enabled by default, to disable analytics set [enableAnalytics] to *false*
  ///
  /// The [analyticsInterval] is how often the analytics will be pushed to the server in milliseconds, defaults to 10000 (10 seconds)
  ///
  /// If you would like to use realtime updates, set [enableRealtimeUpdates] to *true*
  ///
  /// You can configure the realtime updates source URL by setting the [realtimeUpdatesBaseURI] parameter

  const FlagsmithConfig({
    this.baseURI = 'https://api.flagsmith.com/api/v1/',
    this.flagsURI = 'flags/',
    this.identitiesURI = 'identities/',
    this.traitsURI = 'traits/',
    this.analyticsURI = 'analytics/flags/',
    this.connectTimeout = 10000,
    this.receiveTimeout = 20000,
    this.sendTimeout = 20000,
    this.storageType = StorageType.inMemory,
    this.password = 'flagsmith_sdk_secure',
    this.isDebug = false,
    this.caches = false,
    this.enableAnalytics = true,
    this.analyticsInterval = 10000,
    this.enableRealtimeUpdates = false,
    this.realtimeUpdatesBaseURI =
        'https://realtime.flagsmith.com/sse/environments/',
    this.reconnectToSSEInterval = 30000,
  });

  /// Client options from config
  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        sendTimeout: Duration(milliseconds: sendTimeout),
      );
}
