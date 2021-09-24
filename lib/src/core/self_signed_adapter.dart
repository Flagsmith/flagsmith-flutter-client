import 'package:dio/adapter.dart';

/// Self Signed adapter
/// - adapter for accepting self signed certificate
class SelfSignedHttpClientAdapter extends DefaultHttpClientAdapter {
  SelfSignedHttpClientAdapter() {
    onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }
}
