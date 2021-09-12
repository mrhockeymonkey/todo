import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:todo/gauge/gauge_driver.dart';
import 'package:todo/gauge/gauge_painter.dart';

class AnimatedGauge extends StatefulWidget {
  //const AnimatedGauge({Key key, @required this.driver}) : super(key: key);
  const AnimatedGauge({Key key, @required this.percent}) : super(key: key);

  //final GaugeDriver driver;
  final double percent;

  @override
  GaugeState createState() => GaugeState();
}

class GaugeState extends State<AnimatedGauge>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  // String get _readout =>
  //     ((_animation?.value ?? 0) * 100).toStringAsFixed(0) + '%';

  double begin;
  double end;

  @override
  void initState() {
    //begin = 0.0;
    //end = widget.percent;
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    //_animation = Tween<double>(begin: begin, end: end).animate(_controller);
    super.initState();
    //widget.driver.listen(on);
  }

  // void on(dynamic x) => setState(() {
  //       begin = end;
  //       end = x;
  //     });

  final TextStyle _style = TextStyle(
    color: Colors.black?.withOpacity(0.9),
    fontSize: 32,
    fontWeight: FontWeight.w200,
  );

  @override
  Widget build(BuildContext context) {
    begin = 0.0;
    end = widget.percent;
    _animation = Tween<double>(begin: begin, end: end).animate(_controller);
    final double _diameter = (MediaQuery.of(context).size.width / 1.616);

    _controller.reset();
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        begin = end;
      }
    });

    _controller.forward();

    return AnimatedBuilder(
        animation: _animation,
        builder: (context, widget) {
          return CustomPaint(
            foregroundPainter: GaugePainter(percent: _animation.value),
            child: Container(
                constraints: BoxConstraints.expand(
                  height: _diameter,
                  width: _diameter,
                ),
                child: end > 0.99
                    ? Icon(
                        Entypo.flag,
                        color: Colors.red[700],
                      )
                    : Icon(
                        Entypo.hour_glass,
                        color: Colors.grey,
                      )
                // Align(
                //   alignment: Alignment.center,
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: <Widget>[
                //         Text(
                //           _readout,
                //           //style: _style,
                //         ),
                //       ]),
                // ),
                ),
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
