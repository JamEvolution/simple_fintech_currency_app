import 'package:flutter/material.dart';
import '../../../domain/models/currency.dart';

class CurrencyDropdown extends StatelessWidget {
  final List<Currency> currencies;
  final String? value;
  final String labelText;
  final Function(String?) onChanged;

  const CurrencyDropdown({
    super.key,
    required this.currencies,
    required this.value,
    required this.labelText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.currency_exchange),
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
      onChanged: onChanged,
    );
  }
} 