/// Bullet Train SDK for Flutter
///
/// Bullet Train allows you to manage feature flags and remote config across multiple projects, environments and organisations.
library bullet_train;

import 'package:flutter/material.dart';

export 'src/bullet_train_client.dart';
export 'src/bullet_train_config.dart';
export 'src/model/index.dart';
export 'src/extensions/index.dart';
export 'src/store/index.dart';

bool bulletTrainDebug = false;
void log(String message) {
  if (bulletTrainDebug) {
    debugPrint(message);
  }
}
