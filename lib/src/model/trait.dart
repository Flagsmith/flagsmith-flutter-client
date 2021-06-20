import 'dart:convert';

import 'package:equatable/equatable.dart';
import '../extensions/string_x.dart';
import 'identity.dart';

class Trait extends Equatable {
  final int? id;
  final String traitKey;
  final String traitValue;
  @override
  List<Object?> get props => [id, traitKey, traitValue];
  @override
  bool get stringify => true;
  Trait({
    this.id,
    required this.traitKey,
    required this.traitValue,
  });

  Trait copyWith({
    int? id,
    String? traitKey,
    String? traitValue,
  }) {
    return Trait(
      id: id ?? this.id,
      traitKey: traitKey ?? this.traitKey,
      traitValue: traitValue ?? this.traitValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trait_key': traitKey,
      'trait_value': traitValue,
    };
  }

  factory Trait.fromMap(Map<String, dynamic> map) {
    return Trait(
      id: map['id'] as int?,
      traitKey: '${map['trait_key'] ?? ''}'.normalize(),
      traitValue: '${map['trait_value'] ?? ''}'.normalize(),
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
  final String traitKey, traitValue;
  @override
  List<Object?> get props => [identity, traitKey, traitValue];
  @override
  bool get stringify => true;
  TraitWithIdentity({
    required this.identity,
    required this.traitKey,
    required this.traitValue,
  });

  TraitWithIdentity copyWith({
    Identity? identity,
    String? traitKey,
    String? traitValue,
  }) {
    return TraitWithIdentity(
      identity: identity ?? this.identity,
      traitKey: traitKey ?? this.traitKey,
      traitValue: traitValue ?? this.traitValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identity': identity.toMap(),
      'trait_key': traitKey,
      'trait_value': traitValue,
    };
  }

  factory TraitWithIdentity.fromMap(Map<String, dynamic> map) {
    return TraitWithIdentity(
      identity: Identity.fromMap(map['identity'] as Map<String, dynamic>),
      traitKey: '${map['trait_key'] ?? ''}'.normalize(),
      traitValue: '${map['trait_value'] ?? ''}'.normalize(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TraitWithIdentity.fromJson(String source) =>
      TraitWithIdentity.fromMap(json.decode(source) as Map<String, dynamic>);
}
