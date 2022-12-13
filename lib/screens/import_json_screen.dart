import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/export/export_data_v1.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';

import '../date.dart';

class ImportJsonScreen extends StatefulWidget {
  static const String routeName = '/import-json';

  @override
  State<StatefulWidget> createState() => _ImportJsonScreenState();
}

class _ImportJsonScreenState extends State<ImportJsonScreen> {
  String _inputJson = "";

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Import JSON"),
          // elevation: 0.0,
        ),
        body: _buildBody(),
      );

  Widget _buildBody() => Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTextBox(),
                _buildImportButton(),
              ],
            ),
          )
        ],
      );

  Widget _buildImportButton() => ElevatedButton(
        child: Text(
          "Import",
          style: TextStyle(color: Colors.white),
        ),
        style: TextButton.styleFrom(primary: Colors.green),
        onPressed: _handleImport,
      );

  Widget _buildTextBox() => Expanded(
          child: Container(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          initialValue: _inputJson,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Paste JSON Here",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          onChanged: (value) {
            var oldValue = _inputJson;
            _inputJson = value;

            if (oldValue == "" && value != "") setState(() {});
            if (oldValue != "" && value == "") setState(() {});
          },
        ),
      ));

  Future _handleImport() async {
    var importData = ExportDataV1.fromJson(_inputJson);

    var shouldCommit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          children: [
            Text("Import ${importData.tasks.length} tasks"),
            Text("Import ${importData.routines.length} routines"),
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          ElevatedButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (!shouldCommit) return;

    await Provider.of<TaskProvider>(context, listen: false)
        .updateAll(importData.tasks);
    await Provider.of<RoutineProvider>(context, listen: false)
        .updateAll(importData.routines);
  }
}