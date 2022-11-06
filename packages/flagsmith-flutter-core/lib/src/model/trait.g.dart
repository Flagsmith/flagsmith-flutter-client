// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'trait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trait _$TraitFromJson(Map<String, dynamic> json) {
  return Trait(
    id: json['id'] as int?,
    key: json['trait_key'] as String,
    value: nonNullStringFromJson(json['trait_value']),
  );
}

Map<String, dynamic> _$TraitToJson(Trait instance) => <String, dynamic>{
      'id': instance.id,
      'trait_key': instance.key,
      'trait_value': stringToJson(instance.value),
    };

TraitWithIdentity _$TraitWithIdentityFromJson(Map<String, dynamic> json) {
  return TraitWithIdentity(
    identity: Identity.fromJson(json['identity'] as Map<String, dynamic>),
    key: json['trait_key'] as String,
    value: nonNullStringFromJson(json['trait_value']),
  );
}

Map<String, dynamic> _$TraitWithIdentityToJson(TraitWithIdentity instance) =>
    <String, dynamic>{
      'identity': instance.identity.toJson(),
      'trait_key': instance.key,
      'trait_value': stringToJson(instance.value),
    };
