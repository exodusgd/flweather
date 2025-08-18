// Package imports
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocod;

// Project imports
import '../models/location_model.dart';
import '../enums/location_errors.dart';

class LocationService {
  loc.Location flutterLocation = loc.Location();
  bool _isLocationEnabled = false;
  loc.PermissionStatus? _locationPermissionStatus;
  loc.LocationData? _locationData;

  Future<LocationErrors?> checkServiceAndPermissions() async{
    _isLocationEnabled = await flutterLocation.serviceEnabled();
    if (!_isLocationEnabled) {
      _isLocationEnabled = await flutterLocation.requestService();
      if (!_isLocationEnabled) {
        return LocationErrors.servicesNotEnabled;
      }
    }

    _locationPermissionStatus = await flutterLocation.hasPermission();
    if (_locationPermissionStatus == loc.PermissionStatus.denied) {
      _locationPermissionStatus = await flutterLocation.requestPermission();
      if (_locationPermissionStatus != loc.PermissionStatus.granted) {
        return LocationErrors.permissionsNotGranted;
      }
    }
    return null;
  }

  Future<Location?> getLocation() async {
    _locationData = await flutterLocation.getLocation();
    if (_locationData != null) {
      if (_locationData!.longitude != null && _locationData!.latitude != null) {
        List<geocod.Placemark> placemarks = await geocod
            .placemarkFromCoordinates(
              _locationData!.latitude!,
              _locationData!.longitude!,
            );
        if (placemarks.isNotEmpty) {
          if (placemarks.reversed.last.locality! != "") {
            return Location(
              latitude: _locationData!.latitude!,
              longitude: _locationData!.longitude!,
              locality: placemarks.reversed.last.locality!,
              country: placemarks.reversed.last.isoCountryCode!,
            );
          }else{
            return Location(
              latitude: _locationData!.latitude!,
              longitude: _locationData!.longitude!,
              locality: placemarks.reversed.last.subAdministrativeArea!,
              country: placemarks.reversed.last.isoCountryCode!,
            );
          }
        } else {
          // Failed to obtain location name from latitude/longitude
          return null;
        }
      } else {
        // Failed to obtain latitude and/or longitude from location data
        return null;
      }
    } else {
      // Failed to obtain location data
      return null;
    }
  }
}
