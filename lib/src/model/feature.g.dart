// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feature _$FeatureFromJson(Map<String, dynamic> json) {
  return Feature(
    id: json['id'] as int?,
    name: json['name'] as String,
    createdDate: json['created_date'] == null
        ? null
        : DateTime.parse(json['created_date'] as String),
    initialValue: stringFromJson(json['initial_value']),
    defaultValue: json['default_enabled'] as bool?,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_date': instance.createdDate?.toIso8601String(),
      'initial_value': stringToJson(instance.initialValue),
      'default_enabled': instance.defaultValue,
      'description': instance.description,
    };
