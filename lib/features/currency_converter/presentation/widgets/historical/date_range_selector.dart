import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'date_picker_button.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool isLoading;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.isLoading,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarih Aralığı',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DatePickerButton(
                  label: 'Başlangıç',
                  date: startDate,
                  onPressed: isLoading
                      ? null
                      : () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: endDate,
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: theme.colorScheme.primary,
                                    onPrimary: theme.colorScheme.onPrimary,
                                    surface: theme.colorScheme.surface,
                                    onSurface: theme.colorScheme.onSurface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            onStartDateChanged(date);
                          }
                        },
                  dateFormat: dateFormat,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DatePickerButton(
                  label: 'Bitiş',
                  date: endDate,
                  onPressed: isLoading
                      ? null
                      : () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: theme.colorScheme.primary,
                                    onPrimary: theme.colorScheme.onPrimary,
                                    surface: theme.colorScheme.surface,
                                    onSurface: theme.colorScheme.onSurface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            onEndDateChanged(date);
                          }
                        },
                  dateFormat: dateFormat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 