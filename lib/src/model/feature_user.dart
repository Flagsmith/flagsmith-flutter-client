import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Personalized user
class FeatureUser extends Equatable {
  final String? identifier;
  const FeatureUser({
    this.identifier,
  });
  @override
  List<Object?> get props => [identifier];

  @override
  bool get stringify => true;

  /// copy [FeatureUser] to new instance
  FeatureUser copyWith({
    String? identifier,
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
    return FeatureUser(
      identifier: map['identifier'] as String?,
    );
  }

  /// conve [FeatureUser] to Json string
  String toJson() => json.encode(toMap());

  factory FeatureUser.fromJson(String source) =>
      FeatureUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
