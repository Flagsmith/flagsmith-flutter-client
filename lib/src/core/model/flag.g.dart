// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'flag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flag _$FlagFromJson(Map<String, dynamic> json) => Flag(
      id: (json['id'] as num?)?.toInt(),
      feature: Feature.fromJson(json['feature'] as Map<String, dynamic>),
      stateValue: stringFromJson(json['feature_state_value']),
      enabled: json['enabled'] as bool?,
      environment: (json['environment'] as num?)?.toInt(),
      identity: (json['identity'] as num?)?.toInt(),
      featureSegment: (json['feature_segment'] as num?)?.toInt(),
      variant: json['variant'] as String?,
      reason: json['reason'] as String?,
      experiment: experimentFromMetadata(json['metadata']),
    );

Map<String, dynamic> _$FlagToJson(Flag instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'feature': instance.feature.toJson(),
    'feature_state_value': stringToJson(instance.stateValue),
    'enabled': instance.enabled,
    'environment': instance.environment,
    'identity': instance.identity,
    'feature_segment': instance.featureSegment,
    'variant': instance.variant,
    'reason': instance.reason,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('metadata', experimentToMetadata(instance.experiment));
  return val;
}
