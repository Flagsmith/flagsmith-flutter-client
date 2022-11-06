import 'dart:convert';

import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:test/test.dart';

void main() {
  const identityId = '123-456-789';
  const traitStringValue = '''{
    "identity": {
      "identifier": "$identityId"
    },
    "trait_key": "trait_key",
    "trait_value": "value"
  }''';
  final decodedTraitStringValue =
      jsonDecode(traitStringValue) as Map<String, dynamic>;
  const traitNotStringValue = '''{
    "identity": {
      "identifier": "$identityId"
    },
    "trait_key": "trait_key",
    "trait_value": true
  }''';
  final decodedTraitNotStringValue =
      jsonDecode(traitNotStringValue) as Map<String, dynamic>;
  group('[TraitWithIdentity] - basic tests', () {
    test('When trait with identity parsed then success', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitStringValue);
      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
    });

    test('When trait with identity parsed with non string, then success', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitNotStringValue);
      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'true');
    });
  });

  group('[TraitWithIdentity] - converting', () {
    test('When trait with identity converted, then success', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitStringValue);

      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');

      final mapped = trait.asString();
      expect(mapped, isNotNull);
      expect(mapped.runtimeType, String);
    });
    test('When trait with identity converted to Map<String, dynamic>', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitStringValue);

      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');

      final mapped = trait.toJson();
      expect(mapped, isNotNull);
      expect(mapped['identity']['identifier'], identityId);
      expect(mapped['trait_key'], 'trait_key');
      expect(mapped['trait_value'], 'value');
    });
  });
  group('[TraitWithIdentity] - copyWith', () {
    test('When trait with identity updated then success', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitStringValue);

      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
      final updated = trait.copyWith(
          identity: const Identity(identifier: '13'),
          key: 'trait_key2',
          value: 'value2');

      expect(updated.identity.identifier, '13');
      expect(updated.key, 'trait_key2');
      expect(updated.value, 'value2');
    });
    test('When trait with identity not updated then success', () {
      final trait = TraitWithIdentity.fromJson(decodedTraitStringValue);

      expect(trait.identity.identifier, identityId);
      expect(trait.key, 'trait_key');
      expect(trait.value, 'value');
      final updated = trait.copyWith();

      expect(trait.identity.identifier, identityId);
      expect(updated.key, 'trait_key');
      expect(updated.value, 'value');
    });
  });
}
