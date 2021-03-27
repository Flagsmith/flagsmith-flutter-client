import 'package:flagsmith/flagsmith.dart';

final apiKey = '74acvNqePTwZZdUtESiV7f';
final seeds = [
  Flag.seed('my_feature', enabled: true),
  Flag.seed('enabled_feature', enabled: true),
  Flag.seed('enabled_value', enabled: true, value: '1.0.0')
];
