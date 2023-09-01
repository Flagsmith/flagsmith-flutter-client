extension DateTimeX on DateTime {
  double get secondsSinceEpoch =>
      millisecondsSinceEpoch / Duration.millisecondsPerSecond;
}
