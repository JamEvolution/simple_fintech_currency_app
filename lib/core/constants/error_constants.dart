/// Hata kodları
class ErrorCodes {
  // Genel
  static const String unknown = 'UNKNOWN_ERROR';
  
  // Ağ
  static const String network = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  
  // Sunucu
  static const String server = 'SERVER_ERROR';
  static const String badResponse = 'BAD_RESPONSE';
  
  // Veri
  static const String parse = 'PARSE_ERROR';
  static const String cache = 'CACHE_ERROR';
  
  // Doğrulama
  static const String validation = 'VALIDATION_ERROR';
  static const String authentication = 'AUTH_ERROR';
}

/// Hata mesajları
class ErrorMessages {
  // Genel
  static const String unknown = 'Beklenmeyen bir hata oluştu';
  
  // Ağ
  static const String timeout = 'Bağlantı zaman aşımına uğradı';
  static const String noConnection = 'İnternet bağlantısı bulunamadı';
  
  // HTTP durum kodları için
  static const Map<int, String> httpStatus = {
    400: 'Geçersiz istek',
    401: 'Yetkilendirme hatası',
    403: 'Erişim reddedildi',
    404: 'Kaynak bulunamadı',
    500: 'Sunucu hatası',
  };
  
  // Uygulama özel
  static const String sameCurrency = 'Kaynak ve hedef para birimleri aynı olamaz';
  static const String invalidAmount = 'Geçerli bir miktar girin';
  static const String currencyNotSelected = 'Lütfen para birimi seçin';
  static const String currencyNotFound = 'Para birimi bulunamadı';
  static const String rateNotFound = 'Kur bilgisi bulunamadı';
  static const String noDataForDateRange = 'Bu tarih aralığında veri bulunamadı';
  
  // HTTP hatası mesajı
  static String httpError(int statusCode) {
    return httpStatus[statusCode] ?? 'HTTP hatası: $statusCode';
  }
} 