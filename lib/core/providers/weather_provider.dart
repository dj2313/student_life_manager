import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String _error = '';
  String? _lastCity;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String get error => _error;

  String get temperature => _currentWeather != null
      ? '${_currentWeather!.temperature.toStringAsFixed(0)}°C'
      : '--°C';

  String get condition => _currentWeather?.condition ?? 'Unknown';

  IconData get weatherIcon {
    if (_currentWeather == null) return Icons.cloud_off_rounded;
    final condition = _currentWeather!.condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      return Icons.wb_sunny_rounded;
    }
    if (condition.contains('cloud')) {
      return Icons.wb_cloudy_rounded;
    }
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.umbrella_rounded;
    }
    if (condition.contains('thunder') || condition.contains('storm')) {
      return Icons.thunderstorm_rounded;
    }
    if (condition.contains('snow') || condition.contains('ice')) {
      return Icons.ac_unit_rounded;
    }
    if (condition.contains('fog') ||
        condition.contains('mist') ||
        condition.contains('haze')) {
      return Icons.foggy;
    }
    return Icons.wb_cloudy_rounded;
  }

  Future<void> updateWeather(String city) async {
    if (city == _lastCity && _currentWeather != null) return;

    _isLoading = true;
    _error = '';
    _lastCity = city;
    notifyListeners();

    try {
      final data = await _weatherService.fetchWeather(city);
      if (data != null) {
        _currentWeather = data;
      } else {
        _error = 'Failed to load weather';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWeatherByCoords(
    double lat,
    double lon,
    String label,
  ) async {
    _isLoading = true;
    _error = '';
    _lastCity = label;
    notifyListeners();

    try {
      final data = await _weatherService.fetchWeatherByCoords(lat, lon, label);
      if (data != null) {
        _currentWeather = data;
      } else {
        _error = 'Failed to load weather';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
