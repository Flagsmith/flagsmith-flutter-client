import 'package:flutter/foundation.dart';

import '../model/flag.dart';
import '../store/crud_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Sembast persistent storage
class PersistantStore<T extends Flag> implements CrudStore<T> {
  Database _db;
  StoreRef _store;

  final String databasePath;

  /// [path] should be place where is stored your db file with [databaseName].
  ///
  /// ```dart
  /// final appDir = await getApplicationDocumentsDirectory();
  /// await appDir.create(recursive: true);
  /// final databasePath = join(appDir.path, 'bullt_train.db');
  ///
  /// PersistentStore(databasePath: databasePath);
  /// ```
  PersistantStore({@required this.databasePath}) : assert(databasePath != null);

  /// Initialization of storage for sembast with path
  @override
  Future<void> init() async {
    _db = await databaseFactoryIo.openDatabase(databasePath);
    _store = stringMapStoreFactory.store('feature_flags');
    return null;
  }

  /// save [item] if missing
  @override
  Future<void> create(T item) async {
    await _store.add(_db, item.toMap());
  }

  /// delete [item]
  @override
  Future<void> delete(T item) async {
    final finder = Finder(filter: Filter.byKey(item.key));
    return await _store.delete(_db, finder: finder);
  }

  /// regturns all saved flags [List<Flag>]
  @override
  Future<List<T>> getAll() async {
    final recordSnapshot = await _store.find(_db);
    var items = recordSnapshot.map((snapshot) {
      final student = Flag.fromMap(snapshot.value as Map<String, dynamic>);
      return student as T;
    }).toList();
    return items;
  }

  /// read saved by [id]
  /// Retruns [Flag] or [null]
  @override
  Future<T> read(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    var result = await _store.findFirst(_db, finder: finder);
    return Flag.fromMap(result.value as Map<String, dynamic>) as T;
  }

  /// update or create [item]
  @override
  Future<void> update(T item) async {
    await _store.record(item.key)?.update(_db, item.toMap());
    return null;
  }

  /// Clear
  @override
  Future<void> clear() async {
    var count = await _store.count(_db);
    if (count > 0) {
      await _store.delete(_db);
    }

    return null;
  }

  @override
  Future<void> seed(List<T> items) async {
    await _db.transaction((transaction) async {
      var list = items?.map((e) => e.toMap())?.toList() ?? [];
      if (list.isNotEmpty) {
        await _store.addAll(transaction, list);
      }
    });
    return null;
  }
}
