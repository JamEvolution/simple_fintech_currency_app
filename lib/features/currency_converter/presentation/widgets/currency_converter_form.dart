import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_providers.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/models/currency.dart';
import 'converter/amount_input.dart';
import 'converter/currency_dropdown.dart';
import 'converter/result_display.dart';
import 'converter/loading_or_error.dart';

class CurrencyConverterForm extends ConsumerStatefulWidget {
  const CurrencyConverterForm({super.key});

  @override
  ConsumerState<CurrencyConverterForm> createState() => _CurrencyConverterFormState();
}

class _CurrencyConverterFormState extends ConsumerState<CurrencyConverterForm> {
  final _amountController = TextEditingController();
  String? _sourceCurrency;
  String? _targetCurrency;
  double? _result;
  bool _isConverting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      _showError('Lütfen geçerli bir miktar girin');
      return;
    }

    if (_sourceCurrency == null || _targetCurrency == null) {
      _showError('Lütfen kaynak ve hedef para birimlerini seçin');
      return;
    }

    if (_sourceCurrency == _targetCurrency) {
      _showError('Kaynak ve hedef para birimleri aynı olamaz');
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      final rates = await ref.read(latestRatesProvider((
        base: _sourceCurrency!,
        symbols: [_targetCurrency!],
      )).future);

      final rate = rates.rates[_targetCurrency];
      if (rate == null) {
        _showError('Döviz kuru bulunamadı');
        return;
      }

      setState(() {
        _result = amount * rate;
        _isConverting = false;
      });
    } catch (e) {
      setState(() {
        _isConverting = false;
      });
      
      if (e is AppException) {
        _showError(formatErrorMessage(e));
      } else {
        _showError('Döviz çevirme işlemi başarısız oldu: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _swapCurrencies() {
    if (_sourceCurrency == null || _targetCurrency == null) {
      _showError('Lütfen kaynak ve hedef para birimlerini seçin');
      return;
    }

    if (_sourceCurrency == _targetCurrency) {
      _showError('Kaynak ve hedef para birimleri aynı olamaz');
      return;
    }
    
    setState(() {
      final temp = _sourceCurrency;
      _sourceCurrency = _targetCurrency;
      _targetCurrency = temp;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currenciesAsync = ref.watch(currenciesProvider);

    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Miktar girişi
              AmountInput(controller: _amountController),
              const SizedBox(height: 16),
              
              // Para birimi seçimi
              currenciesAsync.when(
                data: (currencies) => _buildCurrencySelectors(currencies),
                loading: () => const LoadingOrError(isLoading: true),
                error: (error, stack) {
                  String errorMessage = 'Veri yüklenirken bir hata oluştu';
                  if (error is AppException) {
                    errorMessage = formatErrorMessage(error);
                  } else {
                    errorMessage = 'Hata: ${error.toString()}';
                  }
                  return LoadingOrError(
                    isLoading: false,
                    errorMessage: errorMessage,
                  );
                },
              ),
              
              // Dönüştür butonu
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isConverting ? null : _convertCurrency,
                icon: _isConverting 
                  ? const SizedBox(
                      width: 16, 
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )
                    ) 
                  : const Icon(Icons.swap_horiz),
                label: Text(_isConverting ? 'Dönüştürülüyor...' : 'Dönüştür'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              // Sonuç gösterimi
              if (_result != null) ...[
                const SizedBox(height: 24),
                ResultDisplay(
                  result: _result!,
                  amount: _amountController.text,
                  sourceCurrency: _sourceCurrency!,
                  targetCurrency: _targetCurrency!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrencySelectors(List<Currency> currencies) {
    return Column(
      children: [
        CurrencyDropdown(
          currencies: currencies,
          value: _sourceCurrency,
          labelText: 'Kaynak Para Birimi',
          onChanged: (value) {
            setState(() {
              _sourceCurrency = value;
              _result = null;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CurrencyDropdown(
                currencies: currencies,
                value: _targetCurrency,
                labelText: 'Hedef Para Birimi',
                onChanged: (value) {
                  setState(() {
                    _targetCurrency = value;
                    _result = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.swap_vert),
              tooltip: 'Para birimlerini değiştir',
              onPressed: _swapCurrencies,
            ),
          ],
        ),
      ],
    );
  }
} 