import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/providers/db_item.dart';

class Category implements DbItem {
  @override
  final String? id;
  final String name;
  final String iconName;
  final Color color;
  final int order;

  IconData get icon => icons[iconName] ?? defaultIcon;
  String get title => name;

  static IconData get defaultIcon => Entypo.pin;

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
    required this.name,
    this.iconName = "pin",
    this.color = AppColour.colorCustom,
    this.order = 0,
  });

  Category.defaultCategory()
      : id = null,
        name = "Default",
        order = 99999,
        iconName = "pin",
        color = AppColour.colorCustom;

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
        iconName: map['iconName'] ?? "flag",
        color: map['color'] == null ? Colors.grey : Color(map['color']),
        order: map['order'] ?? 0,
      );

  Category copyWith({int? order}) => Category(
        id: id,
        name: name,
        iconName: iconName,
        color: color,
        order: order ?? this.order,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'color': color.value,
        'order': order
      };
}
