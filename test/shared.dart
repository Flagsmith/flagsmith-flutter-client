import 'package:flagsmith/flagsmith.dart';

final apiKey = 'CoJErJUXmihfMDVwTzBff4';
final seeds = [
  Flag.seed('my_feature', enabled: true),
  Flag.seed('enabled_feature', enabled: true),
  Flag.seed('enabled_value', enabled: true, value: '2.0.0')
];
