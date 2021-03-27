import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'flag_type.dart';
import '../extensions/flag_type_x.dart';
import '../extensions/string_x.dart';

/// Standard Flagsmith feature
class Feature extends Equatable {
  final int id;
  final String name;
  final DateTime createdDate;
  final String initialValue;
  final FlagType type;
  final String description;
  @override
  List<Object> get props =>
      [id, name, createdDate, initialValue, type, description];
  @override
  bool get stringify => true;
  Feature(
    this.id,
    this.name,
    this.createdDate,
    this.initialValue,
    this.type,
    this.description,
  );
  Feature.named({
    this.id,
    this.name,
    this.createdDate,
    this.initialValue,
    this.type,
    this.description,
  });

  Feature copyWith({
    int id,
    String name,
    DateTime createdDate,
    String initialValue,
    FlagType type,
    String description,
  }) {
    return Feature(
      id ?? this.id,
      name ?? this.name,
      createdDate ?? this.createdDate,
      initialValue ?? this.initialValue,
      type ?? this.type,
      description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name?.normalize(),
      'created_date': createdDate?.toIso8601String(),
      'initial_value': initialValue,
      'type': type?.toMap(),
      'description': description,
    };
  }

  factory Feature.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    return Feature(
      map['id'] as int,
      (map['name'] as String)?.normalize(),
      map['created_date'] != null
          ? DateTime.parse(map['created_date'] as String)
          : null,
      map['initial_value']?.toString(),
      FlagTypeX.fromMap(map['type'] as String),
      map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Feature.fromJson(String source) =>
      Feature.fromMap(json.decode(source) as Map<String, dynamic>);
}
