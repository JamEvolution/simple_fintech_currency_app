import '../constants/error_constants.dart';
import '../utils/logger_utils.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details}) {
    // Hata oluştuğunda otomatik olarak log'a kaydet
    AppLogger.e('$code: $message', details);
  }

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Ağ hatalarına özgü exception sınıfı
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details}) 
      : super(message, code: code ?? ErrorCodes.network, details: details);
}

/// Bağlantı zaman aşımı hataları
class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException({String? details})
      : super(ErrorMessages.timeout, code: ErrorCodes.timeout, details: details);
}

/// Sunucu hatalarına özgü exception sınıfı
class ServerException extends NetworkException {
  final int? statusCode;
  
  ServerException(String message, {this.statusCode, String? code, dynamic details})
      : super(message, code: code ?? ErrorCodes.server, details: details);
  
  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ', Status: $statusCode' : ''}';
}

/// Kötü sunucu yanıtı hataları
class BadResponseException extends ServerException {
  BadResponseException(int statusCode, {String? message, dynamic details})
      : super(
          message ?? ErrorMessages.httpError(statusCode),
          statusCode: statusCode,
          code: ErrorCodes.badResponse,
          details: details
        );
}

/// Veri ayrıştırma hataları
class ParseException extends AppException {
  ParseException(String message, {String? code, dynamic details})
      : super(message, code: code ?? ErrorCodes.parse, details: details);
}

/// Önbellek hataları
class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic details})
      : super(message, code: code ?? ErrorCodes.cache, details: details);
}

/// Bilinmeyen hatalar
class UnknownException extends AppException {
  UnknownException(dynamic error)
      : super(
          ErrorMessages.unknown, 
          code: ErrorCodes.unknown, 
          details: error.toString()
        );
} 