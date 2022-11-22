import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class DayPlanActions extends StatelessWidget {
  final Function? handleSnooze;
  final Function? handleFlag;

  DayPlanActions({
    this.handleFlag,
    this.handleSnooze,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<void>(
        onSelected: (_) => {},
        itemBuilder: (context) => <PopupMenuEntry<void>>[
          PopupMenuItem<void>(
            child: ListTile(
              title: Row(
                children: [
                  handleFlag == null
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            handleFlag!(context);
                          },
                          icon: Icon(Entypo.flag)),
                  handleSnooze == null
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            handleSnooze!(context);
                          },
                          icon: Icon(Icons.snooze)),
                ],
              ),
            ),
          ),
        ],
      );

  static void doNothing() {}
}
