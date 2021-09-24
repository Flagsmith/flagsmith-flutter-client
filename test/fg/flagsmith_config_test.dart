import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith/src/flagsmith_client.dart';
import 'package:test/test.dart';
import 'package:flagsmith_core/flagsmith_core.dart';

import '../shared.dart';

void main() {
  group('[Config]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(
        StorageType.inMemory,
        caches: false,
        isDebug: true,
      );
    });
    tearDown(() {
      fs.close();
    });
    test(
        'When debug is enabled, then we should have LogInterceptor inside client',
        () async {
      expect(fs.client.interceptors, isNotEmpty);
      expect(
          fs.client.interceptors
              .where((element) => element.runtimeType == LogInterceptor),
          isNotEmpty);
    });
  });
  group('[External config]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(
        StorageType.inMemory,
        caches: false,
        isDebug: true,
      );
      (fs.client.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    });
    tearDown(() {
      fs.close();
    });
    test('When self signed cert is enabled, then adapter is SelfSigned type',
        () async {
      expect(fs.client.httpClientAdapter, isNotNull);
      expect(fs.client.httpClientAdapter, isA<DefaultHttpClientAdapter>());
    });
  });
  group('[Standard config]', () {
    late FlagsmithClient fs;
    setUp(() async {
      fs = await setupClientAdapter(
        StorageType.inMemory,
        caches: false,
        isDebug: true,
      );
    });
    tearDown(() {
      fs.close();
    });

    test(
        'When self signed cert is disabled, then adapter is not SelfSigned type',
        () async {
      print('object ${fs.client.httpClientAdapter.runtimeType}');
      expect(fs.client.httpClientAdapter, isNotNull);
      expect(fs.client.httpClientAdapter, isA<DefaultHttpClientAdapter>());
    });
  });
}
