// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Feature _$_$_FeatureFromJson(Map<String, dynamic> json) {
  return _$_Feature(
    id: json['id'] as int,
    name: json['name'] as String,
    createDate: json['created_date'] == null
        ? null
        : DateTime.parse(json['created_date'] as String),
    type: _$enumDecodeNullable(_$FlagTypeEnumMap, json['type']),
    description: json['description'] as String ?? '',
  );
}

Map<String, dynamic> _$_$_FeatureToJson(_$_Feature instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_date': instance.createDate?.toIso8601String(),
      'type': _$FlagTypeEnumMap[instance.type],
      'description': instance.description,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$FlagTypeEnumMap = {
  FlagType.config: 'CONFIG',
  FlagType.flag: 'FLAG',
};
