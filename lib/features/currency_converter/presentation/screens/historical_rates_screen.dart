import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/historical_rates_controller.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/error_formatters.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/exchange_rate.dart';
import '../widgets/historical/date_range_selector.dart';
import '../widgets/historical/rate_summary_card.dart';
import '../widgets/historical/historical_chart.dart';
import '../widgets/historical/empty_or_loading_state.dart';

class HistoricalRatesScreen extends ConsumerStatefulWidget {
  final Currency currency;

  const HistoricalRatesScreen({
    super.key,
    required this.currency,
  });

  @override
  ConsumerState<HistoricalRatesScreen> createState() => _HistoricalRatesScreenState();
}

class _HistoricalRatesScreenState extends ConsumerState<HistoricalRatesScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Verileri yükleme işlemini initState sonrası bir sonraki frame'e planlıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final controller = ref.read(historicalRatesControllerProvider(widget.currency).notifier);
        final state = ref.read(historicalRatesControllerProvider(widget.currency));
        controller.loadRatesForDateRange(
          state.dateRange.startDate, 
          state.dateRange.endDate
        );
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(historicalRatesControllerProvider(widget.currency).notifier);
    final state = ref.watch(historicalRatesControllerProvider(widget.currency));

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.currency.code),
            const SizedBox(width: 8),
            Text(
              '- ${widget.currency.name}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.rates.isLoading ? null : controller.refreshData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarih aralığı seçici
          DateRangeSelector(
            startDate: state.dateRange.startDate,
            endDate: state.dateRange.endDate,
            isLoading: state.rates.isLoading,
            onStartDateChanged: controller.updateStartDate,
            onEndDateChanged: controller.updateEndDate,
          ),
          // İçerik bölümü
          Expanded(
            child: state.rates.when(
              initial: () => const EmptyOrLoadingState(
                isLoading: true,
                isEmpty: false,
              ),
              loading: () => const EmptyOrLoadingState(
                isLoading: true,
                isEmpty: false,
              ),
              data: (rates) => _buildContent(context, rates),
              error: (error) {
                showErrorSnackBar(context, error);
                return const EmptyOrLoadingState(
                  isLoading: false,
                  isEmpty: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ExchangeRate> rates) {
    if (rates.isEmpty) {
      return const EmptyOrLoadingState(
        isLoading: false,
        isEmpty: true,
      );
    }
    
    final theme = Theme.of(context);
    final firstRate = rates.first.rates[widget.currency.code] ?? 0;
    final lastRate = rates.last.rates[widget.currency.code] ?? 0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kur Değişimi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${rates.length} gün',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Kur değişim özeti
          RateSummaryCard(
            firstRate: firstRate,
            lastRate: lastRate,
            currencyCode: widget.currency.code,
          ),
          const SizedBox(height: 16),
          // Grafik
          Expanded(
            child: HistoricalChart(
              rates: rates,
              currencyCode: widget.currency.code,
            ),
          ),
        ],
      ),
    );
  }
} 