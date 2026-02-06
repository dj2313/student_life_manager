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

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, String city) {
    final current = json['current_weather'];
    final int code = current['weathercode'];

    // Map WMO Weather codes to OpenWeather-style icon codes for compatibility
    // or just use descriptive strings
    String icon = '01d'; // default sunny
    String desc = 'Clear';

    if (code == 0) {
      icon = '01d';
      desc = 'Clear';
    } else if (code <= 3) {
      icon = '02d';
      desc = 'Partly Cloudy';
    } else if (code == 45 || code == 48) {
      icon = '50d';
      desc = 'Foggy';
    } else if (code <= 55) {
      icon = '09d';
      desc = 'Drizzle';
    } else if (code <= 65) {
      icon = '10d';
      desc = 'Rainy';
    } else if (code <= 77) {
      icon = '13d';
      desc = 'Snowy';
    } else if (code <= 82) {
      icon = '09d';
      desc = 'Showers';
    } else if (code <= 86) {
      icon = '13d';
      desc = 'Snow Showers';
    } else if (code >= 95) {
      icon = '11d';
      desc = 'Thunderstorm';
    }

    return WeatherData(
      temperature: (current['temperature'] as num).toDouble(),
      condition: desc,
      iconCode: icon,
      cityName: city,
    );
  }
}

class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherData?> fetchWeather(String city) async {
    try {
      // 1. Geocoding: Get Lat/Long for the city name
      final geoResponse = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': city,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
      );

      if (geoResponse.data['results'] == null ||
          (geoResponse.data['results'] as List).isEmpty) {
        return null;
      }

      final location = geoResponse.data['results'][0];
      final double lat = location['latitude'];
      final double lon = location['longitude'];
      final String displayName = location['name'];

      return fetchWeatherByCoords(lat, lon, displayName);
    } catch (e) {
      debugPrint('Weather Service Error: $e');
    }
    return null;
  }

  Future<WeatherData?> fetchWeatherByCoords(
    double lat,
    double lon,
    String city,
  ) async {
    try {
      final weatherResponse = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current_weather': true,
          'timezone': 'auto',
        },
      );

      if (weatherResponse.statusCode == 200) {
        return WeatherData.fromOpenMeteo(weatherResponse.data, city);
      }
    } catch (e) {
      debugPrint('Weather Service Error by coords: $e');
    }
    return null;
  }
}
