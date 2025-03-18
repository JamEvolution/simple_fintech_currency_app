import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final double result;
  final String amount;
  final String sourceCurrency;
  final String targetCurrency;

  const ResultDisplay({
    super.key,
    required this.result,
    required this.amount,
    required this.sourceCurrency,
    required this.targetCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Sonuç',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$amount $sourceCurrency = ',
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            '${result.toStringAsFixed(2)} $targetCurrency',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 