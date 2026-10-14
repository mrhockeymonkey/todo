import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/date.dart';
import 'package:todo/models/category.dart';
import 'package:todo/models/priority.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/task_provider.dart';

/// Inline entry row for adding a new task to a day in the day planner.
/// Nothing is saved until a title is entered; an empty entry is discarded.
class NewDayPlanTask extends StatefulWidget {
  final Date date;
  final VoidCallback onClose;

  const NewDayPlanTask({super.key, required this.date, required this.onClose});

  @override
  State<StatefulWidget> createState() => NewDayPlanTaskState();
}

class NewDayPlanTaskState extends State<NewDayPlanTask> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TaskProvider _taskProvider;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _submit();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // keep whatever was typed if the row is removed before being submitted
    if (!_isClosed) _save();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future _save() async {
    _isClosed = true;

    var title = _controller.text.trim();
    if (title.isEmpty) return;

    await _taskProvider.addOrUpdate(
      Task(title: title, dueDate: widget.date, order: 99999),
    );
  }

  Future _submit() async {
    if (_isClosed) return;
    await _save();
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      Category.defaultCategory().icon,
      color: Priority.notImportant.color,
    ),
    title: TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      cursorColor: Colors.black,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Do Something",
        hintStyle: TextStyle(color: Colors.grey),
      ),
    ),
  );
}
