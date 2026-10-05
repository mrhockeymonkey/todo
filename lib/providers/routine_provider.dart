import 'package:todo/models/routine.dart';
import 'package:todo/providers/provider_base.dart';

class RoutineProvider extends ProviderBase<Routine> {
  RoutineProvider({
    required super.tableName,
  });

  @override
  Routine parse(Map<String, dynamic> json) => Routine.fromJson(json);

  @override
  List<Routine> get items {
    var items = [...super.items];
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  int get isDueCount => items.where((r) => r.isDue).length;
}
