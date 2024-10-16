import 'package:flagsmith/flagsmith.dart';
import 'dart:convert';
import 'package:test/test.dart';

import '../../shared.dart';

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
      final feature =
          Feature.fromJson(jsonDecode(featureValue) as Map<String, dynamic>);
      expect(feature, isNotNull);
      expect(feature.id, 2);
    });

    test('When flag successfuly parsed', () {
      var flag = Flag.fromJson(jsonDecode(testValue) as Map<String, dynamic>);
      final flag0 = flag.asString();
      expect(flag0, isA<String>());
      expect(flag0, isNotNull);
      expect(flag0, isNotEmpty);
    });

    test('When flag value successfuly updated', () {
      var flag = Flag.fromJson(jsonDecode(testValue) as Map<String, dynamic>);
      final feature = flag.feature.copyWith(initialValue: '12');
      final flag0 = flag.copyWith(feature: feature);

      expect(flag.feature.initialValue, '10');
      expect(flag0.feature.initialValue, '12');
      expect(flag.feature.initialValue, isNot(flag0.feature.initialValue));
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
          jsonDecode(identitiesResponseData) as Map<String, dynamic>);
      expect(identity.flags, isNotEmpty);
      expect(identity.traits, isNotEmpty);

      final converted = identity.toJson();
      expect(converted, isNotNull);
      expect(converted, isNotEmpty);

      final copiedIdentity = identity.copyWith(flags: [], traits: []);
      expect(
          copiedIdentity,
          const TypeMatcher<FlagsAndTraits>()
              .having((e) => e.flags, 'flags are empty', isEmpty)
              .having((e) => e.traits, 'traits are empty', isEmpty));
    });
  });
}
