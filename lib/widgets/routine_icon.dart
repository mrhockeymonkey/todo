import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/widgets/flagged_icon.dart';

class RoutineIcon extends StatelessWidget {
  final Color? color;
  final bool isFlagged;

  const RoutineIcon({
    super.key,
    this.color,
    this.isFlagged = false,
  });

  @override
  Widget build(BuildContext context) => FlaggedIcon(
        icon: Entypo.circular_graph,
        color: color,
        showFlag: isFlagged,
      );

  // @override
  // Widget build(BuildContext context) => Transform(
  //       transform: Matrix4.rotationY(pi),
  //       alignment: Alignment.center,
  //       child: FlaggedIcon(
  //         icon: Entypo.circular_graph,
  //         color: color,
  //         showFlag: isFlagged,
  //       ),
  //       // Icon(
  //       //   Entypo.circular_graph,
  //       //   color: color,
  //       // ),
  //     );
}
