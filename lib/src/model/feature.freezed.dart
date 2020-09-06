// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'feature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Feature _$FeatureFromJson(Map<String, dynamic> json) {
  return _Feature.fromJson(json);
}

class _$FeatureTearOff {
  const _$FeatureTearOff();

// ignore: unused_element
  _Feature call(
      {@required int id,
      @required String name,
      @required @JsonKey(name: 'created_date') DateTime createDate,
      @required FlagType type,
      String description = ''}) {
    return _Feature(
      id: id,
      name: name,
      createDate: createDate,
      type: type,
      description: description,
    );
  }
}

// ignore: unused_element
const $Feature = _$FeatureTearOff();

mixin _$Feature {
  int get id;
  String get name;
  @JsonKey(name: 'created_date')
  DateTime get createDate;
  FlagType get type;
  String get description;

  Map<String, dynamic> toJson();
  $FeatureCopyWith<Feature> get copyWith;
}

abstract class $FeatureCopyWith<$Res> {
  factory $FeatureCopyWith(Feature value, $Res Function(Feature) then) =
      _$FeatureCopyWithImpl<$Res>;
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'created_date') DateTime createDate,
      FlagType type,
      String description});
}

class _$FeatureCopyWithImpl<$Res> implements $FeatureCopyWith<$Res> {
  _$FeatureCopyWithImpl(this._value, this._then);

  final Feature _value;
  // ignore: unused_field
  final $Res Function(Feature) _then;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object createDate = freezed,
    Object type = freezed,
    Object description = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as int,
      name: name == freezed ? _value.name : name as String,
      createDate:
          createDate == freezed ? _value.createDate : createDate as DateTime,
      type: type == freezed ? _value.type : type as FlagType,
      description:
          description == freezed ? _value.description : description as String,
    ));
  }
}

abstract class _$FeatureCopyWith<$Res> implements $FeatureCopyWith<$Res> {
  factory _$FeatureCopyWith(_Feature value, $Res Function(_Feature) then) =
      __$FeatureCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'created_date') DateTime createDate,
      FlagType type,
      String description});
}

class __$FeatureCopyWithImpl<$Res> extends _$FeatureCopyWithImpl<$Res>
    implements _$FeatureCopyWith<$Res> {
  __$FeatureCopyWithImpl(_Feature _value, $Res Function(_Feature) _then)
      : super(_value, (v) => _then(v as _Feature));

  @override
  _Feature get _value => super._value as _Feature;

  @override
  $Res call({
    Object id = freezed,
    Object name = freezed,
    Object createDate = freezed,
    Object type = freezed,
    Object description = freezed,
  }) {
    return _then(_Feature(
      id: id == freezed ? _value.id : id as int,
      name: name == freezed ? _value.name : name as String,
      createDate:
          createDate == freezed ? _value.createDate : createDate as DateTime,
      type: type == freezed ? _value.type : type as FlagType,
      description:
          description == freezed ? _value.description : description as String,
    ));
  }
}

@JsonSerializable()
class _$_Feature implements _Feature {
  const _$_Feature(
      {@required this.id,
      @required this.name,
      @required @JsonKey(name: 'created_date') this.createDate,
      @required this.type,
      this.description = ''})
      : assert(id != null),
        assert(name != null),
        assert(createDate != null),
        assert(type != null),
        assert(description != null);

  factory _$_Feature.fromJson(Map<String, dynamic> json) =>
      _$_$_FeatureFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'created_date')
  final DateTime createDate;
  @override
  final FlagType type;
  @JsonKey(defaultValue: '')
  @override
  final String description;

  @override
  String toString() {
    return 'Feature(id: $id, name: $name, createDate: $createDate, type: $type, description: $description)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Feature &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.createDate, createDate) ||
                const DeepCollectionEquality()
                    .equals(other.createDate, createDate)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality()
                    .equals(other.description, description)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(createDate) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(description);

  @override
  _$FeatureCopyWith<_Feature> get copyWith =>
      __$FeatureCopyWithImpl<_Feature>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_FeatureToJson(this);
  }
}

abstract class _Feature implements Feature {
  const factory _Feature(
      {@required int id,
      @required String name,
      @required @JsonKey(name: 'created_date') DateTime createDate,
      @required FlagType type,
      String description}) = _$_Feature;

  factory _Feature.fromJson(Map<String, dynamic> json) = _$_Feature.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'created_date')
  DateTime get createDate;
  @override
  FlagType get type;
  @override
  String get description;
  @override
  _$FeatureCopyWith<_Feature> get copyWith;
}
