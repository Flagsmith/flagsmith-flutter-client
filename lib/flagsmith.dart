//ignore_for_file: avoid_print
/// Flagsmith SDK for Flutter
///
/// Flagsmith allows you to manage feature flags and remote config across multiple projects, environments and organisations.

library flagsmith;

export 'src/flagsmith_client.dart';
export 'src/flagsmith_config.dart';
export 'src/model/index.dart';
export 'src/extensions/index.dart';
export 'src/store/index.dart';

bool flagsmithDebug = false;
void log(String message) {
  if (flagsmithDebug) {
    print(message);
  }
}
