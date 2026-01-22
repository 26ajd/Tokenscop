// ============================================
// ملف: mapping_service.dart
// الوصف: خدمة ربط العملات الموحدة بمعرفات CoinGecko وأزواج Binance
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'image_service.dart';

// ----------------------------
// 2. الثوابت والإعدادات
// ----------------------------

// ----------------------------
// 3. النماذج والفئات
// ----------------------------

// ----------------------------
// 4. المتحكمات وإدارة الحالة
// ----------------------------

// ----------------------------
// 5. الخدمات و API
// ----------------------------

/// خدمة تعيين البيانات (Mapping Service)
/// تساعد في تحويل الرموز الموحدة إلى معرفات خاصة بكل منصة (CoinGecko/Binance)
class MappingService {
  /// خريطة البيانات للعملات المدعومة
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
      'logo': 'https://assets.coingecko.com/coins/images/825/large/binance-coin-logo.png'
    },
    'SOL': {
      'coingecko': 'solana',
      'binance': 'SOLUSDT',
      'name': 'Solana',
      'logo': 'https://assets.coingecko.com/coins/images/4128/large/solana.png'
    },
    'XRP': {
      'coingecko': 'ripple',
      'binance': 'XRPUSDT',
      'name': 'XRP',
      'logo': 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png'
    },
    'ADA': {
      'coingecko': 'cardano',
      'binance': 'ADAUSDT',
      'name': 'Cardano',
      'logo': 'https://assets.coingecko.com/coins/images/975/large/cardano.png'
    },
    'AVAX': {
      'coingecko': 'avalanche-2',
      'binance': 'AVAXUSDT',
      'name': 'Avalanche',
      'logo': 'https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png'
    },
    'DOT': {
      'coingecko': 'polkadot',
      'binance': 'DOTUSDT',
      'name': 'Polkadot',
      'logo': 'https://assets.coingecko.com/coins/images/12171/large/polkadot.png'
    },
    'TRX': {
      'coingecko': 'tron',
      'binance': 'TRXUSDT',
      'name': 'TRON',
      'logo': 'https://assets.coingecko.com/coins/images/1094/large/tron-logo.png'
    },
    'LINK': {
      'coingecko': 'chainlink',
      'binance': 'LINKUSDT',
      'name': 'Chainlink',
      'logo': 'https://assets.coingecko.com/coins/images/877/large/chainlink-logo.png'
    },
    'MATIC': {
      'coingecko': 'matic-network',
      'binance': 'MATICUSDT',
      'name': 'Polygon',
      'logo': 'https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png'
    },
    'SHIB': {
      'coingecko': 'shiba-inu',
      'binance': 'SHIBUSDT',
      'name': 'Shiba Inu',
      'logo': 'https://assets.coingecko.com/coins/images/11939/large/shiba.png'
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
    'ATOM': {
      'coingecko': 'cosmos',
      'binance': 'ATOMUSDT',
      'name': 'Cosmos',
      'logo': 'https://assets.coingecko.com/coins/images/1481/large/cosmos_hub.png'
    },
    'UNI': {
      'coingecko': 'uniswap',
      'binance': 'UNIUSDT',
      'name': 'Uniswap',
      'logo': 'https://assets.coingecko.com/coins/images/12504/large/uniswap-uni.png'
    },
  };

  /// جلب قائمة الرموز الموحدة
  static List<String> get unifiedSymbols => mapping.keys.toList();

  /// جلب معرف CoinGecko للرمز المحدد
  static String? coingeckoIdFor(String unified) => mapping[unified]?['coingecko'];

  /// جلب زوج Binance للرمز المحدد
  static String? binancePairFor(String unified) => mapping[unified]?['binance'];

  /// جلب الاسم الكامل للعملة
  static String? nameFor(String unified) => mapping[unified]?['name'];

  /// جلب رابط شعار العملة مع معالجة CORS إذا لزم الأمر
  static String? logoFor(String unified) {
    final original = mapping[unified]?['logo'];
    return ImageService.getImageUrl(original);
  }
}

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

