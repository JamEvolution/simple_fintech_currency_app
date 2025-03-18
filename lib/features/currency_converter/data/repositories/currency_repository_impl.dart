import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final ApiClient _apiClient;
  final Map<String, List<ExchangeRate>> _cache = {};

  CurrencyRepositoryImpl(this._apiClient);

  @override
  Future<List<Currency>> getCurrencies() async {
    final response = await _apiClient.get(ApiConstants.currencies);
    return (response).entries.map((entry) {
      return Currency(
        code: entry.key,
        name: entry.value as String,
      );
    }).toList();
  }

  @override
  Future<ExchangeRate> getLatestRates({
    String? base,
    List<String>? symbols,
  }) async {
    final queryParams = <String, dynamic>{};
    if (base != null) queryParams[ApiConstants.base] = base;
    if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');

    final response = await _apiClient.get(
      ApiConstants.latest,
      queryParameters: queryParams,
    );

    return ExchangeRate.fromJson(response);
  }

  @override
  Future<ExchangeRate> getHistoricalRates({
    required DateTime date,
    String? base,
    List<String>? symbols,
  }) async {
    final queryParams = <String, dynamic>{};
    if (base != null) queryParams[ApiConstants.base] = base;
    if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');

    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _apiClient.get(
      '/$dateStr',
      queryParameters: queryParams,
    );

    return ExchangeRate.fromJson(response);
  }

  @override
  Future<List<ExchangeRate>> getRatesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? base,
    List<String>? symbols,
  }) async {
    final queryParams = <String, dynamic>{};
    if (base != null) queryParams[ApiConstants.base] = base;
    if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');

    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    // Cache key oluştur
    final cacheKey = '$startDateStr-$endDateStr-${base ?? 'EUR'}-${symbols?.join(',')}';
    
    // Cache'den kontrol et
    if (_cache.containsKey(cacheKey)) {
      print('Cache hit: $cacheKey');
      return _cache[cacheKey]!;
    }
    
    print('API İsteği: /$startDateStr..$endDateStr');
    print('Query Params: $queryParams');
    
    final response = await _apiClient.get(
      '/$startDateStr..$endDateStr',
      queryParameters: queryParams,
    );

    print('API Yanıtı: $response');

    final ratesMap = response['rates'] as Map<String, dynamic>;
    final rates = ratesMap.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final rateValues = entry.value as Map<String, dynamic>;
      return ExchangeRate(
        base: base ?? 'EUR',
        date: date,
        rates: rateValues.map((key, value) => MapEntry(key, value as double)),
      );
    }).toList();

    // Tarihe göre sırala
    rates.sort((a, b) => a.date.compareTo(b.date));

    // Cache'e kaydet
    _cache[cacheKey] = rates;

    print('İşlenmiş Veri Sayısı: ${rates.length}');
    return rates;
  }
} 