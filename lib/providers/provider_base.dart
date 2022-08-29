import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:todo/models/category.dart';

import 'package:todo/providers/db_item.dart';

abstract class ProviderBase<T extends DbItem> with ChangeNotifier {
  final String tableName;
  final Localstore db = Localstore.instance;
  final Map<String, T> _items = {};

  ProviderBase({
    required this.tableName,
  }) {
    _fetch();
  }

  List<T> get items {
    var items = [..._items.values];
    return items;
  }

  Map<String, T> get itemsMap => _items;

  T getItemById(String id) {
    T? item = _items[id];

    if (item == null) throw "No item found with id $id";
    return item;
  }

  // extending class must provide a way to convert json to T
  T parse(Map<String, dynamic> json);

  Future _fetch() async {
    print("fetching data from '$tableName' table");
    var fetched = await db.collection(tableName).get();
    fetched?.entries?.forEach((element) {
      // assert?
      final T item = parse(element.value);
      print(element.value);
      _items.putIfAbsent(item.id!, () => item);
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

  Future addOrUpdate(T item, {bool notify = true}) async {
    Map<String, dynamic> itemMap = item.toMap();

    if (itemMap['id'] == null) {
      itemMap['id'] = db.collection(tableName).doc().id;
      item = parse(itemMap);
      print("Creating new $tableName item with id '${item.id}'");
    }
    String id = itemMap['id'];
    await db.collection(tableName).doc(id).set(itemMap);
    _items[id] = item;
    print("Saved $tableName item: Id '${item.id}', Item: '$itemMap'");

    if (notify) notifyListeners();
  }

  Future updateAll(List<T> items, {bool notify = true}) async {
    items.forEach((item) async {
      await this.addOrUpdate(item, notify: false);
      //await db.collection(tableName).doc(item.id).set(item.toMap());
      //_items[item.id] = item;
    });

    if (notify) notifyListeners();
  }
}
