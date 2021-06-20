import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../extensions/string_x.dart';

/// Standard Flagsmith feature
class Feature extends Equatable {
  final int? id;
  final String name;
  final DateTime? createdDate;
  final String? initialValue;
  final bool? defaultValue;
  final String? description;
  @override
  List<Object?> get props =>
      [id, name, createdDate, initialValue, defaultValue, description];

  @override
  bool get stringify => true;
  Feature(
    this.id,
    this.name,
    this.createdDate,
    this.initialValue,
    this.defaultValue,
    this.description,
  );
  Feature.named({
    this.id,
    required this.name,
    this.createdDate,
    this.initialValue,
    this.defaultValue,
    this.description,
  });

  Feature copyWith({
    int? id,
    String? name,
    DateTime? createdDate,
    String? initialValue,
    bool? defaultValue,
    String? description,
  }) {
    return Feature(
      id ?? this.id,
      name ?? this.name,
      createdDate ?? this.createdDate,
      initialValue ?? this.initialValue,
      defaultValue ?? this.defaultValue,
      description ?? this.description,
      
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name.normalize(),
      'created_date': createdDate?.toIso8601String(),
      'initial_value': initialValue,
      'description': description,
      'initial_value': initialValue,
      'default_value': defaultValue,
      
    };
  }

  factory Feature.fromMap(Map<String, dynamic> map) {
    return Feature(
      map['id'] as int?,
      '${map['name']}'.normalize(),
      map['created_date'] != null
          ? DateTime.parse(map['created_date'] as String)
          : null,
      map['initial_value']?.toString(),
      (map['default_value'] as bool?) ?? false,
      map['description'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Feature.fromJson(String source) =>
      Feature.fromMap(json.decode(source) as Map<String, dynamic>);
}
