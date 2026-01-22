// ============================================
// ملف: currency_controller.dart
// الوصف: المتحكم الرئيسي في بيانات العملات الرقمية، جلب الأسعار، والتعامل مع APIs
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/currency_model.dart';
import '../models/market_overview.dart';
import '../widgets/binance_currency.dart';
import '../services/mapping_service.dart';

// ----------------------------
// 2. الثوابت والإعدادات
// ----------------------------

// ----------------------------
// 3. النماذج والفئات
// ----------------------------

/// ملحق لتسهيل البحث في القوائم
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// ----------------------------
// 4. المتحكمات وإدارة الحالة
// ----------------------------

/// متحكم العملات
/// يدير حالة قائمة العملات، التفاصيل، والاشتراكات الحية (WebSockets)
class CurrencyController extends GetxController {
  // --- متغيرات الحالة (Reactive Variables) ---
  final RxList<CurrencyModel> currencies = <CurrencyModel>[].obs;
  final Rxn<CurrencyModel> selectedCurrency = Rxn<CurrencyModel>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  
  // --- متغيرات البحث ---
  final RxString searchQuery = ''.obs;

  // --- أدوات التحكم والقفل (Internal Cache & Timers) ---
  final Map<String, Map<String, DateTime>> _chartFetchedAt = {};
  final Duration _chartTtl = const Duration(minutes: 5);
  final Map<String, Future<void>> _ongoingDetailFetches = {};
  final Map<String, DateTime> _metaFetchedAt = {};
  final Duration _metaTtl = const Duration(hours: 24);
  
  Timer? _updateTimer;
  WebSocket? _binanceWs;
  final Set<String> _subscribedPairs = {};
  Timer? _wsReconnectTimer;

  // --- عملاء الشبكة (API Clients) ---
  late final Dio _dioCG;
  late final Dio _dioBinance;

  /// تهيئة المتحكم
  CurrencyController._internal(this._dioCG, this._dioBinance);

  /// المصنع لإنشاء نسخة مفردة مع إعدادات Dio
  factory CurrencyController() {
    final cgOptions = BaseOptions(
      baseUrl: 'https://api.coingecko.com/api/v3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
    final binanceOptions = BaseOptions(
      baseUrl: 'https://api.binance.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    final dioCG = Dio(cgOptions);
    final dioBinance = Dio(binanceOptions);

    // إضافة معترضات بسيطة للبيانات
    dioCG.interceptors.add(LogInterceptor(responseBody: false));
    dioBinance.interceptors.add(LogInterceptor(responseBody: false));

    return CurrencyController._internal(dioCG, dioBinance);
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    // تحديث الأسعار كل 30 ثانية
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      updatePrices();
    });
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    _wsReconnectTimer?.cancel();
    try {
      _binanceWs?.close();
    } catch (_) {}
    super.onClose();
  }

  // --- عمليات تصفية البيانات (Logic) ---

  /// جلب العملات المصفاة بناءً على نص البحث
  List<CurrencyModel> get filteredCurrencies {
    if (searchQuery.value.isEmpty) return currencies.toList();
    return currencies
        .where((c) =>
            c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            c.symbol.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            c.id.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // ----------------------------
  // 5. الخدمات و API
  // ----------------------------

  /// جلب قائمة العملات الأولية من Binance
  Future<void> fetchCurrencies() async {
    try {
      isLoading.value = true;

      final symbols = MappingService.unifiedSymbols;
      final binancePairs = symbols
          .map((s) => MappingService.binancePairFor(s))
          .whereType<String>()
          .toList();

      final tickerFutures = binancePairs.map((pair) async {
        try {
          final resp = await _dioBinance.get<Map<String, dynamic>>(
            '/api/v3/ticker/24hr',
            queryParameters: {'symbol': pair},
          );
          return resp.data;
        } catch (e) {
          return null;
        }
      }).toList();

      final tickerResults = await Future.wait(tickerFutures);

      final Map<String, Map<String, dynamic>> tickerMap = {};
      for (var t in tickerResults.whereType<Map<String, dynamic>>()) {
        final sym = t['symbol'] as String?;
        if (sym != null) tickerMap[sym] = t;
      }

      final List<CurrencyModel> result = [];

      for (var unified in symbols) {
        final bPair = MappingService.binancePairFor(unified);
        final ticker = bPair != null ? tickerMap[bPair] : null;

        final price = ticker != null
            ? double.tryParse(ticker['lastPrice']?.toString() ?? '')
            : null;
        final changePct = ticker != null
            ? double.tryParse(ticker['priceChangePercent']?.toString() ?? '')
            : null;
        final vol = ticker != null
            ? double.tryParse(ticker['volume']?.toString() ?? '')
            : null;

        final model = CurrencyModel(
          id: unified,
          coingeckoId: null,
          binanceSymbol: bPair,
          name: MappingService.nameFor(unified) ?? unified,
          symbol: unified,
          currentPrice: price,
          marketCap: null,
          volume: vol,
          iconUrl: MappingService.logoFor(unified),
          logoUrl: MappingService.logoFor(unified),
          priceChange24h: null,
          priceChangePercentage24h: changePct,
          chartData: null,
        );

        result.add(model);
      }

      // تفعيل اشتراكات WebSocket لكل زوج
      for (var pair in binancePairs) {
        _ensureWsForPair(pair);
      }

      currencies.assignAll(result);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب العملات: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب تفاصيل العملة والبيانات البيانية
  Future<void> fetchCurrencyDetails(String unifiedSymbol, {int days = 1}) async {
    final key = '$unifiedSymbol:$days';

    if (_ongoingDetailFetches.containsKey(key)) {
      await _ongoingDetailFetches[key];
      return;
    }

    final future = () async {
      try {
        isLoading.value = true;

        final coingeckoId = MappingService.coingeckoIdFor(unifiedSymbol);
        if (coingeckoId == null) {
          Get.snackbar('خطأ', 'لا يوجد ربط لهذه العملة $unifiedSymbol',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }

        // التحقق من التخزين المؤقت (Cache)
        final idx = currencies.indexWhere((c) => c.id == unifiedSymbol);
        if (idx != -1) {
          final existing = currencies[idx];
          final cached = existing.chartData?[days.toString()];
          final fetchedMap = _chartFetchedAt[unifiedSymbol];
          final fetchedAt = fetchedMap == null ? null : fetchedMap[days.toString()];
          if (cached != null && fetchedAt != null) {
            final age = DateTime.now().difference(fetchedAt);
            if (age <= _chartTtl) {
              selectedCurrency.value = existing;
              return;
            }
          }
        }

        final bPair = MappingService.binancePairFor(unifiedSymbol);
        if (bPair == null) return;

        const interval = '1h';
        final int limit = ((days * 24).clamp(1, 1000)).toInt();

        final klineResp = await _retryGet(
          _dioBinance,
          '/api/v3/klines',
          queryParameters: {
            'symbol': bPair,
            'interval': interval,
            'limit': limit.toString(),
          },
        );

        if (klineResp == null) return;

        final List<dynamic> klines = klineResp as List<dynamic>;
        final List<List<num>> rawPrices = klines.map<List<num>>((row) {
          final ts = (row[0] as num).toInt();
          final closeStr = row[4].toString();
          final price = double.tryParse(closeStr) ?? 0.0;
          return [ts, price];
        }).toList();

        final idx2 = currencies.indexWhere((c) => c.id == unifiedSymbol);
        if (idx2 != -1) {
          final existing = currencies[idx2];
          final chartMap = <String, List<List<num>>>{};
          chartMap[days.toString()] = rawPrices;

          final updated = existing.copyWith(
            chartData: {
              if (existing.chartData != null) ...existing.chartData!,
              ...chartMap,
            },
          );

          currencies[idx2] = updated;
          _chartFetchedAt[unifiedSymbol] ??= {};
          _chartFetchedAt[unifiedSymbol]![days.toString()] = DateTime.now();
          selectedCurrency.value = updated;
          await _fetchMetadataIfNeeded(unifiedSymbol, coingeckoId: coingeckoId);
        }
      } catch (e) {
        Get.snackbar('خطأ', 'فشل في جلب التفاصيل: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
        _ongoingDetailFetches.remove(key);
      }
    }();

    _ongoingDetailFetches[key] = future;
    await future;
  }

  /// محاولة الطلب مع إعادة المحاولة في حال وجود حد للمعدل (Rate Limiting)
  Future<dynamic> _retryGet(
    Dio dio,
    String path, {
    Map<String, dynamic>? queryParameters,
    int maxAttempts = 3,
    bool silent = false,
  }) async {
    var attempt = 0;
    while (attempt < maxAttempts) {
      try {
        final resp = await dio.get<dynamic>(
          path,
          queryParameters: queryParameters,
        );
        return resp.data;
      } on DioException catch (err) {
        final status = err.response?.statusCode;
        if (status == 429) {
          attempt++;
          final ra = err.response?.headers.value('Retry-After');
          if (ra != null) {
            final sec = int.tryParse(ra.toString());
            if (sec != null) {
              await Future.delayed(Duration(seconds: sec));
              continue;
            }
          }
          final waitMs = 500 * (1 << (attempt - 1));
          if (attempt >= maxAttempts) {
            if (!silent) Get.snackbar('تنبيه', 'تم تجاوز حد الطلبات، يرجى المحاولة لاحقاً');
            return null;
          }
          await Future.delayed(Duration(milliseconds: waitMs));
          continue;
        }
        if (!silent) Get.snackbar('خطأ', 'فشل الطلب: ${err.message}');
        return null;
      } catch (err) {
        return null;
      }
    }
    return null;
  }

  /// جلب البيانات الوصفية من CoinGecko إذا لزم الأمر
  Future<void> _fetchMetadataIfNeeded(String unified, {String? coingeckoId}) async {
    if (coingeckoId == null) return;
    final last = _metaFetchedAt[unified];
    if (last != null && DateTime.now().difference(last) <= _metaTtl) return;

    try {
      final resp = await _retryGet(_dioCG, '/coins/$coingeckoId',
          queryParameters: {
            'localization': 'false',
            'tickers': 'false',
            'market_data': 'true',
          },
          silent: true);
      if (resp == null) return;

      final Map<String, dynamic> data = resp as Map<String, dynamic>;
      final String? desc = (data['description']?['en'])?.toString();
      final Map<String, dynamic>? md = data['market_data'] as Map<String, dynamic>?;
      
      final overview = MarketOverview(
        marketCapRank: data['market_cap_rank'],
        circulatingSupply: (md?['circulating_supply'] as num?)?.toDouble(),
        maxSupply: (md?['max_supply'] as num?)?.toDouble(),
        ath: (md?['ath']?['usd'] as num?)?.toDouble(),
        atl: (md?['atl']?['usd'] as num?)?.toDouble(),
        change7dPercent: (md?['price_change_percentage_7d'] as num?)?.toDouble(),
      );

      final idx = currencies.indexWhere((c) => c.id == unified);
      if (idx != -1) {
        final updated = currencies[idx].copyWith(
          description: desc,
          marketOverview: overview,
        );
        currencies[idx] = updated;
        if (selectedCurrency.value?.id == unified) selectedCurrency.value = updated;
      }

      _metaFetchedAt[unified] = DateTime.now();
    } catch (_) {}
  }

  // --- إدارة WebSocket ---

  void _ensureWsForPair(String pair) {
    if (_subscribedPairs.contains(pair)) return;
    _subscribedPairs.add(pair);
    _scheduleWsReconnect();
  }

  void _scheduleWsReconnect() {
    _wsReconnectTimer?.cancel();
    _wsReconnectTimer = Timer(const Duration(milliseconds: 500), () {
      _connectWsWithSubscribedPairs();
    });
  }

  Future<void> _connectWsWithSubscribedPairs() async {
    final pairs = _subscribedPairs.toList();
    if (pairs.isEmpty) return;

    try {
      await _binanceWs?.close();
    } catch (_) {}

    final streams = pairs.map((p) => '${p.toLowerCase()}@miniTicker').join('/');
    final uri = Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams');
    
    try {
      _binanceWs = await WebSocket.connect(uri.toString());
      _binanceWs!.listen((message) {
        try {
          final envelope = jsonDecode(message as String) as Map<String, dynamic>;
          final data = envelope['data'] as Map<String, dynamic>?;
          final sym = data?['s'] as String?;
          final priceStr = (data?['c'] ?? data?['p'])?.toString();
          final price = priceStr != null ? double.tryParse(priceStr) : null;
          
          if (sym != null && price != null) {
            final idx = currencies.indexWhere((c) => c.binanceSymbol == sym);
            if (idx != -1) {
              currencies[idx] = currencies[idx].copyWith(currentPrice: price);
              if (selectedCurrency.value?.id == currencies[idx].id) {
                selectedCurrency.value = currencies[idx];
              }
            }
          }
        } catch (_) {}
      }, onDone: _scheduleWsReconnect, onError: (_) => _scheduleWsReconnect());
    } catch (_) {
      _scheduleWsReconnect();
    }
  }

  /// تحديث الأسعار يدوياً
  Future<void> updatePrices() async {
    try {
      if (currencies.isEmpty) return;
      isUpdating.value = true;

      final pairs = currencies
          .map((c) => c.binanceSymbol)
          .whereType<String>()
          .toSet()
          .toList();

      final futures = pairs.map((pair) async {
        try {
          final resp = await _dioBinance.get<Map<String, dynamic>>(
            '/api/v3/ticker/price',
            queryParameters: {'symbol': pair},
          );
          return BinanceCurrency.fromJson(resp.data!);
        } catch (e) {
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);

      for (var b in results.whereType<BinanceCurrency>()) {
        final p = double.tryParse(b.price);
        if (p != null) {
          final idx = currencies.indexWhere((c) => c.binanceSymbol == b.symbol);
          if (idx != -1 && currencies[idx].currentPrice != p) {
            currencies[idx] = currencies[idx].copyWith(currentPrice: p);
          }
        }
      }
    } catch (_) {
    } finally {
      isUpdating.value = false;
    }
  }
}

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------
// لا توجد ويدجتات في هذا الملف

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

