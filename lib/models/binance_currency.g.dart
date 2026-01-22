
part of '../widgets/binance_currency.dart';


BinanceCurrency _$BinanceCurrencyFromJson(Map<String, dynamic> json) =>
    BinanceCurrency(
      symbol: json['symbol'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$BinanceCurrencyToJson(BinanceCurrency instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
    };

