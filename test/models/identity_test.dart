import 'dart:convert';

import 'package:flagsmith/src/model/identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final identityId = '123-456-789';
  final identityJson = r'''{"identifier":"123-456-789"}''';
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
