// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'feature_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
FeatureUser _$FeatureUserFromJson(Map<String, dynamic> json) {
  return _FeatureUser.fromJson(json);
}

class _$FeatureUserTearOff {
  const _$FeatureUserTearOff();

// ignore: unused_element
  _FeatureUser call({@required String identifier}) {
    return _FeatureUser(
      identifier: identifier,
    );
  }
}

// ignore: unused_element
const $FeatureUser = _$FeatureUserTearOff();

mixin _$FeatureUser {
  String get identifier;

  Map<String, dynamic> toJson();
  $FeatureUserCopyWith<FeatureUser> get copyWith;
}

abstract class $FeatureUserCopyWith<$Res> {
  factory $FeatureUserCopyWith(
          FeatureUser value, $Res Function(FeatureUser) then) =
      _$FeatureUserCopyWithImpl<$Res>;
  $Res call({String identifier});
}

class _$FeatureUserCopyWithImpl<$Res> implements $FeatureUserCopyWith<$Res> {
  _$FeatureUserCopyWithImpl(this._value, this._then);

  final FeatureUser _value;
  // ignore: unused_field
  final $Res Function(FeatureUser) _then;

  @override
  $Res call({
    Object identifier = freezed,
  }) {
    return _then(_value.copyWith(
      identifier:
          identifier == freezed ? _value.identifier : identifier as String,
    ));
  }
}

abstract class _$FeatureUserCopyWith<$Res>
    implements $FeatureUserCopyWith<$Res> {
  factory _$FeatureUserCopyWith(
          _FeatureUser value, $Res Function(_FeatureUser) then) =
      __$FeatureUserCopyWithImpl<$Res>;
  @override
  $Res call({String identifier});
}

class __$FeatureUserCopyWithImpl<$Res> extends _$FeatureUserCopyWithImpl<$Res>
    implements _$FeatureUserCopyWith<$Res> {
  __$FeatureUserCopyWithImpl(
      _FeatureUser _value, $Res Function(_FeatureUser) _then)
      : super(_value, (v) => _then(v as _FeatureUser));

  @override
  _FeatureUser get _value => super._value as _FeatureUser;

  @override
  $Res call({
    Object identifier = freezed,
  }) {
    return _then(_FeatureUser(
      identifier:
          identifier == freezed ? _value.identifier : identifier as String,
    ));
  }
}

@JsonSerializable()
class _$_FeatureUser implements _FeatureUser {
  const _$_FeatureUser({@required this.identifier})
      : assert(identifier != null);

  factory _$_FeatureUser.fromJson(Map<String, dynamic> json) =>
      _$_$_FeatureUserFromJson(json);

  @override
  final String identifier;

  @override
  String toString() {
    return 'FeatureUser(identifier: $identifier)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _FeatureUser &&
            (identical(other.identifier, identifier) ||
                const DeepCollectionEquality()
                    .equals(other.identifier, identifier)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(identifier);

  @override
  _$FeatureUserCopyWith<_FeatureUser> get copyWith =>
      __$FeatureUserCopyWithImpl<_FeatureUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_FeatureUserToJson(this);
  }
}

abstract class _FeatureUser implements FeatureUser {
  const factory _FeatureUser({@required String identifier}) = _$_FeatureUser;

  factory _FeatureUser.fromJson(Map<String, dynamic> json) =
      _$_FeatureUser.fromJson;

  @override
  String get identifier;
  @override
  _$FeatureUserCopyWith<_FeatureUser> get copyWith;
}
