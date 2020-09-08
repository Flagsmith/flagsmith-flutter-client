import 'package:bullet_train/src/model/flag.dart';
import 'package:bullet_train/src/store/crud_store.dart';
import 'package:bullet_train/src/store/exceptions.dart';

/// InMemoryStore for flags
class InMemoryStore<T extends Flag> implements CrudStore<T> {
  final Map<String, dynamic> _items = <String, dynamic>{};

  /// save [flag] if missing
  @override
  Flag create(Flag flag) {
    _items.putIfAbsent(flag.id.toString(), () => flag.toJson());
    return flag;
  }

  /// delete by [id]
  @override
  void delete(String id) {
    if (_items.containsKey(id)) {
      _items.remove(id);
    }
    throw RecordNotFound();
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
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

  /// update or create [flag]
  /// Retruns [Flag]
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

  /// regturns all saved flags [List<Flag>]
  @override
  List<Flag> getAll() {
    var result = <Flag>{};
    _items.forEach((key, dynamic value) {
      result.add(Flag.fromJson(value as Map<String, dynamic>));
    });
    return result.toList();
  }

  /// Clear
  @override
  void clear() {
    _items.clear();
  }
}
