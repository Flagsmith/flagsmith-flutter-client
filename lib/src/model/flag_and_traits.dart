import 'package:bullet_train/src/model/trait.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'flag.dart';

part 'flag_and_traits.freezed.dart';
part 'flag_and_traits.g.dart';

/// Holds a list of feature flags and user traits.
@freezed
abstract class FlagAndTraits with _$FlagAndTraits {
  const factory FlagAndTraits(
      {@Default(<Flag>[]) List<Flag> flags,
      @Default(<Trait>[]) List<Trait> traits}) = _FlagAndTraits;
  factory FlagAndTraits.fromJson(Map<String, dynamic> json) =>
      _$FlagAndTraitsFromJson(json);
}
