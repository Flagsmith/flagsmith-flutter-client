import '../../../bullet_train.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistantStore extends CrudStore with ExtendCrudStore {
  SharedPreferences _prefs;

  PersistantStore() {
    init();
  }

  Future<bool> containsKey(String key) async {
    return Future<bool>.value(_prefs.containsKey(key));
  }

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> clear() => _prefs.clear();

  @override
  Future<bool> create(String key, String item) async {
    await init();
    if (!await containsKey(key)) {
      return await _prefs.setString(key, item);
    } else {
      return update(key, item);
    }
  }

  @override
  Future<String> read(String key) async {
    await init();
    if (await containsKey(key)) {
      return _prefs.getString(key);
    }
    return null;
  }

  @override
  Future<bool> delete(String key) async {
    await init();
    if (await containsKey(key)) {
      return await _prefs.remove(key);
    }
    return false;
  }

  @override
  Future<List<String>> getAll() async {
    await init();
    var items = <String>[];
    var keys = _prefs.getKeys();
    for (var key in keys) {
      var item = await read(key);
      items.add(item);
    }
    return items;
  }

  @override
  Future<bool> seed(List<MapEntry<String, String>> items) async {
    await init();
    if (items != null && items?.isNotEmpty == true) {
      for (var item in items) {
        await create(item.key, item.value);
      }
    }
    return true;
  }

  @override
  Future<bool> update(String key, String item) async {
    await init();
    if (await containsKey(key)) {
      return await _prefs.setString(key, item);
    }
    throw BulletTrainException(BulletTrainExceptionType.notSaved);
  }
}
