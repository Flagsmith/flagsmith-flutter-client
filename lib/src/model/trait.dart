import 'dart:convert';

import '../extensions/converters.dart';
import 'package:json_annotation/json_annotation.dart';

import 'identity.dart';
part 'trait.g.dart';

@JsonSerializable()
class Trait {
  final int? id;
  @JsonKey(name: 'trait_key')
  final String key;
  @JsonKey(
      name: 'trait_value',
      fromJson: nonNullStringFromJson,
      toJson: stringToJson)
  final String value;
  Trait({
    this.id,
    required this.key,
    required this.value,
  });
  factory Trait.fromJson(Map<String, dynamic> json) => _$TraitFromJson(json);

  Map<String, dynamic> toJson() => _$TraitToJson(this);
  String asString() => jsonEncode(toJson());
  Trait copyWith({
    int? id,
    String? key,  
    String? value,
  }) =>
      Trait(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );
}
@JsonSerializable()
class TraitWithIdentity {
  final Identity identity;
  @JsonKey(name: 'trait_key')
  final String key;
  @JsonKey(
      name: 'trait_value',
      fromJson: nonNullStringFromJson,
      toJson: stringToJson)
  final String value;
  
  TraitWithIdentity({
    required this.identity,
    required this.key,
    required this.value,
  });
factory TraitWithIdentity.fromJson(Map<String, dynamic> json) =>
      _$TraitWithIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$TraitWithIdentityToJson(this);
  String asString() => jsonEncode(toJson());
  TraitWithIdentity copyWith({
    Identity? identity,
    String? key,  
    String? value,
  }) =>
      TraitWithIdentity(
        identity: identity ?? this.identity,
        key: key ?? this.key,
        value: value ?? this.value,
      );
}
