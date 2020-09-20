import 'dart:convert';

import 'package:flutter/material.dart';

/// Personalized user
@immutable
class FeatureUser {
  final String identifier;
  FeatureUser({
    this.identifier,
  });

  /// copy [FeatureUser] to new instance
  FeatureUser copyWith({
    String identifier,
  }) {
    return FeatureUser(
      identifier: identifier ?? this.identifier,
    );
  }

  /// map [FeatureUser] to Json map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identifier': identifier,
    };
  }

  /// create [FeatureUser] from map
  factory FeatureUser.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    return FeatureUser(
      identifier: map['identifier'] as String,
    );
  }

  /// conve [FeatureUser] to Json string
  String toJson() => json.encode(toMap());

  factory FeatureUser.fromJson(String source) =>
      FeatureUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'FeatureUser(identifier: $identifier)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is FeatureUser && o.identifier == identifier;
  }

  @override
  int get hashCode => identifier.hashCode;
}
