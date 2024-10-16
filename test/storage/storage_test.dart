import 'package:flagsmith/flagsmith.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared.dart';

void main() {
  SharedPreferences.setMockInitialValues(<String, String>{});

  final CoreStorage storage = FlagsmithSharedPreferenceStore();
  late StorageProvider storageProvider;

  setUpAll(() {
    storageProvider =
        StorageProvider(storage, password: 'pa5w0rD', logEnabled: true);
  });

  test('adds one to input values', () async {
    final response = await storageProvider.seed(items: seeds);
    expect(response, true);
    final all = await storageProvider.getAll();
    expect(all.length, seeds.length);
  });
  test('When update value', () async {
    final response = await storageProvider.read(myFeatureName);
    expect(response, isNotNull);
    expect(response!.enabled, isTrue);
  });
  test('Update with enabled false', () async {
    await storageProvider.update(
        myFeatureName, Flag.seed(myFeatureName, enabled: false));
    final responseUpdated = await storageProvider.read(myFeatureName);
    expect(responseUpdated, isNotNull);
    expect(responseUpdated!.enabled, isFalse);
  });
  test('Remove item from storage', () async {
    await storageProvider.delete(myFeatureName);
    final items = await storageProvider.getAll();
    expect(items, isNotEmpty);
    expect(items.length, seeds.length - 1);
  });
  test('Remove item from storage', () async {
    await storageProvider.clear();
    final items = await storageProvider.getAll();
    expect(items, isEmpty);
  });
  test('Create a flag', () async {
    final created = await storageProvider.create(
        'test_feature', Flag.seed('test_feature', enabled: false));
    expect(created, isTrue);
  });
  test('Save all flags', () async {
    final created = await storageProvider.saveAll([
      Flag.seed('test_feature_a', enabled: false),
      Flag.seed('test_feature_b', enabled: true)
    ]);
    expect(created, isTrue);
    final all0 = await storageProvider.getAll();
    expect(all0, isNotEmpty);
    expect(
        all0,
        const TypeMatcher<List<Flag>>().having(
            (p0) => p0
                .firstWhereOrNull((element) => element.key == 'test_feature_a'),
            'saved flags containse feature flag `test_feature_a`',
            isNotNull));
  });

  test('Update all flags', () async {
    final created = await storageProvider.saveAll([
      Flag.seed('test_feature_a', enabled: false),
      Flag.seed('test_feature_b', enabled: true)
    ]);
    expect(created, isTrue);
    final all0 = await storageProvider.getAll();
    expect(all0, isNotEmpty);
    expect(
        all0,
        const TypeMatcher<List<Flag>>().having(
            (p0) => p0
                .firstWhereOrNull((element) => element.key == 'test_feature_a'),
            'saved flags containse feature flag `test_feature_a`',
            isNotNull));
  });

  test('Init storage over', () async {
    storageProvider =
        StorageProvider(storage, password: 'pa5w0rD', logEnabled: true);
    await storageProvider.clear();
    expect(await storageProvider.seed(items: seeds), isTrue);
    expect(await storageProvider.seed(items: seeds), isFalse);
  });

  test('Init storage missing passowrd', () {
    expect(() {
      StorageProvider(storage, password: null, logEnabled: true);
    }, throwsA(isA<AssertionError>()));
  });
}
