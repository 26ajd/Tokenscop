import 'package:json_annotation/json_annotation.dart';

part 'coingecko_currency.g.dart';

@JsonSerializable()
class CoinGeckoCurrency {
  final String id;
  final String symbol;
  final String name;

  @JsonKey(name: 'image')
  final String imageUrl;

  @JsonKey(name: 'current_price')
  final double currentPrice;

  @JsonKey(name: 'market_cap')
  final double? marketCap;

  @JsonKey(name: 'total_volume')
  final double? totalVolume;

  @JsonKey(name: 'price_change_24h')
  final double? priceChange24h;

  @JsonKey(name: 'price_change_percentage_24h')
  final double? priceChangePercentage24h;

  CoinGeckoCurrency({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    this.marketCap,
    this.totalVolume,
    this.priceChange24h,
    this.priceChangePercentage24h,
  });

  factory CoinGeckoCurrency.fromJson(Map<String, dynamic> json) =>
      _$CoinGeckoCurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CoinGeckoCurrencyToJson(this);
}

