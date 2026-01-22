
part of 'coingecko_currency.dart';


CoinGeckoCurrency _$CoinGeckoCurrencyFromJson(Map<String, dynamic> json) =>
    CoinGeckoCurrency(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      totalVolume: (json['total_volume'] as num?)?.toDouble(),
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CoinGeckoCurrencyToJson(CoinGeckoCurrency instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'image': instance.imageUrl,
      'current_price': instance.currentPrice,
      'market_cap': instance.marketCap,
      'total_volume': instance.totalVolume,
      'price_change_24h': instance.priceChange24h,
      'price_change_percentage_24h': instance.priceChangePercentage24h,
    };

