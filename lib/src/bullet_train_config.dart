import 'package:dio/dio.dart';

class BulletTrainConfig {
  final int defaultConnectTimeout = 2000;
  final int defaultReceiveTimeout = 5000;
  final int defaultSendTimeout = 5000;
  final String defaultBaseUri = 'https://api.bullet-train.io/api/v1/';
  final String baseURI;
  final String flagsURI;
  final String identitiesURI;
  final String traitsURI;
  const BulletTrainConfig({
    this.baseURI,
    this.flagsURI = 'flags/',
    this.identitiesURI = 'identities/',
    this.traitsURI = 'traits/',
  });

  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI ?? defaultBaseUri,
        connectTimeout: defaultConnectTimeout,
        receiveTimeout: defaultReceiveTimeout,
        sendTimeout: defaultSendTimeout,
      );
}
