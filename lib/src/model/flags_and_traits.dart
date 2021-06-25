import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'index.dart';

class FlagsAndTraits extends Equatable {
  final List<Flag>? flags;
  final List<Trait>? traits;
  @override
  List<Object?> get props => [flags, traits];
  @override
  bool get stringify => true;
  FlagsAndTraits({
    this.flags = const <Flag>[],
    this.traits = const <Trait>[],
  });

  FlagsAndTraits copyWith({
    List<Flag>? flags,
    List<Trait>? traits,
  }) {
    return FlagsAndTraits(
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

  factory FlagsAndTraits.fromMap(Map<String, dynamic> map) {
    return FlagsAndTraits(
      flags: List<Flag>.from(map['flags']
              ?.map((dynamic x) => Flag.fromMap(x as Map<String, dynamic>))
          as Iterable<dynamic>),
      traits: List<Trait>.from(map['traits']
              ?.map((dynamic x) => Trait.fromMap(x as Map<String, dynamic>))
          as Iterable<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory FlagsAndTraits.fromJson(String source) =>
      FlagsAndTraits.fromMap(json.decode(source) as Map<String, dynamic>);
}
