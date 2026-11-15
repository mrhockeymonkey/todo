import 'package:flutter/material.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

/// Dialog for choosing how a routine repeats: every N days/weeks/..., or on
/// chosen days of the month. Pops the chosen [RepeatSchedule] on OK.
class RepeatPicker extends StatefulWidget {
  final RepeatSchedule repeatPickerAnswer;

  const RepeatPicker(this.repeatPickerAnswer, {super.key});

  @override
  State<StatefulWidget> createState() => _RepeatPickerState();
}

enum _Mode { periodic, onDates }

class _RepeatPickerState extends State<RepeatPicker> {
  static const double _wheelItemSize = 48;
  static const double _wheelHeight = 144;
  static const int _daysInGrid = 31;
  static const int _gridColumns = 7;

  final List<int> _periodChoices = List<int>.generate(31, (i) => i + 1);
  final List<PeriodType> _periodTypes = PeriodType.all;

  late _Mode _mode;
  late int _period;
  late PeriodType _periodType;
  late Set<int> _dates;

  @override
  void initState() {
    super.initState();
    final schedule = widget.repeatPickerAnswer;
    _mode =
        schedule.type.value == const ScheduleType.onDates().value
            ? _Mode.onDates
            : _Mode.periodic;
    _period = schedule.period;
    _periodType = schedule.periodType;
    _dates = schedule.dates.toSet();
  }

  bool get _canSubmit => _mode == _Mode.periodic || _dates.isNotEmpty;

  RepeatSchedule get _answer =>
      _mode == _Mode.periodic
          ? widget.repeatPickerAnswer.copyWith(
            type: const ScheduleType.periodic(),
            period: _period,
            periodType: _periodType,
          )
          : widget.repeatPickerAnswer.copyWith(
            type: const ScheduleType.onDates(),
            dates: (_dates.toList()..sort()),
          );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Repeat"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeSwitch(),
            const SizedBox(height: 24),
            _mode == _Mode.periodic
                ? _buildPeriodicSelector()
                : _buildDateSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              _canSubmit ? () => Navigator.of(context).pop(_answer) : null,
          child: const Text("OK"),
        ),
      ],
    );
  }

  Widget _buildModeSwitch() {
    return SegmentedButton<_Mode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: _Mode.periodic, label: Text("Periodically")),
        ButtonSegment(value: _Mode.onDates, label: Text("On dates")),
      ],
      selected: {_mode},
      onSelectionChanged:
          (selection) => setState(() => _mode = selection.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColour.colorCustom,
        selectedForegroundColor: Colors.white,
        foregroundColor: AppColour.colorCustom,
      ),
    );
  }

  // --- Periodic ---------------------------------------------------------

  Widget _buildPeriodicSelector() {
    const labelStyle = TextStyle(fontSize: 16, color: Colors.black54);
    return SizedBox(
      height: _wheelHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Highlight band behind the selected row of both wheels.
          Container(
            height: _wheelItemSize,
            decoration: BoxDecoration(
              color: AppColour.colorCustom.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Every", style: labelStyle),
              const SizedBox(width: 16),
              SizedBox(width: 56, child: _buildPeriodWheel()),
              const SizedBox(width: 8),
              SizedBox(width: 96, child: _buildUnitWheel()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodWheel() {
    return WheelChooser.custom(
      startPosition: _periodChoices.indexOf(_period),
      itemSize: _wheelItemSize,
      children:
          _periodChoices
              .map((e) => _wheelText(e.toString(), selected: e == _period))
              .toList(),
      onValueChanged:
          (index) => setState(() => _period = _periodChoices[index]),
    );
  }

  Widget _buildUnitWheel() {
    return WheelChooser.custom(
      startPosition: _periodTypes.indexOf(_periodType),
      itemSize: _wheelItemSize,
      children:
          _periodTypes
              .map(
                (type) => _wheelText(
                  _unitLabel(type),
                  selected: type.value == _periodType.value,
                ),
              )
              .toList(),
      onValueChanged:
          (index) => setState(() => _periodType = _periodTypes[index]),
    );
  }

  // "days" -> "day" when the period is 1.
  String _unitLabel(PeriodType type) =>
      _period == 1
          ? type.value.substring(0, type.value.length - 1)
          : type.value;

  Widget _wheelText(String text, {required bool selected}) => Text(
    text,
    style: TextStyle(
      fontSize: selected ? 20 : 16,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      color: selected ? AppColour.colorCustom : Colors.grey,
    ),
  );

  // --- On dates ---------------------------------------------------------

  Widget _buildDateSelector() {
    final sorted = _dates.toList()..sort();
    final skipsShortMonths = sorted.any((d) => d > 28);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rows rather than a GridView, which can't be measured by the dialog.
        for (var start = 1; start <= _daysInGrid; start += _gridColumns)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                for (var day = start; day < start + _gridColumns; day++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child:
                          day <= _daysInGrid
                              ? AspectRatio(
                                aspectRatio: 1,
                                child: _buildDayButton(day),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          sorted.isEmpty
              ? "Choose at least one day"
              : "${sorted.map(_ordinal).join(", ")} of every month",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: sorted.isEmpty ? Colors.grey : AppColour.colorCustom,
          ),
        ),
        if (skipsShortMonths)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Skipped in months that are too short",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildDayButton(int day) {
    final selected = _dates.contains(day);
    return Material(
      color: selected ? AppColour.colorCustom : Colors.grey[100],
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey("day-$day"),
        onTap:
            () => setState(() {
              if (!_dates.remove(day)) _dates.add(day);
            }),
        child: Center(
          child: Text(
            "$day",
            style: TextStyle(
              color: selected ? Colors.white : AppColour.colorCustom,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return "${n}th";
    switch (n % 10) {
      case 1:
        return "${n}st";
      case 2:
        return "${n}nd";
      case 3:
        return "${n}rd";
      default:
        return "${n}th";
    }
  }
}
