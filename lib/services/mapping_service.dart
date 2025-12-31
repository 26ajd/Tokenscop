class MappingService {
  static final Map<String, Map<String, String>> mapping = {
    'BTC': {
      'coingecko': 'bitcoin',
      'binance': 'BTCUSDT',
      'name': 'Bitcoin',
      'logo': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png'
    },
    'ETH': {
      'coingecko': 'ethereum',
      'binance': 'ETHUSDT',
      'name': 'Ethereum',
      'logo': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png'
    },
    'BNB': {
      'coingecko': 'binancecoin',
      'binance': 'BNBUSDT',
      'name': 'BNB',
      'logo':
          'https://assets.coingecko.com/coins/images/825/large/binance-coin-logo.png'
    },
    'ADA': {
      'coingecko': 'cardano',
      'binance': 'ADAUSDT',
      'name': 'Cardano',
      'logo': 'https://assets.coingecko.com/coins/images/975/large/cardano.png'
    },
    'XRP': {
      'coingecko': 'ripple',
      'binance': 'XRPUSDT',
      'name': 'XRP',
      'logo':
          'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png'
    },
    'SOL': {
      'coingecko': 'solana',
      'binance': 'SOLUSDT',
      'name': 'Solana',
      'logo': 'https://assets.coingecko.com/coins/images/4128/large/solana.png'
    },
    'DOT': {
      'coingecko': 'polkadot',
      'binance': 'DOTUSDT',
      'name': 'Polkadot',
      'logo':
          'https://assets.coingecko.com/coins/images/12171/large/polkadot.png'
    },
    'DOGE': {
      'coingecko': 'dogecoin',
      'binance': 'DOGEUSDT',
      'name': 'Dogecoin',
      'logo': 'https://assets.coingecko.com/coins/images/5/large/dogecoin.png'
    },
    'LTC': {
      'coingecko': 'litecoin',
      'binance': 'LTCUSDT',
      'name': 'Litecoin',
      'logo': 'https://assets.coingecko.com/coins/images/2/large/litecoin.png'
    },
  };

  static List<String> get unifiedSymbols => mapping.keys.toList();

  static String? coingeckoIdFor(String unified) =>
      mapping[unified]?['coingecko'];

  static String? binancePairFor(String unified) => mapping[unified]?['binance'];

  static String? nameFor(String unified) => mapping[unified]?['name'];

  static String? logoFor(String unified) => mapping[unified]?['logo'];
}

