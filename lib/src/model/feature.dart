import 'package:bullet_train/src/model/flag_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'feature.freezed.dart';
part 'feature.g.dart';

/// Representation of the feature model of the feature Flag.
///
@freezed
abstract class Feature with _$Feature {
  const factory Feature(
      {@required int id,
      @required String name,
      @required @JsonKey(name: 'created_date') DateTime createDate,
      @required FlagType type,
      @Default('') String description}) = _Feature;

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
}
