// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:flweather/services/location_service.dart';
import 'package:flweather/services/weather_service.dart';
import 'models/weather_model.dart';
import 'models/location_model.dart';
import 'package:flweather/settings_page.dart';
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
  String _locationTemperature = "Null";
  String _locationWeatherCondition = "Null";

  // Location vars
  final LocationService _locationService = LocationService();

  // Weather vars
  final WeatherService _weatherService = WeatherService(
    // API key from openweathermap.org
    apiKey: "391870125944c3e1dd3eb3d26bdf5f85",
  );

  // Shared preferences
  SharedPreferences? _sharedPrefs;

  @override
  void initState() {
    super.initState();
    // Initializes shared preferences before the page is built
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

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
      _locationTemperature = "loading...";
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

  void _updateCurrentWeather(Weather newWeather) {
    // if(_sharedPrefs != null){
    //   String? tempUnit = _sharedPrefs!.getString(SharedPrefsKeys.temperatureUnit.toString());
    // }
    setState(() {
      _locationTemperature =
          "${(newWeather.temperature - 273.15).round().toString()} ºC";
      _locationWeatherCondition = newWeather.condition;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
              _locationTemperature,
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
          Navigator.pushNamed(context, "settings");
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
