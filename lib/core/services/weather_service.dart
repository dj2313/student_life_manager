import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String iconUrl;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.cityName,
  });

  factory WeatherData.fromWeatherstack(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return WeatherData(
      temperature: (current['temperature'] as num).toDouble(),
      condition: current['weather_descriptions'][0] ?? 'Unknown',
      iconUrl: current['weather_icons'][0] ?? '',
      cityName: location['name'],
    );
  }
}

class WeatherService {
  final Dio _dio = Dio();
  // Using HTTP because Weatherstack free tier does not support HTTPS
  static const String _baseUrl = 'http://api.weatherstack.com/current';
  String get _apiKey => dotenv.env['WEATHERSTACK_API_KEY'] ?? '';

  Future<WeatherData?> fetchWeather(String city) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'access_key': _apiKey, 'query': city},
      );

      if (response.statusCode == 200 && response.data['current'] != null) {
        return WeatherData.fromWeatherstack(response.data);
      } else if (response.data['error'] != null) {
        debugPrint('Weatherstack API Error: ${response.data['error']['info']}');
      }
    } catch (e) {
      debugPrint('Weather Service Error: $e');
    }
    return null;
  }

  Future<WeatherData?> fetchWeatherByCoords(
    double lat,
    double lon,
    String label,
  ) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'access_key': _apiKey, 'query': '$lat,$lon'},
      );

      if (response.statusCode == 200 && response.data['current'] != null) {
        return WeatherData.fromWeatherstack(response.data);
      } else if (response.data['error'] != null) {
        debugPrint('Weatherstack API Error: ${response.data['error']['info']}');
      }
    } catch (e) {
      debugPrint('Weather Service Error by coords: $e');
    }
    return null;
  }
}
