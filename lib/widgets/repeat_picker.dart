import 'package:flutter/material.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class RepeatPicker extends StatefulWidget {
  final Function updateRepeatValues;

  const RepeatPicker(this.updateRepeatValues, {super.key});

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
        SizedBox(
          width: 60,
          height: 140,
          child: WheelChooser.custom(
            startPosition: repeatAmmountChoice.indexOf(repeatAmmountValue),
            children: repeatAmmountChoice
                .map((e) => Text(
                      e,
                      style: TextStyle(
                          color: repeatAmmountValue == e
                              ? Colors.black
                              : Colors.grey),
                    ))
                .toList(),
            onValueChanged: (index) {
              setState(() {
                repeatAmmountValue = repeatAmmountChoice.elementAt(index);
                widget.updateRepeatValues(
                    repeatAmmountValue, repeatDenominationValue);
              });
            },
          ),
        ),
        SizedBox(
          width: 90,
          height: 140,
          child: WheelChooser.custom(
            startPosition:
                repeatDenominationChoice.indexOf(repeatDenominationValue),
            children: repeatDenominationChoice
                .map((e) => Text(
                      e,
                      style: TextStyle(
                          color: repeatDenominationValue == e
                              ? Colors.black
                              : Colors.grey),
                    ))
                .toList(),
            onValueChanged: (index) {
              setState(() {
                repeatDenominationValue =
                    repeatDenominationChoice.elementAt(index);
                widget.updateRepeatValues(
                    repeatAmmountValue, repeatDenominationValue);
              });
            },
          ),
        ),
      ],
    );
  }
}
