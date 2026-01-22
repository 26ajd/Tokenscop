import 'package:json_annotation/json_annotation.dart';
import 'market_overview.dart';

part 'currency_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CurrencyModel {
  final String id;

  final String? coingeckoId;

  final String? binanceSymbol;

  final String name;
  final String symbol;

  final double? currentPrice;

  final double? marketCap;
  final double? volume;

  final String? iconUrl;

  final String? logoUrl;

  final String? description;

  final String? homepage;

  final int? marketCapRank;

  final double? ath;
  final double? atl;

  final double? circulatingSupply;

  final MarketOverview? marketOverview;

  final double? priceChange24h;
  final double? priceChangePercentage24h;

  final Map<String, List<List<num>>>? chartData;

  CurrencyModel({
    required this.id,
    this.coingeckoId,
    this.binanceSymbol,
    required this.name,
    required this.symbol,
    this.currentPrice,
    this.marketCap,
    this.volume,
    this.iconUrl,
    this.logoUrl,
    this.description,
    this.homepage,
    this.marketCapRank,
    this.ath,
    this.atl,
    this.circulatingSupply,
    this.marketOverview,
    this.priceChange24h,
    this.priceChangePercentage24h,
    this.chartData,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyModelFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyModelToJson(this);

  CurrencyModel copyWith({
    double? currentPrice,
    double? marketCap,
    double? volume,
    String? iconUrl,
    String? logoUrl,
    String? description,
    String? homepage,
    int? marketCapRank,
    double? ath,
    double? atl,
    double? circulatingSupply,
    MarketOverview? marketOverview,
    double? priceChange24h,
    double? priceChangePercentage24h,
    Map<String, List<List<num>>>? chartData,
  }) {
    return CurrencyModel(
      id: id,
      coingeckoId: coingeckoId,
      binanceSymbol: binanceSymbol,
      name: name,
      symbol: symbol,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap: marketCap ?? this.marketCap,
      volume: volume ?? this.volume,
      iconUrl: iconUrl ?? this.iconUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      homepage: homepage ?? this.homepage,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      ath: ath ?? this.ath,
      atl: atl ?? this.atl,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      marketOverview: marketOverview ?? this.marketOverview,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      chartData: chartData ?? this.chartData,
    );
  }
}

