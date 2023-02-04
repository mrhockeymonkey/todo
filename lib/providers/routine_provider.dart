import 'package:todo/models/routine.dart';
import 'package:todo/providers/provider_base.dart';

class RoutineProvider extends ProviderBase<Routine> {
  RoutineProvider({
    required String tableName,
  }) : super(tableName: tableName);

  @override
  Routine parse(Map<String, dynamic> json) => Routine.fromJson(json);

  @override
  List<Routine> get items {
    var items = [...super.items];
    items.sort((a, b) => b.percent.compareTo(a.percent));
    return items;
  }

  int get isDueCount => items.where((r) => r.isDue).length;
}
