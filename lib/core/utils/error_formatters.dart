import 'package:flutter/material.dart';
import '../errors/app_exceptions.dart';

/// Hata mesajını formatlayan fonksiyon
String formatErrorMessage(Exception error) {
  if (error is AppException) {
    return error.message;
  }
  return 'Beklenmeyen bir hata oluştu: ${error.toString()}';
}

/// ScaffoldMessenger ile hata mesajı gösteren yardımcı metot
void showErrorSnackBar(BuildContext context, Exception error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(formatErrorMessage(error)),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// ScaffoldMessenger ile özel mesaj gösteren yardımcı metot
void showMessageSnackBar(
  BuildContext context, 
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError 
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ),
  );
} 