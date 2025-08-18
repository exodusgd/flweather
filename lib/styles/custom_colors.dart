import 'package:flutter/material.dart';

class CustomColors {
  static const lightSkyBlue = Color(0xFF48AECD);
  static const skyBlue = Color(0xFF2B7CCD);
  static const darkSkyBlue = Color(0xFF0E4BBC);
  static const cloudWhite = Color(0xCCB8DFE8);
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightSkyBlue, darkSkyBlue],
  );
}