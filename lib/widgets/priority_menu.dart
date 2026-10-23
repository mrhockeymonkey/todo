import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/models/priority.dart';

class PriorityMenu extends StatelessWidget {
  final Widget child;
  final void Function(Priority) onSelected;

  const PriorityMenu({
    super.key,
    required this.child,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<Priority>(
        tooltip: 'Set priority',
        onSelected: onSelected,
        itemBuilder: (context) => <PopupMenuEntry<Priority>>[
          for (var priority in Priority.values) _buildItem(priority),
        ],
        child: child,
      );

  PopupMenuItem<Priority> _buildItem(Priority priority) =>
      PopupMenuItem<Priority>(
        value: priority,
        child: ListTile(
          title: Text(priority.label),
          leading: Icon(Entypo.pin, color: priority.color),
        ),
      );
}
