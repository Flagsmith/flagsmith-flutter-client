import 'package:json_annotation/json_annotation.dart';

part 'experiment_metadata.g.dart';

/// The running experiment a flag was evaluated under; identity evaluations only.
@JsonSerializable()
class ExperimentMetadata {
  final int id;
  final String name;

  /// Whether the identity is enrolled. `variant` alone cannot tell.
  @JsonKey(name: 'in_experiment', defaultValue: false)
  final bool inExperiment;

  const ExperimentMetadata({
    required this.id,
    required this.name,
    this.inExperiment = false,
  });

  factory ExperimentMetadata.fromJson(Map<String, dynamic> json) =>
      _$ExperimentMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentMetadataToJson(this);

  @override
  String toString() =>
      'ExperimentMetadata($id:$name, inExperiment=$inExperiment)';
}

/// `metadata.experiment` -> [ExperimentMetadata]; null when absent or malformed.
ExperimentMetadata? experimentFromMetadata(Object? metadata) {
  if (metadata is! Map) {
    return null;
  }
  final experiment = metadata['experiment'];
  if (experiment is! Map) {
    return null;
  }
  try {
    return ExperimentMetadata.fromJson(Map<String, dynamic>.from(experiment));
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? experimentToMetadata(ExperimentMetadata? experiment) {
  if (experiment == null) {
    return null;
  }
  return <String, dynamic>{'experiment': experiment.toJson()};
}
