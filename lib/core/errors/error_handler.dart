import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import '../utils/logger_utils.dart';
import 'app_exceptions.dart';

/// Uygulama genelinde hata yakalama ve işlemeyi sağlayan sınıf
class ErrorHandler {
  static Future<void> initialize() async {
    AppLogger.info('ErrorHandler başlatılıyor');
    
    // Flutter framework'ünden gelen hataları yakala
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.e('Flutter Error', details.exception, details.stack);
      
      // Debug modda hata stacktrace göster
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    
    // Uygulama genelinde yakalanmamış hataları yakala
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.fatal('Yakalanmamış Hata', error, stack);
      return true;
    };
    
    // Isolate hataları için
    Isolate.current.addErrorListener(RawReceivePort((pair) {
      final List<dynamic> errorAndStacktrace = pair;
      final error = errorAndStacktrace[0];
      final stack = StackTrace.fromString(errorAndStacktrace[1].toString());
      AppLogger.fatal('Isolate Hatası', error, stack);
    }).sendPort);
    
    // Zone ile yakalanmamış hataları ele al
    runZonedGuarded(
      () {
        // Bu boş olabilir çünkü bu sadece hata yakalama için kurulum
      },
      (error, stack) {
        AppLogger.fatal('Zone Hatası', error, stack);
      },
    );
  }
  
  /// Exception'ı AppException'a dönüştür
  static AppException convertToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is TimeoutException) {
      return ConnectionTimeoutException(details: error.toString());
    }
    
    return UnknownException(error);
  }
} 