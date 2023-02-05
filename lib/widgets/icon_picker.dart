import 'package:flutter/material.dart';
import 'package:todo/models/category.dart';

class IconPicker extends StatefulWidget {
  final String currentIcon;
  final Color color;

  const IconPicker({
    required this.currentIcon,
    required this.color,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _IconPickerState();
  }
}

class _IconPickerState extends State<IconPicker> {
  final List<String> iconChoice = Category.icons.keys.toList();
  String currentIconName = "pin";
  late String answer;

  @override
  void initState() {
    super.initState();
    answer = widget.currentIcon;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _buildIconGridView(),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(answer),
        ),
      ],
    );
  }

  Widget _buildIconGridView() {
    var circleSize = 45.0; // TODO expose as variables
    var spacing = 9.0;

    // Size of dialog
    final double width = MediaQuery.of(context).size.width * 0.8;
    final double height = MediaQuery.of(context).size.height * 0.6;
    // Number of circle per line, depend on width and circleSize
    final int nbrCircleLine = width ~/ (circleSize + spacing);

    return SizedBox(
      height: height,
      width: width,
      child: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        crossAxisCount: nbrCircleLine,
        children: _buildIconButtons(),
      ),
    );
  }

  List<Widget> _buildIconButtons() {
    return Category.icons.entries.map((e) => _buildIconButton(e)).toList();
  }

  Widget _buildIconButton(MapEntry<String, IconData> iconPair) {
    var isSelected = iconPair.key == answer;
    return GestureDetector(
        onTap: () => setState(() {
              answer = iconPair.key;
            }),
        child: Material(
          elevation: 0.0, // TODO cold remove Material if not used
          shape: const CircleBorder(),
          child: CircleAvatar(
            backgroundColor: isSelected ? widget.color : Colors.transparent,
            child: IconButton(
              onPressed: () {
                setState(() {
                  answer = iconPair.key;
                });
              },
              icon: Icon(iconPair.value,
                  color: isSelected ? Colors.white : Colors.grey),
            ),
          ),
        ));
  }
}
