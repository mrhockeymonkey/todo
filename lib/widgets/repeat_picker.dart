import 'package:flutter/material.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/app_constants.dart';
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

  late final double width = MediaQuery.of(context).size.width * 0.8;
  late final List<RepeatPickerDateChoice> dateChoices;

  int _selectedTab = 0;
  late RepeatSchedule answer;

  @override
  void initState() {
    super.initState();
    answer = widget.repeatPickerAnswer;
    _selectedTab =
        answer.type.value == const ScheduleType.periodic().value ? 0 : 1;
    dateChoices = List.generate(
        31,
        (index) => RepeatPickerDateChoice(
              index + 1,
              answer.dates.contains(index + 1),
            ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //width = MediaQuery.of(context).size.width * 0.8;
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

  Widget _buildDialog() {
    return SizedBox(
      // height: 250,
      width: width,
      child: DefaultTabController(
        length: 2,
        initialIndex: _selectedTab,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              onTap: (value) => setState(() {
                _selectedTab = value;
              }),
              tabs: const [
                Text(
                  "Periodically",
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  "On Dates",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            // TabBarView has unbounded heigh so cannot be used here
            // Builder repaces it, see https://stackoverflow.com/questions/54642710/tabbarview-with-dynamic-container-height
            Builder(builder: (_) {
              if (_selectedTab == 0) {
                return _buildPeriodicSelector();
              } else if (_selectedTab == 1) {
                return _buildDateSelector();
              } else {
                return Container(); //3rd tabView
              }
            })
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final int nbrCircleLine = width ~/
        (AppConstants.pickerCircleSize + AppConstants.pickerCircleSpacing);

    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: AppConstants.pickerCircleSpacing,
      mainAxisSpacing: AppConstants.pickerCircleSpacing,
      crossAxisCount: nbrCircleLine,
      shrinkWrap: true,
      children: _buildDatesButtons(),
    );
  }

  List<Widget> _buildDatesButtons() {
    return dateChoices.map((e) => _buildDateButton(e)).toList();
  }

  Widget _buildDateButton(RepeatPickerDateChoice dateChoice) {
    return Material(
      elevation: 0.0,
      shape: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor:
            dateChoice.isSelected ? AppColour.colorCustom : Colors.grey[100],
        child: Container(
            alignment: Alignment.center,
            child: TextButton(
              child: Text(
                dateChoice.date.toString(),
                style: TextStyle(
                    color: dateChoice.isSelected
                        ? Colors.white
                        : AppColour.colorCustom),
              ),
              onPressed: () => setState(() {
                dateChoice.isSelected = !dateChoice.isSelected;
                answer = answer.copyWith(
                  type: const ScheduleType.onDates(),
                  dates: dateChoices
                      .where((choice) => choice.isSelected)
                      .map((choice) => choice.date)
                      .toList(),
                );
              }),
            )),
      ),
    );
  }

  Widget _buildPeriodicSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 60,
          height: 140,
          child: WheelChooser.custom(
            startPosition: repeatAmmountChoice.indexOf(answer.period),
            children: repeatAmmountChoice
                .map((e) => Text(
                      e.toString(),
                      style: TextStyle(
                          color:
                              answer.period == e ? Colors.black : Colors.grey),
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
            startPosition: periodTypeOptions.indexOf(answer.periodType),
            children: periodTypeOptions
                .map((periodType) => Text(
                      periodType.value,
                      style: TextStyle(
                          color: answer.periodType == periodType
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
