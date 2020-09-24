import 'dart:convert';

import 'package:equatable/equatable.dart';
import '../extensions/string_x.dart';
import 'feature_user.dart';

class Trait extends Equatable {
  final int id;
  final FeatureUser identity;
  final String key;
  final String value;
  @override
  List<Object> get props => [id, identity, key, value];
  @override
  bool get stringify => true;
  Trait({
    this.id,
    this.identity,
    this.key,
    this.value,
  });

  Trait copyWith({
    int id,
    FeatureUser identity,
    String key,
    String value,
  }) {
    return Trait(
      id: id ?? this.id,
      identity: identity ?? this.identity,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'identity': identity?.toMap(),
      'trait_key': key,
      'trait_value': value,
    };
  }

  factory Trait.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    return Trait(
      id: map['id'] as int,
      identity: map['identity'] != null
          ? FeatureUser.fromMap(map['identity'] as Map<String, dynamic>)
          : null,
      key: (map['trait_key'] as String)?.normalize(),
      value: (map['trait_value'] as String)?.normalize(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Trait.fromJson(String source) =>
      Trait.fromMap(json.decode(source) as Map<String, dynamic>);
}
