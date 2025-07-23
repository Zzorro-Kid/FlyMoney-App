import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberFormatter {
  static final _currencyFormatter = NumberFormat.currency(
    decimalDigits: 2,
    symbol: '',
  );

  static String formatMoney(double amount) {
    return _currencyFormatter.format(amount);
  }

  static double parseMoney(String input) {
    try {
      return _currencyFormatter.parse(input).toDouble();
    } catch (e) {
      return 0.0;
    }
  }
}

class FormValidators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter amount';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Incorrect number';
    }
    if (amount <= 0) {
      return 'The amount must be greater than zero.';
    }
    return null;
  }
}

class DateUtils {
  static String formatShortDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  static String formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (dateDay == yesterday) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    }
  }
}

class ThemeUtils {
  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getContrastColor(BuildContext context) {
    return isDarkTheme(context) ? Colors.white : Colors.black;
  }
}

class ApiUtils {
  static String handleApiError(dynamic error) {
    if (error is String) return error;
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    return 'An error has occurred. Please try again later.';
  }
}

/// Extensions for [BuildContext]
extension ContextExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;
}

/// Extensions for [String]
extension StringExtensions on String {
  /// Truncates the string if it is longer [maxLength]
  String truncate({int maxLength = 20}) {
    return length <= maxLength ? this : '${substring(0, maxLength)}...';
  }
}

/// Extensions for [DateTime]
extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
