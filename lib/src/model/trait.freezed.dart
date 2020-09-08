// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'trait.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Trait _$TraitFromJson(Map<String, dynamic> json) {
  return _Trait.fromJson(json);
}

class _$TraitTearOff {
  const _$TraitTearOff();

// ignore: unused_element
  _Trait call(
      {FeatureUser identity,
      @JsonKey(name: 'trait_key') String key,
      @JsonKey(name: 'trait_value', fromJson: stringFromInt) String value}) {
    return _Trait(
      identity: identity,
      key: key,
      value: value,
    );
  }
}

// ignore: unused_element
const $Trait = _$TraitTearOff();

mixin _$Trait {
  FeatureUser get identity;
  @JsonKey(name: 'trait_key')
  String get key;
  @JsonKey(name: 'trait_value', fromJson: stringFromInt)
  String get value;

  Map<String, dynamic> toJson();
  $TraitCopyWith<Trait> get copyWith;
}

abstract class $TraitCopyWith<$Res> {
  factory $TraitCopyWith(Trait value, $Res Function(Trait) then) =
      _$TraitCopyWithImpl<$Res>;
  $Res call(
      {FeatureUser identity,
      @JsonKey(name: 'trait_key') String key,
      @JsonKey(name: 'trait_value', fromJson: stringFromInt) String value});

  $FeatureUserCopyWith<$Res> get identity;
}

class _$TraitCopyWithImpl<$Res> implements $TraitCopyWith<$Res> {
  _$TraitCopyWithImpl(this._value, this._then);

  final Trait _value;
  // ignore: unused_field
  final $Res Function(Trait) _then;

  @override
  $Res call({
    Object identity = freezed,
    Object key = freezed,
    Object value = freezed,
  }) {
    return _then(_value.copyWith(
      identity: identity == freezed ? _value.identity : identity as FeatureUser,
      key: key == freezed ? _value.key : key as String,
      value: value == freezed ? _value.value : value as String,
    ));
  }

  @override
  $FeatureUserCopyWith<$Res> get identity {
    if (_value.identity == null) {
      return null;
    }
    return $FeatureUserCopyWith<$Res>(_value.identity, (value) {
      return _then(_value.copyWith(identity: value));
    });
  }
}

abstract class _$TraitCopyWith<$Res> implements $TraitCopyWith<$Res> {
  factory _$TraitCopyWith(_Trait value, $Res Function(_Trait) then) =
      __$TraitCopyWithImpl<$Res>;
  @override
  $Res call(
      {FeatureUser identity,
      @JsonKey(name: 'trait_key') String key,
      @JsonKey(name: 'trait_value', fromJson: stringFromInt) String value});

  @override
  $FeatureUserCopyWith<$Res> get identity;
}

class __$TraitCopyWithImpl<$Res> extends _$TraitCopyWithImpl<$Res>
    implements _$TraitCopyWith<$Res> {
  __$TraitCopyWithImpl(_Trait _value, $Res Function(_Trait) _then)
      : super(_value, (v) => _then(v as _Trait));

  @override
  _Trait get _value => super._value as _Trait;

  @override
  $Res call({
    Object identity = freezed,
    Object key = freezed,
    Object value = freezed,
  }) {
    return _then(_Trait(
      identity: identity == freezed ? _value.identity : identity as FeatureUser,
      key: key == freezed ? _value.key : key as String,
      value: value == freezed ? _value.value : value as String,
    ));
  }
}

@JsonSerializable()
class _$_Trait implements _Trait {
  const _$_Trait(
      {this.identity,
      @JsonKey(name: 'trait_key') this.key,
      @JsonKey(name: 'trait_value', fromJson: stringFromInt) this.value});

  factory _$_Trait.fromJson(Map<String, dynamic> json) =>
      _$_$_TraitFromJson(json);

  @override
  final FeatureUser identity;
  @override
  @JsonKey(name: 'trait_key')
  final String key;
  @override
  @JsonKey(name: 'trait_value', fromJson: stringFromInt)
  final String value;

  @override
  String toString() {
    return 'Trait(identity: $identity, key: $key, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Trait &&
            (identical(other.identity, identity) ||
                const DeepCollectionEquality()
                    .equals(other.identity, identity)) &&
            (identical(other.key, key) ||
                const DeepCollectionEquality().equals(other.key, key)) &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(identity) ^
      const DeepCollectionEquality().hash(key) ^
      const DeepCollectionEquality().hash(value);

  @override
  _$TraitCopyWith<_Trait> get copyWith =>
      __$TraitCopyWithImpl<_Trait>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_TraitToJson(this);
  }
}

abstract class _Trait implements Trait {
  const factory _Trait(
      {FeatureUser identity,
      @JsonKey(name: 'trait_key')
          String key,
      @JsonKey(name: 'trait_value', fromJson: stringFromInt)
          String value}) = _$_Trait;

  factory _Trait.fromJson(Map<String, dynamic> json) = _$_Trait.fromJson;

  @override
  FeatureUser get identity;
  @override
  @JsonKey(name: 'trait_key')
  String get key;
  @override
  @JsonKey(name: 'trait_value', fromJson: stringFromInt)
  String get value;
  @override
  _$TraitCopyWith<_Trait> get copyWith;
}
