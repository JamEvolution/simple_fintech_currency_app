class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException({String? details})
      : super('Bağlantı zaman aşımına uğradı', code: 'TIMEOUT', details: details);
}

class ServerException extends NetworkException {
  final int? statusCode;
  
  ServerException(String message, {this.statusCode, String? code, dynamic details})
      : super(message, code: code ?? 'SERVER_ERROR', details: details);
  
  @override
  String toString() => 'ServerException: $message (Code: $code, Status: $statusCode)';
}

class BadResponseException extends ServerException {
  BadResponseException(int statusCode, {String? message, dynamic details})
      : super(
          message ?? _getMessageForStatus(statusCode),
          statusCode: statusCode,
          code: 'BAD_RESPONSE',
          details: details
        );
  
  static String _getMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek';
      case 401:
        return 'Yetkilendirme hatası';
      case 403:
        return 'Erişim reddedildi';
      case 404:
        return 'Kaynak bulunamadı';
      case 500:
        return 'Sunucu hatası';
      default:
        return 'HTTP hatası: $statusCode';
    }
  }
}

class ParseException extends AppException {
  ParseException(String message, {String? code, dynamic details})
      : super(message, code: code ?? 'PARSE_ERROR', details: details);
}

class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic details})
      : super(message, code: code ?? 'CACHE_ERROR', details: details);
}

class UnknownException extends AppException {
  UnknownException(dynamic error)
      : super(
          'Beklenmeyen bir hata oluştu', 
          code: 'UNKNOWN_ERROR', 
          details: error.toString()
        );
} 