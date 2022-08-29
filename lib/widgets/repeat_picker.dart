import 'package:flutter/material.dart';

class RepeatPicker extends StatefulWidget {
  final Function updateRepeatValues;

  RepeatPicker(this.updateRepeatValues);

  @override
  State<StatefulWidget> createState() {
    return _RepeatPickerState();
  }
}

class _RepeatPickerState extends State<RepeatPicker> {
  static final List<String> repeatAmmountChoice =
      List<String>.generate(31, (i) => (i + 1).toString());
  static const List<String> repeatDenominationChoice = [
    'minutes',
    'hours',
    'days',
    'weeks',
    'months'
  ];
  String repeatAmmountValue = repeatAmmountChoice[0];
  String repeatDenominationValue = repeatDenominationChoice[2];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("Every "),
        DropdownButton<String>(
          value: repeatAmmountValue,
          items: repeatAmmountChoice.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              repeatAmmountValue = newValue ?? repeatAmmountValue;
              widget.updateRepeatValues(
                  repeatAmmountValue, repeatDenominationValue);
            });
          },
        ),
        DropdownButton<String>(
          value: repeatDenominationValue,
          items: repeatDenominationChoice.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              repeatDenominationValue = newValue ?? repeatDenominationValue;
              widget.updateRepeatValues(
                  repeatAmmountValue, repeatDenominationValue);
            });
          },
        ),
      ],
    );
  }
}
