import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_converter/services/api_service.dart';
import 'model.dart';

class CurrencyConverter with ChangeNotifier {
  List<Currency> currencies = [
    Currency(code: 'USD', name: 'Dollar USA', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'RUB', name: 'Russian ruble', flag: '🇷🇺'),
    Currency(code: 'GBP', name: 'Pound sterling', flag: '🇬🇧'),
    Currency(code: 'PLN', name: 'Polish zloty', flag: '🇵🇱'),
    Currency(code: 'UAH', name: 'Ukrainian hryvnia', flag: '🇺🇦'),
    Currency(code: 'JPY', name: 'Japanese yen', flag: '🇯🇵'),
  ];

  Currency? _fromCurrency;
  Currency? _toCurrency;
  double _amount = 0;
  double _convertedAmount = 0;
  bool _isLoading = false;
  String _error = '';

  Currency? get fromCurrency => _fromCurrency;
  Currency? get toCurrency => _toCurrency;
  double get amount => _amount;
  double get convertedAmount => _convertedAmount;
  bool get isLoading => _isLoading;
  String get error => _error;

  CurrencyConverter() {
    _loadLastSelectedCurrencies();
  }

  Future<void> _loadLastSelectedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final fromCode = prefs.getString('lastFromCurrency');
    final toCode = prefs.getString('lastToCurrency');

    if (fromCode != null) {
      _fromCurrency = currencies.firstWhere((c) => c.code == fromCode);
    } else {
      _fromCurrency = currencies.first;
    }

    if (toCode != null) {
      _toCurrency = currencies.firstWhere((c) => c.code == toCode);
    } else {
      _toCurrency = currencies[1];
    }

    notifyListeners();
  }

  void setFromCurrency(Currency? currency) async {
    _fromCurrency = currency;
    if (currency != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastFromCurrency', currency.code);
    }
    _convert();
    notifyListeners();
  }

  void setToCurrency(Currency? currency) async {
    _toCurrency = currency;
    if (currency != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastToCurrency', currency.code);
    }
    notifyListeners();
    _convert();
  }

  void setAmount(double amount) {
    debugPrint('Setting amount: $amount');
    _amount = amount;
    _convert();
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    notifyListeners();
    _convert();
  }

  Future<void> _convert() async {
    debugPrint('''
      Conversion started:
      From: ${_fromCurrency?.code}
      To: ${_toCurrency?.code}
      Amount: $_amount
      ''');
    if (_fromCurrency == null || _toCurrency == null || _amount <= 0) {
      _convertedAmount = 0;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final rate = await ExchangeRateAPI.getExchangeRate(
        _fromCurrency!.code,
        _toCurrency!.code,
      );

      _convertedAmount = _amount * rate;
      _error = '';
    } catch (e) {
      _error = 'Error getting course: $e';
      final prefs = await SharedPreferences.getInstance();
      final lastRate = prefs.getDouble(
        'lastRate_${_fromCurrency!.code}_${_toCurrency!.code}',
      );

      if (lastRate != null) {
        _convertedAmount = _amount * lastRate;
        _error = 'The last saved rate is used (possibly outdated)';
      } else {
        _convertedAmount = 0;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
