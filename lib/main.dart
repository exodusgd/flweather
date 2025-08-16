// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Project imports
import 'services/location_service.dart';
import 'services/weather_service.dart';
import 'settings_page.dart';
import 'models/weather_model.dart';
import 'models/location_model.dart';
import 'enums/shared_prefs_keys.dart';
import 'enums/temperature_units.dart';

void main() {
  runApp(const FlweatherApp());
}

class FlweatherApp extends StatelessWidget {
  const FlweatherApp({super.key});

  // This widget is the root of your application.
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

// ----------- STATEFUL WIDGET -----------
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Display vars
  String _locationCoords = "Null";
  String _locationName = "Null";
  String _locationTemperatureString = "Null";
  String _locationWeatherCondition = "Null";

  bool _hasReceivedWeatherInfo = false;
  double _locationTemperature = 0;

  // Location vars
  final LocationService _locationService = LocationService();

  // Weather vars
  final WeatherService _weatherService = WeatherService(
    // API key from openweathermap.org
    apiKey: "391870125944c3e1dd3eb3d26bdf5f85",
  );

  // Shared preferences
  SharedPreferences? _sharedPrefs;

  // Temperature units
  final TemperatureUnitsUtilities _tempUnitsUtils = TemperatureUnitsUtilities();

  // Clock
  late String _currentTime;
  late Timer _clockTimer;

  // Runs before the page is built
  @override
  void initState() {
    super.initState();
    // Initializes shared preferences
    _initSharedPreferences();
    // Starts the timer updating current time
    _startClock();
  }

  void _initSharedPreferences() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  // TODO: Display some sort of error message when location services/perms are not allowed
  void _fetchLocationAndWeather() async {
    _locationService.getLocation().then(
      (location) => {
        _updateCurrentLocation(location!),
        _weatherService
            .getWeather(location.latitude, location.longitude)
            .then((weather) => {_updateCurrentWeather(weather)}),
      },
    );
  }

  void _setLoadingText() {
    setState(() {
      _locationCoords = "loading...";
      _locationName = "loading...";
      _locationTemperatureString = "loading...";
      _locationWeatherCondition = "loading...";
    });
  }

  void _updateCurrentLocation(Location newLocation) {
    setState(() {
      _locationCoords =
          "lat: ${newLocation.latitude.toString()} \n"
          "long: ${newLocation.longitude.toString()}";
      _locationName = "${newLocation.locality}, ${newLocation.country}";
    });
  }

  String _formatTemperature(double tempToFormat) {
    String newTemperature = "Null";
    if (_sharedPrefs != null) {
      String? tempUnitString = _sharedPrefs!.getString(
        SharedPrefsKeys.temperatureUnit.toString(),
      );
      if (tempUnitString != null) {
        TemperatureUnits tempUnit = _tempUnitsUtils.convertStringToValue(
          tempUnitString,
        )!;
        switch (tempUnit) {
          case TemperatureUnits.celsius:
            newTemperature = "${(tempToFormat - 273.15).round().toString()} ºC";

          case TemperatureUnits.fahrenheit:
            newTemperature =
                "${(1.8 * (tempToFormat - 273) + 32).round().toString()} ºF";
        }
        return newTemperature;
      }
    }
    // Defaults to celsius
    newTemperature = "${(tempToFormat - 273.15).round().toString()} ºC";
    return newTemperature;
  }

  void _updateCurrentWeather(Weather newWeather) {
    _hasReceivedWeatherInfo = true;
    _locationTemperature = newWeather.temperature;
    setState(() {
      _locationTemperatureString = _formatTemperature(_locationTemperature);
      _locationWeatherCondition = newWeather.condition;
    });
  }

  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => _updateClock(),
    );
  }

  void _updateClock() {
    DateTime time = DateTime.now();
    String formattedDate = DateFormat('d-M-y \n kk:mm:ss').format(time);
    setState(() {
      _currentTime = formattedDate;
    });
  }

  @override
  void dispose() {
    // Cancel the clock timer
    _clockTimer.cancel();
    super.dispose();
  }

  // --------------------------------- BUILD ---------------------------------
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Current time:", style: TextStyle(fontSize: 30)),
            Text(
              _currentTime,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("Current location:", style: TextStyle(fontSize: 30)),
            Text(
              _locationCoords,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _locationName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("Weather at location:", style: TextStyle(fontSize: 30)),
            Text(
              _locationTemperatureString,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _locationWeatherCondition,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                _setLoadingText();
                _fetchLocationAndWeather();
              },
              child: const Text("Get weather"),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "settings").then(
            (value) => setState(() {
              if (_hasReceivedWeatherInfo) {
                _locationTemperatureString = _formatTemperature(
                  _locationTemperature,
                );
              }
            }),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
