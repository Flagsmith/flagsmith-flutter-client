import '../model/flag.dart';

/// Abstract for CRUD operations over storage
abstract class CrudStore<T extends Flag> {
  Future<void> create(T item);
  Future<T> read(String id);
  Future<void> update(T item);
  Future<void> delete(T item);
  Future<List<T>> getAll();
  Future<void> clear();
  Future<void> init();
}
