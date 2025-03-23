import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 72.0 / 2,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Jiffy.now().MMMMEEEEd.toString(),
                    //DateFormat.MMMMEEEEd().format(DateTime.now()),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
