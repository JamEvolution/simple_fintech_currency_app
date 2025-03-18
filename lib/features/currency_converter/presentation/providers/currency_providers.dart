import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../data/repositories/currency_repository_impl.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CurrencyRepositoryImpl(apiClient);
});

final currenciesProvider = FutureProvider<List<Currency>>((ref) async {
  final repository = ref.watch(currencyRepositoryProvider);
  final result = await repository.getCurrencies();
  
  return result.handle(
    onSuccess: (data) => data,
    onFailure: (error) => throw error,
  );
});

final latestRatesProvider = FutureProvider.family<ExchangeRate,
    ({String? base, List<String>? symbols})>((ref, params) async {
  final repository = ref.watch(currencyRepositoryProvider);
  final result = await repository.getLatestRates(
    base: params.base,
    symbols: params.symbols,
  );
  
  return result.handle(
    onSuccess: (data) => data,
    onFailure: (error) => throw error,
  );
});

final historicalRatesProvider = FutureProvider.family<
    ExchangeRate,
    ({
      DateTime date,
      String? base,
      List<String>? symbols
    })>((ref, params) async {
  final repository = ref.watch(currencyRepositoryProvider);
  final result = await repository.getHistoricalRates(
    date: params.date,
    base: params.base,
    symbols: params.symbols,
  );
  
  return result.handle(
    onSuccess: (data) => data,
    onFailure: (error) => throw error,
  );
});

final ratesForDateRangeProvider = FutureProvider.family<
    List<ExchangeRate>,
    ({
      DateTime startDate,
      DateTime endDate,
      String? base,
      List<String>? symbols,
    })>((ref, params) async {
  final repository = ref.watch(currencyRepositoryProvider);
  final result = await repository.getRatesForDateRange(
    startDate: params.startDate,
    endDate: params.endDate,
    base: params.base,
    symbols: params.symbols,
  );
  
  return result.handle(
    onSuccess: (data) => data,
    onFailure: (error) => throw error,
  );
});

String formatErrorMessage(AppException error) {
  if (error is NetworkException) {
    return 'Ağ hatası: ${error.message}';
  } else if (error is ServerException) {
    return 'Sunucu hatası: ${error.message} (${error.statusCode})';
  } else if (error is ParseException) {
    return 'Veri ayrıştırma hatası: ${error.message}';
  } else if (error is CacheException) {
    return 'Önbellek hatası: ${error.message}';
  } else {
    return 'Beklenmeyen bir hata oluştu: ${error.message}';
  }
}
