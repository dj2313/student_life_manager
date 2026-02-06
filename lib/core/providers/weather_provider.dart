import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String _error = '';

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String get error => _error;

  String get temperature => _currentWeather != null
      ? '${_currentWeather!.temperature.toStringAsFixed(0)}°C'
      : '--°C';

  String get condition => _currentWeather?.condition ?? 'Unknown';

  IconData get weatherIcon {
    if (_currentWeather == null) return Icons.cloud_off_rounded;
    final code = _currentWeather!.iconCode;
    if (code.contains('01')) return Icons.wb_sunny_rounded;
    if (code.contains('02')) return Icons.wb_cloudy_rounded;
    if (code.contains('03') || code.contains('04')) return Icons.cloud_rounded;
    if (code.contains('09') || code.contains('10'))
      return Icons.umbrella_rounded;
    if (code.contains('11')) return Icons.thunderstorm_rounded;
    if (code.contains('13')) return Icons.ac_unit_rounded;
    if (code.contains('50')) return Icons.foggy;
    return Icons.wb_cloudy_rounded;
  }

  Future<void> updateWeather(String city) async {
    _isLoading = true;
    _error = '';
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
}
