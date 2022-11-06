import 'dart:convert';

import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:test/test.dart';

void main() {
  const identityId = '123-456-789';
  const identityJson = r'''{"identifier":"123-456-789"}''';
  final decodedIdentityJson = jsonDecode(identityJson) as Map<String, dynamic>;
  // final malformedIdentityJson = '''{"identifier_bad_guy":"$identityId"}''';
  group('[Identity]', () {
    test('When identy response converted then success', () {
      final identity = Identity.fromJson(decodedIdentityJson);
      expect(identity.identifier, identityId);
    });
  });

  group('[Identity] - copyWith', () {
    test('When identity updated then success', () {
      final identity = Identity.fromJson(decodedIdentityJson);
      expect(identity.identifier, identityId);

      final updated = identity.copyWith(identifier: 'newOne');
      expect(updated.identifier, 'newOne');
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
