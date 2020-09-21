import 'dart:async';
import '../../bullet_train.dart';
import 'tools/security.dart';

class StorageProvider with SecureStore {
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
    return decrypted;
  }

  @override
  Future<bool> setSecuredValue(String key, String value,
      {bool update = false}) async {
    var encrypted = _storageSecurity.encrypt(value);
    if (update) {
      return await _store.update(key, encrypted);
    }
    return await _store.create(key, encrypted);
  }

  Future<bool> create(String key, Flag item) async {
    var result = setSecuredValue(key, item.toJson());
    return result;
  }

  Future<bool> delete(String key) => _store.delete(key);

  Future<Flag> read(String key) async {
    var decrypted = await getSecuredValue(key);
    return Flag.fromJson(decrypted);
  }

  Future<bool> update(String key, Flag item) =>
      setSecuredValue(key, item.toJson(), update: true);

  Future<bool> clear() async {
    await _store.clear();
    return true;
  }

  Future<List<Flag>> getAll() async {
    var list = await _store.getAll();
    return list.map((item) {
      var decrypted = _storageSecurity.decrypt(item);
      return Flag.fromJson(decrypted);
    }).toList();
  }

  Future<bool> saveAll(List<Flag> items) async {
    for (var item in items) {
      await create(item.key, item);
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
