import 'dart:convert';

import '../extensions/converters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';

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
  final bool? enabled;
  final int? environment;
  final int? identity;
  @JsonKey(name: 'feature_segment')
  final int? featureSegment;
  Flag(
      {
    this.id,
    required this.feature,
    this.stateValue,
    this.enabled,
    this.environment,
    this.identity,
    this.featureSegment
  });

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
          bool? enabled,
          int? environment,
          int? identity,
          int? featureSegment}) =>
      Flag(
        id: id,
        feature: feature,
        stateValue: stateValue,
        enabled: enabled,
        environment: environment,
        identity: identity,
        featureSegment: featureSegment,
      );
  factory Flag.seed(String featureName, {bool enabled = true, String? value}) {
    var id = _generateNum(1, 100);

    return Flag.named(
        id: id,
        stateValue: value,
        feature: Feature.named(
            id: id,
            name: featureName,
            createdDate:
                DateTime.now().add(
            Duration(days: _generateNum(0, 10)),
          ),
          initialValue: '',
          defaultValue: false,
        ),
        enabled: enabled);
  }

  factory Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);

  Map<String, dynamic> toJson() => _$FlagToJson(this);
  String asString() => jsonEncode(toJson());

  Flag copyWith(
          {int? id,
          Feature? feature,
          String? stateValue,
          bool? enabled,
          int? environment,
          int? identity,
          int? featureSegment}) =>
      Flag(
        id: id ?? this.id,
        feature: feature ?? this.feature,
        stateValue: stateValue ?? this.stateValue,
        enabled: enabled ?? this.enabled,
        environment: environment ?? this.environment,
        identity: identity ?? this.identity,
        featureSegment: featureSegment ?? this.featureSegment,
      );
}
