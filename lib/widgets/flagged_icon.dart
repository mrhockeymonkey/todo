import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class FlaggedIcon extends StatelessWidget {
  final IconData icon;
  final bool showFlag;
  final Color? color;

  const FlaggedIcon({
    super.key,
    required this.icon,
    required this.showFlag,
    this.color,
  });

  @override
  Widget build(BuildContext context) => showFlag ? _flagged() : _notFlagged();

  Widget _notFlagged() => Icon(
        icon,
        color: color,
      );

  Widget _flagged() => SizedBox(
        height: 30,
        width: 30,
        child: Stack(
          children: <Widget>[
            Icon(
              icon,
              color: color,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                // decoration: new BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(6),
                // ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: const Icon(
                  Entypo.flag,
                  color: Colors.red,
                  size: 12.0,
                ),
              ),
            ),
          ],
        ),
      );
}
