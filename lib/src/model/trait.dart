import 'package:freezed_annotation/freezed_annotation.dart';
import 'feature_user.dart';

part 'trait.freezed.dart';
part 'trait.g.dart';

/// Representation of the user trait model.

@freezed
abstract class Trait with _$Trait {
  const factory Trait(
      {FeatureUser identity,
      @JsonKey(name: 'trait_key') String key,
      @JsonKey(name: 'trait_value') String value}) = _Trait;
  factory Trait.fromJson(Map<String, dynamic> json) => _$TraitFromJson(json);
}
