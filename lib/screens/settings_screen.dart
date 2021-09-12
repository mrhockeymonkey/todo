import 'package:flutter/material.dart';
import 'package:todo/screens/categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildCategoriesTile(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoriesTile(BuildContext context) => ListTile(
      leading: Icon(Icons.category),
      title: Text("Categories"),
      //subtitle: Text(""),
      //isThreeLine: true,
      onTap: () => Navigator.of(context).pushNamed(CategoriesScreen.routeName));
}
