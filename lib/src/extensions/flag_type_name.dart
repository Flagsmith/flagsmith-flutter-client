import '../../flagsmith.dart';

extension FlagTypeName on FlagType {
  String get name => enumToName(this).toUpperCase();
}

String enumToName(Object enumEntry) {
  final description = enumEntry.toString();
  final indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}
