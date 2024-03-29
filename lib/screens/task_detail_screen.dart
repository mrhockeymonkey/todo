import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/date.dart';
import 'package:todo/models/category.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/widgets/custom_color_selection_handle.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  static const String routeName = '/task-detail';

  const TaskDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() => TaskDetailScreenState();
}

class TaskDetailScreenState extends State<TaskDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _isInit = false;
  bool _shouldFocusTitleField = true;
  bool _isPinned = false;
  String? _taskId;
  String _taskTitle = "";
  String? _categoryId;
  Date? _selectedDate;
  String _notesValue = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      var taskId = ModalRoute.of(context)?.settings.arguments;

      if (taskId is String) {
        final task = Provider.of<TaskProvider>(context, listen: false)
            .getItemById(taskId);

        _taskId = task.id;
        _taskTitle = task.title;
        _categoryId = task.categoryId;
        _shouldFocusTitleField = false;
        _isPinned = task.isFlagged;
        _selectedDate = task.dueDate;
        _notesValue = task.notes;
      }

      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildTitleHeader(),
          _buildOptionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future _save() async {
    // validate and save the form data
    final isValid = _form.currentState?.validate() ?? false;
    debugPrint("is valid: $isValid");

    if (!isValid) {
      return;
    }
    debugPrint("savin");
    _form.currentState?.save();

    // save item via provider and pop
    final task = Task(
      id: _taskId,
      title: _taskTitle,
      categoryId: _categoryId,
      isFlagged: _isPinned,
      dueDate: _selectedDate,
      notes: _notesValue,
    );
    await Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future _delete() async {
    if (_taskId != null) {
      await Provider.of<TaskProvider>(context, listen: false).delete(_taskId!);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  //---------- category picker popup
  Future _selectCategory() async {
    final categories =
        Provider.of<CategoryProvider>(context, listen: false).items;
    List<Widget> options = [];

    for (var i = 0; i < categories.length; i++) {
      options.add(
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, i);
          },
          child: Container(
            color: categories[i].color,
            height: 80.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: <Widget>[
                Icon(
                  categories[i].icon,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  categories[i].title,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    var picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: options,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _categoryId = categories[picked].id;
      });
    }
  }

  Widget _buildTitleHeader() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      height: 72,
      color: AppColour.colorCustom,
      child: Form(
        key: _form,
        child: TextFormField(
          style: const TextStyle(color: Colors.white),
          selectionControls: CustomColorSelectionHandle(Colors.white),
          cursorColor: Colors.white,
          textCapitalization: TextCapitalization.words,
          initialValue: _taskTitle,
          autofocus: _shouldFocusTitleField,
          onSaved: (String? value) {
            _taskTitle = value ?? "";
          },
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Must enter a task title';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintStyle: TextStyle(color: Colors.white30),
            labelStyle: TextStyle(color: Colors.white),
            hintText: 'Do Something',
            labelText: 'Title',
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
      ));

  Widget _buildOptionsList() {
    Category category = _categoryId == null
        ? Category.defaultCategory()
        : Provider.of<CategoryProvider>(context).getItemById(_categoryId!);

    return ListView(
      shrinkWrap: true, // constrain listview within remaining column space
      children: [
        ListTile(
          title: const Text('Category'),
          leading: Icon(
            category.icon,
            color: category.color,
          ),
          subtitle: Text(category.title),
          onTap: _selectCategory,
        ),
        // ListTile(
        //     title: Text("Pin"),
        //     leading: Icon(
        //       Entypo.pin,
        //       color: _isPinned
        //           ? AppColour.pinActiveColor
        //           : AppColour.InactiveColor,
        //     ),
        //     subtitle: Text("Toggle pin for this task"),
        //     onTap: () {
        //       setState(() {
        //         _isPinned = !_isPinned;
        //       });
        //     }),
        ListTile(
          title: const Text("When"),
          leading: Icon(Icons.today,
              color: _selectedDate != null
                  ? category.color
                  : AppColour.inactiveColor),
          trailing: _selectedDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                )
              : null,
          subtitle: _selectedDate != null
              ? Text(_selectedDate!.yMMMd())
              : const Text("At Some Point"),
          onTap: _selectDate,
        ),
        ListTile(
          title: TextFormField(
            initialValue: _notesValue,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "Notes",
              hintStyle: TextStyle(color: Colors.black54),
            ),
            onChanged: (value) {
              var oldValue = _notesValue;
              _notesValue = value;

              if (oldValue == "" && value != "") setState(() {});
              if (oldValue != "" && value == "") setState(() {});
            },
          ),
          leading: Icon(
            //Icons.subject,
            FontAwesome.sticky_note,
            color: _notesValue != ""
                ? AppColour.colorCustom
                : AppColour.inactiveColor,
          ),
        ),
      ],
    );
  }

  //---------- datepicker popup
  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
    if (picked != null) {
      setState(() {
        _selectedDate = Date(picked);
      });
    }
  }
}
