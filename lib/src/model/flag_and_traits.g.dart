// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

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
