// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'experiment_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentMetadata _$ExperimentMetadataFromJson(Map<String, dynamic> json) =>
    ExperimentMetadata(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      inExperiment: json['in_experiment'] as bool? ?? false,
    );

Map<String, dynamic> _$ExperimentMetadataToJson(ExperimentMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'in_experiment': instance.inExperiment,
    };
