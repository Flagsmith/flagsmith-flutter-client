import 'package:bullet_train/src/model/flag.dart';
import 'package:bullet_train/src/store/crud_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Sembast persistent storage
class PersistantStore<T extends Flag> implements CrudStore<T> {
  Database _db;
  StoreRef _store;

  /// Clear
  @override
  Future<void> clear() async {
    return await _store.delete(_db);
  }

  /// save [item] if missing
  @override
  Future<void> create(T item) async {
    _store.add(_db, item.toJson());
  }

  /// delete [item]
  @override
  Future<void> delete(T item) async {
    final finder = Finder(filter: Filter.byKey(item.key));
    return await _store.delete(await _db, finder: finder);
  }

  /// regturns all saved flags [List<Flag>]
  @override
  Future<List<T>> getAll() async {
    final recordSnapshot = await _store.find(_db);
    return recordSnapshot.map((snapshot) {
      final student = Flag.fromJson(snapshot.value as Map<String, dynamic>);
      return student as T;
    }).toList();
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
  @override
  Future<T> read(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    var result = await _store.findFirst(_db, finder: finder);
    return Flag.fromJson(result.value as Map<String, dynamic>) as T;
  }

  /// update or create [item]
  @override
  Future<void> update(T flag) async {}

  /// Initialization of storage for sembast with path
  @override
  Future<void> init() async {
    _db = await databaseFactoryIo.openDatabase('bullt_train.db');
    _store = stringMapStoreFactory.store('feature_flags');
  }
}
