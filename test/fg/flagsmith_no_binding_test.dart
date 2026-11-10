import 'package:flagsmith/flagsmith.dart';
import 'package:test/test.dart';

import '../shared.dart';

// Own file so the Flutter binding is never initialised in this isolate.
void main() {
  test('When client is created before the Flutter binding, then it works',
      () async {
    final fs = FlagsmithClient(
        apiKey: apiKey, config: const FlagsmithConfig(enableEvents: true));

    await expectLater(fs.close(), completes);
  });
}
