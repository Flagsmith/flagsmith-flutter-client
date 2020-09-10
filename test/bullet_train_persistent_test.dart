import 'package:bullet_train/bullet_train.dart';
import 'package:bullet_train/src/bullet_train_client.dart';
import 'package:bullet_train/src/model/feature_user.dart';
import 'package:bullet_train/src/model/flag_type.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiKey = '74acvNqePTwZZdUtESiV7f';
  final seeds = [
    Flag(
        id: 2020,
        feature: Feature(
            id: 3001,
            name: 'my_feature',
            createDate: DateTime.now().add(Duration(days: -5)),
            type: FlagType.flag),
        enabled: true),
    Flag(
        id: 2021,
        feature: Feature(
            id: 3002,
            name: 'enabled_feature',
            createDate: DateTime.now().add(Duration(days: -6)),
            type: FlagType.flag),
        enabled: true)
  ];
  var bulletTrain = BulletTrainClient(
      apiKey: apiKey,
      seeds: seeds,
      config: BulletTrainConfig(usePersistantStorage: true));
  group('persitent_integration', () {
    test('When has seeded Features then success', () async {
      var result = await bulletTrain.getFeatureFlags(reload: false);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });
    test('When has Feature then success', () async {
      var result = await bulletTrain.getFeatureFlags();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get Features then success', () async {
      var result = await bulletTrain.hasFeatureFlag('enabled_feature');
      expect(result, true);
    });

    test('When get Features for user then success', () async {
      var user = FeatureUser(identifier: 'test_sample_user');
      var result = await bulletTrain.getFeatureFlags(user: user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var flag in result) {
        expect(flag, isNotNull);
      }
    });

    test('When get User traits then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTraits(user);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
      for (var trait in result) {
        expect(trait, isNotNull);
      }
    });

    test('When get User traits for invalid user then return empty', () async {
      var user = FeatureUser(identifier: 'invalid_users_another_user');
      var result = await bulletTrain.getTraits(user);

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('When get User trait then success', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTraits(user, keys: ['age']);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('When get User trait Update then Updated', () async {
      var user = FeatureUser(identifier: 'test_another_user');
      var result = await bulletTrain.getTrait(user, 'age');
      expect(result, isNotNull);
      expect(result.value, isNotNull);

      var toUpdate = result.copyWith(value: '25');
      var updateResult = await bulletTrain.updateTrait(user, toUpdate);
      expect(updateResult, isNotNull);
      expect(updateResult.value, '25');
    });
  });
}
