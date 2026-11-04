import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/screens/routine_detail_screen.dart';

/// A summary card for routines, floating above the bottom of the day plan.
///
/// Unlike the task tiles it is never removed: it focuses on one due routine at
/// a time, which can be marked done (check button or swipe) or swapped for the
/// next due routine. The leading ring shows the share of routines that are
/// done (not due).
class RoutinePeek extends StatefulWidget {
  const RoutinePeek({super.key});

  @override
  State<StatefulWidget> createState() => RoutinePeekState();
}

class RoutinePeekState extends State<RoutinePeek> {
  int _focusIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineProvider>(context);
    final all = provider.items;
    if (all.isEmpty) return const SizedBox.shrink();

    final due = all.where((r) => r.isDue).toList();
    final focused = due.isEmpty ? null : due[_focusIndex % due.length];
    final others = due.length - 1;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: _ProgressRing(
          done: all.length - due.length,
          total: all.length,
        ),
        // Only the title slides on swipe; the ring, subtitle and buttons stay
        // put. The clip stops the sliding text drawing over the buttons.
        title: ClipRect(
          child: Dismissible(
            key: const ValueKey('routine-peek'),
            direction:
                focused == null
                    ? DismissDirection.none
                    : DismissDirection.startToEnd,
            // Mark the focused routine done but never dismiss the title.
            confirmDismiss: (_) async {
              if (focused != null) _markDone(provider, focused);
              return false;
            },
            child: SizedBox(
              // The whole title row is the swipe target, not just the text.
              width: double.infinity,
              child: Text(focused?.title ?? "All routines done"),
            ),
          ),
        ),
        subtitle:
            others > 0
                ? Text("+ $others routine${others == 1 ? "" : "s"}")
                : null,
        trailing:
            focused == null
                ? null
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      tooltip: "Mark done",
                      onPressed: () => _markDone(provider, focused),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: "Next routine",
                      onPressed:
                          due.length < 2
                              ? null
                              : () => setState(
                                () =>
                                    _focusIndex =
                                        (_focusIndex % due.length + 1) %
                                        due.length,
                              ),
                    ),
                  ],
                ),
        onTap:
            focused == null
                ? null
                : () => Navigator.of(context).pushNamed(
                  RoutineDetailScreen.routeName,
                  arguments: focused.id,
                ),
      ),
    );
  }

  // The focus index is kept, so once the done routine leaves the due list the
  // focus moves on to the routine that followed it.
  void _markDone(RoutineProvider provider, Routine routine) =>
      provider.addOrUpdate(routine.done());
}

class _ProgressRing extends StatelessWidget {
  final int done;
  final int total;

  const _ProgressRing({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 1.0 : done / total;
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            color: AppColour.colorCustom,
            backgroundColor: Colors.grey[300],
          ),
          Center(
            child: Text(
              "${(value * 100).round()}%",
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
