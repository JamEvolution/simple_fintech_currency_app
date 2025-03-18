import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/currency_providers.dart';
import 'package:flutter/services.dart';

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
      });
    } catch (e) {
      _showError('Döviz çevirme işlemi başarısız oldu');
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
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Miktar',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              currenciesAsync.when(
                data: (currencies) => Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _sourceCurrency,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kaynak Para Birimi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency.code,
                          child: Text(
                            '${currency.code} - ${currency.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _sourceCurrency = value;
                          _result = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _targetCurrency,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Hedef Para Birimi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency.code,
                          child: Text(
                            '${currency.code} - ${currency.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _targetCurrency = value;
                          _result = null;
                        });
                      },
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Hata: $error',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _convertCurrency,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Dönüştür'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sonuç',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_amountController.text} $_sourceCurrency = ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${_result!.toStringAsFixed(2)} $_targetCurrency',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 