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
        // Colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.lightSkyBlue,
          brightness: Brightness.dark,
          outline: CustomColors.cloudWhite,
        ),
        // Text
        fontFamily: "Rubik",
        textTheme: TextTheme(displayLarge: const TextStyle(fontSize: 90)),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: CustomColors.cloudWhite),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty<Color>.fromMap(
              <WidgetStatesConstraint, Color>{
               WidgetState.any:
               CustomColors.skyBlue,
              },
            ),
          ),
        ),
        menuButtonTheme: MenuButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty<Color>.fromMap(
              <WidgetStatesConstraint, Color>{
                WidgetState.pressed | WidgetState.focused:
                    CustomColors.darkSkyBlue,
                WidgetState.hovered | WidgetState.any: CustomColors.skyBlue,
              },
            ),
          ),
        ),
      ),
    );
  }
}
