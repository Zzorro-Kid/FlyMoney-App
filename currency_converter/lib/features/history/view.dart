import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history.dart';
import '../converter/model.dart';

class ConversionHistoryScreen extends StatelessWidget {
  const ConversionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<ConversionHistory>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion history'),
        actions: [
          if (history.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmClearHistory(context),
            ),
        ],
      ),
      body: history.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    'Conversion history is empty',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: history.history.length,
              itemBuilder: (context, index) {
                final item = history.history[index];
                return _buildHistoryItem(item, theme);
              },
            ),
    );
  }

  Widget _buildHistoryItem(ConversionResult item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          '${item.amount.toStringAsFixed(2)} ${item.fromCurrency} → ${item.result.toStringAsFixed(2)} ${item.toCurrency}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          _formatDate(item.date),
          style: theme.textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'All records will be deleted without the possibility of recovery..',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final history = Provider.of<ConversionHistory>(context, listen: false);
      await history.clearHistory();
    }
  }
}
