import 'package:flutter/material.dart';

abstract class DayPlanBase {

  DayPlanBase();

  Widget build(BuildContext context);

  int get order; 

  bool get isDone; 

  bool get isFlagged; 
  
}
