import '../../../../core/result/result.dart';
import '../models/currency.dart';
import '../models/exchange_rate.dart';

abstract class CurrencyRepository {
  /// Tüm para birimlerini getirir
  Future<Result<List<Currency>>> getCurrencies();
  
  /// Güncel döviz kurlarını getirir
  Future<Result<ExchangeRate>> getLatestRates({
    String? base,
    List<String>? symbols,
  });
  
  /// Belirli bir tarihe ait döviz kurlarını getirir
  Future<Result<ExchangeRate>> getHistoricalRates({
    required DateTime date,
    String? base,
    List<String>? symbols,
  });
  
  /// Belirli bir tarih aralığındaki döviz kurlarını getirir
  Future<Result<List<ExchangeRate>>> getRatesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? base,
    List<String>? symbols,
  });
  
  /// Önbellek yönetimi için metodlar
  void clearAllCache();
} 