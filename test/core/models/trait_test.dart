import 'package:flagsmith/flagsmith.dart';
import 'dart:convert';
import 'package:test/test.dart';

void main() {
  const traitStringValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": "value"
  }''';
  final decodedTraitStringValue =
      jsonDecode(traitStringValue) as Map<String, dynamic>;

  const traitBoolValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": true
  }''';
  final decodedTraitBoolValue =
      jsonDecode(traitBoolValue) as Map<String, dynamic>;
  const traitIntValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": 1
  }''';
  final decodedTraitIntValue =
      jsonDecode(traitIntValue) as Map<String, dynamic>;
  const traitDoubleValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": 10.1
  }''';
  final decodedTraitDoubleValue =
      jsonDecode(traitDoubleValue) as Map<String, dynamic>;
  const transientTraitValue = '''{
    "id": 12,
    "trait_key": "trait_key",
    "trait_value": "transient",
    "transient": true
  }''';
  final decodedTransientTraitValue =
      jsonDecode(transientTraitValue) as Map<String, dynamic>;

  group('[Trait] - basic tests', () {
    test('When trait parsed then success', () {
      final trait = Trait.fromJson(decodedTraitStringValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
    });

    test('When trait parsed with bool value then success', () {
      final trait = Trait.fromJson(decodedTraitBoolValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, true);
    });
    test('When trait parsed with int value then success', () {
      final trait = Trait.fromJson(decodedTraitIntValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 1);
    });

    test('When trait parsed with double value then success', () {
      final trait = Trait.fromJson(decodedTransientTraitValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'transient');
      expect(trait.transient, true);
    });

    test('When transient trait parsed then success', () {
      final trait = Trait.fromJson(decodedTraitDoubleValue);
      expect(trait.id, 12);
      expect(trait.key, 'trait_key');
      expect(trait.value, 10.1);
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

  group('toJson', () {
    test(
        'When trait with int value converted to Map<String, dynamic> then success',
        () {
      final trait = Trait(
        id: 12,
        key: 'trait_key',
        value: 42,
      );

      final mapped = trait.toJson();

      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 42);
    });

    test(
        'When trait with string value converted to Map<String, dynamic> then success',
        () {
      final trait = Trait(
        id: 12,
        key: 'trait_key',
        value: 'trait_value',
      );

      final mapped = trait.toJson();

      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 'trait_value');
    });

    test(
        'When trait with double value converted to Map<String, dynamic> then success',
        () {
      final trait = Trait(
        id: 12,
        key: 'trait_key',
        value: 3.14,
      );

      final mapped = trait.toJson();

      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 3.14);
    });

    test(
        'When trait with bool value converted to Map<String, dynamic> then success',
        () {
      final trait = Trait(
        id: 12,
        key: 'trait_key',
        value: true,
      );

      final mapped = trait.toJson();

      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], true);
    });

    test('When transient trait converted to Map<String, dynamic> then success',
        () {
      final trait = Trait(
        id: 12,
        key: 'trait_key',
        value: 'transient',
        transient: true,
      );

      final mapped = trait.toJson();

      expect(mapped, isNotNull);
      expect(mapped['id'], 12);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 'transient');
      expect(mapped['transient'], true);
    });
  });
}
