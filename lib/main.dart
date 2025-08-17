// Flutter imports
import 'package:flutter/material.dart';

// Project imports
import 'pages/main_page.dart';
import 'pages/settings_page.dart';
import 'utils/shared_prefs_utils.dart';

void main() async{
  // Required for async calls in `main`
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPrefs instance.
  await SharedPrefsUtils.init();

  runApp(const FlweatherApp());
}

class FlweatherApp extends StatelessWidget {
  const FlweatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flweather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MainPage(),
      routes: {"settings": (context) => const SettingsPage()},
    );
  }
}


