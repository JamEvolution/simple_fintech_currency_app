import 'package:flutter/material.dart';

class EmptyOrLoadingState extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;

  const EmptyOrLoadingState({
    super.key,
    required this.isLoading,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Veriler yükleniyor...'),
          ],
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarih aralığında veri bulunamadı.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen farklı bir tarih aralığı seçin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
} 