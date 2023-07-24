import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  final Widget icon;
  final int badgeCount;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          SizedBox(
            height: 35,
            width: 35,
            child: icon,
          ),
          // icon,
          badgeCount <= 0
              ? const SizedBox(
                  height: 1,
                  width: 1,
                )
              : Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
        ],
      );
}
