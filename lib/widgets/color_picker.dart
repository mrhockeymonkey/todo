import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';

class ColorPicker extends StatefulWidget {
  final Function updateIconValue;

  const ColorPicker(this.updateIconValue, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> colorChoice = Category.colors;
  Color currentColor = Colors.red;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Color>(
      value: currentColor,
      items: colorChoice.map((Color col) {
        return DropdownMenuItem<Color>(
          value: col,
          child: SizedBox(
            height: 20,
            width: 20,
            child: Container(
              color: col,
            ),
          ),
        );
      }).toList(),
      onChanged: (Color? newValue) {
        setState(() {
          currentColor = newValue ?? currentColor;
          widget.updateIconValue(newValue);
        });
      },
    );
  }
}
