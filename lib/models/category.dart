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
    this.id,
    this.name,
    this.iconName = "pin",
    this.color = AppColour.colorCustom,
    this.order = 0,
  });

  Category.defaultCategory()
      : this.id = null,
        this.name = "Default",
        this.order = 99999,
        this.iconName = "pin",
        this.color = AppColour.colorCustom;

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        iconName: map['iconName'] ?? "flag",
        color: map['color'] == null ? Colors.grey : Color(map['color']),
        order: map['order'] ?? 0,
      );

  Category copyWith(int order) => Category(
        id: this.id,
        name: this.name,
        iconName: this.iconName,
        color: this.color,
        order: order ?? this.order,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'color': color.value,
        'order': order
      };
}
