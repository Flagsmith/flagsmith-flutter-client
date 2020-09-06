import 'package:dio/dio.dart';

import '../../bullet_train.dart';

class TokenInterceptor extends Interceptor {
  String apiKey;
  TokenInterceptor(this.apiKey)
      : assert(apiKey != null, 'Missing Bullet-train.io apiKey');

  @override
  Future onRequest(RequestOptions options) async {
    options.headers.putIfAbsent(BulletTrainClient.authHeader, () => apiKey);
    return super.onRequest(options);
  }
}
