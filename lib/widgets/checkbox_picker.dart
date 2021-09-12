import 'package:flutter/material.dart';

class CheckboxPicker extends StatefulWidget {
  final Function updateValue;
  final bool initialValue;

  CheckboxPicker({
    @required this.updateValue,
    @required this.initialValue,
  });

  @override
  State<StatefulWidget> createState() {
    return _CheckboxPickerState();
  }
}

class _CheckboxPickerState extends State<CheckboxPicker> {
  bool currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: currentValue,
      onChanged: (bool newValue) {
        setState(() {
          currentValue = newValue;
          widget.updateValue(newValue);
        });
      },
    );
  }
}
