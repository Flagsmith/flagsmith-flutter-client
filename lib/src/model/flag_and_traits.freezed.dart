// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'flag_and_traits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
FlagAndTraits _$FlagAndTraitsFromJson(Map<String, dynamic> json) {
  return _FlagAndTraits.fromJson(json);
}

class _$FlagAndTraitsTearOff {
  const _$FlagAndTraitsTearOff();

// ignore: unused_element
  _FlagAndTraits call(
      {List<Flag> flags = const <Flag>[],
      List<Trait> traits = const <Trait>[]}) {
    return _FlagAndTraits(
      flags: flags,
      traits: traits,
    );
  }
}

// ignore: unused_element
const $FlagAndTraits = _$FlagAndTraitsTearOff();

mixin _$FlagAndTraits {
  List<Flag> get flags;
  List<Trait> get traits;

  Map<String, dynamic> toJson();
  $FlagAndTraitsCopyWith<FlagAndTraits> get copyWith;
}

abstract class $FlagAndTraitsCopyWith<$Res> {
  factory $FlagAndTraitsCopyWith(
          FlagAndTraits value, $Res Function(FlagAndTraits) then) =
      _$FlagAndTraitsCopyWithImpl<$Res>;
  $Res call({List<Flag> flags, List<Trait> traits});
}

class _$FlagAndTraitsCopyWithImpl<$Res>
    implements $FlagAndTraitsCopyWith<$Res> {
  _$FlagAndTraitsCopyWithImpl(this._value, this._then);

  final FlagAndTraits _value;
  // ignore: unused_field
  final $Res Function(FlagAndTraits) _then;

  @override
  $Res call({
    Object flags = freezed,
    Object traits = freezed,
  }) {
    return _then(_value.copyWith(
      flags: flags == freezed ? _value.flags : flags as List<Flag>,
      traits: traits == freezed ? _value.traits : traits as List<Trait>,
    ));
  }
}

abstract class _$FlagAndTraitsCopyWith<$Res>
    implements $FlagAndTraitsCopyWith<$Res> {
  factory _$FlagAndTraitsCopyWith(
          _FlagAndTraits value, $Res Function(_FlagAndTraits) then) =
      __$FlagAndTraitsCopyWithImpl<$Res>;
  @override
  $Res call({List<Flag> flags, List<Trait> traits});
}

class __$FlagAndTraitsCopyWithImpl<$Res>
    extends _$FlagAndTraitsCopyWithImpl<$Res>
    implements _$FlagAndTraitsCopyWith<$Res> {
  __$FlagAndTraitsCopyWithImpl(
      _FlagAndTraits _value, $Res Function(_FlagAndTraits) _then)
      : super(_value, (v) => _then(v as _FlagAndTraits));

  @override
  _FlagAndTraits get _value => super._value as _FlagAndTraits;

  @override
  $Res call({
    Object flags = freezed,
    Object traits = freezed,
  }) {
    return _then(_FlagAndTraits(
      flags: flags == freezed ? _value.flags : flags as List<Flag>,
      traits: traits == freezed ? _value.traits : traits as List<Trait>,
    ));
  }
}

@JsonSerializable(explicitToJson: true)
class _$_FlagAndTraits implements _FlagAndTraits {
  const _$_FlagAndTraits(
      {this.flags = const <Flag>[], this.traits = const <Trait>[]})
      : assert(flags != null),
        assert(traits != null);

  factory _$_FlagAndTraits.fromJson(Map<String, dynamic> json) =>
      _$_$_FlagAndTraitsFromJson(json);

  @JsonKey(defaultValue: const <Flag>[])
  @override
  final List<Flag> flags;
  @JsonKey(defaultValue: const <Trait>[])
  @override
  final List<Trait> traits;

  @override
  String toString() {
    return 'FlagAndTraits(flags: $flags, traits: $traits)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _FlagAndTraits &&
            (identical(other.flags, flags) ||
                const DeepCollectionEquality().equals(other.flags, flags)) &&
            (identical(other.traits, traits) ||
                const DeepCollectionEquality().equals(other.traits, traits)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(flags) ^
      const DeepCollectionEquality().hash(traits);

  @override
  _$FlagAndTraitsCopyWith<_FlagAndTraits> get copyWith =>
      __$FlagAndTraitsCopyWithImpl<_FlagAndTraits>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_FlagAndTraitsToJson(this);
  }
}

abstract class _FlagAndTraits implements FlagAndTraits {
  const factory _FlagAndTraits({List<Flag> flags, List<Trait> traits}) =
      _$_FlagAndTraits;

  factory _FlagAndTraits.fromJson(Map<String, dynamic> json) =
      _$_FlagAndTraits.fromJson;

  @override
  List<Flag> get flags;
  @override
  List<Trait> get traits;
  @override
  _$FlagAndTraitsCopyWith<_FlagAndTraits> get copyWith;
}
