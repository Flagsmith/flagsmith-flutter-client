import 'dart:convert';

import 'package:bullet_train/src/model/flag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flag test', (){
    var testValue = '''{
      "id": 2,
      "feature": {
        "id": 2,
        "name": "font_size",
        "created_date": "2018-06-04T12:51:18.646762Z",
        "initial_value": "10",
        "description": "test description",
        "type": "CONFIG",
        "project": 2
      },
      "feature_state_value": "10",
      "enabled": true,
      "environment": 2,
      "identity": null
    }
    ''';
    var data = jsonDecode(testValue.toString()) as Map<String, dynamic>;
    var flag = Flag.fromJson(data);
    expect(flag.stateValue, isNotNull);
    expect(flag.enabled, true);
    expect(flag.feature, isNotNull);
    expect(flag.feature.name, isNotNull);
    expect(flag.feature.type, isNotNull);
    expect(flag.feature.description, isNotNull);
  });
}
