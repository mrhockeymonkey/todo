import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_target.dart';
import 'package:todo/celebration/circuit_animation.dart';
import 'package:todo/celebration/circuit_settings.dart';
import 'package:todo/models/priority.dart';

/// Tune the completion animation and try it out on a practice list.
class CelebrationScreen extends StatelessWidget {
  static const String routeName = '/celebration';

  const CelebrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CircuitSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text("Completion animation")),
      body: ChangeNotifierProvider(
        create: (_) => CelebrationController(),
        child: ListView(
          children: [
            _CircuitControls(settings: settings),
            const Divider(),
            const _PracticeList(),
          ],
        ),
      ),
    );
  }
}

/// Sliders for every [CircuitParam], in a collapsible section per
/// [CircuitGroup] so the practice list stays in reach.
class _CircuitControls extends StatelessWidget {
  final CircuitSettings settings;

  const _CircuitControls({required this.settings});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final group in CircuitGroup.values)
        ExpansionTile(
          key: PageStorageKey(group),
          title: Text(group.label),
          subtitle: Text(_summary(group)),
          initiallyExpanded: group == CircuitGroup.main,
          dense: true,
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (final param in CircuitParam.values)
              if (param.group == group) _slider(param),
          ],
        ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            settings.options = const CircuitOptions();
            settings.save();
          },
          child: const Text("Reset to defaults"),
        ),
      ),
    ],
  );

  /// The group's current values, shown under its title.
  String _summary(CircuitGroup group) => [
    for (final param in CircuitParam.values)
      if (param.group == group)
        "${param.label} ${param.format(settings.options[param])}",
  ].join(" · ");

  Widget _slider(CircuitParam param) {
    final value = settings.options[param];
    final display = param.format(value);
    return Row(
      children: [
        SizedBox(width: 80, child: Text(param.label)),
        Expanded(
          child: Slider(
            value: value,
            min: param.min,
            max: param.max,
            divisions: param.divisions,
            label: display,
            // Read the current options when changed, not when built, so a
            // change to another slider since the last build isn't lost.
            onChanged:
                (v) => settings.options = settings.options.withValue(param, v),
            onChangeEnd: (_) => settings.save(),
          ),
        ),
        SizedBox(width: 84, child: Text(display, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _PracticeItem {
  final String id;
  final String title;
  final Priority priority;
  bool done = false;

  _PracticeItem(this.id, this.title, this.priority);
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
      _PracticeItem("practice-1", "Pay the bills", Priority.urgent),
      _PracticeItem("practice-2", "Reply to emails", Priority.important),
      _PracticeItem("practice-3", "Water the plants", Priority.notImportant),
      _PracticeItem("practice-4", "Book the dentist", Priority.urgent),
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
                      : Icon(Icons.circle, color: item.priority.color),
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
              subtitle: Text(item.priority.label),
            ),
          ),
        ),
  );

  void _celebrate(BuildContext itemContext, _PracticeItem item) {
    final box = itemContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    itemContext.read<CelebrationController>().celebrate(
      itemContext,
      options: itemContext.read<CircuitSettings>().options,
      request: CircuitRequest(
        taskId: item.id,
        colour: item.priority.color,
        source: box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
