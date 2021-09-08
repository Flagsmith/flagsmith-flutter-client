import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'identity.g.dart';

/// Personalized user
@JsonSerializable()
class Identity {
  final String identifier;
  const Identity({
    required this.identifier,
  });

  factory Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityToJson(this);
  String asString() => jsonEncode(toJson());
  Identity copyWith({String? identifier}) =>
      Identity(identifier: identifier ?? this.identifier);
}
