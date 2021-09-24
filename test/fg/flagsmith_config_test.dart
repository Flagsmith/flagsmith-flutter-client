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
      fs = await setupClientAdapter(StorageType.inMemory,
          caches: false, isDebug: true, isSelfSigned: true);
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
    test('When self signed cert is enabled, then adapter is SelfSigned type',
        () async {
      expect(fs.client.httpClientAdapter, isNotNull);
      expect(fs.client.httpClientAdapter, isA<SelfSignedHttpClientAdapter>());
    });
    test(
        'When self signed cert is disabled, then adapter is not SelfSigned type',
        () async {
      fs = await setupClientAdapter(StorageType.inMemory, isSelfSigned: false);

      expect(fs.client.httpClientAdapter, isNotNull);
      expect(fs.client.httpClientAdapter, isA<DefaultHttpClientAdapter>());
    });
  });
}
