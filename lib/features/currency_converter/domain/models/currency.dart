import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency.freezed.dart';
part 'currency.g.dart';

@freezed
class Currency with _$Currency {
  const factory Currency({
    required String code,
    required String name,
  }) = _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) => 
      _$CurrencyFromJson(json);
} 