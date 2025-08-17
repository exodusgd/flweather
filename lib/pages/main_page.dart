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
import '../enums/location_options.dart';
import '../utils/location_options_utils.dart';
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
  bool _hasFetchedLocationAndWeather = false;

  // Display vars
  String _currentLocationName = "";
  LocationOptions _selectedLocationOption = LocationOptions.current;

  double _currentTemperature = 0;
  String _currentTemperatureString = "";
  String _currentTemperatureUnitString = "";
  TemperatureUnits _currentTemperatureUnit = TemperatureUnits.celsius;

  // TODO: change default 3D icon
  String _3dModelPath = "assets/3d/sunny_icon.glb";
  // Clock
  late String _currentDate;
  late String _currentTimeHM;
  late String _currentTimeSecs;
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

  void _initSharedPrefs() async {
    _sharedPrefs = await SharedPrefsUtils.getSharedPrefs();
    _loadLocationOption();
    _loadTemperatureUnit();
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
    String formattedDate = DateFormat("d-M-y").format(time);
    String formattedTimeHM = DateFormat("kk:mm").format(time);
    String formattedTimeSecs = DateFormat(":ss").format(time);
    setState(() {
      _currentDate = formattedDate;
      _currentTimeHM = formattedTimeHM;
      _currentTimeSecs = formattedTimeSecs;
    });
  }

  // Loads location option from shared preferences
  // and updates display if the selected location changed
  void _loadLocationOption() {
    if (_sharedPrefs != null) {
      String? locOptionString = _sharedPrefs!.getString(
        SharedPrefsKeys.weatherLocation.toString(),
      );
      if (locOptionString != null) {
        LocationOptions locOption =
            LocationOptionsUtils.convertSavedStringToValue(locOptionString)!;
        if (locOption != _selectedLocationOption) {
          _selectedLocationOption = locOption;
          // Fetch info from new selected location
          _fetchLocationAndWeather();
          return;
        }
      }
    }
    if (!_hasFetchedLocationAndWeather) {
      // Fetch info from default location
      _fetchLocationAndWeather();
    }
  }

  // TODO: Display some sort of error message when location services/perms are not allowed
  void _fetchLocationAndWeather() async {
    _hasFetchedLocationAndWeather = true;
    _setLoadingText();
    if (_selectedLocationOption == LocationOptions.current) {
      _locationService.getLocation().then(
        (location) => {
          _updateCurrentLocation(location!),
          _weatherService
              .getWeatherByCoords(location.latitude, location.longitude)
              .then((weather) => {_updateCurrentWeather(weather)}),
        },
      );
    } else {
      _weatherService
          .getWeatherByCityID(
            LocationOptionsUtils.getCityID(_selectedLocationOption)!,
          )
          .then(
            (weather) => {
              _updateCurrentWeather(weather),
              _currentLocationName =
                  "${weather.cityName}, ${weather.countryCode}",
              // Update display
              setState(() {}),
            },
          );
    }
  }

  // Updates current location var based on given location and updates display
  void _updateCurrentLocation(Location newLocation) {
    setState(() {
      _currentLocationName = "${newLocation.locality}, ${newLocation.country}";
    });
  }

  // Updates current weather var based on given weather and updates display
  void _updateCurrentWeather(Weather newWeather) {
    _hasReceivedWeatherInfo = true;
    _currentTemperature = newWeather.currentTemperature;
    _updateWeather3DModel(newWeather.condition!);
    _updateTemperatureDisplay();
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

  // Loads temperature unit from shared preferences
  // and updates display if the temperature unit to use has changed
  void _loadTemperatureUnit() {
    if (_hasReceivedWeatherInfo && _sharedPrefs != null) {
      String? tempUnitString = _sharedPrefs!.getString(
        SharedPrefsKeys.temperatureUnit.toString(),
      );
      if (tempUnitString != null) {
        TemperatureUnits tempUnit = TemperatureUnitsUtils.convertStringToValue(
          tempUnitString,
        )!;
        if (tempUnit != _currentTemperatureUnit) {
          _currentTemperatureUnit = tempUnit;
          _updateTemperatureDisplay();
        }
      }
    }
  }

  // Updates the temperature display
  void _updateTemperatureDisplay() {
    setState(() {
      _currentTemperatureString = _formatTemperature(
        _currentTemperature,
        _currentTemperatureUnit,
      );
    });
  }

  // TODO: Find another solution to show the info is loading
  void _setLoadingText() {
    setState(() {
      _currentLocationName = "loading...";
      _currentTemperatureString = "loading...";
    });
  }

  // Formats given temperature value (in ºK) to specified temperature unit
  String _formatTemperature(double tempToFormat, TemperatureUnits tempUnit) {
    String newTemperature = "Null";
    switch (tempUnit) {
      case TemperatureUnits.celsius:
        newTemperature = (tempToFormat - 273.15).round().toString();
        _currentTemperatureUnitString = "ºC";

      case TemperatureUnits.fahrenheit:
        newTemperature = (1.8 * (tempToFormat - 273) + 32).round().toString();
        _currentTemperatureUnitString = "ºF";
    }
    return newTemperature;
  }

  // --------------------------------- BUILD ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF41B2DC), const Color(0xFF0E4BBC)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ----------------- Location -----------------
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 20),
                child: Text(
                  _currentLocationName,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              // ------------------- Time -------------------
              Padding(
                padding: const EdgeInsets.only(left:40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentTimeHM,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 5),
                      child: Text(
                        _currentTimeSecs,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // ------------------- Date -------------------
              Text(
                _currentDate,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              // ------------------ 3D View ------------------
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(height: MediaQuery.of(context).size.height*0.4, child: Flutter3DViewer(src: _3dModelPath)),
              ),
              // ---------------- Temperature ----------------
              Padding(
                padding: const EdgeInsets.only(left:30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTemperatureString,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      _currentTemperatureUnitString,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              // ---------------------------------------------
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            "settings",
          ).then((value) => {_loadTemperatureUnit(), _loadLocationOption()});
        },
        backgroundColor: Color(0xFF0E5FBC),
        child: const Icon(Icons.settings),
      ),
    );
  }
}
