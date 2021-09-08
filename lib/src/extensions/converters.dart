String? stringFromJson(dynamic value) => value == null ? null : '$value';
String nonNullStringFromJson(dynamic value) => '$value';
dynamic stringToJson(Object? value) {
  if (value == null) {
    return null;
  }
  return value;
}
