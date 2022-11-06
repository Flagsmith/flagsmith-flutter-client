import 'dart:convert';
import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:test/test.dart';

import '../shared.dart';

void main() {
  group('[Flag]', () {
    late String testValue, featureValue;
    setUp(() {
      featureValue = r'''{
        "id": 2,
        "name": "font_size",
        "created_date": "2018-06-04T12:51:18.646762Z",
        "initial_value": 10,
        "description": "test description",
        "type": "STANDARD",
        "project": 2
      }''';
      testValue = '''{
      "id": 2,
      "feature": {
        "id": 2,
        "name": "font_size",
        "created_date": "2018-06-04T12:51:18.646762Z",
        "initial_value": 10,
        "description": "test description",
        "type": "STANDARD",
        "project": 2
      },
      "feature_state_value": "10.1.0",
      "enabled": true,
      "environment": 2,
      "identity": 1
    }
    ''';
    });
    test('When flag is not empty, test values', () {
      var flag = Flag.fromJson(jsonDecode(testValue) as Map<String, dynamic>);
      expect(flag.stateValue, isNotNull);
      expect(flag.enabled, true);
      expect(flag.feature, isNotNull);
      expect(flag.feature.name, isNotNull);
      expect(flag.feature.description, isNotNull);
    });
    test('When feature successfuly parsed', () async {
      final _feature =
          Feature.fromJson(jsonDecode(featureValue) as Map<String, dynamic>);
      expect(_feature, isNotNull);
      expect(_feature.id, 2);
    });

    test('When flag successfuly parsed', () {
      var flag = Flag.fromJson(jsonDecode(testValue) as Map<String, dynamic>);
      final _flag = flag.asString();
      expect(_flag, isA<String>());
      expect(_flag, isNotNull);
      expect(_flag, isNotEmpty);
    });

    test('When flag value successfuly updated', () {
      var flag = Flag.fromJson(jsonDecode(testValue) as Map<String, dynamic>);
      final _feature = flag.feature.copyWith(initialValue: '12');
      final _flag = flag.copyWith(feature: _feature);

      expect(flag.feature.initialValue, '10');
      expect(_flag.feature.initialValue, '12');
      expect(flag.feature.initialValue, isNot(_flag.feature.initialValue));
    });

    test('When flag seed state is enabled', () {
      var flagDefault = Flag.seed('feature');

      expect(flagDefault.enabled, true);
      expect(flagDefault.feature, isNotNull);

      var flag = Flag.seed('feature');

      expect(flag.enabled, true);
      expect(flag.feature, isNotNull);
    });
    test('When flag seed state is disabled', () {
      var flag = Flag.seed('feature', enabled: false);
      expect(flag.enabled, false);
      expect(flag.feature, isNotNull);
    });
    test('When flag seed type is cofig', () {
      var flag = Flag.seed('feature', enabled: false, value: '1.0.0');
      expect(flag.enabled, false);
      expect(flag.feature, isNotNull);
      expect(flag.stateValue, isNotNull);
      expect(flag.stateValue, '1.0.0');
    });
  });

  group('[FlagAndTraits]', () {
    test('When response successfuly parsed', () {
      final identity = FlagsAndTraits.fromJson(
          jsonDecode(fakeIdentitiesResponse) as Map<String, dynamic>);
      expect(identity.flags, isNotEmpty);
      expect(identity.traits, isNotEmpty);

      final _converted = identity.toJson();
      expect(_converted, isNotNull);
      expect(_converted, isNotEmpty);

      final _copiedIdentity = identity.copyWith(flags: [], traits: []);
      expect(
          _copiedIdentity,
          const TypeMatcher<FlagsAndTraits>()
              .having((e) => e.flags, 'flags are empty', isEmpty)
              .having((e) => e.traits, 'traits are empty', isEmpty));
    });
  });
}
