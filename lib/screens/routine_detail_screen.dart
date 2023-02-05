import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'package:todo/widgets/custom_color_selection_handle.dart';

import 'package:todo/models/routine.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/repeat_picker.dart';

import '../app_colour.dart';

class RoutineDetailScreen extends StatefulWidget {
  static const String routeName = '/routine-detail';

  const RoutineDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() => RoutineDetailScreenState();
}

class RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _isInit = false;
  bool _shouldFocusTitleField = true;
  String? _routineId;
  String _routineTitle = "";
  RepeatSchedule _schedule = RepeatSchedule();
  String _notesValue = "";
  bool _displayOnPinned = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      var routineId = ModalRoute.of(context)?.settings.arguments;

      if (routineId is String) {
        final routine = Provider.of<RoutineProvider>(context, listen: false)
            .getItemById(routineId);
        _routineId = routine.id;
        _routineTitle = routine.title;
        _schedule = routine.schedule;
        _shouldFocusTitleField = false;
        _notesValue = routine.notes;
        _displayOnPinned = routine.displayOnPinned;
      }

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Routine"),
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
    if (!isValid) {
      return;
    }
    _form.currentState?.save();

    // save item via provider and pop
    final routine = Routine(
      id: _routineId,
      title: _routineTitle,
      schedule: _schedule,
      notes: _notesValue,
      displayOnPinned: _displayOnPinned,
    );
    await Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future _delete() async {
    if (_routineId != null) {
      await Provider.of<RoutineProvider>(context, listen: false)
          .delete(_routineId!);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future _selectSchedule() async {
    var answer = await showDialog(
        context: context,
        builder: (BuildContext context) => RepeatPicker(_schedule));

    if (answer != null) {
      setState(() {
        _schedule = answer;
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
            initialValue: _routineTitle,
            autofocus: _shouldFocusTitleField,
            onSaved: (String? value) {
              _routineTitle = value ?? "";
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Must enter a routine title';
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
        ),
      );

  Widget _buildOptionsList() {
    return ListView(
      shrinkWrap: true, // constrain listview within remaining column space
      children: [
        ListTile(
          leading: const Icon(
            Icons.repeat,
            color: AppColour.colorCustom,
          ),
          title: const Text("Repeats"),
          subtitle: Text(_schedule.displayName),
          onTap: _selectSchedule,
        ),
        ListTile(
            title: const Text("Scheduled"),
            leading: const Icon(
              Entypo.calendar,
              color: AppColour.inactiveColor,
            ),
            subtitle: const Text("Coming Soon"),
            onTap: () {
              setState(() {
                _displayOnPinned = !_displayOnPinned;
              });
            }),
        ListTile(
          title: TextFormField(
            initialValue: _notesValue,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "Notes",
              hintStyle: TextStyle(color: Colors.black54),
            ),
            cursorColor: Colors.black,
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
}
