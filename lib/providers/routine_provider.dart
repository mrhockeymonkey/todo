import 'package:todo/models/routine.dart';
import 'package:todo/providers/provider_base.dart';

class RoutineProvider extends ProviderBase<Routine> {
  RoutineProvider({String tableName}) : super(tableName: tableName);

  @override
  Routine parse(Map<String, dynamic> json) => Routine.fromMap(json);

  List<Routine> get items {
    var items = [...super.items];
    items.sort((a, b) => b.percent.compareTo(a.percent));
    return items;
  }

  int get isDueCount => items.where((r) => r.isDue).length;

  List<Routine> get pinnedItems {
    var items = [...super.items];
    //items.sort((a, b) => b.isDone ? -1 : 1);
    return items.where((r) => r.displayOnPinned);
  }

  // Routine getRoutineById(String id) => _items[id];

  // Future<void> fetch() async {
  //   var fetched = await _db.collection(_routines).get();
  //   fetched?.entries?.forEach((element) {
  //     final item = Routine.fromMap(element.value);
  //     print(element.value);
  //     _items.putIfAbsent(item.id, () => item);
  //   });
  //   notifyListeners();
  // }

  // void delete(String id) async {
  //   print("Deleting routine with is ${id.toString()}");
  //   await _db.collection(_routines).doc(id).delete();
  //   _items.remove(id);
  //   notifyListeners();
  // }

  // void addOrUpdate(Routine routine) async {
  //   if (routine.id == null) {
  //     var routineMap = routine.toMap();
  //     routineMap['id'] = _db.collection(_routines).doc().id;
  //     routine = Routine.fromMap(routineMap);
  //     print("Creating new routine with id '${routine.id}'");
  //   }

  //   await _db.collection(_routines).doc(routine.id).set(routine.toMap());
  //   _items[routine.id] = routine;
  //   print("Saved routine: Id '${routine.id}', Title '${routine.title}'");
  //   notifyListeners();
  // }
}
