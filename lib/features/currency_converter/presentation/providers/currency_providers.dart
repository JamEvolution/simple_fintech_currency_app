import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
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
  return repository.getCurrencies();
});

final latestRatesProvider = FutureProvider.family<ExchangeRate,
    ({String? base, List<String>? symbols})>((ref, params) async {
  final repository = ref.watch(currencyRepositoryProvider);
  return repository.getLatestRates(
    base: params.base,
    symbols: params.symbols,
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
  return repository.getHistoricalRates(
    date: params.date,
    base: params.base,
    symbols: params.symbols,
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
  print('Provider çağrıldı: ${params.startDate} - ${params.endDate}');
  print('Base: ${params.base}, Symbols: ${params.symbols}');

  final repository = ref.watch(currencyRepositoryProvider);
  final rates = await repository.getRatesForDateRange(
    startDate: params.startDate,
    endDate: params.endDate,
    base: params.base,
    symbols: params.symbols,
  );

  print('Provider sonucu: ${rates.length} adet veri');
  return rates;
});
