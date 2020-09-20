import 'package:flutter/foundation.dart';
import '../../bullet_train.dart';
import 'tools/security.dart';

class StorageProvider extends CrudStore with SecureStore {
  StorageSecurity _storageSecurity;
  final ExtendCrudStore _store;
  StorageProvider(this._store, {String password}) {
    _storageSecurity = StorageSecurity(password);
    _store.init();
  }

  @override
  Future<String> getSecuredValue(String key) async {
    var item = await _store.read(key);
    var decrypted = _storageSecurity.decrypt(item);
    debugPrint('_getString: $key : stored: $item  decrypted: [$decrypted]');
    return decrypted;
  }

  @override
  Future<bool> setSecuredValue(String key, String value,
      {bool update = false}) async {
    var encrypted = _storageSecurity.encrypt(value);
    debugPrint(
        ' ${update ? '_updateString' : '_setString'}: $key : store: $value encrypted: [$encrypted]');
    if (update) {
      return await _store.update(key, encrypted);
    }
    return await _store.create(key, encrypted);
  }

  @override
  Future<bool> create(String key, String item) => setSecuredValue(key, item);

  @override
  Future<bool> delete(String key) => _store.delete(key);

  @override
  Future<String> read(String key) => getSecuredValue(key);

  @override
  Future<bool> update(String key, String item) =>
      setSecuredValue(key, item, update: true);

  Future<bool> clear() => _store.clear();

  Future<List<Flag>> getAll() async {
    var list = await _store.getAll();
    return list.map((item) {
      var decrypted = _storageSecurity.decrypt(item);
      return Flag.fromJson(decrypted);
    }).toList();
  }

  Future<bool> saveAll(List<Flag> items) async {
    for (var item in items) {
      await create(item.key, item.toJson());
    }
    return true;
  }

  Future<bool> seed(List<Flag> items) async {
    var list = items
        ?.map((e) => MapEntry(e.key, _storageSecurity.encrypt(e.toJson())))
        ?.toList();
    return await _store.seed(list);
  }
}
