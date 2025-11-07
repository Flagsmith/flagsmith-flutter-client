import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';
import '../shared.dart';

void main() {
  late FlagsmithClient fs;

  group('[User-Agent Header]', () {
    setUp(() async {
      fs = await setupClientAdapter(
        StorageType.inMemory,
        isDebug: false,
      );
    });

    tearDown(() {
      fs.close();
    });

    test('Should set User-Agent header with correct SDK version', () {
      // x-release-please-start-version
      final expectedVersion = '6.1.0';
      // x-release-please-end
      
      final userAgent = fs.client.options.headers[FlagsmithClient.userAgentHeader];
      final expectedUserAgent = 'flagsmith-flutter-sdk/$expectedVersion';
      
      expect(userAgent, isNotNull, reason: 'User-Agent header should be set');
      expect(userAgent, equals(expectedUserAgent), 
        reason: 'User-Agent should be flagsmith-flutter-sdk/$expectedVersion');
    });
  });
}
