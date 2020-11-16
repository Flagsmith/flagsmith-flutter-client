import '../../model/flag.dart';
import '../crud_store.dart';
import '../tools/exceptions.dart';

/// InMemoryStore storage
class InMemoryStore extends CrudStore with ExtendCrudStore {
  final Map<String, String> _items = <String, String>{};

  InMemoryStore() {
    init();
  }

  @override
  Future<void> init() async {
    return null;
  }

  /// Clear items
  @override
  Future<bool> clear() async {
    _items.clear();
    return true;
  }

  /// save [item] in [key] if missing
  @override
  Future<bool> create(String key, String item) async {
    if (!_items.containsKey(key)) {
      _items[key] = item;
    }
    return update(key, item);
  }

  /// delete [item]
  @override
  Future<bool> delete(String key) async {
    if (_items.containsKey(key)) {
      _items.remove(key);
      return true;
    }
    throw FlagsmithException(FlagsmithExceptionType.notDeleted);
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
  @override
  Future<String> read(String key) async {
    if (_items.containsKey(key)) {
      return Future<String>.value(_items[key]);
    }
    throw FlagsmithException(FlagsmithExceptionType.notFound);
  }

  /// update or create [item]
  @override
  Future<bool> update(String key, String item) async {
    if (_items.containsKey(key)) {
      _items[key] = item;
      return true;
    }
    throw FlagsmithException(FlagsmithExceptionType.notSaved);
  }

  /// regturns all saved flags [List<Flag>]
  @override
  Future<List<String>> getAll() async {
    var result = <String>[];
    _items.forEach((key, String value) {
      result.add(value);
    });
    return result.toList();
  }

  @override
  Future<bool> seed(List<MapEntry<String, String>> items) async {
    var saved = await getAll();
    if (saved.isEmpty && items != null && items?.isNotEmpty == true) {
      for (var item in items) {
        await create(item.key, item.value);
      }
      return true;
    }
    return false;
  }
}
