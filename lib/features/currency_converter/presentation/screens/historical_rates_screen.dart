import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_providers.dart';
import '../../../../core/errors/app_exceptions.dart';
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
  late DateTime _startDate;
  late DateTime _endDate;
  List<ExchangeRate>? _rates;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final provider = ratesForDateRangeProvider((
        startDate: _startDate,
        endDate: _endDate,
        base: 'EUR',
        symbols: [widget.currency.code],
      ));
      
      final result = await ref.read(provider.future);
      
      setState(() {
        _rates = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is AppException) {
          _errorMessage = formatErrorMessage(e);
        } else {
          _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
        }
      });
      _showError(_errorMessage!);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarih aralığı seçici
          DateRangeSelector(
            startDate: _startDate,
            endDate: _endDate,
            isLoading: _isLoading,
            onStartDateChanged: (date) {
              setState(() => _startDate = date);
              _loadData();
            },
            onEndDateChanged: (date) {
              setState(() => _endDate = date);
              _loadData();
            },
          ),
          // İçerik bölümü
          Expanded(
            child: _isLoading || _rates == null || _rates!.isEmpty
                ? EmptyOrLoadingState(
                    isLoading: _isLoading,
                    isEmpty: _rates == null ? false : _rates!.isEmpty,
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    if (_rates == null || _rates!.isEmpty) return const SizedBox.shrink();
    
    final firstRate = _rates!.first.rates[widget.currency.code] ?? 0;
    final lastRate = _rates!.last.rates[widget.currency.code] ?? 0;
    
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
                '${_rates!.length} gün',
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
              rates: _rates!,
              currencyCode: widget.currency.code,
            ),
          ),
        ],
      ),
    );
  }
} 