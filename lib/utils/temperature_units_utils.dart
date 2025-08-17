import '../enums/temperature_units.dart';

class TemperatureUnitsUtils{
  // Map with temperature unit names as map keys and enum values as map values
  // (populated on initState)
  static Map<String, TemperatureUnits> _tempUnitStringToValue = {};

  // Populates the tempUnitNameToValue map
  static void _initStringToValueMap(){
    for(TemperatureUnits unit in TemperatureUnits.values){
      _tempUnitStringToValue[unit.toString()] = unit;
    }
  }

  static TemperatureUnits? convertStringToValue(String stringToConvert){
    if(_tempUnitStringToValue.isEmpty){
      _initStringToValueMap();
    }
    return _tempUnitStringToValue[stringToConvert];
  }
}