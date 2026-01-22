
part of 'currency_model.dart';


CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      id: json['id'] as String,
      coingeckoId: json['coingeckoId'] as String?,
      binanceSymbol: json['binanceSymbol'] as String?,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      currentPrice: (json['currentPrice'] as num?)?.toDouble(),
      marketCap: (json['marketCap'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
      iconUrl: json['iconUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      homepage: json['homepage'] as String?,
      marketCapRank: (json['marketCapRank'] as num?)?.toInt(),
      ath: (json['ath'] as num?)?.toDouble(),
      atl: (json['atl'] as num?)?.toDouble(),
      circulatingSupply: (json['circulatingSupply'] as num?)?.toDouble(),
      marketOverview: json['marketOverview'] == null
          ? null
          : MarketOverview.fromJson(
              json['marketOverview'] as Map<String, dynamic>),
      priceChange24h: (json['priceChange24h'] as num?)?.toDouble(),
      priceChangePercentage24h:
          (json['priceChangePercentage24h'] as num?)?.toDouble(),
      chartData: (json['chartData'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => (e as List<dynamic>).map((e) => e as num).toList())
                .toList()),
      ),
    );

Map<String, dynamic> _$CurrencyModelToJson(CurrencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coingeckoId': instance.coingeckoId,
      'binanceSymbol': instance.binanceSymbol,
      'name': instance.name,
      'symbol': instance.symbol,
      'currentPrice': instance.currentPrice,
      'marketCap': instance.marketCap,
      'volume': instance.volume,
      'iconUrl': instance.iconUrl,
      'logoUrl': instance.logoUrl,
      'description': instance.description,
      'homepage': instance.homepage,
      'marketCapRank': instance.marketCapRank,
      'ath': instance.ath,
      'atl': instance.atl,
      'circulatingSupply': instance.circulatingSupply,
      'marketOverview': instance.marketOverview?.toJson(),
      'priceChange24h': instance.priceChange24h,
      'priceChangePercentage24h': instance.priceChangePercentage24h,
      'chartData': instance.chartData,
    };

