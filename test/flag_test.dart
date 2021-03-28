import 'package:flagsmith/src/model/flag_type.dart';
import 'package:flagsmith/src/model/flag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('flag test', () {
    var testValue = '''{
      "id": 2,
      "feature": {
        "id": 2,
        "name": "font_size",
        "created_date": "2018-06-04T12:51:18.646762Z",
        "initial_value": 10,
        "description": "test description",
        "type": "CONFIG",
        "project": 2
      },
      "feature_state_value": "10.1.0",
      "enabled": true,
      "environment": 2,
      "identity": null
    }
    ''';

    var flag = Flag.fromJson(testValue);
    expect(flag.stateValue, isNotNull);
    expect(flag.enabled, true);
    expect(flag.feature, isNotNull);
    expect(flag.feature!.name, isNotNull);
    expect(flag.feature!.type, isNotNull);
    expect(flag.feature!.description, isNotNull);
  });

  test('flag seed - enabled', () {
    var flagDefault = Flag.seed('feature');

    expect(flagDefault.enabled, true);
    expect(flagDefault.feature, isNotNull);
    expect(flagDefault.feature!.type, FlagType.flag);

    var flag = Flag.seed('feature');

    expect(flag.enabled, true);
    expect(flag.feature, isNotNull);
    expect(flag.feature!.type, FlagType.flag);
  });
  test('flag seed - disabled', () {
    var flag = Flag.seed('feature', enabled: false);
    expect(flag.enabled, false);
    expect(flag.feature, isNotNull);
    expect(flag.feature!.type, FlagType.flag);
  });

  test('flag seed - cofig', () {
    var flag = Flag.seed('feature', enabled: false, value: '1.0.0');
    expect(flag.enabled, false);
    expect(flag.feature, isNotNull);
    expect(flag.feature!.type, FlagType.config);
    expect(flag.stateValue, isNotNull);
    expect(flag.stateValue, '1.0.0');
  });
}
