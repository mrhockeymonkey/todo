import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/gauge/gauge_painter.dart';

class AnimatedGauge extends StatefulWidget {
  final double percent;

  // const AnimatedGauge({Key key, required this.percent}) : super(key: key);
  const AnimatedGauge({super.key, required this.percent}); //: super(key: key);

  //final GaugeDriver driver;

  @override
  GaugeState createState() => GaugeState();
}

class GaugeState extends State<AnimatedGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // String get _readout =>
  //     ((_animation?.value ?? 0) * 100).toStringAsFixed(0) + '%';

  // double begin;
  // double end = widget.percent;

  @override
  void initState() {
    super.initState();
    //begin = 0.0;
    //end = widget.percent;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    //_animation = Tween<double>(begin: begin, end: end).animate(_controller);
    //widget.driver.listen(on);
  }

  // void on(dynamic x) => setState(() {
  //       begin = end;
  //       end = x;
  //     });

  // final TextStyle _style = TextStyle(
  //   color: Colors.black?.withOpacity(0.9),
  //   fontSize: 32,
  //   fontWeight: FontWeight.w200,
  // );

  @override
  Widget build(BuildContext context) {
    var begin = 0.0;
    var end = widget.percent;
    var animation = Tween<double>(begin: begin, end: end).animate(_controller);
    final double diameter = (MediaQuery.of(context).size.width / 1.616);

    _controller.reset();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        begin = end;
      }
    });

    _controller.forward();

    return AnimatedBuilder(
        animation: animation,
        builder: (context, widget) {
          return CustomPaint(
            foregroundPainter: GaugePainter(percent: animation.value),
            child: Container(
                constraints: BoxConstraints.expand(
                  height: diameter,
                  width: diameter,
                ),
                child: end > 0.99
                    ? Icon(
                        Entypo.flag,
                        color: Colors.red[700],
                      )
                    : const Icon(
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
