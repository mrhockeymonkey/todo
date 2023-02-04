import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/export/export_container.dart';

import '../providers/routine_provider.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';

class ExportJsonPage extends StatefulWidget {
  static const String routeName = '/export-json';

  const ExportJsonPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ExportJsonPageState();
  }
}

class _ExportJsonPageState extends State<ExportJsonPage> {
  String json = "";

  @override
  void didChangeDependencies() {
    json = _buildJson(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup Data"),
        // elevation: 0.0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() => Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTextBox(),
                _buildButton(),
              ],
            ),
          )
        ],
      );

  Widget _buildTextBox() => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(json),
        ),
      );

  Widget _buildButton() => ElevatedButton(
        child: const Text(
          "Copy To Clipboard",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: json));
          debugPrint("copied to clipboard");
        },
      );

  String _buildJson(BuildContext context) {
    var exportTasks = Provider.of<TaskProvider>(context)
        .items
        .where((t) => !t.isDone)
        .toList();

    var exportRoutines = Provider.of<RoutineProvider>(context).items.toList();

    var exportCategories =
        Provider.of<CategoryProvider>(context).items.toList();

    var exportData = ExportContainer(
      exportTasks,
      exportRoutines,
      exportCategories,
    );

    return jsonEncode(exportData);
  }
}
