// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'bt_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$BtEventTearOff {
  const _$BtEventTearOff();

// ignore: unused_element
  _Started started() {
    return const _Started();
  }

// ignore: unused_element
  _GetFeatures getFeatures() {
    return const _GetFeatures();
  }

// ignore: unused_element
  _HasFeature hasFeature(String value) {
    return _HasFeature(
      value,
    );
  }
}

// ignore: unused_element
const $BtEvent = _$BtEventTearOff();

mixin _$BtEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result started(),
    @required Result getFeatures(),
    @required Result hasFeature(String value),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result started(),
    Result getFeatures(),
    Result hasFeature(String value),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result started(_Started value),
    @required Result getFeatures(_GetFeatures value),
    @required Result hasFeature(_HasFeature value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result started(_Started value),
    Result getFeatures(_GetFeatures value),
    Result hasFeature(_HasFeature value),
    @required Result orElse(),
  });
}

abstract class $BtEventCopyWith<$Res> {
  factory $BtEventCopyWith(BtEvent value, $Res Function(BtEvent) then) =
      _$BtEventCopyWithImpl<$Res>;
}

class _$BtEventCopyWithImpl<$Res> implements $BtEventCopyWith<$Res> {
  _$BtEventCopyWithImpl(this._value, this._then);

  final BtEvent _value;
  // ignore: unused_field
  final $Res Function(BtEvent) _then;
}

abstract class _$StartedCopyWith<$Res> {
  factory _$StartedCopyWith(_Started value, $Res Function(_Started) then) =
      __$StartedCopyWithImpl<$Res>;
}

class __$StartedCopyWithImpl<$Res> extends _$BtEventCopyWithImpl<$Res>
    implements _$StartedCopyWith<$Res> {
  __$StartedCopyWithImpl(_Started _value, $Res Function(_Started) _then)
      : super(_value, (v) => _then(v as _Started));

  @override
  _Started get _value => super._value as _Started;
}

class _$_Started implements _Started {
  const _$_Started();

  @override
  String toString() {
    return 'BtEvent.started()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result started(),
    @required Result getFeatures(),
    @required Result hasFeature(String value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return started();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result started(),
    Result getFeatures(),
    Result hasFeature(String value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result started(_Started value),
    @required Result getFeatures(_GetFeatures value),
    @required Result hasFeature(_HasFeature value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return started(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result started(_Started value),
    Result getFeatures(_GetFeatures value),
    Result hasFeature(_HasFeature value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class _Started implements BtEvent {
  const factory _Started() = _$_Started;
}

abstract class _$GetFeaturesCopyWith<$Res> {
  factory _$GetFeaturesCopyWith(
          _GetFeatures value, $Res Function(_GetFeatures) then) =
      __$GetFeaturesCopyWithImpl<$Res>;
}

class __$GetFeaturesCopyWithImpl<$Res> extends _$BtEventCopyWithImpl<$Res>
    implements _$GetFeaturesCopyWith<$Res> {
  __$GetFeaturesCopyWithImpl(
      _GetFeatures _value, $Res Function(_GetFeatures) _then)
      : super(_value, (v) => _then(v as _GetFeatures));

  @override
  _GetFeatures get _value => super._value as _GetFeatures;
}

class _$_GetFeatures implements _GetFeatures {
  const _$_GetFeatures();

  @override
  String toString() {
    return 'BtEvent.getFeatures()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _GetFeatures);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result started(),
    @required Result getFeatures(),
    @required Result hasFeature(String value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return getFeatures();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result started(),
    Result getFeatures(),
    Result hasFeature(String value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getFeatures != null) {
      return getFeatures();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result started(_Started value),
    @required Result getFeatures(_GetFeatures value),
    @required Result hasFeature(_HasFeature value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return getFeatures(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result started(_Started value),
    Result getFeatures(_GetFeatures value),
    Result hasFeature(_HasFeature value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (getFeatures != null) {
      return getFeatures(this);
    }
    return orElse();
  }
}

abstract class _GetFeatures implements BtEvent {
  const factory _GetFeatures() = _$_GetFeatures;
}

abstract class _$HasFeatureCopyWith<$Res> {
  factory _$HasFeatureCopyWith(
          _HasFeature value, $Res Function(_HasFeature) then) =
      __$HasFeatureCopyWithImpl<$Res>;
  $Res call({String value});
}

class __$HasFeatureCopyWithImpl<$Res> extends _$BtEventCopyWithImpl<$Res>
    implements _$HasFeatureCopyWith<$Res> {
  __$HasFeatureCopyWithImpl(
      _HasFeature _value, $Res Function(_HasFeature) _then)
      : super(_value, (v) => _then(v as _HasFeature));

  @override
  _HasFeature get _value => super._value as _HasFeature;

  @override
  $Res call({
    Object value = freezed,
  }) {
    return _then(_HasFeature(
      value == freezed ? _value.value : value as String,
    ));
  }
}

class _$_HasFeature implements _HasFeature {
  const _$_HasFeature(this.value) : assert(value != null);

  @override
  final String value;

  @override
  String toString() {
    return 'BtEvent.hasFeature(value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _HasFeature &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(value);

  @override
  _$HasFeatureCopyWith<_HasFeature> get copyWith =>
      __$HasFeatureCopyWithImpl<_HasFeature>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result started(),
    @required Result getFeatures(),
    @required Result hasFeature(String value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return hasFeature(value);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result started(),
    Result getFeatures(),
    Result hasFeature(String value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (hasFeature != null) {
      return hasFeature(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result started(_Started value),
    @required Result getFeatures(_GetFeatures value),
    @required Result hasFeature(_HasFeature value),
  }) {
    assert(started != null);
    assert(getFeatures != null);
    assert(hasFeature != null);
    return hasFeature(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result started(_Started value),
    Result getFeatures(_GetFeatures value),
    Result hasFeature(_HasFeature value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (hasFeature != null) {
      return hasFeature(this);
    }
    return orElse();
  }
}

abstract class _HasFeature implements BtEvent {
  const factory _HasFeature(String value) = _$_HasFeature;

  String get value;
  _$HasFeatureCopyWith<_HasFeature> get copyWith;
}

class _$BtStateTearOff {
  const _$BtStateTearOff();

// ignore: unused_element
  _BtState call({@required LoadingState state, List<Flag> flags}) {
    return _BtState(
      state: state,
      flags: flags,
    );
  }
}

// ignore: unused_element
const $BtState = _$BtStateTearOff();

mixin _$BtState {
  LoadingState get state;
  List<Flag> get flags;

  $BtStateCopyWith<BtState> get copyWith;
}

abstract class $BtStateCopyWith<$Res> {
  factory $BtStateCopyWith(BtState value, $Res Function(BtState) then) =
      _$BtStateCopyWithImpl<$Res>;
  $Res call({LoadingState state, List<Flag> flags});
}

class _$BtStateCopyWithImpl<$Res> implements $BtStateCopyWith<$Res> {
  _$BtStateCopyWithImpl(this._value, this._then);

  final BtState _value;
  // ignore: unused_field
  final $Res Function(BtState) _then;

  @override
  $Res call({
    Object state = freezed,
    Object flags = freezed,
  }) {
    return _then(_value.copyWith(
      state: state == freezed ? _value.state : state as LoadingState,
      flags: flags == freezed ? _value.flags : flags as List<Flag>,
    ));
  }
}

abstract class _$BtStateCopyWith<$Res> implements $BtStateCopyWith<$Res> {
  factory _$BtStateCopyWith(_BtState value, $Res Function(_BtState) then) =
      __$BtStateCopyWithImpl<$Res>;
  @override
  $Res call({LoadingState state, List<Flag> flags});
}

class __$BtStateCopyWithImpl<$Res> extends _$BtStateCopyWithImpl<$Res>
    implements _$BtStateCopyWith<$Res> {
  __$BtStateCopyWithImpl(_BtState _value, $Res Function(_BtState) _then)
      : super(_value, (v) => _then(v as _BtState));

  @override
  _BtState get _value => super._value as _BtState;

  @override
  $Res call({
    Object state = freezed,
    Object flags = freezed,
  }) {
    return _then(_BtState(
      state: state == freezed ? _value.state : state as LoadingState,
      flags: flags == freezed ? _value.flags : flags as List<Flag>,
    ));
  }
}

class _$_BtState implements _BtState {
  const _$_BtState({@required this.state, this.flags}) : assert(state != null);

  @override
  final LoadingState state;
  @override
  final List<Flag> flags;

  @override
  String toString() {
    return 'BtState(state: $state, flags: $flags)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _BtState &&
            (identical(other.state, state) ||
                const DeepCollectionEquality().equals(other.state, state)) &&
            (identical(other.flags, flags) ||
                const DeepCollectionEquality().equals(other.flags, flags)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(state) ^
      const DeepCollectionEquality().hash(flags);

  @override
  _$BtStateCopyWith<_BtState> get copyWith =>
      __$BtStateCopyWithImpl<_BtState>(this, _$identity);
}

abstract class _BtState implements BtState {
  const factory _BtState({@required LoadingState state, List<Flag> flags}) =
      _$_BtState;

  @override
  LoadingState get state;
  @override
  List<Flag> get flags;
  @override
  _$BtStateCopyWith<_BtState> get copyWith;
}
