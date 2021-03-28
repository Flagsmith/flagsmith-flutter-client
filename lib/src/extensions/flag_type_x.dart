import '../../flagsmith.dart';
import 'package:collection/collection.dart' show IterableExtension;

extension FlagTypeX on FlagType {
  static FlagType? byName(String name) {
    return FlagType.values
        .firstWhereOrNull((e) => e.name == name.toUpperCase());
  }

  static FlagType? fromMap(String? value) {
    if (value == null) {
      return null;
    }
    switch (value) {
      case 'CONFIG':
        return FlagType.config;
      case 'FLAG':
      default:
        return FlagType.flag;
    }
  }

  String toMap() {
    switch (this) {
      case FlagType.config:
        return 'CONFIG';
      case FlagType.flag:
      default:
        return 'FLAG';
    }
  }
}
