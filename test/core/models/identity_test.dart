import 'package:flagsmith/flagsmith.dart';
import 'dart:convert';
import 'package:test/test.dart';

void main() {
  const identityId = '123-456-789';
  const identityJson = r'''{"identifier":"123-456-789"}''';
  const transientIdentityJson =
      r'''{"identifier":"123-456-789","transient":true}''';
  final decodedIdentityJson = jsonDecode(identityJson) as Map<String, dynamic>;
  final decodedTransientIdentityJson =
      jsonDecode(transientIdentityJson) as Map<String, dynamic>;
  // final malformedIdentityJson = '''{"identifier_bad_guy":"$identityId"}''';
  group('[Identity]', () {
    test('When identity response converted then success', () {
      final identity = Identity.fromJson(decodedIdentityJson);
      expect(identity.identifier, identityId);
    });
    test('When transient identity response converted then success', () {
      final identity = Identity.fromJson(decodedTransientIdentityJson);
      expect(identity.identifier, identityId);
      expect(identity.transient, true);
    });
  });

  group('[Identity] - copyWith', () {
    test('When identity updated then success', () {
      final identity = Identity.fromJson(decodedIdentityJson);
      expect(identity.identifier, identityId);

      final updated = identity.copyWith(identifier: 'newOne', transient: true);
      expect(updated.identifier, 'newOne');
      expect(updated.transient, true);
      expect(identity.hashCode, isNot(updated.hashCode));
    });
    test('When identity not updated then success', () {
      final identity = Identity.fromJson(decodedIdentityJson);
      expect(identity.identifier, identityId);

      final updated = identity.copyWith();

      expect(identity.identifier, identityId);
      expect(identity, isNot(updated));
    });
  });
}
