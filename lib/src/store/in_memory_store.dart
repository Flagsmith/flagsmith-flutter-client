import 'package:bullet_train/src/model/flag.dart';
import 'package:bullet_train/src/store/crud_store.dart';
import 'package:bullet_train/src/store/exceptions.dart';

/// InMemoryStore storage
class InMemoryStore<T extends Flag> implements CrudStore<T> {
  final Map<String, dynamic> _items = <String, dynamic>{};
  InMemoryStore() {
    init();
  }
  @override
  Future<void> init() async {
    return null;
  }

  /// save [item] if missing
  @override
  Future<void> create(T item) async {
    if (!_items.containsKey(item.key)) {
      _items[item.key] = item.toJson();
    } else {
      throw BulletTrainException(BulletTrainExceptionType.notSaved);
    }
    return item;
  }

  /// delete [item]
  @override
  Future<void> delete(T item) async {
    if (_items.containsKey(item.key)) {
      _items.remove(item.key);
      return;
    }
    throw BulletTrainException(BulletTrainExceptionType.notDeleted);
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
  @override
  Future<T> read(String id) async {
    if (_items.containsKey(id)) {
      var flag = _items[id] as Map<String, dynamic>;
      if (flag != null) {
        return Flag.fromJson(flag) as T;
      }
    }
    throw BulletTrainException(BulletTrainExceptionType.notFound);
  }

  /// update or create [item]
  @override
  Future<void> update(T item) async {
    if (_items.containsKey(item.key)) {
      _items[item.key] = item.toJson();
      return null;
    }
    throw BulletTrainException(BulletTrainExceptionType.notSaved);
  }

  /// regturns all saved flags [List<Flag>]
  @override
  Future<List<T>> getAll() async {
    var result = <T>{};
    _items.forEach((key, dynamic value) {
      print('\nkey: $key value: $value');
      result.add(Flag.fromJson(value as Map<String, dynamic>) as T);
    });
    return result.toList();
  }

  /// Clear
  @override
  Future<void> clear() async {
    return await _items.clear();
  }
}
