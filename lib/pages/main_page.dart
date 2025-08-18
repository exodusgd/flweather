// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flweather/enums/location_errors.dart';

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
import '../styles/custom_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // --------------------------- CLASS VARIABLES ---------------------------
  // State vars
  bool _hasFetchedLocationAndWeather = false;
  bool _canDisplayWeatherInfo = false;
  bool _canDrawTryAgainButton = false;
  bool _canDraw3DView = true;

  // Display vars
  String _currentLocationName = "";
  LocationOptions _selectedLocationOption = LocationOptions.current;

  double _currentTemperature = 0;
  String _currentTemperatureString = "";
  String _currentTemperatureUnitString = "";
  TemperatureUnits _currentTemperatureUnit = TemperatureUnits.celsius;

  WeatherConditions _currentWeatherCondition = WeatherConditions.sunny;

  String _currentStatusMessage = "Unknown error, please try again later";
  final String _loadingMessage = "Loading weather info...";
  final String _locationServicesNotEnabledMessage =
      "Could not retrieve current location, please set a different weather location"
      " or turn on device location and try again.";
  final String _locationPermissionsNotGrantedMessage =
      "Could not retrieve current location, please set a different weather location"
      " or allow location permissions and try again.";
  final String _locationServiceCallFailedMessage =
      "Could not retrieve current location, please set a different weather location"
      " or try again later.";
  final String _weatherServiceCallFailedMessage =
      "Could not retrieve current weather, please try again later.";

  String _3dModelPath = "assets/3d/sunny_icon.glb";
  // Clock
  late String _currentDate;
  late String _currentTimeHours;
  late String _currentTimeMins;
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
    String formattedTimeHours = DateFormat.H().format(time);
    String formattedTimeMins = DateFormat("mm").format(time);
    String formattedTimeSecs = DateFormat("ss").format(time);
    setState(() {
      _currentDate = formattedDate;
      _currentTimeHours = formattedTimeHours;
      _currentTimeMins = formattedTimeMins;
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

  void _fetchLocationAndWeather() async {
    _canDisplayWeatherInfo = false;
    _setStatusMessage(_loadingMessage, false);
    if (_selectedLocationOption == LocationOptions.current) {
      _locationService.checkServiceAndPermissions().then(
        (locError) => {
          switch (locError) {
            // If error is null then services are enabled and permissions are granted
            null => _locationService.getLocation().then(
              (location) => {
                if (location != null)
                  {
                    _updateCurrentLocation(location),
                    _weatherService
                        .getWeatherByCoords(
                          location.latitude,
                          location.longitude,
                        )
                        .then(
                          (weather) => {
                            if (weather != null)
                              {
                                _updateCurrentWeather(weather),
                                // Successfully fetched loc and weather
                                _hasFetchedLocationAndWeather = true,
                              }
                            else
                              {
                                _setStatusMessage(
                                  // Failed to fetch weather
                                  _weatherServiceCallFailedMessage,
                                  true,
                                ),
                              },
                          },
                        ),
                  }
                else
                  {_setStatusMessage(_locationServiceCallFailedMessage, true)},
              },
            ),
            LocationErrors.servicesNotEnabled => _setStatusMessage(
              _locationServicesNotEnabledMessage,
              true,
            ),

            LocationErrors.permissionsNotGranted => _setStatusMessage(
              _locationPermissionsNotGrantedMessage,
              true,
            ),
          },
        },
      );
    } else {
      _weatherService
          .getWeatherByCityID(
            LocationOptionsUtils.getCityID(_selectedLocationOption)!,
          )
          .then(
            (weather) => {
              if (weather != null)
                {
                  _updateCurrentWeather(weather),
                  _currentLocationName =
                      "${weather.cityName}, ${weather.countryCode}",
                  // Successfully fetched loc and weather
                  _hasFetchedLocationAndWeather = true,
                  // Update display
                  setState(() {}),
                }
              else
                {
                  _setStatusMessage(
                    // Failed to fetch weather
                    _weatherServiceCallFailedMessage,
                    true,
                  ),
                },
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
    _currentTemperature = newWeather.currentTemperature;
    _updateTemperatureDisplay();
    _updateWeather3DModel(newWeather.condition!);
  }

  void _displayWeatherInfo() {
    _canDisplayWeatherInfo = true;
  }

  // Changes the displayed 3D model based on the weather condition
  void _updateWeather3DModel(WeatherConditions newWeatherCondition) {
    if (newWeatherCondition != _currentWeatherCondition) {
      _currentWeatherCondition = newWeatherCondition;
      _canDraw3DView = true;
      String basePath = "assets/3d/";
      switch (newWeatherCondition) {
        case WeatherConditions.cloudy:
          _3dModelPath =
              "$basePath"
              "cloudy_icon.glb";
          setState(() {});

        case WeatherConditions.rain:
          _3dModelPath =
              "$basePath"
              "rain_icon.glb";
          setState(() {});

        case WeatherConditions.snow:
          _3dModelPath =
              "$basePath"
              "snow_icon.glb";
          setState(() {});

        case WeatherConditions.sunny:
          _3dModelPath =
              "$basePath"
              "sunny_icon.glb";
          setState(() {});

        case WeatherConditions.thunder:
          _3dModelPath =
              "$basePath"
              "thunder_icon.glb";
          setState(() {});
      }
    } else {
      _displayWeatherInfo();
    }
  }

  // Loads temperature unit from shared preferences
  // and updates display if the temperature unit to use has changed
  void _loadTemperatureUnit() {
    if (_canDisplayWeatherInfo && _sharedPrefs != null) {
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

  void _setStatusMessage(String newMessage, bool drawButton) {
    setState(() {
      _currentStatusMessage = newMessage;
      _canDrawTryAgainButton = drawButton;
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

  void _on3DModelLoaded() {
    if (_hasFetchedLocationAndWeather) {
      _displayWeatherInfo();
    }
  }

  void _on3DModelLoadError() {
    _canDraw3DView = false;
    _displayWeatherInfo();
  }

  // --------------------------------- BUILD ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(gradient: CustomColors.bgGradient),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // ----------------- Location -----------------
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 20),
                      child: Text(
                        textAlign: TextAlign.center,
                        _currentLocationName,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),

                    // ------------------- Time -------------------
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .11,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width * .15,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                textAlign: TextAlign.right,
                                _currentTimeHours,
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                            ),
                          ),
                          Text(
                            ":",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width * .15,
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              _currentTimeMins,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, bottom: 4),
                            child: Text(
                              ":",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width * .1,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 2,
                              ),
                              child: Text(
                                textAlign: TextAlign.left,
                                _currentTimeSecs,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------- Date -------------------
                    Text(
                      _currentDate,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    // ------------------ 3D View ------------------
                    Builder(
                      builder: (context) {
                        if (_canDraw3DView) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Flutter3DViewer(
                                src: _3dModelPath,
                                progressBarColor: Color(0x00FFFFFF),
                                onLoad: (String modelAddress) {
                                  _on3DModelLoaded();
                                },
                                onError: (String error) {
                                  _on3DModelLoadError();
                                },
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    // ---------------- Temperature ----------------
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.right,
                            _currentTemperatureString,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          Text(
                            textAlign: TextAlign.left,
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
          ),
          // ---------------- App status display message ----------------
          Builder(
            builder: (context) {
              if (!_canDisplayWeatherInfo) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(gradient: CustomColors.bgGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textAlign: TextAlign.justify,
                            _currentStatusMessage,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Builder(
                            builder: (context) {
                              if (_canDrawTryAgainButton) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _fetchLocationAndWeather();
                                    },
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Try again",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            "settings",
          ).then((value) => {_loadTemperatureUnit(), _loadLocationOption()});
        },
        backgroundColor: Color(0x000E5FBC),
        elevation: 0,
        child: const Icon(Icons.settings, size: 40),
      ),
    );
  }
}
