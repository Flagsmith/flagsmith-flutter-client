import 'dart:convert';

import '../extensions/converters.dart';
import 'package:json_annotation/json_annotation.dart';
part 'feature.g.dart';

/// Standard Flagsmith feature
@JsonSerializable()
class Feature {
  final int? id;
  final String name;
  @JsonKey(name: 'created_date')
  final DateTime? createdDate;

  @JsonKey(
      name: 'initial_value', fromJson: stringFromJson, toJson: stringToJson)
  final String? initialValue;

  @JsonKey(name: 'default_enabled')
  final bool? defaultValue;
  final String? description;

  Feature({
    this.id,
    required this.name,
    this.createdDate,
    this.initialValue,
    this.defaultValue,
    this.description,
  });
  factory Feature.named({
    int? id,
    required String name,
    DateTime? createdDate,
    String? initialValue,
    bool? defaultValue,
    String? description,
  }) =>
      Feature(
          id: id,
          name: name,
          createdDate: createdDate,
          initialValue: initialValue,
          defaultValue: defaultValue,
          description: description);

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
  String asString() => jsonEncode(toJson());
  Feature copyWith({
    int? id,
    String? name,
    DateTime? createdDate,
    String? initialValue,
    bool? defaultValue,
    String? description,
  }) =>
      Feature(
        id: id ?? this.id,
        name: name ?? this.name,
        createdDate: createdDate ?? this.createdDate,
        initialValue: initialValue ?? this.initialValue,
        defaultValue: defaultValue ?? this.defaultValue,
        description: description ?? this.description,
      );
}
