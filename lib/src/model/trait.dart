import 'dart:convert';

import 'package:equatable/equatable.dart';
import '../extensions/string_x.dart';
import 'identity.dart';

class Trait extends Equatable {
  final int? id;
  final String key;
  final String value;
  @override
  List<Object?> get props => [id, key, value];
  @override
  bool get stringify => true;
  Trait({
    this.id,
    required this.key,
    required this.value,
  });

  Trait copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return Trait(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trait_key': key,
      'trait_value': value,
    };
  }

  factory Trait.fromMap(Map<String, dynamic> map) {
    return Trait(
      id: map['id'] as int?,
      key: '${map['trait_key'] ?? ''}'.normalize(),
      value: '${map['trait_value'] ?? ''}'.normalize(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Trait.fromJson(String source) =>
      Trait.fromMap(json.decode(source) as Map<String, dynamic>);
}

class IdentityWithTraitsRequest extends Equatable {
  final String identifier;
  final List<Trait> traits;
  @override
  List<Object?> get props => [identifier, traits];
  @override
  bool get stringify => true;
  IdentityWithTraitsRequest({
    required this.identifier,
    required this.traits,
  });

  IdentityWithTraitsRequest copyWith(
      {String? identifier, List<Trait>? traits}) {
    return IdentityWithTraitsRequest(
      identifier: identifier ?? this.identifier,
      traits: traits ?? this.traits,
    );
  }
}

class TraitWithIdentity extends Equatable {
  final Identity identity;
  final String key, value;
  @override
  List<Object?> get props => [identity, key, value];
  @override
  bool get stringify => true;
  TraitWithIdentity({
    required this.identity,
    required this.key,
    required this.value,
  });

  TraitWithIdentity copyWith({
    Identity? identity,
    String? key,
    String? value,
  }) {
    return TraitWithIdentity(
      identity: identity ?? this.identity,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identity': identity.toMap(),
      'trait_key': key,
      'trait_value': value,
    };
  }

  factory TraitWithIdentity.fromMap(Map<String, dynamic> map) {
    return TraitWithIdentity(
      identity: Identity.fromMap(map['identity'] as Map<String, dynamic>),
      key: '${map['trait_key'] ?? ''}'.normalize(),
      value: '${map['trait_value'] ?? ''}'.normalize(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TraitWithIdentity.fromJson(String source) =>
      TraitWithIdentity.fromMap(json.decode(source) as Map<String, dynamic>);
}
