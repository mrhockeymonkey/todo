import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColour {
  static const MaterialColor colorCustom = MaterialColor(0xFF07618E, {
    50: Color(0xff07618e),
    100: Color(0xff065780),
    200: Color(0xff064e72),
    300: Color(0xff054463),
    400: Color(0xff043a55),
    500: Color(0xff043147),
    600: Color(0xff032739),
    700: Color(0xff021d2b),
    800: Color(0xff01131c),
    900: Color(0xff010a0e),
  });

  static const pinActiveColor = Colors.red;
  static const inactiveColor = Colors.grey;

  static void setStatusBarColor(Color color) =>
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: color,
      ));

  static void resetStatusBarColor() =>
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: colorCustom,
      ));

  // static final Map<int, Color> swatch = {
  //   50: const Color(0xff07618e),
  //   100: const Color(0xff065780),
  //   200: const Color(0xff064e72),
  //   300: const Color(0xff054463),
  //   400: const Color(0xff043a55),
  //   500: const Color(0xff043147),
  //   600: const Color(0xff032739),
  //   700: const Color(0xff021d2b),
  //   800: const Color(0xff01131c),
  //   900: const Color(0xff010a0e),
  // };
}
