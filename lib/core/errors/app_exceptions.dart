class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Ağ hatalarına özgü exception sınıfı
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details}) 
      : super(message, code: code ?? 'NETWORK_ERROR', details: details);
}

/// Bağlantı zaman aşımı hataları
class ConnectionTimeoutException extends NetworkException {
  ConnectionTimeoutException({String? details})
      : super('Bağlantı zaman aşımına uğradı', code: 'TIMEOUT', details: details);
}

/// Sunucu hatalarına özgü exception sınıfı
class ServerException extends NetworkException {
  final int? statusCode;
  
  ServerException(String message, {this.statusCode, String? code, dynamic details})
      : super(message, code: code ?? 'SERVER_ERROR', details: details);
  
  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ', Status: $statusCode' : ''}';
}

/// Kötü sunucu yanıtı hataları
class BadResponseException extends ServerException {
  static final Map<int, String> _statusMessages = {
    400: 'Geçersiz istek',
    401: 'Yetkilendirme hatası',
    403: 'Erişim reddedildi',
    404: 'Kaynak bulunamadı',
    500: 'Sunucu hatası',
  };

  BadResponseException(int statusCode, {String? message, dynamic details})
      : super(
          message ?? _getMessageForStatus(statusCode),
          statusCode: statusCode,
          code: 'BAD_RESPONSE',
          details: details
        );
  
  static String _getMessageForStatus(int statusCode) {
    return _statusMessages[statusCode] ?? 'HTTP hatası: $statusCode';
  }
}

/// Veri ayrıştırma hataları
class ParseException extends AppException {
  ParseException(String message, {String? code, dynamic details})
      : super(message, code: code ?? 'PARSE_ERROR', details: details);
}

/// Önbellek hataları
class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic details})
      : super(message, code: code ?? 'CACHE_ERROR', details: details);
}

/// Bilinmeyen hatalar
class UnknownException extends AppException {
  UnknownException(dynamic error)
      : super(
          'Beklenmeyen bir hata oluştu', 
          code: 'UNKNOWN_ERROR', 
          details: error.toString()
        );
} 