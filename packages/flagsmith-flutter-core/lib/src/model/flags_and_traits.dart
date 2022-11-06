import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'index.dart';
part 'flags_and_traits.g.dart';

@JsonSerializable()
class FlagsAndTraits {
  final List<Flag>? flags;
  final List<Trait>? traits;
  FlagsAndTraits({
    this.flags,
    this.traits,
  });
  factory FlagsAndTraits.fromJson(Map<String, dynamic> json) =>
      _$FlagsAndTraitsFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsAndTraitsToJson(this);
  String asString() => jsonEncode(toJson());
  FlagsAndTraits copyWith({
    List<Flag>? flags,
    List<Trait>? traits,
  }) =>
      FlagsAndTraits(
        flags: flags ?? this.flags,
        traits: traits ?? this.traits,
      );
}
