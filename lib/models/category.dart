import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/providers/db_item.dart';

class Category extends DbItem {
  final String id;
  final String name;
  final String iconName;
  final Color color;
  final int order;

  IconData get icon => icons[iconName];
  String get title => name ?? "<name>";

  static IconData get defaultIcon => icons["pin"];

  static final Map<String, IconData> icons = {
    "flag": Entypo.flag,
    "game_controller": Entypo.game_controller,
    "pin": Entypo.pin,
    "code": Entypo.code,
    "book": Entypo.book,
    "credit": Entypo.credit,
    "credit_card": Entypo.credit_card,
    "graduation_cap": Entypo.graduation_cap,
    "help": Entypo.help,
    "home": Entypo.home,
    "info": Entypo.info,
    "language": Entypo.language,
    "leaf": Entypo.leaf,
    "shopping_cart": Entypo.shopping_cart,
    "star": Entypo.star,
    "tools": Entypo.tools,
    "beamed_note": Entypo.beamed_note,
    "bowl": Entypo.bowl,
    "drink": Entypo.drink,
    "flower": Entypo.flower,
  };

  static final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  const Category({
    @required this.id,
    @required this.name,
    this.iconName = "pin",
    this.color = AppColour.colorCustom,
    this.order = 0,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        iconName: map['iconName'] ?? "flag",
        color: map['color'] == null ? Colors.grey : Color(map['color']),
        order: map['order'] ?? 0,
      );

  factory Category.Reordered(Category category, int newOrder) => Category(
        id: category.id,
        name: category.name,
        iconName: category.iconName,
        color: category.color,
        order: newOrder,
      );

  factory Category.defaultCategory() => Category(
        id: null,
        name: "Default",
        order: 9223372036854775807,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'color': color.value,
        'order': order
      };
}
