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

  group('[Experiment]', () {
    Map<String, dynamic> flagJson({Object? metadata, bool withKey = true}) =>
        <String, dynamic>{
          'id': 7,
          'feature': {'id': 7, 'name': 'checkout_cta'},
          'enabled': true,
          'feature_state_value': 'buy-now',
          'variant': 'treatment-a',
          'reason': 'SPLIT; weight=50',
          if (withKey) 'metadata': metadata,
        };

    test('When metadata.experiment present, then experiment is populated', () {
      final flag = Flag.fromJson(flagJson(metadata: {
        'experiment': {
          'id': 42,
          'name': 'New checkout CTA',
          'in_experiment': true
        }
      }));
      expect(flag.variant, 'treatment-a');
      expect(flag.reason, 'SPLIT; weight=50');
      expect(flag.experiment, isNotNull);
      expect(flag.experiment!.id, 42);
      expect(flag.experiment!.name, 'New checkout CTA');
      expect(flag.experiment!.inExperiment, isTrue);
    });

    test('When in_experiment false, then inExperiment is false', () {
      final flag = Flag.fromJson(flagJson(metadata: {
        'experiment': {'id': 42, 'name': 'x', 'in_experiment': false}
      }));
      expect(flag.experiment!.inExperiment, isFalse);
    });

    test('When metadata absent or null, then experiment is null', () {
      expect(Flag.fromJson(flagJson(withKey: false)).experiment, isNull);
      expect(Flag.fromJson(flagJson(metadata: null)).experiment, isNull);
    });

    test('When metadata has only unknown keys, then experiment is null', () {
      final flag = Flag.fromJson(flagJson(metadata: {
        'something_else': {'id': 1}
      }));
      expect(flag.experiment, isNull);
    });

    test('When experiment is malformed, then parsing still succeeds', () {
      final flag = Flag.fromJson(flagJson(metadata: {
        'experiment': {'name': 'missing id'}
      }));
      expect(flag.experiment, isNull);
      expect(flag.variant, 'treatment-a');
    });

    test('When old server omits variant and reason, then both are null', () {
      final flag = Flag.fromJson(<String, dynamic>{
        'feature': {'id': 7, 'name': 'checkout_cta'},
        'enabled': true,
        'feature_state_value': null,
      });
      expect(flag.variant, isNull);
      expect(flag.reason, isNull);
      expect(flag.experiment, isNull);
      expect(flag.toJson().containsKey('metadata'), isFalse);
    });

    test('When flag round-trips through toJson, then experiment survives', () {
      final original = Flag.fromJson(flagJson(metadata: {
        'experiment': {
          'id': 42,
          'name': 'New checkout CTA',
          'in_experiment': true
        },
        'unknown_key': 1,
      }));
      final json = original.toJson();
      expect(json['metadata'], {
        'experiment': {
          'id': 42,
          'name': 'New checkout CTA',
          'in_experiment': true
        }
      });

      final restored = Flag.fromJson(jsonDecode(jsonEncode(json)));
      expect(restored.variant, original.variant);
      expect(restored.reason, original.reason);
      expect(restored.experiment!.id, 42);
      expect(restored.experiment!.name, 'New checkout CTA');
      expect(restored.experiment!.inExperiment, isTrue);
    });

    test('When copyWith sets experiment, then other fields are kept', () {
      final flag = Flag.fromJson(flagJson(withKey: false));
      final copy = flag.copyWith(
          experiment:
              const ExperimentMetadata(id: 1, name: 'e', inExperiment: true));
      expect(copy.experiment!.id, 1);
      expect(copy.variant, 'treatment-a');
      expect(flag.experiment, isNull);
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
