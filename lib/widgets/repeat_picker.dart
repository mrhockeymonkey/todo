import 'package:flutter/material.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'package:todo/widgets/repeat_picker_date_choice.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class RepeatPicker extends StatefulWidget {
  final RepeatSchedule repeatPickerAnswer;

  const RepeatPicker(this.repeatPickerAnswer, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _RepeatPickerState();
  }
}

class _RepeatPickerState extends State<RepeatPicker> {
  final List<int> repeatAmmountChoice = List<int>.generate(31, (i) => (i + 1));
  final List<PeriodType> periodTypeOptions = PeriodType.all;

  late final List<RepeatPickerDateChoice> dateChoices;

  late RepeatSchedule answer;

  @override
  void initState() {
    super.initState();
    answer = widget.repeatPickerAnswer;
    dateChoices = List.generate(
        31,
        (index) => RepeatPickerDateChoice(
              index + 1,
              answer.dates.contains(index + 1),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _buildDialog(),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(answer),
        ),
      ],
    );
  }

  Widget _buildDialog() => SizedBox(
        height: 250,
        width: 100,
        child: DefaultTabController(
          length: 2,
          initialIndex:
              answer.type.value == const ScheduleType.periodic().value ? 0 : 1,
          child: Column(children: [
            const TabBar(tabs: [
              Text(
                "Periodically",
                style: TextStyle(color: Colors.black),
              ),
              Text(
                "On Dates",
                style: TextStyle(color: Colors.black),
              ),
            ]),
            Expanded(
              child: TabBarView(children: [
                _buildPeriodicSelector(),
                _buildDateSelector(),
              ]),
            ),
          ]),
        ),
      );

  Widget _buildDateSelector() {
    return GridView.count(
        crossAxisCount: 7,
        children: List.generate(
          dateChoices.length,
          (index) {
            var choice = dateChoices[index];
            return Container(
                padding: const EdgeInsets.all(3),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      choice.isSelected = !choice.isSelected;
                      answer = answer.copyWith(
                        type: const ScheduleType.onDates(),
                        dates: dateChoices
                            .where((choice) => choice.isSelected)
                            .map((choice) => choice.date)
                            .toList(),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(0.0),
                    backgroundColor:
                        choice.isSelected ? Colors.blue : Colors.grey[300],
                    foregroundColor: Colors.red,
                  ),
                  child: Text(
                    choice.date.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                ));
          },
        ));
  }

  Widget _buildPeriodicSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 60,
          height: 140,
          child: WheelChooser.custom(
            startPosition:
                repeatAmmountChoice.indexOf(widget.repeatPickerAnswer.period),
            children: repeatAmmountChoice
                .map((e) => Text(
                      e.toString(),
                      style: TextStyle(
                          color: widget.repeatPickerAnswer.period == e
                              ? Colors.black
                              : Colors.grey),
                    ))
                .toList(),
            onValueChanged: (index) {
              setState(() {
                answer = answer.copyWith(
                    type: const ScheduleType.periodic(),
                    period: repeatAmmountChoice.elementAt(index));
              });
            },
          ),
        ),
        SizedBox(
          width: 90,
          height: 140,
          child: WheelChooser.custom(
            startPosition:
                periodTypeOptions.indexOf(widget.repeatPickerAnswer.periodType),
            children: periodTypeOptions
                .map((periodType) => Text(
                      periodType.value,
                      style: TextStyle(
                          color:
                              widget.repeatPickerAnswer.periodType == periodType
                                  ? Colors.black
                                  : Colors.grey),
                    ))
                .toList(),
            onValueChanged: (index) {
              setState(() {
                answer = answer.copyWith(
                    type: const ScheduleType.periodic(),
                    periodType: periodTypeOptions.elementAt(index));
              });
            },
          ),
        ),
      ],
    );
  }
}
