class MarketOverview {
  final int? marketCapRank;
  final double? circulatingSupply;
  final double? maxSupply;
  final double? ath;
  final double? atl;
  final double? change7dPercent;
  final double? change30dPercent;
  final String? website;
  final String? twitter;
  final String? github;

  MarketOverview({
    this.marketCapRank,
    this.circulatingSupply,
    this.maxSupply,
    this.ath,
    this.atl,
    this.change7dPercent,
    this.change30dPercent,
    this.website,
    this.twitter,
    this.github,
  });

  factory MarketOverview.fromJson(Map<String, dynamic> json) {
    return MarketOverview(
      marketCapRank: json['marketCapRank'] as int?,
      circulatingSupply: json['circulatingSupply'] is num
          ? (json['circulatingSupply'] as num).toDouble()
          : (json['circulatingSupply'] != null
              ? double.tryParse(json['circulatingSupply'].toString())
              : null),
      maxSupply: json['maxSupply'] is num
          ? (json['maxSupply'] as num).toDouble()
          : (json['maxSupply'] != null
              ? double.tryParse(json['maxSupply'].toString())
              : null),
      ath: json['ath'] is num
          ? (json['ath'] as num).toDouble()
          : (json['ath'] != null
              ? double.tryParse(json['ath'].toString())
              : null),
      atl: json['atl'] is num
          ? (json['atl'] as num).toDouble()
          : (json['atl'] != null
              ? double.tryParse(json['atl'].toString())
              : null),
      change7dPercent: json['change7dPercent'] is num
          ? (json['change7dPercent'] as num).toDouble()
          : (json['change7dPercent'] != null
              ? double.tryParse(json['change7dPercent'].toString())
              : null),
      change30dPercent: json['change30dPercent'] is num
          ? (json['change30dPercent'] as num).toDouble()
          : (json['change30dPercent'] != null
              ? double.tryParse(json['change30dPercent'].toString())
              : null),
      website: json['website'] as String?,
      twitter: json['twitter'] as String?,
      github: json['github'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'marketCapRank': marketCapRank,
        'circulatingSupply': circulatingSupply,
        'maxSupply': maxSupply,
        'ath': ath,
        'atl': atl,
        'change7dPercent': change7dPercent,
        'change30dPercent': change30dPercent,
        'website': website,
        'twitter': twitter,
        'github': github,
      };
}

