import 'package:bullet_train/bullet_train.dart';

final apiKey = '74acvNqePTwZZdUtESiV7f';
final seeds = [
  Flag.named(
      id: 2020,
      feature: Feature.named(
          id: 3001,
          name: 'my_feature',
          createdDate: DateTime.now().toUtc().add(Duration(days: -5)),
          type: FlagType.flag),
      enabled: true),
  Flag.named(
      id: 2021,
      feature: Feature.named(
          id: 3002,
          name: 'enabled_feature',
          createdDate: DateTime.now().toUtc().add(Duration(days: -6)),
          type: FlagType.flag),
      enabled: true)
];
