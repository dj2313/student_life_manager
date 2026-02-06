import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String iconCode;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      cityName: json['name'],
    );
  }
}

class WeatherService {
  final Dio _dio = Dio();
  final String _apiKey =
      '8db950d86ae486337894d0774653697e'; // Placeholder/Actual Free Key for Demo

  Future<WeatherData?> fetchWeather(String city) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {'q': city, 'appid': _apiKey, 'units': 'metric'},
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Weather Service Error: $e');
    }
    return null;
  }
}
