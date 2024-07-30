import 'package:flutter/material.dart';

class AlcMobileColors {
  static const MaterialColor primary = MaterialColor(
    0xffc3002f,
    <int, Color>{
      50: Color(0xFFF8E0E6),
      100: Color(0xFFEDB3C1),
      200: Color(0xFFE18097),
      300: Color(0xFFD54D6D),
      400: Color(0xFFCC264E),
      500: Color(0xffc3002f),
      600: Color(0xFFBD002A),
      700: Color(0xFFB50023),
      800: Color(0xFFAE001D),
      900: Color(0xFFA10012),
    },
  );

  static const int _redAlertPrimaryValue = 0xFFFD4E4E;
  static const MaterialColor redAlert = MaterialColor(
    _redAlertPrimaryValue,
    <int, Color>{
      100: Color(0xFFFF8E92),
      200: Color(0xFFFF656C),
      400: Color(_redAlertPrimaryValue),
      600: Color(0xFFDC2C36),
      800: Color(0xFFA5232A),
    },
  );

  static const disabledColor = Color(0x61000000);
  static const loginBackgroundColor = primary;
  static const scaffoldBackgroundColor = Color(0xFFFFFFFF);
  static const inputBorderColor = Color(0xFFC2C2C2);
  static const inputIconColor = Color(0xff878787);
  static const inputLabelColor = Color(0xff17181E);
  static const textThemeColor = Color(0xff212121);
  static const textBodyColor = Color(0xff7D8A8B);
  static const backgroundColor = Color(0xFFFFFFFF);
  static const lightGray = Color(0xffD2DAE2);
  static const disableInputBackground = Color(0xffF4F9F8);
  static const alertTitle = Color(0xff0E0637);
}