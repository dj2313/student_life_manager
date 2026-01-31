import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final Dio _dio = Dio();

  // Free API - no key required for basic usage
  // Alternative: https://open.er-api.com/v6/latest/EUR
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  Map<String, double> _cachedRates = {};
  DateTime? _lastUpdated;
  String _baseCurrency = 'EUR';

  // Getters
  Map<String, double> get rates => _cachedRates;
  DateTime? get lastUpdated => _lastUpdated;
  String get baseCurrency => _baseCurrency;

  /// Fetch latest exchange rates
  Future<Map<String, double>> fetchRates({String base = 'EUR'}) async {
    try {
      _baseCurrency = base;
      final response = await _dio.get('$_baseUrl/$base');

      if (response.statusCode == 200) {
        final data = response.data;
        Map<String, double> rates = {};

        // Parse rates
        final ratesData = data['rates'] as Map<String, dynamic>;
        ratesData.forEach((key, value) {
          rates[key] = (value as num).toDouble();
        });

        _cachedRates = rates;
        _lastUpdated = DateTime.now();

        debugPrint('✅ Currency rates updated: ${rates.length} currencies');
        return rates;
      } else {
        debugPrint('❌ Failed to fetch rates: ${response.statusCode}');
        return _cachedRates; // Return cached if available
      }
    } catch (e) {
      debugPrint('❌ Error fetching currency rates: $e');
      return _cachedRates; // Return cached if available
    }
  }

  /// Convert amount from one currency to another
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    if (_cachedRates.isEmpty) {
      debugPrint('⚠️ No rates available. Please fetch rates first.');
      return amount;
    }

    // If converting to base currency
    if (to == _baseCurrency && _cachedRates.containsKey(from)) {
      return amount / _cachedRates[from]!;
    }

    // If converting from base currency
    if (from == _baseCurrency && _cachedRates.containsKey(to)) {
      return amount * _cachedRates[to]!;
    }

    // If converting between two non-base currencies
    if (_cachedRates.containsKey(from) && _cachedRates.containsKey(to)) {
      // Convert to base first, then to target
      final inBase = amount / _cachedRates[from]!;
      return inBase * _cachedRates[to]!;
    }

    debugPrint('⚠️ Conversion not possible: $from → $to');
    return amount;
  }

  /// Get exchange rate between two currencies
  double getRate(String from, String to) {
    if (_cachedRates.isEmpty) return 1.0;

    if (to == _baseCurrency && _cachedRates.containsKey(from)) {
      return 1 / _cachedRates[from]!;
    }

    if (from == _baseCurrency && _cachedRates.containsKey(to)) {
      return _cachedRates[to]!;
    }

    if (_cachedRates.containsKey(from) && _cachedRates.containsKey(to)) {
      return _cachedRates[to]! / _cachedRates[from]!;
    }

    return 1.0;
  }

  /// Get formatted exchange rate string
  String getFormattedRate(String from, String to, {int decimals = 4}) {
    final rate = getRate(from, to);
    return rate.toStringAsFixed(decimals);
  }

  /// Check if rates are stale (older than 1 hour)
  bool get isStale {
    if (_lastUpdated == null) return true;
    final difference = DateTime.now().difference(_lastUpdated!);
    return difference.inHours >= 1;
  }

  /// Get list of supported currencies
  List<String> get supportedCurrencies {
    if (_cachedRates.isEmpty) {
      return ['EUR', 'USD', 'GBP', 'INR', 'JPY', 'AUD', 'CAD', 'CHF'];
    }
    return [_baseCurrency, ..._cachedRates.keys.toList()];
  }

  /// Get currency symbol
  String getCurrencySymbol(String code) {
    const symbols = {
      'EUR': '€',
      'USD': '\$',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'AED': 'د.إ',
      'BRL': 'R\$',
      'KRW': '₩',
      'MXN': 'Mex\$',
      'RUB': '₽',
      'SGD': 'S\$',
      'THB': '฿',
      'TRY': '₺',
      'ZAR': 'R',
    };
    return symbols[code] ?? code;
  }

  /// Get currency name
  String getCurrencyName(String code) {
    const names = {
      'EUR': 'Euro',
      'USD': 'US Dollar',
      'GBP': 'British Pound',
      'INR': 'Indian Rupee',
      'JPY': 'Japanese Yen',
      'AUD': 'Australian Dollar',
      'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc',
      'CNY': 'Chinese Yuan',
      'AED': 'UAE Dirham',
      'BRL': 'Brazilian Real',
      'KRW': 'South Korean Won',
      'MXN': 'Mexican Peso',
      'RUB': 'Russian Ruble',
      'SGD': 'Singapore Dollar',
      'THB': 'Thai Baht',
      'TRY': 'Turkish Lira',
      'ZAR': 'South African Rand',
    };
    return names[code] ?? code;
  }

  /// Clear cached rates
  void clearCache() {
    _cachedRates.clear();
    _lastUpdated = null;
  }
}
