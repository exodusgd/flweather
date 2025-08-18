import 'package:flutter/material.dart';

class CustomColors {
  static const skyBlue = Color(0xFF41B2DC);
  static const darkSkyBlue = Color(0xFF0E4BBC);
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue, darkSkyBlue],
  );
}
