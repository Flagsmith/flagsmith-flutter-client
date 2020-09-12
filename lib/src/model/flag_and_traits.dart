import 'dart:convert';
import 'package:collection/collection.dart';
import 'index.dart';

class FlagAndTraits {
  List<Flag> flags;
  List<Trait> traits;
  FlagAndTraits({
    this.flags,
    this.traits,
  });

  FlagAndTraits copyWith({
    List<Flag> flags,
    List<Trait> traits,
  }) {
    return FlagAndTraits(
      flags: flags ?? this.flags,
      traits: traits ?? this.traits,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flags': flags?.map((x) => x?.toMap())?.toList(),
      'traits': traits?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory FlagAndTraits.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

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

  @override
  String toString() => 'FlagAndTraits(flags: $flags, traits: $traits)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    final listEquals = const DeepCollectionEquality().equals;

    return o is FlagAndTraits &&
        listEquals(o.flags, flags) &&
        listEquals(o.traits, traits);
  }

  @override
  int get hashCode => flags.hashCode ^ traits.hashCode;
}
