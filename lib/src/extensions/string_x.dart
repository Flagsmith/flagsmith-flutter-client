extension StringX on String {
  String normalize() => toLowerCase()?.trim()?.replaceAll(' ', '_');
}
