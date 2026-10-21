import 'dart:convert';

import '../extensions/converters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';

import 'experiment_metadata.dart';
import 'feature.dart';
part 'flag.g.dart';

@JsonSerializable()
class Flag {
  final int? id;
  final Feature feature;
  @JsonKey(
      name: 'feature_state_value',
      fromJson: stringFromJson,
      toJson: stringToJson)
  final String? stateValue;

  /// The flag's value with its JSON type: a String, num, bool or null.
  /// Falls back to [stateValue] when the flag was not parsed from JSON.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Object? value;
  final bool? enabled;
  final int? environment;
  final int? identity;
  @JsonKey(name: 'feature_segment')
  final int? featureSegment;

  final String? variant;
  final String? reason;

  /// Lifted from `metadata.experiment`; null unless an experiment is running.
  @JsonKey(
      name: 'metadata',
      fromJson: experimentFromMetadata,
      toJson: experimentToMetadata,
      includeIfNull: false)
  final ExperimentMetadata? experiment;
  Flag(
      {this.id,
      required this.feature,
      this.stateValue,
      Object? value,
      this.enabled,
      this.environment,
      this.identity,
      this.featureSegment,
      this.variant,
      this.reason,
      this.experiment})
      : value = value ?? stateValue;

  String get key => feature.name;
  @override
  String toString() {
    return 'F(${feature.name}:$enabled)';
  }

  static int _generateNum(int min, int max) =>
      min + Random().nextInt(max - min);
  factory Flag.named(
          {int? id,
          required Feature feature,
          String? stateValue,
          Object? value,
          bool? enabled,
          int? environment,
          int? identity,
          int? featureSegment,
          String? variant,
          String? reason,
          ExperimentMetadata? experiment}) =>
      Flag(
        id: id,
        feature: feature,
        stateValue: stateValue,
        value: value,
        enabled: enabled,
        environment: environment,
        identity: identity,
        featureSegment: featureSegment,
        variant: variant,
        reason: reason,
        experiment: experiment,
      );
  factory Flag.seed(String featureName, {bool enabled = true, String? value}) {
    var id = _generateNum(1, 100);

    return Flag.named(
        id: id,
        stateValue: value,
        feature: Feature.named(
          id: id,
          name: featureName,
          createdDate: DateTime.now().add(
            Duration(days: _generateNum(0, 10)),
          ),
          initialValue: '',
          defaultValue: false,
        ),
        enabled: enabled);
  }

  factory Flag.fromJson(Map<String, dynamic> json) =>
      _$FlagFromJson(json).copyWith(value: json['feature_state_value']);

  /// Writes [value] with its type, so that [Flag.fromJson] restores it.
  Map<String, dynamic> toJson() =>
      _$FlagToJson(this)..['feature_state_value'] = value;
  String asString() => jsonEncode(toJson());

  Flag copyWith(
          {int? id,
          Feature? feature,
          String? stateValue,
          Object? value,
          bool? enabled,
          int? environment,
          int? identity,
          int? featureSegment,
          String? variant,
          String? reason,
          ExperimentMetadata? experiment}) =>
      Flag(
        id: id ?? this.id,
        feature: feature ?? this.feature,
        stateValue: stateValue ?? this.stateValue,
        // A new stateValue without a value replaces the old value too.
        value: value ?? (stateValue == null ? this.value : null),
        enabled: enabled ?? this.enabled,
        environment: environment ?? this.environment,
        identity: identity ?? this.identity,
        featureSegment: featureSegment ?? this.featureSegment,
        variant: variant ?? this.variant,
        reason: reason ?? this.reason,
        experiment: experiment ?? this.experiment,
      );
}
