// Package imports
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocod;

// Project imports
import 'package:flweather/models/location_model.dart';

class LocationService {
  loc.Location flutterLocation = loc.Location();
  bool _isLocationEnabled = false;
  loc.PermissionStatus? _locationPermissionStatus;
  loc.LocationData? _locationData;

  Future<Location?> getLocation() async {
    _isLocationEnabled = await flutterLocation.serviceEnabled();
    if (!_isLocationEnabled) {
      _isLocationEnabled = await flutterLocation.requestService();
      if (!_isLocationEnabled) {
        throw Exception("Location services are not enabled");
      }
    }

    _locationPermissionStatus = await flutterLocation.hasPermission();
    if (_locationPermissionStatus == loc.PermissionStatus.denied) {
      _locationPermissionStatus = await flutterLocation.requestPermission();
      if (_locationPermissionStatus != loc.PermissionStatus.granted) {
        throw Exception("Location permissions are not granted");
      }
    }

    _locationData = await flutterLocation.getLocation();
    if (_locationData != null) {
      if (_locationData!.longitude != null && _locationData!.latitude != null) {
        List<geocod.Placemark> placemarks = await geocod
            .placemarkFromCoordinates(
              _locationData!.latitude!,
              _locationData!.longitude!,
            );
        if (placemarks.isNotEmpty) {
          return Location(
            latitude: _locationData!.latitude!,
            longitude: _locationData!.longitude!,
            locality: placemarks.reversed.last.locality!,
            country: placemarks.reversed.last.isoCountryCode!,
          );
        } else {
          throw Exception(
            "Failed to obtain location name from latitude/longitude",
          );
        }
      } else {
        throw Exception(
          "Failed to obtain latitude and/or longitude from location data",
        );
      }
    } else {
      throw Exception("Failed to obtain location data");
    }
  }
}
