import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/screens/category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = '/categories';

  const CategoriesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    //Provider.of<CategoryProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: _buildCategoryList(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed(
          CategoryDetailScreen.routeName,
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    debugPrint("Build: RoutineList");
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.items;

    builder(context, index) {
      var category = categories[index];
      return ListTile(
          key: ValueKey(index),
          title: Text(category.title),
          //subtitle: Text("id: ${category.id}, index: $index"),
          leading: Icon(
            Category.icons[category.iconName],
            color: category.color,
          ),
          onTap: () => Navigator.of(context).pushNamed(
              CategoryDetailScreen.routeName,
              arguments: category.id),
          trailing: const Icon(Icons.drag_indicator));
    }

    return ReorderableListView.builder(
      itemBuilder: builder,
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex = newIndex - 1;
          }
          final item = categories.removeAt(oldIndex);
          categories.insert(newIndex, item);
          final reordered = categories
              .asMap()
              .map((index, category) =>
                  MapEntry(index, category.copyWith(order: index)))
              .values
              .toList();
          Provider.of<CategoryProvider>(context, listen: false)
              .updateAll(reordered);
        });
      },
    );
  }
}
