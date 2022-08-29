import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

import 'package:todo/providers/db_item.dart';

abstract class ProviderBase<T extends DbItem> with ChangeNotifier {
  final String tableName;
  final Localstore db = Localstore.instance;
  final Map<String, T> _items = {};

  ProviderBase({
    this.tableName,
  }) {
    _fetch();
  }

  List<T> get items {
    var items = [..._items.values];
    return items;
  }

  T getItemById(String id) => _items[id];

  // extending class must provide a way to convert json to T
  T parse(Map<String, dynamic> json);

  Future _fetch() async {
    print("fetching data from '$tableName' table");
    var fetched = await db.collection(tableName).get();
    fetched?.entries?.forEach((element) {
      final T item = parse(element.value);
      print(element.value);
      _items.putIfAbsent(item.id, () => item);
    });
    notifyListeners();
  }

  Future delete(String id, {bool notify: true}) async {
    print("Deleting $tableName item with id $id");
    await db.collection(tableName).doc(id).delete();
    _items.remove(id);
    if (notify) {
      notifyListeners();
    }
  }

  Future addOrUpdate(T item) async {
    if (item.id == null) {
      var itemMap = item.toMap();
      itemMap['id'] = db.collection(tableName).doc().id;
      item = parse(itemMap);
      // Routine.fromMap(routineMap);
      print("Creating new $tableName item with id '${item.id}'");
    }

    await db.collection(tableName).doc(item.id).set(item.toMap());
    _items[item.id] = item;
    print("Saved $tableName item: Id '${item.id}', Item: '${item.toMap()}'");
    notifyListeners();
  }

  Future updateAll(List<T> items, {bool notify = true}) async {
    items.forEach((item) async {
      await db.collection(tableName).doc(item.id).set(item.toMap());
      _items[item.id] = item;
    });

    if (notify) {
      notifyListeners();
    }
  }
}
