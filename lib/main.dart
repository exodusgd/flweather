// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocod;

// Project imports
import 'package:flweather/services/weather_service.dart';
import 'models/weather_model.dart';

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
      home: const MainPage(title: 'Flweather'),
    );
  }
}

// ----------- STATEFUL WIDGET -----------
class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

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
  Location location = Location();
  bool _isLocationEnabled = false;
  PermissionStatus? _locationPermissionStatus;
  LocationData? _locationData;

  // Weather vars
  final WeatherService _weatherService = WeatherService(
    apiKey: "391870125944c3e1dd3eb3d26bdf5f85",
  );
  Weather? _weather;

  void _requestLocationPermission() async {
    _isLocationEnabled = await location.serviceEnabled();
    if (!_isLocationEnabled) {
      _isLocationEnabled = await location.requestService();
      if (!_isLocationEnabled) {
        return;
      }
    }

    _locationPermissionStatus = await location.hasPermission();
    if (_locationPermissionStatus == PermissionStatus.denied) {
      _locationPermissionStatus = await location.requestPermission();
      if (_locationPermissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    // if location service is enabled and permission is granted
    // then get location, then covert location into a name, then update the ui
    location.getLocation().then(
      (locData) => {
        _getLocationNameFromData(locData).then(
          (locName) => {
            _updateCurrentLocation(
              "lat: ${locData.latitude.toString()} \n long: ${locData.longitude.toString()}",
              locName,
            ),
            _weatherService
                .getWeather(locData.latitude!, locData.longitude!)
                .then((locWeather) => {_updateCurrentWeather(locWeather)}),
          },
        ),
      },
    );
  }

  void _updateCurrentLocation(
    String newLocationCoords,
    String newLocationName,
  ) {
    setState(() {
      _locationCoords = newLocationCoords;
      _locationName = newLocationName;
    });
  }

  void _updateCurrentWeather(Weather newWeather) {
    setState(() {
      _locationTemperature = "${(newWeather.temperature - 273.15).round().toString()} ºC";
      _locationWeatherCondition = newWeather.condition;
    });
  }

  Future<String> _getLocationNameFromData(LocationData? locData) async {
    List<geocod.Placemark> placemarks = await geocod.placemarkFromCoordinates(
      locData!.latitude!,
      locData.longitude!,
    );
    return "${placemarks.reversed.last.locality}, ${placemarks.reversed.last.country}";
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text(widget.title)),
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
                _requestLocationPermission();
              },
              child: const Text("Get location"),
            ),
          ],
        ),
      ),
    );
  }
}
