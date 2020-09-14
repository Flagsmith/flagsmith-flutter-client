import '../../bullet_train.dart';

extension FlagTypeX on FlagType {
  static FlagType fromMap(String value) {
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
