import 'package:flutter/foundation.dart';

import '../../bullet_train.dart';

extension FlagTypeName on FlagType {
  String get name => describeEnum(this).toUpperCase();
}
