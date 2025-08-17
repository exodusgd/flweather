import '../enums/location_options.dart';

class LocationOptionsUtils {
  // Map with temperature unit names as map keys and enum values as map values
  // (populated on initState)
  static Map<String, LocationOptions> _locationOptionsStringToValue = {};

  // Populates the tempUnitNameToValue map
  static void _initStringToValueMap() {
    for (LocationOptions unit in LocationOptions.values) {
      _locationOptionsStringToValue[unit.toString()] = unit;
    }
  }

  static LocationOptions? convertSavedStringToValue(String stringToConvert) {
    if (_locationOptionsStringToValue.isEmpty) {
      _initStringToValueMap();
    }
    return _locationOptionsStringToValue[stringToConvert];
  }

  static String? getCityID(LocationOptions loc) {
    switch (loc) {
      case LocationOptions.current:
        throw Exception("Invalid location, please provide a valid city");
      case LocationOptions.lisbon:
        return "2267056";
      case LocationOptions.leiria:
        return "2267094";
      case LocationOptions.coimbra:
        return "2740636";
      case LocationOptions.porto:
        return "2735941";
      case LocationOptions.faro:
        return "2268337";
    }
  }
}
