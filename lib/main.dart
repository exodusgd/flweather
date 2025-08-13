import 'package:flutter/material.dart';
import 'package:location/location.dart';

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
  String _locationName = "Null";

  Location location = Location();
  bool _isLocationEnabled = false;
  PermissionStatus? _locationPermissionStatus;
  LocationData? _locationData;

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

    // location service is enabled and permission is granted
    _locationData = await location.getLocation();
    _updateCurrentLocation(_locationData.toString());
  }

  void _updateCurrentLocation(String newLocationName) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _locationName = newLocationName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.blue,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Current location:", style: TextStyle(fontSize: 30)),
            Text(
              _locationName,
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
