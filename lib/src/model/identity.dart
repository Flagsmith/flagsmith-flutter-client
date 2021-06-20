import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Personalized user
class Identity extends Equatable {
  final String identifier;
  const Identity({
    required this.identifier,
  });
  @override
  List<Object?> get props => [identifier];

  @override
  bool get stringify => true;

  /// copy [Identity] to new instance
  Identity copyWith({
    String? identifier,
  }) {
    return Identity(
      identifier: identifier ?? this.identifier,
    );
  }

  /// map [Identity] to Json map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'identifier': identifier,
    };
  }

  /// create [Identity] from map
  factory Identity.fromMap(Map<String, dynamic> map) {
    return Identity(
      identifier: map['identifier'] as String,
    );
  }

  /// convert [Identity] to Json string
  String toJson() => json.encode(toMap());

  factory Identity.fromJson(String source) =>
      Identity.fromMap(json.decode(source) as Map<String, dynamic>);
}
