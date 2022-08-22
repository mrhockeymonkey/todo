import 'package:todo/models/day_plan.dart';

import 'package:todo/providers/provider_base.dart';

class DayPlanProvider extends ProviderBase<DayPlan> {
  DayPlanProvider({String tableName}) : super(tableName: tableName);

  @override
  DayPlan parse(Map<String, dynamic> json) => DayPlan.fromMap(json);

  @override
  List<DayPlan> get items {
    var items = [...super.items];
    return items;
  } // TODO expresion? what is ...?

  //DayPlan get current => super.items.single;

  DayPlan get current => new DayPlan(date: DateTime.now());

}
