import 'package:bullet_train/src/model/flag.dart';
import 'package:bullet_train/src/store/crud_store.dart';

class RecordNotFound implements Exception {}

class InMemoryStore<T extends Flag> implements CrudStore<T> {
  final Map<String, dynamic> _items = <String, dynamic>{};

  @override
  Flag create(Flag flag) {
    _items.putIfAbsent(flag.id.toString(), () => flag.toJson());
    return flag;
  }

  @override
  void delete(String id) {
    if (_items.containsKey(id)) {
      _items.remove(id);
    }
    throw RecordNotFound();
  }

  @override
  Flag read(String id) {
    if (_items.containsKey(id)) {
      var flag = _items[id] as Map<String, dynamic>;
      if (flag != null) {
        return Flag.fromJson(flag);
      }
    }
    return null;
  }

  @override
  Flag update(Flag flag) {
    var id = flag.id.toString();
    if (_items.containsKey(id)) {
      _items[id] = flag.toJson();
      return flag;
    } else {
      create(flag);
      return flag;
    }
  }
}
