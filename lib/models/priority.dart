import 'package:flutter/material.dart';

enum Priority {
  urgent('Urgent', Colors.red),
  important('Important', Colors.blue),
  notImportant('Not important', Colors.grey);

  const Priority(this.label, this.color);

  final String label;
  final Color color;

  static Priority fromJson(Object? value) =>
      Priority.values.asNameMap()[value] ?? Priority.notImportant;
}
