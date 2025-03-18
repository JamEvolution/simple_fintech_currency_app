import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/error_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/state/ui_state.dart';
import '../../../../core/utils/logger_utils.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../providers/currency_providers.dart';

/// Para birimi dönüştürücüsü için controller
class CurrencyConverterController
    extends StateNotifier<CurrencyConverterState> {
  final CurrencyRepository _repository;

  /// Controller oluşturur
  CurrencyConverterController({
    required CurrencyRepository repository,
  })  : _repository = repository,
        super(CurrencyConverterState.initial()) {
    AppLogger.info('CurrencyConverterController başlatıldı');
  }

  /// Tüm para birimlerini yükler
  Future<void> loadCurrencies() async {
    AppLogger.d('Para birimleri yükleniyor');
    state = state.copyWith(currencies: const Loading());

    final result = await _repository.getCurrencies();

    result.handle(
      onSuccess: (currencies) {
        AppLogger.d('${currencies.length} para birimi başarıyla yüklendi');
        state = state.copyWith(currencies: Data(currencies));
      },
      onFailure: (error) {
        AppLogger.e('Para birimleri yüklenirken hata oluştu', error);
        state = state.copyWith(currencies: Error(error));
      },
    );
  }

  /// Döviz kurlarını yükler
  Future<void> convertCurrency({
    required String sourceCurrency,
    required String targetCurrency,
    required double amount,
  }) async {
    AppLogger.d('Döviz dönüştürme: $amount $sourceCurrency -> $targetCurrency');
    state = state.copyWith(
      conversionResult: const Loading(),
    );

    // Aynı para birimi kontrolü
    if (sourceCurrency == targetCurrency) {
      final error = AppException(ErrorMessages.sameCurrency);
      AppLogger.warning('Dönüşüm hatası: Aynı para birimi seçildi');
      state = state.copyWith(
        conversionResult: Error(error),
      );
      return;
    }

    final result = await _repository.getLatestRates(
      base: sourceCurrency,
      symbols: [targetCurrency],
    );

    result.handle(
      onSuccess: (rate) {
        final targetRate = rate.rates[targetCurrency];
        if (targetRate == null) {
          AppLogger.warning('Dönüşüm hatası: Hedef kur bulunamadı - $targetCurrency');
          state = state.copyWith(
            conversionResult: Error(
              AppException(ErrorMessages.rateNotFound),
            ),
          );
        } else {
          final convertedAmount = amount * targetRate;
          AppLogger.info('Dönüşüm başarılı: $amount $sourceCurrency = $convertedAmount $targetCurrency (Kur: $targetRate)');
          state = state.copyWith(
            conversionResult: Data(
              ConversionResult(
                amount: amount,
                convertedAmount: convertedAmount,
                rate: targetRate,
                sourceCurrency: sourceCurrency,
                targetCurrency: targetCurrency,
              ),
            ),
          );
        }
      },
      onFailure: (error) {
        AppLogger.e('Dönüşüm işlemi sırasında hata', error);
        state = state.copyWith(
          conversionResult: Error(error),
        );
      },
    );
  }

  void resetConversion() {
    AppLogger.d('Dönüşüm sonucu sıfırlanıyor');
    state = state.copyWith(
      conversionResult: const Initial(),
    );
  }
}

/// Para birimi dönüştürücü ekranı için state sınıfı
class CurrencyConverterState {
  final UIState<List<Currency>> currencies;
  final UIState<ConversionResult> conversionResult;

  CurrencyConverterState({
    required this.currencies,
    required this.conversionResult,
  });

  /// Başlangıç durumunu oluşturur
  factory CurrencyConverterState.initial() => CurrencyConverterState(
        currencies: const Initial(),
        conversionResult: const Initial(),
      );

  /// State'in sadece belirli alanlarını güncelleyen yardımcı metot
  CurrencyConverterState copyWith({
    UIState<List<Currency>>? currencies,
    UIState<ConversionResult>? conversionResult,
  }) {
    return CurrencyConverterState(
      currencies: currencies ?? this.currencies,
      conversionResult: conversionResult ?? this.conversionResult,
    );
  }
}

/// Dönüştürme sonucunu içeren sınıf
class ConversionResult {
  final double amount;
  final double convertedAmount;
  final double rate;
  final String sourceCurrency;
  final String targetCurrency;

  ConversionResult({
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.sourceCurrency,
    required this.targetCurrency,
  });
}

/// Currency converter controller provider
final currencyConverterControllerProvider =
    StateNotifierProvider<CurrencyConverterController, CurrencyConverterState>(
  (ref) => CurrencyConverterController(
    repository: ref.watch(currencyRepositoryProvider),
  ),
);
