// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'flags_and_traits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlagsAndTraits _$FlagsAndTraitsFromJson(Map<String, dynamic> json) {
  return FlagsAndTraits(
    flags: (json['flags'] as List<dynamic>?)
        ?.map((e) => Flag.fromJson(e as Map<String, dynamic>))
        .toList(),
    traits: (json['traits'] as List<dynamic>?)
        ?.map((e) => Trait.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$FlagsAndTraitsToJson(FlagsAndTraits instance) =>
    <String, dynamic>{
      'flags': instance.flags?.map((e) => e.toJson()).toList(),
      'traits': instance.traits?.map((e) => e.toJson()).toList(),
    };
