// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_and_traits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_FlagAndTraits _$_$_FlagAndTraitsFromJson(Map<String, dynamic> json) {
  return _$_FlagAndTraits(
    flags: (json['flags'] as List)
            ?.map((e) =>
                e == null ? null : Flag.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
    traits: (json['traits'] as List)
            ?.map((e) =>
                e == null ? null : Trait.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$_$_FlagAndTraitsToJson(_$_FlagAndTraits instance) =>
    <String, dynamic>{
      'flags': instance.flags?.map((e) => e?.toJson())?.toList(),
      'traits': instance.traits?.map((e) => e?.toJson())?.toList(),
    };
