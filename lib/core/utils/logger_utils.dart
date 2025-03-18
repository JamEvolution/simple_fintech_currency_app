import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Uygulama genelinde kullanılan logger sınıfı
class AppLogger {
  /// Varsayılan logger örneği
  static final Logger _defaultLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// Sade (düz metin) logger örneği
  static final Logger _simpleLogger = Logger(
    printer: SimplePrinter(colors: true, printTime: true),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// Debug log oluşturur
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Bilgi log'u oluşturur
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Uyarı log'u oluşturur
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Hata log'u oluşturur
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Detaylı log için kullanılır (en düşük seviye)
  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Kritik hata log'u oluşturur (en yüksek seviye)
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _defaultLogger.f(message, error: error, stackTrace: stackTrace);
  }
  
  /// Sade debug log oluşturur
  static void simpleDebug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _simpleLogger.d(message, error: error, stackTrace: stackTrace);
  }
  
  /// Sade hata log'u oluşturur
  static void simpleError(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _simpleLogger.e(message, error: error, stackTrace: stackTrace);
  }
} 