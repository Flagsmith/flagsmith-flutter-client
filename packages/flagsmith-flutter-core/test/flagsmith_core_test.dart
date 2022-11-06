import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  final InMemoryStorage storage = InMemoryStorage();
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
    final response = await storageProvider.read(myFeature);
    expect(response, isNotNull);
    expect(response!.enabled, isTrue);
  });
  test('Update with enabled false', () async {
    await storageProvider.update(
        myFeature, Flag.seed(myFeature, enabled: false));
    final responseUpdated = await storageProvider.read(myFeature);
    expect(responseUpdated, isNotNull);
    expect(responseUpdated!.enabled, isFalse);
  });
  test('Remove item from storage', () async {
    await storageProvider.delete(myFeature);
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
    final _created = await storageProvider.create(
        'test_feature', Flag.seed('test_feature', enabled: false));
    expect(_created, isTrue);
  });
  test('Save all flags', () async {
    final _created = await storageProvider.saveAll([
      Flag.seed('test_feature_a', enabled: false),
      Flag.seed('test_feature_b', enabled: true)
    ]);
    expect(_created, isTrue);
    final _all = await storageProvider.getAll();
    expect(_all, isNotEmpty);
    expect(
        _all,
        const TypeMatcher<List<Flag>>().having(
            (p0) => p0
                .firstWhereOrNull((element) => element.key == 'test_feature_a'),
            'saved flags containse feature flag `test_feature_a`',
            isNotNull));
  });

  test('Update all flags', () async {
    final _created = await storageProvider.saveAll([
      Flag.seed('test_feature_a', enabled: false),
      Flag.seed('test_feature_b', enabled: true)
    ]);
    expect(_created, isTrue);
    final _all = await storageProvider.getAll();
    expect(_all, isNotEmpty);
    expect(
        _all,
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
