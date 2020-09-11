// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'flag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Flag _$FlagFromJson(Map<String, dynamic> json) {
  return _Flag.fromJson(json);
}

class _$FlagTearOff {
  const _$FlagTearOff();

// ignore: unused_element
  _Flag call(
      {@required
          int id,
      @required
          Feature feature,
      @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
          String stateValue,
      @required
          bool enabled}) {
    return _Flag(
      id: id,
      feature: feature,
      stateValue: stateValue,
      enabled: enabled,
    );
  }
}

// ignore: unused_element
const $Flag = _$FlagTearOff();

mixin _$Flag {
  int get id;
  Feature get feature;
  @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
  String get stateValue;
  bool get enabled;

  Map<String, dynamic> toJson();
  $FlagCopyWith<Flag> get copyWith;
}

abstract class $FlagCopyWith<$Res> {
  factory $FlagCopyWith(Flag value, $Res Function(Flag) then) =
      _$FlagCopyWithImpl<$Res>;
  $Res call(
      {int id,
      Feature feature,
      @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
          String stateValue,
      bool enabled});

  $FeatureCopyWith<$Res> get feature;
}

class _$FlagCopyWithImpl<$Res> implements $FlagCopyWith<$Res> {
  _$FlagCopyWithImpl(this._value, this._then);

  final Flag _value;
  // ignore: unused_field
  final $Res Function(Flag) _then;

  @override
  $Res call({
    Object id = freezed,
    Object feature = freezed,
    Object stateValue = freezed,
    Object enabled = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as int,
      feature: feature == freezed ? _value.feature : feature as Feature,
      stateValue:
          stateValue == freezed ? _value.stateValue : stateValue as String,
      enabled: enabled == freezed ? _value.enabled : enabled as bool,
    ));
  }

  @override
  $FeatureCopyWith<$Res> get feature {
    if (_value.feature == null) {
      return null;
    }
    return $FeatureCopyWith<$Res>(_value.feature, (value) {
      return _then(_value.copyWith(feature: value));
    });
  }
}

abstract class _$FlagCopyWith<$Res> implements $FlagCopyWith<$Res> {
  factory _$FlagCopyWith(_Flag value, $Res Function(_Flag) then) =
      __$FlagCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      Feature feature,
      @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
          String stateValue,
      bool enabled});

  @override
  $FeatureCopyWith<$Res> get feature;
}

class __$FlagCopyWithImpl<$Res> extends _$FlagCopyWithImpl<$Res>
    implements _$FlagCopyWith<$Res> {
  __$FlagCopyWithImpl(_Flag _value, $Res Function(_Flag) _then)
      : super(_value, (v) => _then(v as _Flag));

  @override
  _Flag get _value => super._value as _Flag;

  @override
  $Res call({
    Object id = freezed,
    Object feature = freezed,
    Object stateValue = freezed,
    Object enabled = freezed,
  }) {
    return _then(_Flag(
      id: id == freezed ? _value.id : id as int,
      feature: feature == freezed ? _value.feature : feature as Feature,
      stateValue:
          stateValue == freezed ? _value.stateValue : stateValue as String,
      enabled: enabled == freezed ? _value.enabled : enabled as bool,
    ));
  }
}

@JsonSerializable(explicitToJson: true, includeIfNull: true, createToJson: true)
class _$_Flag implements _Flag {
  _$_Flag(
      {@required
          this.id,
      @required
          this.feature,
      @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
          this.stateValue,
      @required
          this.enabled})
      : assert(id != null),
        assert(feature != null),
        assert(enabled != null);

  factory _$_Flag.fromJson(Map<String, dynamic> json) =>
      _$_$_FlagFromJson(json);

  @override
  final int id;
  @override
  final Feature feature;
  @override
  @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
  final String stateValue;
  @override
  final bool enabled;

  bool _didkey = false;
  String _key;

  @override
  String get key {
    if (_didkey == false) {
      _didkey = true;
      _key = id.toString();
    }
    return _key;
  }

  @override
  String toString() {
    return 'Flag(id: $id, feature: $feature, stateValue: $stateValue, enabled: $enabled, key: $key)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Flag &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.feature, feature) ||
                const DeepCollectionEquality()
                    .equals(other.feature, feature)) &&
            (identical(other.stateValue, stateValue) ||
                const DeepCollectionEquality()
                    .equals(other.stateValue, stateValue)) &&
            (identical(other.enabled, enabled) ||
                const DeepCollectionEquality().equals(other.enabled, enabled)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(feature) ^
      const DeepCollectionEquality().hash(stateValue) ^
      const DeepCollectionEquality().hash(enabled);

  @override
  _$FlagCopyWith<_Flag> get copyWith =>
      __$FlagCopyWithImpl<_Flag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_FlagToJson(this);
  }
}

abstract class _Flag implements Flag {
  factory _Flag(
      {@required
          int id,
      @required
          Feature feature,
      @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
          String stateValue,
      @required
          bool enabled}) = _$_Flag;

  factory _Flag.fromJson(Map<String, dynamic> json) = _$_Flag.fromJson;

  @override
  int get id;
  @override
  Feature get feature;
  @override
  @JsonKey(name: 'feature_state_value', fromJson: stringFromInt)
  String get stateValue;
  @override
  bool get enabled;
  @override
  _$FlagCopyWith<_Flag> get copyWith;
}
