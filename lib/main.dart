// Flutter imports
import 'package:flutter/material.dart';

// Project imports
import 'package:flweather/services/location_service.dart';
import 'package:flweather/services/weather_service.dart';
import 'models/weather_model.dart';
import 'models/location_model.dart';

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
  final LocationService _locationService = LocationService();

  // Weather vars
  final WeatherService _weatherService = WeatherService(
    // API key from openweathermap.org
    apiKey: "391870125944c3e1dd3eb3d26bdf5f85",
  );

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

  void _updateCurrentLocation(Location newLocation) {
    setState(() {
      _locationCoords = "lat: ${newLocation.latitude.toString()} \n long: ${newLocation.longitude.toString()}";
      _locationName = "${newLocation.locality}, ${newLocation.country}";
    });
  }

  void _updateCurrentWeather(Weather newWeather) {
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
                _fetchLocationAndWeather();
              },
              child: const Text("Get location"),
            ),
          ],
        ),
      ),
    );
  }
}
