import 'dart:convert';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Weather> getWeather(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse(
          "$BASE_URL?lat=$latitude&lon=$longitude&appid=$apiKey",
      ),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to load weather data, status code: ${response.statusCode}",
      );
    }
  }
}
