import 'dart:convert';

import 'flag_type.dart';
import 'flag_type_x.dart';

class Feature {
  final int id;
  final String name;
  final DateTime createdDate;
  final FlagType type;
  String description;
  Feature(
    this.id,
    this.name,
    this.createdDate,
    this.type,
    this.description,
  );
  Feature.named({
    this.id,
    this.name,
    this.createdDate,
    this.type,
    this.description,
  });

  Feature copyWith({
    int id,
    String name,
    DateTime createdDate,
    FlagType type,
    String description,
  }) {
    return Feature(
      id ?? this.id,
      name ?? this.name,
      createdDate ?? this.createdDate,
      type ?? this.type,
      description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'created_date': createdDate?.toIso8601String(),
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
      map['name'] as String,
      map['created_date'] != null
          ? DateTime.parse(map['created_date'] as String)
          : null,
      FlagTypeX.fromMap(map['type'] as String),
      map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Feature.fromJson(String source) =>
      Feature.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Feature(id: $id, name: $name, type: $type, description: $description)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is Feature &&
        o.id == id &&
        o.name == name &&
        o.type == type &&
        o.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ type.hashCode ^ description.hashCode;
  }
}
