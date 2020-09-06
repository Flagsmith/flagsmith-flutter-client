import '../model/flag.dart';

abstract class CrudStore<T extends Flag> {
  Flag create(Flag flag);
  Flag read(String id);
  Flag update(Flag flag);
  void delete(String id);
}
