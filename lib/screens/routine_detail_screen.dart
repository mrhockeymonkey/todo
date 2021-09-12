import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo/models/routine.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/repeat_picker.dart';

import '../app_colour.dart';

class RoutineDetailScreen extends StatefulWidget {
  static const String routeName = '/routine-detail';

  @override
  State<StatefulWidget> createState() => RoutineDetailScreenState();
}

class RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _isInit = false;
  bool _shouldFocusTitleField = true;
  String _routineId;
  String _routineTitle;
  int _routineRecurNum = 1;
  String _routineRecurLen = "hours";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final routineId = ModalRoute.of(context).settings.arguments as String;

      if (routineId != null) {
        final routine = Provider.of<RoutineProvider>(context, listen: false)
            .getItemById(routineId);
        _routineId = routine.id;
        _routineTitle = routine.title;
        _routineRecurNum = routine.recurNum;
        _routineRecurLen = routine.recurLen;
        _shouldFocusTitleField = false;
      }

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routine"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
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
        child: Icon(Icons.check),
        onPressed: _save,
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void _save() async {
    // validate and save the form data
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    // save item via provider and pop
    final routine = Routine(
      id: _routineId,
      title: _routineTitle,
      recurNum: _routineRecurNum,
      recurLen: _routineRecurLen,
    );
    await Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine);
    Navigator.of(context).pop();
  }

  void _delete() async {
    await Provider.of<RoutineProvider>(context, listen: false)
        .delete(_routineId);
    Navigator.of(context).pop();
  }

  void _updateRecurValues(String recurNum, String recurLen) {
    setState(() {
      _routineRecurNum = int.parse(recurNum);
      _routineRecurLen = recurLen;
    });
  }

  Future _selectSchedule() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RepeatPicker(_updateRecurValues),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  print("repeatNum: " +
                      _routineRecurNum.toString() +
                      " repeatLen: " +
                      _routineRecurLen);
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildTitleHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        height: 72,
        color: AppColour.colorCustom,
        child: Form(
          key: _form,
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            initialValue: _routineTitle,
            autofocus: _shouldFocusTitleField,
            onSaved: (String value) {
              _routineTitle = value;
            },
            decoration: InputDecoration(
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
          leading: Icon(Icons.repeat),
          title: Text("Schedule"),
          subtitle:
              Text("Every ${_routineRecurNum.toString()} $_routineRecurLen"),
          onTap: _selectSchedule,
        )
      ],
    );
  }
}
