import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class RemoveFromDayPlanIcon extends StatelessWidget {
  const RemoveFromDayPlanIcon({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 30,
        width: 30,
        child: Stack(
          children: <Widget>[
            const Icon(
              Entypo.list,
              // color: color,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Icon(
                  Entypo.circle_with_minus,
                  color: Colors.red,
                  size: 14.0,
                ),
              ),
            ),
          ],
        ),
      );
}
