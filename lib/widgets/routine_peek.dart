import 'dart:math';

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
/// next due routine. The leading ring has a segment per routine, filled
/// in as routines are done (not due). The card hides itself while the keyboard is open and once
/// no routines are due.
class RoutinePeek extends StatefulWidget {
  const RoutinePeek({super.key});

  @override
  State<StatefulWidget> createState() => RoutinePeekState();
}

class RoutinePeekState extends State<RoutinePeek> with WidgetsBindingObserver {
  int _focusIndex = 0;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The enclosing Scaffolds strip viewInsets from MediaQuery, so read the
  // view's insets directly.
  @override
  void didChangeMetrics() {
    final visible = View.of(context).viewInsets.bottom > 0;
    if (visible != _keyboardVisible) setState(() => _keyboardVisible = visible);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineProvider>(context);
    final all = provider.items;
    final due = all.where((r) => r.isDue).toList();
    if (_keyboardVisible || due.isEmpty) return const SizedBox.shrink();

    final focused = due[_focusIndex % due.length];
    final others = due.length - 1;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: SegmentedRing(
          done: all.length - due.length,
          total: all.length,
        ),
        // Only the title slides on swipe; the ring, subtitle and buttons stay
        // put. The clip stops the sliding text drawing over the buttons.
        title: ClipRect(
          child: Dismissible(
            key: const ValueKey('routine-peek'),
            direction: DismissDirection.startToEnd,
            // Mark the focused routine done but never dismiss the title.
            confirmDismiss: (_) async {
              _markDone(provider, focused);
              return false;
            },
            child: SizedBox(
              // The whole title row is the swipe target, not just the text.
              width: double.infinity,
              child: Text(focused.title),
            ),
          ),
        ),
        subtitle:
            others > 0
                ? Text("+ $others routine${others == 1 ? "" : "s"}")
                : null,
        trailing: Row(
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
                                (_focusIndex % due.length + 1) % due.length,
                      ),
            ),
          ],
        ),
        onTap:
            () => Navigator.of(
              context,
            ).pushNamed(RoutineDetailScreen.routeName, arguments: focused.id),
      ),
    );
  }

  // The focus index is kept, so once the done routine leaves the due list the
  // focus moves on to the routine that followed it.
  void _markDone(RoutineProvider provider, Routine routine) =>
      provider.addOrUpdate(routine.done());
}

/// A ring split into [total] equal segments, the first [done] of which are
/// filled.
class SegmentedRing extends StatelessWidget {
  final int done;
  final int total;

  const SegmentedRing({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(
        painter: _SegmentedRingPainter(
          done: done,
          total: total,
          filled: AppColour.colorCustom,
          empty: Colors.grey[300]!,
        ),
      ),
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  static const double _strokeWidth = 4;
  static const double _gap = 0.25; // radians between segments

  final int done;
  final int total;
  final Color filled;
  final Color empty;

  _SegmentedRingPainter({
    required this.done,
    required this.total,
    required this.filled,
    required this.empty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(_strokeWidth / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = total == 1 ? StrokeCap.butt : StrokeCap.round;

    final sweep = 2 * pi / total;
    // A lone segment is a closed circle, so it has no gap to leave.
    final drawn = total == 1 ? sweep : sweep - _gap;
    for (var i = 0; i < total; i++) {
      paint.color = i < done ? filled : empty;
      // Start at the top and run clockwise.
      final start = -pi / 2 + i * sweep + (total == 1 ? 0 : _gap / 2);
      canvas.drawArc(arcRect, start, drawn, false, paint);
    }
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter old) =>
      old.done != done ||
      old.total != total ||
      old.filled != filled ||
      old.empty != empty;
}
