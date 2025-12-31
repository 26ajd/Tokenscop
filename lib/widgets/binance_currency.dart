import 'package:json_annotation/json_annotation.dart';

part '../models/binance_currency.g.dart';

@JsonSerializable()
class BinanceCurrency {
  final String symbol;

  final String price;

  BinanceCurrency({
    required this.symbol,
    required this.price,
  });

  factory BinanceCurrency.fromJson(Map<String, dynamic> json) =>
      _$BinanceCurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$BinanceCurrencyToJson(this);
}

