// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, non_constant_identifier_names, type_annotate_public_apis, omit_local_variable_types, unnecessary_this

part of 'trait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trait _$TraitFromJson(Map<String, dynamic> json) => Trait(
      id: (json['id'] as num?)?.toInt(),
      transient: json['transient'] as bool?,
      key: json['trait_key'] as String,
      value: Trait._fromJson(json['trait_value']),
    );

Map<String, dynamic> _$TraitToJson(Trait instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('transient', instance.transient);
  val['trait_key'] = instance.key;
  val['trait_value'] = Trait._toJson(instance.value);
  return val;
}

TraitWithIdentity _$TraitWithIdentityFromJson(Map<String, dynamic> json) =>
    TraitWithIdentity(
      identity: Identity.fromJson(json['identity'] as Map<String, dynamic>),
      key: json['trait_key'] as String,
      value: TraitWithIdentity._fromJson(json['trait_value']),
    );

Map<String, dynamic> _$TraitWithIdentityToJson(TraitWithIdentity instance) =>
    <String, dynamic>{
      'identity': instance.identity.toJson(),
      'trait_key': instance.key,
      'trait_value': TraitWithIdentity._toJson(instance.value),
    };
