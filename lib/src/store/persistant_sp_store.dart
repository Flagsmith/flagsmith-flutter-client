import '../../bullet_train.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SharedPrefsStore extends CrudStore {
  SharedPrefsStore._internal(this._store, this._password);

  static SharedPrefsStore _instance;

  static Future<CrudStore> getInstance(
      {SharedPreferences store, String password = 'bullet_train_sdk'}) async {
    if (_instance == null) {
      store ??= await SharedPreferences.getInstance();
      _instance = SharedPrefsStore._internal(store, password);
    }

    return _instance;
  }

  final SharedPreferences _store;
  final String _password;

  Future<bool> containsKey(String key) async {
    return Future<bool>.value(_store.containsKey(key));
  }

  String decrypt(String value) {}
  String crypt(String value) {
    var bytes = utf8.encode(value);
    var digets = sha1.convert(bytes);
    return digets.toString();
  }

  @override
  Future<void> clear() {
    return _store.clear();
  }

  @override
  Future<void> create(Flag item) async {
    return await _store.setString(item.key, item.toJson());
  }

  @override
  Future<void> delete(Flag item) async {
    if (await containsKey(item.key)) {
      await _store.remove(item.key);
    }
    return null;
  }

  @override
  Future<List<Flag>> getAll() async {
    var items = <Flag>[];
    var keys = await _store.getKeys();
    // var x = keys.map((e) async => await read(e)).toList();
    for (var key in keys) {
      var item = await read(key);
      items.add(item);
    }
    return items;
  }

  @override
  Future<void> init() async {
    if (_instance == null) {
      var store = await SharedPreferences.getInstance();
      _instance = SharedPrefsStore._internal(store, '');
    }
  }

  @override
  Future<Flag> read(String id) async {
    if (await containsKey(id)) {
      var item = await _store.getString(id);
      return Flag.fromJson(item);
    }
    return null;
  }

  @override
  Future<void> seed(List<Flag> items) async {
    if (items != null) {
      for (var item in items) {
        await _store.setString(item.key, item.toJson());
      }
    }
    return null;
  }

  @override
  Future<void> update(Flag item) async {
    return await _store.setString(item.key, item.toJson());
  }
}
