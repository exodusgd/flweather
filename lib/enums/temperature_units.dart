// Enum with all the possible temperature units
enum TemperatureUnits { celsius, fahrenheit }

class TemperatureUnitsUtilities{
  // Map with temperature unit names as map keys and enum values as map values
  // (populated on initState)
  Map<String, TemperatureUnits> _tempUnitStringToValue = {};

  // Populates the tempUnitNameToValue map
  void _initStringToValueMap(){
    for(TemperatureUnits unit in TemperatureUnits.values){
      _tempUnitStringToValue[unit.toString()] = unit;
    }
  }

  TemperatureUnits? convertStringToValue(String stringToConvert){
    if(_tempUnitStringToValue.isEmpty){
      _initStringToValueMap();
    }
    return _tempUnitStringToValue[stringToConvert];
  }
}