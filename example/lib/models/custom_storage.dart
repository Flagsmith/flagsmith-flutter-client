import 'package:flagsmith_flutter_core/flagsmith_flutter_core.dart';

/// CustomInMemoryStore storage
class CustomInMemoryStore extends CoreStorage {
  final Map<String, String> _items = <String, String>{};

  CustomInMemoryStore() {
    init();
  }

  @override
  Future<void> init() async {
    return Future(() => null);
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
      return true;
    }
    return false;
  }

  /// delete [item]
  @override
  Future<bool> delete(String key) async {
    if (_items.containsKey(key)) {
      _items.remove(key);
      return true;
    }
    return false;
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
  @override
  Future<String?> read(String key) async {
    if (_items.containsKey(key)) {
      return Future<String>.value(_items[key]);
    }
    return null;
  }

  /// update or create [item]
  @override
  Future<bool> update(String key, String item) async {
    if (_items.containsKey(key)) {
      _items[key] = item;
      return true;
    }
    return false;
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
  Future<bool> seed(List<MapEntry<String, String>>? items) async {
    var saved = await getAll();
    if (saved.isEmpty && items != null && items.isNotEmpty == true) {
      for (var item in items) {
        await create(item.key, item.value);
      }
      return true;
    }
    return false;
  }
}
