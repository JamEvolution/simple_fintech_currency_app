import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/currency_converter_controller.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/state/ui_state.dart';
import '../../../../core/utils/error_formatters.dart';
import '../../../../core/constants/error_constants.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Kurları yükleme işlemini initState sonrası bir sonraki frame'e planlıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        ref.read(currencyConverterControllerProvider.notifier).loadCurrencies();
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) {
      showMessageSnackBar(context, ErrorMessages.invalidAmount, isError: true);
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      showMessageSnackBar(context, ErrorMessages.invalidAmount, isError: true);
      return;
    }
    
    if (_sourceCurrency == null) {
      showMessageSnackBar(context, ErrorMessages.currencyNotSelected, isError: true);
      return;
    }
    
    if (_targetCurrency == null) {
      showMessageSnackBar(context, ErrorMessages.currencyNotSelected, isError: true);
      return;
    }
    
    // Controller'ı çağır
    ref.read(currencyConverterControllerProvider.notifier).convertCurrency(
      amount: amount,
      sourceCurrency: _sourceCurrency!,
      targetCurrency: _targetCurrency!,
    );
  }

  void _swapCurrencies() {
    if (_sourceCurrency != null && _targetCurrency != null) {
      setState(() {
        final temp = _sourceCurrency;
        _sourceCurrency = _targetCurrency;
        _targetCurrency = temp;
      });
    }
    
    // Swap sonrası sonucu sıfırla
    ref.read(currencyConverterControllerProvider.notifier).resetConversion();
  }

  @override
  Widget build(BuildContext context) {
    // Controller'dan state'i oku
    final state = ref.watch(currencyConverterControllerProvider);

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
              state.currencies.when(
                initial: () => const LoadingOrError(isLoading: true),
                loading: () => const LoadingOrError(isLoading: true),
                data: (currencies) => _buildCurrencySelectors(currencies),
                error: (error) => LoadingOrError(
                  isLoading: false,
                  errorMessage: formatErrorMessage(error),
                ),
              ),
              
              // Dönüştür butonu
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: state.conversionResult.isLoading ? null : _convertCurrency,
                icon: state.conversionResult.isLoading
                  ? const SizedBox(
                      width: 16, 
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )
                    ) 
                  : const Icon(Icons.swap_horiz),
                label: Text(state.conversionResult.isLoading ? 'Dönüştürülüyor...' : 'Dönüştür'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              // Sonuç gösterimi
              if (state.conversionResult.hasData) ...[
                const SizedBox(height: 24),
                ResultDisplay(
                  result: state.conversionResult.dataOrNull!.convertedAmount,
                  amount: state.conversionResult.dataOrNull!.amount.toString(),
                  sourceCurrency: state.conversionResult.dataOrNull!.sourceCurrency,
                  targetCurrency: state.conversionResult.dataOrNull!.targetCurrency,
                ),
              ],
              
              // Hata mesajı gösterimi
              if (state.conversionResult.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  formatErrorMessage(state.conversionResult.errorOrNull!),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
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
            });
            ref.read(currencyConverterControllerProvider.notifier).resetConversion();
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
                  });
                  ref.read(currencyConverterControllerProvider.notifier).resetConversion();
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