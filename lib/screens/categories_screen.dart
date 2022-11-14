import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/screens/category_detail_screen.dart';
import 'package:todo/widgets/checkbox_picker.dart';
import 'package:todo/widgets/icon_picker.dart';
import 'package:todo/widgets/color_picker.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = '/categories';

  @override
  State<StatefulWidget> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    //Provider.of<CategoryProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: _buildCategoryList(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed(
          CategoryDetailScreen.routeName,
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    print("Build: RoutineList");
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.items;

    final builder = (context, index) {
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
          trailing: Icon(Icons.drag_indicator));
    };

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

  // TODO this could be a stateful widget
  _displayDialog(BuildContext context, String? categoryId) async {
    _textFieldController.clear();
    Category thisCategory;
    if (categoryId != null) {
      thisCategory = Provider.of<CategoryProvider>(context, listen: false)
          .getItemById(categoryId);
    } else {
      thisCategory = Category.defaultCategory();
    }
    String currentCategoryName = thisCategory.name;
    String currentIconName = thisCategory.iconName;
    Color currentColor = thisCategory.color;
    bool isDefaultCategory = false;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Category'),
            content: Column(
              children: [
                Row(
                  children: [
                    Text("Name:"),
                    FittedBox(),
                  ],
                ),
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: currentCategoryName),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (String newName) {
                    currentCategoryName = newName;
                  },
                ),
                Container(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Icon:"),
                    FittedBox(),
                  ],
                ),
                IconPicker((String newName) => currentIconName = newName),
                Container(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Color:"),
                    FittedBox(),
                  ],
                ),
                ColorPicker((Color newColor) => currentColor = newColor),
                Container(
                  height: 20,
                ),
              ],
            ),
            actions: <Widget>[
              categoryId != null
                  ? TextButton(
                      child: Text(
                        "DELETE",
                        style: TextStyle(color: Colors.red[600]),
                      ),
                      onPressed: () {
                        Provider.of<CategoryProvider>(context, listen: false)
                            .delete(categoryId);
                        Navigator.of(context).pop();
                      },
                    )
                  : Container(),
              new TextButton(
                child: new Text('OK'),
                onPressed: () {
                  Provider.of<CategoryProvider>(context, listen: false)
                      .addOrUpdate(Category(
                    id: thisCategory.id,
                    name: currentCategoryName,
                    iconName: currentIconName,
                    color: currentColor,
                  ));
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
