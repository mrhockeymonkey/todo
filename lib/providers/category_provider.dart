import 'package:todo/models/category.dart';
import 'package:todo/providers/provider_base.dart';

class CategoryProvider extends ProviderBase<Category> {
  CategoryProvider({
    required String tableName,
  }) : super(tableName: tableName);

  @override
  Category parse(Map<String, dynamic> json) => Category.fromMap(json);

  List<Category> get items {
    var items = [...super.items];
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  Category getCategoryOrDefault(String? categoryId) {
    if (categoryId == null) return Category.defaultCategory();

    if (itemsMap.containsKey(categoryId)) {
      return itemsMap[categoryId]!;
    }

    return Category.defaultCategory(); // TODO null-object
  }
}
