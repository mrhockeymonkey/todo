import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class TextHeader extends StatelessWidget {
  String text;

  TextHeader({
    @required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      height: 72.0 / 2,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.text,
                    //Jiffy(dateTime).MMMMEEEEd.toString(),
                    //Jiffy(dateTime).yMMMMEEEEd.toString(),

                    //DateFormat.MMMMEEEEd().format(DateTime.now()),
                    style: TextStyle(color: Colors.white),
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
