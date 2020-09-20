/// Abstract for CRUD operations over storage
abstract class CrudStore {
  Future<bool> create(String key, String item);
  Future<String> read(String key);
  Future<bool> update(String key, String item);
  Future<bool> delete(String key);
}

mixin ExtendCrudStore on CrudStore {
  Future<bool> clear();
  Future<void> init();
  Future<bool> seed(List<MapEntry<String, String>> items);
  Future<List<String>> getAll();
}
mixin SecureStore {
  Future<String> getSecuredValue(String key);
  Future<bool> setSecuredValue(String key, String value, {bool update = false});
}
