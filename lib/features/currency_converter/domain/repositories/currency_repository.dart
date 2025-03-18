import '../models/currency.dart';
import '../models/exchange_rate.dart';

abstract class CurrencyRepository {
  Future<List<Currency>> getCurrencies();
  Future<ExchangeRate> getLatestRates({
    String? base,
    List<String>? symbols,
  });
  Future<ExchangeRate> getHistoricalRates({
    required DateTime date,
    String? base,
    List<String>? symbols,
  });
  Future<List<ExchangeRate>> getRatesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? base,
    List<String>? symbols,
  });
} 