import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class RoutineIcon extends StatelessWidget {
  final Color? color;

  const RoutineIcon({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Transform(
        transform: Matrix4.rotationY(pi),
        alignment: Alignment.center,
        child: Icon(
          Entypo.circular_graph,
          color: color,
        ),
      );
}
