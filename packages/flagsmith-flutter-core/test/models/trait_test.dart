import 'dart:convert';

import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:test/test.dart';

void main() {
  const traitStringValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": "value"
  }''';
  final decodedTraitStringValue =
      jsonDecode(traitStringValue) as Map<String, dynamic>;
  const traitNotStringValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": true
  }''';
  final decodedTraitNotStringValue =
      jsonDecode(traitNotStringValue) as Map<String, dynamic>;
  group('[Trait] - basic tests', () {
    test('When trait parsed then success', () {
      final trait = Trait.fromJson(decodedTraitStringValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
    });

    test('When trait parsed with bool value then success', () {
      final trait = Trait.fromJson(decodedTraitNotStringValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'true');
    });
  });

  group('[Trait] - converting', () {
    test('When trait parsed & converted then success', () {
      final trait = Trait.fromJson(decodedTraitStringValue);

      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');

      final mapped = trait.asString();
      expect(mapped, isNotNull);
      expect(mapped.runtimeType, String);
    });
    test('When trait converted to Map<String, dynamic> then success ', () {
      final trait = Trait.fromJson(decodedTraitStringValue);

      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');

      final mapped = trait.toJson();
      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 'value');
    });
  });
  group('[Trait] - copyWith', () {
    test('as a developer want to use with new data', () {
      final trait = Trait.fromJson(decodedTraitStringValue);

      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
      final updated =
          trait.copyWith(id: 13, key: 'trait_key2', value: 'value2');

      expect(updated.id, 13);
      expect(updated.key, 'trait_key2');
      expect(updated.value, 'value2');
    });
    test('as a developer want to use copyWith same data', () {
      final trait = Trait.fromJson(decodedTraitStringValue);

      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
      final updated = trait.copyWith();

      expect(updated.id, 12);
      expect(updated.key, 'trait_key');
      expect(updated.value, 'value');
    });
  });
}
