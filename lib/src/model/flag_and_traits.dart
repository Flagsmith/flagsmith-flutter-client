import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'index.dart';

class FlagAndTraits extends Equatable {
  final List<Flag>? flags;
  final List<Trait>? traits;
  @override
  List<Object?> get props => [flags, traits];
  @override
  bool get stringify => true;
  FlagAndTraits({
    this.flags,
    this.traits,
  });

  FlagAndTraits copyWith({
    List<Flag>? flags,
    List<Trait>? traits,
  }) {
    return FlagAndTraits(
      flags: flags ?? this.flags,
      traits: traits ?? this.traits,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flags': flags?.map((x) => x.toMap()).toList(),
      'traits': traits?.map((x) => x.toMap()).toList(),
    };
  }

  factory FlagAndTraits.fromMap(Map<String, dynamic> map) {
    return FlagAndTraits(
      flags: List<Flag>.from(map['flags']
              ?.map((dynamic x) => Flag.fromMap(x as Map<String, dynamic>))
          as Iterable<dynamic>),
      traits: List<Trait>.from(map['traits']
              ?.map((dynamic x) => Trait.fromMap(x as Map<String, dynamic>))
          as Iterable<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory FlagAndTraits.fromJson(String source) =>
      FlagAndTraits.fromMap(json.decode(source) as Map<String, dynamic>);
}
