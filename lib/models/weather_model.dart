import '../enums/weather_conditions.dart';

class Weather {
  // TODO: check if cityName is in use
  final String cityName;
  final String countryCode;
  final double currentTemperature;
  final String conditionString;
  WeatherConditions? condition;

  Weather({
    required this.cityName,
    required this.countryCode,
    required this.currentTemperature,
    required this.conditionString,
  }) {
    condition = _apiConditionStringToValue(conditionString);
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json["name"],
      countryCode: json["sys"]["country"],
      currentTemperature: json["main"]["temp"].toDouble(),
      conditionString: json["weather"][0]["main"],
    );
  }

  WeatherConditions? _apiConditionStringToValue(String apiCondition) {
    switch (apiCondition) {
      case "Thunderstorm":
        return WeatherConditions.thunder;

      case "Drizzle":
        return WeatherConditions.rain;

      case "Rain":
        return WeatherConditions.rain;

      case "Snow":
        return WeatherConditions.snow;

      case "Clear":
        return WeatherConditions.sunny;

      case "Clouds":
        return WeatherConditions.cloudy;

      default:
        // TODO: Figure out how to handle remaining weather conditions
        return WeatherConditions.cloudy;
    }
  }
}
