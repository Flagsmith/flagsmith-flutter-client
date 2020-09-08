// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'flag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Flag _$_$_FlagFromJson(Map<String, dynamic> json) {
  return _$_Flag(
    id: json['id'] as int,
    feature: json['feature'] == null
        ? null
        : Feature.fromJson(json['feature'] as Map<String, dynamic>),
    stateValue: stringFromInt(json['feature_state_value']),
    enabled: json['enabled'] as bool,
  );
}

Map<String, dynamic> _$_$_FlagToJson(_$_Flag instance) => <String, dynamic>{
      'id': instance.id,
      'feature': instance.feature?.toJson(),
      'feature_state_value': instance.stateValue,
      'enabled': instance.enabled,
    };
