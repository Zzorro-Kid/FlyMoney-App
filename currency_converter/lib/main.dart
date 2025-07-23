import 'package:flutter/material.dart';
import 'package:currency_converter/app/app.dart';
import 'package:currency_converter/app/theme.dart';
import 'package:provider/provider.dart';
import 'package:currency_converter/features/converter/converter.dart';
import 'package:currency_converter/features/history/history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => CurrencyConverter()),
        ChangeNotifierProvider(create: (_) => ConversionHistory()),
      ],
      child: const CurrencyApp(),
    ),
  );
}
