// Flutter imports
import 'package:flutter/material.dart';

// Project imports
import 'pages/main_page.dart';
import 'pages/settings_page.dart';
import 'styles/custom_colors.dart';

void main() {
  runApp(const FlweatherApp());
}

class FlweatherApp extends StatelessWidget {
  const FlweatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TODO: Uncomment the line below to remove debug banner
      //debugShowCheckedModeBanner: false,
      title: 'Flweather',
      home: const MainPage(),
      routes: {"settings": (context) => const SettingsPage()},
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColors.skyBlue, brightness: Brightness.dark),
        fontFamily: "Rubik",
        textTheme: TextTheme(displayLarge: const TextStyle(fontSize: 90)),
      ),
    );
  }
}
