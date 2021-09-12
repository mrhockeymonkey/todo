import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';
import 'package:todo/providers/provider_base.dart';

class CategoryProvider extends ProviderBase<Category> {
  CategoryProvider({String tableName}) : super(tableName: tableName);

  @override
  Category parse(Map<String, dynamic> json) => Category.fromMap(json);

  List<Category> get items {
    var items = [...super.items];
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }
}
