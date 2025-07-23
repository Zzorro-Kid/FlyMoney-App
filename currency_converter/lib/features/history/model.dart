class ConversionResult {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double result;
  final DateTime date;

  ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.result,
    required this.date,
  });

  String get formattedResult {
    final currenciesWithSymbols = {
      'PLN': 'zł',
      'UAH': '₴',
      'USD': '\$',
      'EUR': '€',
      'JPY': '¥',
      'GBP': '£',
      'RUB': '₽',
    };

    final fromSymbol = currenciesWithSymbols[fromCurrency] ?? fromCurrency;
    final toSymbol = currenciesWithSymbols[toCurrency] ?? toCurrency;

    return '${amount.toStringAsFixed(2)} $fromSymbol → ${result.toStringAsFixed(2)} $toSymbol';
  }
}
