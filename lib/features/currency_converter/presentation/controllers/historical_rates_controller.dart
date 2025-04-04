import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/error_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/state/ui_state.dart';
import '../../../../core/utils/logger_utils.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../providers/currency_providers.dart';

/// Geçmiş kurlar ekranı için controller
class HistoricalRatesController extends StateNotifier<HistoricalRatesState> {
  final CurrencyRepository _repository;
  final Currency _currency;

  HistoricalRatesController({
    required CurrencyRepository repository,
    required Currency currency,
  })  : _repository = repository,
        _currency = currency,
        super(HistoricalRatesState.initial()) {
    AppLogger.info('HistoricalRatesController başlatıldı: ${currency.code}');
  }

  /// Belirli bir tarih aralığı için kurları yükler
  Future<void> loadRatesForDateRange(DateTime startDate, DateTime endDate) async {
    final formattedStartDate = startDate.toIso8601String().split('T')[0];
    final formattedEndDate = endDate.toIso8601String().split('T')[0];
    
    AppLogger.d('Tarih aralığı için kurlar yükleniyor: $formattedStartDate - $formattedEndDate (${_currency.code})');
    
    state = state.copyWith(
      dateRange: DateRange(startDate: startDate, endDate: endDate),
      rates: const Loading(),
    );

    final result = await _repository.getRatesForDateRange(
      startDate: startDate,
      endDate: endDate,
      base: 'EUR',
      symbols: [_currency.code],
    );

    result.handle(
      onSuccess: (rates) {
        if (rates.isEmpty) {
          AppLogger.warning('Tarih aralığında veri bulunamadı: $formattedStartDate - $formattedEndDate');
          state = state.copyWith(
            rates: Error(AppException(ErrorMessages.noDataForDateRange)),
          );
        } else {
          AppLogger.info('${rates.length} günlük kur verisi yüklendi');
          state = state.copyWith(
            rates: Data(rates),
          );
        }
      },
      onFailure: (error) {
        AppLogger.e('Kur verileri yüklenirken hata oluştu', error);
        state = state.copyWith(
          rates: Error(error),
        );
      },
    );
  }

  /// Başlangıç tarihini günceller
  void updateStartDate(DateTime date) {
    final formattedDate = date.toIso8601String().split('T')[0];
    AppLogger.d('Başlangıç tarihi güncelleniyor: $formattedDate');
    
    final currentRange = state.dateRange;
    
    // Eğer yeni başlangıç tarihi, bitiş tarihinden sonra ise ayarlamalar yap
    if (date.isAfter(currentRange.endDate)) {
      AppLogger.warning('Başlangıç tarihi bitiş tarihinden sonra, tarihler düzenleniyor');
      state = state.copyWith(
        dateRange: DateRange(
          startDate: date,
          endDate: date.add(const Duration(days: 1)),
        ),
      );
    } else {
      state = state.copyWith(
        dateRange: DateRange(
          startDate: date,
          endDate: currentRange.endDate,
        ),
      );
    }
    
    // Yeni tarih aralığına göre verileri yükle
    loadRatesForDateRange(state.dateRange.startDate, state.dateRange.endDate);
  }

  /// Bitiş tarihini günceller
  void updateEndDate(DateTime date) {
    final formattedDate = date.toIso8601String().split('T')[0];
    AppLogger.d('Bitiş tarihi güncelleniyor: $formattedDate');
    
    final currentRange = state.dateRange;
    
    // Eğer yeni bitiş tarihi, başlangıç tarihinden önce ise ayarlamalar yap
    if (date.isBefore(currentRange.startDate)) {
      AppLogger.warning('Bitiş tarihi başlangıç tarihinden önce, tarihler düzenleniyor');
      state = state.copyWith(
        dateRange: DateRange(
          startDate: date.subtract(const Duration(days: 1)),
          endDate: date,
        ),
      );
    } else {
      state = state.copyWith(
        dateRange: DateRange(
          startDate: currentRange.startDate,
          endDate: date,
        ),
      );
    }
    
    // Yeni tarih aralığına göre verileri yükle
    loadRatesForDateRange(state.dateRange.startDate, state.dateRange.endDate);
  }

  /// Verileri yeniler
  void refreshData() {
    AppLogger.d('Veriler yenileniyor');
    loadRatesForDateRange(state.dateRange.startDate, state.dateRange.endDate);
  }
}

/// Geçmiş kurlar ekranı için state sınıfı
class HistoricalRatesState {
  final DateRange dateRange;
  final UIState<List<ExchangeRate>> rates;

  HistoricalRatesState({
    required this.dateRange,
    required this.rates,
  });

  /// Başlangıç durumunu oluşturur
  factory HistoricalRatesState.initial() {
    final now = DateTime.now();
    return HistoricalRatesState(
      dateRange: DateRange(
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
      ),
      rates: const Initial(),
    );
  }

  /// State'in sadece belirli alanlarını güncelleyen yardımcı metot
  HistoricalRatesState copyWith({
    DateRange? dateRange,
    UIState<List<ExchangeRate>>? rates,
  }) {
    return HistoricalRatesState(
      dateRange: dateRange ?? this.dateRange,
      rates: rates ?? this.rates,
    );
  }
}

/// Tarih aralığı sınıfı
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });
}

/// Historical rates controller provider
final historicalRatesControllerProvider = StateNotifierProvider.family<
    HistoricalRatesController, HistoricalRatesState, Currency>(
  (ref, currency) => HistoricalRatesController(
    repository: ref.watch(currencyRepositoryProvider),
    currency: currency,
  ),
); 