import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  final String text;

  const TextHeader({
    super.key,
    required this.text,
  });

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
                    text,
                    //Jiffy(dateTime).MMMMEEEEd.toString(),
                    //Jiffy(dateTime).yMMMMEEEEd.toString(),

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
