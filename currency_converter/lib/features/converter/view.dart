import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'converter.dart';
import 'package:currency_converter/features/converter/model.dart';
import 'package:currency_converter/app/theme.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();

    return Consumer<CurrencyConverter>(
      builder: (context, converter, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Currency converter'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showThemeDialog(context),
                tooltip: 'Theme settings',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCurrencyInput(converter, theme, context),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildSwapButton(converter),
                  ),
                  const SizedBox(height: 20),
                  _buildCurrencyOutput(converter, theme),
                  if (converter.error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        converter.error,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyInput(
      CurrencyConverter converter, ThemeData theme, BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<Currency>(
              value: converter.fromCurrency,
              isExpanded: true,
              items: converter.currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.flag} ${currency.toString()}'),
                    ),
                  )
                  .toList(),
              onChanged: converter.setFromCurrency,
            ),
            const SizedBox(height: 16),
            _buildAmountTextField(converter, context),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountTextField(
      CurrencyConverter converter, BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Amount',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.attach_money),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            converter.setAmount(0.0);
          },
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (value) {
        debugPrint('Raw input: $value');

        final cleanValue =
            value.replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(',', '.');

        final amount = double.tryParse(cleanValue) ?? 0.0;
        debugPrint('Parsed amount: $amount');

        converter.setAmount(amount);
      },
    );
  }

  Widget _buildSwapButton(CurrencyConverter converter) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.swap_vert, color: Colors.white),
      ),
      iconSize: 40,
      onPressed: converter.swapCurrencies,
    );
  }

  Widget _buildCurrencyOutput(CurrencyConverter converter, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<Currency>(
              value: converter.toCurrency,
              isExpanded: true,
              items: converter.currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.flag} ${currency.toString()}'),
                    ),
                  )
                  .toList(),
              onChanged: converter.setToCurrency,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Result:', style: theme.textTheme.titleMedium),
                  converter.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          converter.convertedAmount.toStringAsFixed(2),
                          style: theme.textTheme.headlineSmall,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final theme = Provider.of<AppTheme>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: theme.themeMode,
              onChanged: (_) => theme.toggleTheme(false),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: theme.themeMode,
              onChanged: (_) => theme.toggleTheme(false),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: theme.themeMode,
              onChanged: (_) => theme.toggleTheme(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
