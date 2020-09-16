import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'feature.dart';

@immutable
class Flag {
  final int id;
  final Feature feature;
  final String stateValue;
  final bool enabled;

  Flag(
    this.id,
    this.feature,
    this.stateValue,
    this.enabled,
  );
  Flag.named({
    this.id,
    this.feature,
    this.stateValue,
    this.enabled,
  });

  Flag copyWith({
    int id,
    Feature feature,
    String stateValue,
    bool enabled,
  }) {
    return Flag(
      id ?? this.id,
      feature ?? this.feature,
      stateValue ?? this.stateValue,
      enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'feature': feature?.toMap(),
      'feature_state_value': stateValue,
      'enabled': enabled,
    };
  }

  factory Flag.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    return Flag(
      map['id'] as int,
      Feature.fromMap(map['feature'] as Map<String, dynamic>),
      map['feature_state_value']?.toString(),
      map['enabled'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Flag.fromJson(String source) =>
      Flag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Flag(id: $id, feature: $feature, stateValue: $stateValue, enabled: $enabled)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is Flag &&
        o.id == id &&
        o.feature == feature &&
        o.stateValue == stateValue &&
        o.enabled == enabled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        feature.hashCode ^
        stateValue.hashCode ^
        enabled.hashCode;
  }

  String get key => id.toString();
}
