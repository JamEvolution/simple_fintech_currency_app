import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/result/result.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final ApiClient _apiClient;
  final CacheManager _cacheManager;
  
  // Cache key prefixes
  static const String _currenciesCacheKey = 'currencies';
  static const String _latestRatesCacheKey = 'latest_rates';
  static const String _historicalRatesCacheKey = 'historical_rates';
  static const String _dateRangeCacheKey = 'date_range_rates';
  
  // Default cache durations
  static const Duration _currenciesCacheDuration = Duration(days: 1);
  static const Duration _ratesCacheDuration = Duration(minutes: 30);
  
  CurrencyRepositoryImpl(this._apiClient) : _cacheManager = CacheManager();

  @override
  Future<Result<List<Currency>>> getCurrencies() async {
    try {
      final currencies = await _cacheManager.getOrSet(
        _currenciesCacheKey,
        () => _fetchCurrencies(),
        timeToLive: _currenciesCacheDuration,
      );
      return Result.success(currencies);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownException(e));
    }
  }
  
  Future<List<Currency>> _fetchCurrencies() async {
    try {
      final response = await _apiClient.get(ApiConstants.currencies);
      
      return response.entries.map((entry) {
        return Currency(
          code: entry.key,
          name: entry.value as String,
        );
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Para birimleri ayrıştırılırken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Result<ExchangeRate>> getLatestRates({
    String? base,
    List<String>? symbols,
  }) async {
    final cacheKey = _buildLatestRatesCacheKey(base, symbols);
    
    try {
      final rates = await _cacheManager.getOrSet(
        cacheKey,
        () => _fetchLatestRates(base, symbols),
        timeToLive: _ratesCacheDuration,
      );
      return Result.success(rates);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownException(e));
    }
  }
  
  Future<ExchangeRate> _fetchLatestRates(String? base, List<String>? symbols) async {
    try {
      final queryParams = <String, dynamic>{};
      if (base != null) queryParams[ApiConstants.base] = base;
      if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');

      final response = await _apiClient.get(
        ApiConstants.latest,
        queryParameters: queryParams,
      );

      return ExchangeRate.fromJson(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Güncel kurlar ayrıştırılırken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Result<ExchangeRate>> getHistoricalRates({
    required DateTime date,
    String? base,
    List<String>? symbols,
  }) async {
    final dateStr = _formatDate(date);
    final cacheKey = _buildHistoricalRatesCacheKey(dateStr, base, symbols);
    
    try {
      final rates = await _cacheManager.getOrSet(
        cacheKey,
        () => _fetchHistoricalRates(dateStr, base, symbols),
        timeToLive: _ratesCacheDuration,
      );
      return Result.success(rates);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownException(e));
    }
  }
  
  Future<ExchangeRate> _fetchHistoricalRates(String dateStr, String? base, List<String>? symbols) async {
    try {
      final queryParams = <String, dynamic>{};
      if (base != null) queryParams[ApiConstants.base] = base;
      if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');

      final response = await _apiClient.get(
        '/$dateStr',
        queryParameters: queryParams,
      );

      return ExchangeRate.fromJson(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Geçmiş kurlar ayrıştırılırken hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<ExchangeRate>>> getRatesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? base,
    List<String>? symbols,
  }) async {
    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);
    final cacheKey = _buildDateRangeCacheKey(startDateStr, endDateStr, base, symbols);
    
    try {
      final rates = await _cacheManager.getOrSet(
        cacheKey,
        () => _fetchRatesForDateRange(startDateStr, endDateStr, base, symbols),
        timeToLive: _ratesCacheDuration,
      );
      return Result.success(rates);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownException(e));
    }
  }
  
  Future<List<ExchangeRate>> _fetchRatesForDateRange(
    String startDateStr, 
    String endDateStr, 
    String? base, 
    List<String>? symbols
  ) async {
    try {
      final queryParams = <String, dynamic>{};
      if (base != null) queryParams[ApiConstants.base] = base;
      if (symbols != null) queryParams[ApiConstants.symbols] = symbols.join(',');
      
      final response = await _apiClient.get(
        '/$startDateStr..$endDateStr',
        queryParameters: queryParams,
      );

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
      return rates;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Tarih aralığı kurları ayrıştırılırken hata oluştu: ${e.toString()}');
    }
  }
  
  // Yardımcı metotlar
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _buildLatestRatesCacheKey(String? base, List<String>? symbols) {
    return '$_latestRatesCacheKey-${base ?? 'default'}-${symbols?.join(',') ?? 'all'}';
  }
  
  String _buildHistoricalRatesCacheKey(String date, String? base, List<String>? symbols) {
    return '$_historicalRatesCacheKey-$date-${base ?? 'default'}-${symbols?.join(',') ?? 'all'}';
  }
  
  String _buildDateRangeCacheKey(String startDate, String endDate, String? base, List<String>? symbols) {
    return '$_dateRangeCacheKey-$startDate-$endDate-${base ?? 'default'}-${symbols?.join(',') ?? 'all'}';
  }
  
  // Cache temizleme metotları
  void clearCurrenciesCache() {
    _cacheManager.remove(_currenciesCacheKey);
  }
  
  void clearLatestRatesCache() {
    _cacheManager.clearByPrefix(_latestRatesCacheKey);
  }
  
  void clearHistoricalRatesCache() {
    _cacheManager.clearByPrefix(_historicalRatesCacheKey);
  }
  
  void clearDateRangeCache() {
    _cacheManager.clearByPrefix(_dateRangeCacheKey);
  }
  
  @override
  void clearAllCache() {
    _cacheManager.clear();
  }
} 