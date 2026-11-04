import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_style.dart';
import 'package:todo/celebration/celebration_target.dart';
import 'package:todo/celebration/effects/circuit_effect.dart';

/// Pick the completion animation and try it out on a practice list.
class CelebrationScreen extends StatelessWidget {
  static const String routeName = '/celebration';

  const CelebrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CelebrationSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text("Completion animation")),
      body: ChangeNotifierProvider(
        create: (_) => CelebrationController(),
        child: ListView(
          children: [
            // Controls and practice list first, so you can tweak and swipe
            // without scrolling.
            if (settings.style == CelebrationStyle.circuit)
              _CircuitControls(settings: settings),
            const _PracticeList(),
            const Divider(),
            RadioGroup<CelebrationStyle>(
              groupValue: settings.style,
              onChanged: (style) {
                if (style != null) settings.style = style;
              },
              child: Column(
                children: [
                  for (final style in CelebrationStyle.values)
                    RadioListTile<CelebrationStyle>(
                      value: style,
                      title: Text(style.label),
                      subtitle: Text(style.description),
                      dense: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliders for the Circuit line's thickness and speed.
class _CircuitControls extends StatelessWidget {
  final CelebrationSettings settings;

  const _CircuitControls({required this.settings});

  @override
  Widget build(BuildContext context) {
    final circuit = settings.circuit;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Circuit line", style: Theme.of(context).textTheme.titleSmall),
          _slider(
            label: "Thickness",
            value: circuit.thickness,
            min: CircuitOptions.minThickness,
            max: CircuitOptions.maxThickness,
            divisions: 38,
            display: "${circuit.thickness.toStringAsFixed(1)} px",
            onChanged:
                (v) =>
                    settings.circuit = settings.circuit.copyWith(thickness: v),
          ),
          _slider(
            label: "Speed",
            value: circuit.speed,
            min: CircuitOptions.minSpeed,
            max: CircuitOptions.maxSpeed,
            divisions: 56,
            display: "${circuit.speed.round()} px/s",
            onChanged:
                (v) => settings.circuit = settings.circuit.copyWith(speed: v),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                settings.circuit = const CircuitOptions();
                settings.save();
              },
              child: const Text("Reset to defaults"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) => Row(
    children: [
      SizedBox(width: 80, child: Text(label)),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: display,
          onChanged: onChanged,
          onChangeEnd: (_) => settings.save(),
        ),
      ),
      SizedBox(width: 76, child: Text(display, textAlign: TextAlign.end)),
    ],
  );
}

class _PracticeItem {
  final String id;
  final String title;
  final Color colour;
  bool done = false;

  _PracticeItem(this.id, this.title, this.colour);
}

/// A few pretend tasks that behave like the day plan: swipe one and it moves
/// below the outstanding ones as done.
class _PracticeList extends StatefulWidget {
  const _PracticeList();

  @override
  State<_PracticeList> createState() => _PracticeListState();
}

class _PracticeListState extends State<_PracticeList> {
  late List<_PracticeItem> _items;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _generation++;
    _items = [
      _PracticeItem("practice-1", "Water the plants", Colors.green),
      _PracticeItem("practice-2", "Reply to emails", Colors.blue),
      _PracticeItem("practice-3", "Go for a run", Colors.red),
      _PracticeItem("practice-4", "Read a chapter", Colors.purple),
    ];
  }

  List<_PracticeItem> get _sorted => [
    ..._items.where((i) => !i.done),
    ..._items.where((i) => i.done),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListTile(
        title: const Text("Practice — swipe right to complete"),
        trailing: TextButton(
          onPressed: () => setState(_reset),
          child: const Text("Reset"),
        ),
      ),
      for (final item in _sorted) _buildItem(item),
    ],
  );

  Widget _buildItem(_PracticeItem item) => Builder(
    key: ValueKey("${item.id}-${item.done}-$_generation"),
    builder:
        (itemContext) => Dismissible(
          key: ValueKey("${item.id}-${item.done}-$_generation"),
          direction: DismissDirection.startToEnd,
          confirmDismiss: (_) async {
            if (!item.done) _celebrate(itemContext, item);
            return true;
          },
          onDismissed: (_) => setState(() => item.done = true),
          child: CelebrationTarget(
            taskId: item.id,
            enabled: item.done,
            child: ListTile(
              leading:
                  item.done
                      ? Icon(Icons.check, color: Colors.grey[350])
                      : Icon(Icons.circle, color: item.colour),
              title: Text(
                item.title,
                style:
                    item.done
                        ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        )
                        : null,
              ),
            ),
          ),
        ),
  );

  void _celebrate(BuildContext itemContext, _PracticeItem item) {
    final box = itemContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    itemContext.read<CelebrationController>().celebrate(
      itemContext,
      style: itemContext.read<CelebrationSettings>().style,
      circuit: itemContext.read<CelebrationSettings>().circuit,
      request: CelebrationRequest(
        taskId: item.id,
        title: item.title,
        colour: item.colour,
        source: box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
