// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'trait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Trait _$_$_TraitFromJson(Map<String, dynamic> json) {
  return _$_Trait(
    identity: json['identity'] == null
        ? null
        : FeatureUser.fromJson(json['identity'] as Map<String, dynamic>),
    key: json['trait_key'] as String,
    value: json['trait_value'] as String,
  );
}

Map<String, dynamic> _$_$_TraitToJson(_$_Trait instance) => <String, dynamic>{
      'identity': instance.identity?.toJson(),
      'trait_key': instance.key,
      'trait_value': instance.value,
    };
