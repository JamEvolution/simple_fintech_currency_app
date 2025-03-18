import 'package:flutter/material.dart';

class LoadingOrError extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;

  const LoadingOrError({
    super.key,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Hata: $errorMessage',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
} 