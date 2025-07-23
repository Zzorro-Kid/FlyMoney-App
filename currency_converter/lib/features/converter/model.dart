class Currency {
  final String code;
  final String name;
  final String flag;

  Currency({required this.code, required this.name, required this.flag});

  @override
  String toString() => '$code - $name';
}

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

  Map<String, dynamic> toMap() => {
    'from': fromCurrency,
    'to': toCurrency,
    'amount': amount,
    'result': result,
    'date': date.toIso8601String(),
  };

  factory ConversionResult.fromMap(Map<String, dynamic> map) =>
      ConversionResult(
        fromCurrency: map['from'],
        toCurrency: map['to'],
        amount: map['amount'],
        result: map['result'],
        date: DateTime.parse(map['date']),
      );
}
