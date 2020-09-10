import 'package:bullet_train/src/model/flag.dart';
import 'package:bullet_train/src/store/crud_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class PersistantStore<T extends Flag> implements CrudStore<T> {
  Database _db;
  StoreRef _store;

  @override
  Future<void> clear() async {
    return await _store.delete(_db);
  }

  @override
  Future<void> create(T item) async {
    _store.add(_db, item.toJson());
  }

  @override
  Future<void> delete(T item) async {
    final finder = Finder(filter: Filter.byKey(item.key));
    return await _store.delete(await _db, finder: finder);
  }

  @override
  Future<List<T>> getAll() async {
    final recordSnapshot = await _store.find(_db);
    return recordSnapshot.map((snapshot) {
      final student = Flag.fromJson(snapshot.value as Map<String, dynamic>);
      return student as T;
    }).toList();
  }

  @override
  Future<T> read(String id) async {
    final finder = Finder(filter: Filter.byKey(id));
    var result = await _store.findFirst(_db, finder: finder);
    return Flag.fromJson(result.value as Map<String, dynamic>) as T;
  }

  @override
  Future<void> update(T flag) async {}

  @override
  Future<void> init() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var path = join(dir.path, 'bullt_train.db');
    _db = await databaseFactoryIo.openDatabase(path);
    _store = stringMapStoreFactory.store('feature_flags');
  }
}
