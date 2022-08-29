import 'package:flutter/material.dart';

class CheckboxPicker extends StatefulWidget {
  final Function updateValue;
  final bool initialValue;

  CheckboxPicker({
    required this.updateValue,
    required this.initialValue,
  });

  @override
  State<StatefulWidget> createState() {
    return _CheckboxPickerState();
  }
}

class _CheckboxPickerState extends State<CheckboxPicker> {
  late final bool currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: currentValue,
      onChanged: (bool? newValue) {
        setState(() {
          currentValue = newValue ?? currentValue;
          widget.updateValue(newValue);
        });
      },
    );
  }
}
