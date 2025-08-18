import 'dart:convert';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Weather?> getWeatherByCoords(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse("$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey"),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      // Failed to load weather data
      return null;
    }
  }

  Future<Weather?> getWeatherByCityID(String cityID) async {
    final response = await http.get(
      Uri.parse("$baseUrl?id=$cityID&appid=$apiKey"),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      // Failed to load weather data
      return null;
    }
  }
}
