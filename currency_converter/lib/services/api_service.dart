import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateAPI {
  static const String _frankfurterUrl = 'https://api.frankfurter.app';
  static const String _exchangeRateHostUrl = 'https://api.exchangerate.host';

  static Future<double> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    try {
      return await _fetchFromFrankfurter(from, to);
    } catch (e) {
      if (kDebugMode) {
        print('Frankfurter API error: $e');
      }
    }

    try {
      return await _fetchFromExchangeRateHost(from, to);
    } catch (e) {
      if (kDebugMode) {
        print('ExchangeRate.host error: $e');
      }
    }

    final cachedRate = await _getCachedRate(from, to);
    if (cachedRate != null) return cachedRate;

    return _getHardcodedRate(from, to);
  }

  static Future<double> _fetchFromFrankfurter(String from, String to) async {
    final url = '$_frankfurterUrl/latest?from=$from';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = Map<String, dynamic>.from(data['rates']);
      final rate = rates[to]?.toDouble() ?? _throwRateNotFound(to);

      await _saveRateToCache(from, to, rate);
      return rate;
    }
    throw Exception('Frankfurter API: ${response.statusCode}');
  }

  static Future<double> _fetchFromExchangeRateHost(
      String from, String to) async {
    final url = '$_exchangeRateHostUrl/convert?from=$from&to=$to';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rate = data['result']?.toDouble() ?? _throwRateNotFound(to);

      await _saveRateToCache(from, to, rate);
      return rate;
    }
    throw Exception('ExchangeRate.host: ${response.statusCode}');
  }

  static double _getHardcodedRate(String from, String to) {
    final rates = {
      'USD': {'EUR': 0.94, 'UAH': 39.0, 'PLN': 4.2, 'JPY': 154.0},
      'EUR': {'USD': 1.07, 'UAH': 42.0, 'PLN': 4.5, 'JPY': 164.0},
      'UAH': {'USD': 0.026, 'EUR': 0.024, 'PLN': 0.11, 'JPY': 4.0},
      'PLN': {'USD': 0.24, 'EUR': 0.22, 'UAH': 9.5, 'JPY': 37.0},
    };

    return rates[from]?[to] ?? 1.0;
  }

  static Future<void> _saveRateToCache(
      String from, String to, double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rate_${from}_$to', rate);
    await prefs.setInt(
        'last_update_${from}_$to', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<double?> _getCachedRate(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('last_update_${from}_$to') ?? 0;
    final hoursSinceUpdate =
        (DateTime.now().millisecondsSinceEpoch - lastUpdate) / (1000 * 3600);

    if (hoursSinceUpdate < 24) {
      return prefs.getDouble('rate_${from}_$to');
    }
    return null;
  }

  static Never _throwRateNotFound(String currency) {
    throw Exception('Exchange rate for $currency not found in API response');
  }
}
