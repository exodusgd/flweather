// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:intl/intl.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../enums/shared_prefs_keys.dart';
import '../enums/temperature_units.dart';
import '../enums/weather_conditions.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/temperature_units_utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // --------------------------- CLASS VARIABLES ---------------------------
  // State vars
  bool _hasReceivedWeatherInfo = false;

  // Display vars
  String _currentLocationCoords = "Null";
  String _currentLocationName = "Null";

  double _currentTemperature = 0;
  String _currentTemperatureString = "Null";
  TemperatureUnits _currentTemperatureUnit = TemperatureUnits.celsius;

  String _currentWeatherCondition = "Null";
  // TODO: change default 3D icon
  String _3dModelPath = "assets/3d/sunny_icon.glb";
  // Clock
  late String _currentTime;
  late Timer _clockTimer;

  // Services
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService(
    // API key from openweathermap.org
    apiKey: "391870125944c3e1dd3eb3d26bdf5f85",
  );

  // Shared preferences
  SharedPreferences? _sharedPrefs;

  // --------------------------- CLASS FUNCTIONS ---------------------------

  // Runs before the page is built
  @override
  void initState() {
    super.initState();
    _startClock();
    _initSharedPrefs();
  }

  @override
  void dispose() {
    // Cancel the clock timer
    _clockTimer.cancel();
    super.dispose();
  }

  void _initSharedPrefs() async{
    _sharedPrefs = await SharedPrefsUtils.getSharedPrefs();
  }

  // Starts the timer updating clock display
  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => _updateClock(),
    );
  }

  // Updates clock display with current time
  void _updateClock() {
    DateTime time = DateTime.now();
    String formattedDate = DateFormat('d-M-y \n kk:mm:ss').format(time);
    setState(() {
      _currentTime = formattedDate;
    });
  }

  // TODO: Display some sort of error message when location services/perms are not allowed
  void _fetchLocationAndWeather() async {
    _setLoadingText();
    _locationService.getLocation().then(
          (location) => {
        _updateCurrentLocation(location!),
        _weatherService
            .getWeather(location.latitude, location.longitude)
            .then((weather) => {_updateCurrentWeather(weather)}),
      },
    );
  }

  // Updates current location var based on given location and updates display
  void _updateCurrentLocation(Location newLocation) {
    setState(() {
      _currentLocationCoords =
      "lat: ${newLocation.latitude.toString()} \n"
          "long: ${newLocation.longitude.toString()}";
      _currentLocationName = "${newLocation.locality}, ${newLocation.country}";
    });
  }

  // Updates current weather var based on given weather and updates display
  void _updateCurrentWeather(Weather newWeather) {
    _hasReceivedWeatherInfo = true;
    _currentTemperature = newWeather.currentTemperature;
    _updateWeather3DModel(newWeather.condition!);
    setState(() {
      _currentTemperatureString = _formatTemperature(
        _currentTemperature,
        _currentTemperatureUnit,
      );
      _currentWeatherCondition = newWeather.conditionString;
    });
  }

  // Changes the displayed 3D model based on the weather condition
  void _updateWeather3DModel(WeatherConditions weatherCondition) {
    String basePath = "assets/3d/";
    switch (weatherCondition) {
      case WeatherConditions.cloudy:
        _3dModelPath =
            "$basePath"
            "cloudy_icon.glb";

      case WeatherConditions.rain:
        _3dModelPath =
            "$basePath"
            "rain_icon.glb";

      case WeatherConditions.snow:
        _3dModelPath =
            "$basePath"
            "snow_icon.glb";

      case WeatherConditions.sunny:
        _3dModelPath =
            "$basePath"
            "sunny_icon.glb";

      case WeatherConditions.thunder:
        _3dModelPath =
            "$basePath"
            "thunder_icon.glb";
    }
  }

  // Reformats temperature display if the temp unit to use has changed
  void _updateTemperatureUnit() async{
    if (_hasReceivedWeatherInfo && _sharedPrefs!= null) {
      String? tempUnitString = _sharedPrefs!.getString(
        SharedPrefsKeys.temperatureUnit.toString(),
      );
      if (tempUnitString != null) {
        TemperatureUnits tempUnit = TemperatureUnitsUtils.convertStringToValue(
          tempUnitString,
        )!;
        if (tempUnit != _currentTemperatureUnit) {
          _currentTemperatureUnit = tempUnit;
          setState(() {
            _currentTemperatureString = _formatTemperature(
              _currentTemperature,
              _currentTemperatureUnit,
            );
          });
        }
      }
    }
  }

  // TODO: Find another solution to show the info is loading
  void _setLoadingText() {
    setState(() {
      _currentLocationCoords = "loading...";
      _currentLocationName = "loading...";
      _currentTemperatureString = "loading...";
      _currentWeatherCondition = "loading...";
    });
  }

  // Formats given temperature value (in ºK) to specified temperature unit
  String _formatTemperature(double tempToFormat, TemperatureUnits tempUnit) {
    String newTemperature = "Null";
    switch (tempUnit) {
      case TemperatureUnits.celsius:
        newTemperature = "${(tempToFormat - 273.15).round().toString()} ºC";

      case TemperatureUnits.fahrenheit:
        newTemperature =
        "${(1.8 * (tempToFormat - 273) + 32).round().toString()} ºF";
    }
    return newTemperature;
  }

  // --------------------------------- BUILD ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 400, child: Flutter3DViewer(src: _3dModelPath)),
            const Text("Current time:", style: TextStyle(fontSize: 30)),
            Text(
              _currentTime,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("Current location:", style: TextStyle(fontSize: 30)),
            Text(
              _currentLocationCoords,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _currentLocationName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("Weather at location:", style: TextStyle(fontSize: 30)),
            Text(
              _currentTemperatureString,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _currentWeatherCondition,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
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
          Navigator.pushNamed(
            context,
            "settings",
          ).then((value) => _updateTemperatureUnit());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
