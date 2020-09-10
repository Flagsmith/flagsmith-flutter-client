// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Trait _$_$_TraitFromJson(Map<String, dynamic> json) {
  return _$_Trait(
    identity: json['identity'] == null
        ? null
        : FeatureUser.fromJson(json['identity'] as Map<String, dynamic>),
    key: json['trait_key'] as String,
    value: stringFromInt(json['trait_value']),
  );
}

Map<String, dynamic> _$_$_TraitToJson(_$_Trait instance) => <String, dynamic>{
      'identity': instance.identity?.toJson(),
      'trait_key': instance.key,
      'trait_value': instance.value,
    };
