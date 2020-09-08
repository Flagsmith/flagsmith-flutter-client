import '../model/flag.dart';

/// Abstract for CRUD operations over storage
abstract class CrudStore<T extends Flag> {
  Flag create(Flag flag);
  Flag read(String id);
  Flag update(Flag flag);
  void delete(String id);
  List<Flag> getAll();
  void clear();
}
