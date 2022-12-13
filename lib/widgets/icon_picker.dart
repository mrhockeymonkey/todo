import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';

class IconPicker extends StatefulWidget {
  final Function updateIconValue;

  const IconPicker(this.updateIconValue, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _IconPickerState();
  }
}

class _IconPickerState extends State<IconPicker> {
  final List<String> iconChoice = Category.icons.keys.toList();
  String currentIconName = "pin";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentIconName,
      items: iconChoice.map((String iconName) {
        return DropdownMenuItem<String>(
          value: iconName,
          child: Icon(Category.icons[iconName]),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          currentIconName = newValue ?? currentIconName;
          widget.updateIconValue(newValue);
        });
      },
    );
  }
}
