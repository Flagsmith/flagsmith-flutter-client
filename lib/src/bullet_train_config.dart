import 'package:dio/dio.dart';

class BulletTrainConfig {
  final String baseURI;
  final String flagsURI;
  final String identitiesURI;
  final String traitsURI;

  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;

  const BulletTrainConfig({
    this.baseURI = 'https://api.bullet-train.io/api/v1/',
    this.flagsURI = 'flags/',
    this.identitiesURI = 'identities/',
    this.traitsURI = 'traits/',
    this.connectTimeout = 2000,
    this.receiveTimeout = 5000,
    this.sendTimeout = 5000,
  });

  BaseOptions get clientOptions => BaseOptions(
        baseUrl: baseURI,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );
}
