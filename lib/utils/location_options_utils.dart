import '../enums/location_options.dart';

class LocationOptionsUtils{
  // Map with temperature unit names as map keys and enum values as map values
  // (populated on initState)
  static Map<String, LocationOptions> _locationOptionsStringToValue = {};

  // Populates the tempUnitNameToValue map
  static void _initStringToValueMap(){
    for(LocationOptions unit in LocationOptions.values){
      _locationOptionsStringToValue[unit.toString()] = unit;
    }
  }

  static LocationOptions? convertStringToValue(String stringToConvert){
    if(_locationOptionsStringToValue.isEmpty){
      _initStringToValueMap();
    }
    return _locationOptionsStringToValue[stringToConvert];
  }
}