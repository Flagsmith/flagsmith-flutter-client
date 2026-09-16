import 'package:json_annotation/json_annotation.dart';

part 'experiment.g.dart';

/// The running experiment a flag was evaluated under; identity evaluations only.
@JsonSerializable()
class Experiment {
  final int id;
  final String name;

  /// Whether the identity is enrolled. `variant` alone cannot tell.
  @JsonKey(name: 'in_experiment', defaultValue: false)
  final bool inExperiment;

  const Experiment({
    required this.id,
    required this.name,
    this.inExperiment = false,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) =>
      _$ExperimentFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentToJson(this);

  @override
  String toString() => 'Experiment($id:$name, inExperiment=$inExperiment)';
}

/// `metadata.experiment` -> [Experiment]; null when absent or malformed.
Experiment? experimentFromMetadata(Object? metadata) {
  if (metadata is! Map) {
    return null;
  }
  final experiment = metadata['experiment'];
  if (experiment is! Map) {
    return null;
  }
  try {
    return Experiment.fromJson(Map<String, dynamic>.from(experiment));
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? experimentToMetadata(Experiment? experiment) {
  if (experiment == null) {
    return null;
  }
  return <String, dynamic>{'experiment': experiment.toJson()};
}
