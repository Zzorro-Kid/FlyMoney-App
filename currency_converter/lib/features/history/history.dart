import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../converter/model.dart';
import 'dart:convert';

class ConversionHistory with ChangeNotifier {
  List<ConversionResult> _history = [];

  List<ConversionResult> get history => _history;

  ConversionHistory() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('conversionHistory') ?? [];

    _history = historyJson
        .map((json) => ConversionResult.fromMap(jsonDecode(json)))
        .toList();

    notifyListeners();
  }

  Future<void> addToHistory(ConversionResult result) async {
    _history.insert(0, result);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'conversionHistory',
      _history.map((item) => jsonEncode(item.toMap())).toList(),
    );

    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('conversionHistory');
    notifyListeners();
  }
}
