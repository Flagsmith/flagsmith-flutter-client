import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'identity.dart';
part 'trait.g.dart';

@JsonSerializable()
class Trait {
  @JsonKey(includeIfNull: false)
  final int? id;
  @JsonKey(includeIfNull: false)
  final bool? transient;
  @JsonKey(name: 'trait_key')
  final String key;
  @JsonKey(name: 'trait_value', fromJson: _fromJson, toJson: _toJson)
  final dynamic value;

  Trait({
    this.id,
    this.transient,
    required this.key,
    required this.value,
  });

  factory Trait.fromJson(Map<String, dynamic> json) => _$TraitFromJson(json);

  Map<String, dynamic> toJson() => _$TraitToJson(this);

  String asString() => jsonEncode(toJson());

  Trait copyWith({
    int? id,
    String? key,
    dynamic value,
  }) =>
      Trait(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );

  static dynamic _fromJson(dynamic jsonValue) {
    if (jsonValue is num) {
      if (jsonValue % 1 == 0) {
        return jsonValue.toInt(); // Treat as int if it's a whole number
      } else {
        return jsonValue.toDouble(); // Treat as double if it's a decimal
      }
    } else if (jsonValue is String || jsonValue is bool) {
      return jsonValue;
    }
    throw ArgumentError('Invalid value type');
  }

  static dynamic _toJson(dynamic value) {
    if (value is double || value is int || value is String || value is bool) {
      return value;
    }
    throw ArgumentError('Invalid value type');
  }
}

@JsonSerializable()
class TraitWithIdentity {
  final Identity identity;
  @JsonKey(name: 'trait_key')
  final String key;
  @JsonKey(
    name: 'trait_value',
    fromJson: _fromJson,
    toJson: _toJson,
  )
  final dynamic value;

  TraitWithIdentity({
    required this.identity,
    required this.key,
    required this.value,
  });

  factory TraitWithIdentity.fromJson(Map<String, dynamic> json) =>
      _$TraitWithIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$TraitWithIdentityToJson(this);

  String asString() => jsonEncode(toJson());

  TraitWithIdentity copyWith({
    Identity? identity,
    String? key,
    dynamic value,
  }) =>
      TraitWithIdentity(
        identity: identity ?? this.identity,
        key: key ?? this.key,
        value: value ?? this.value,
      );

  static dynamic _fromJson(dynamic jsonValue) {
    if (jsonValue is num) {
      if (jsonValue % 1 == 0) {
        return jsonValue.toInt(); // Treat as int if it's a whole number
      } else {
        return jsonValue.toDouble(); // Treat as double if it's a decimal
      }
    } else if (jsonValue is String || jsonValue is bool) {
      return jsonValue;
    }
    throw ArgumentError('Invalid value type');
  }

  static dynamic _toJson(dynamic value) {
    if (value is double || value is int || value is String || value is bool) {
      return value;
    }
    throw ArgumentError('Invalid value type');
  }
}
