import 'package:test/test.dart';
import 'package:flagsmith_flutter_core/src/extensions/string_ext.dart';

void main() {
  group('[Futures]', () {
    test('When value is normalized then success', () {
      var testValue = 'test String';
      var normalized = testValue.normalize();
      expect(normalized, 'test_string');
    });

    test('When value was not trimed, then normalize', () {
      var testValue = ' _testStri ng';
      var normalized = testValue.normalize();
      expect(normalized, '_teststri_ng');
    });
  });
}
