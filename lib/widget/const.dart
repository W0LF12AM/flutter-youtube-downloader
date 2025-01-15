import 'package:flutter/material.dart';

const bgColor = Color(0xff1E1E1E);

class Sizes {
  static double containerWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width * 0.8;
  }

  static double containerHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height * 0.4;
  }

  static const double buttonWidth = 88.0;
  static const double buttonHeight = 48.0;

  static const double formHeight = 48.0;
  static const double formWidth = 88.0;
}
