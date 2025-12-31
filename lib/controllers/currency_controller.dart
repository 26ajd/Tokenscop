import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/currency_model.dart';
import '../models/market_overview.dart';
import '../widgets/binance_currency.dart';
import '../services/mapping_service.dart';

class CurrencyController extends GetxController {
  final Dio _dioCG;
  final Dio _dioBinance;

  CurrencyController._internal(this._dioCG, this._dioBinance);

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

    dioCG.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options);
    }, onError: (e, handler) {
      return handler.next(e);
    }));

    dioBinance.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) {
      return handler.next(options);
    }, onError: (e, handler) {
      return handler.next(e);
    }));

    return CurrencyController._internal(dioCG, dioBinance);
  }

  final RxList<CurrencyModel> currencies = <CurrencyModel>[].obs;
  final Rxn<CurrencyModel> selectedCurrency = Rxn<CurrencyModel>();
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  Timer? _updateTimer;
  final Map<String, Map<String, DateTime>> _chartFetchedAt = {};
  final Duration _chartTtl = const Duration(minutes: 5);

  final Map<String, Future<void>> _ongoingDetailFetches = {};
  WebSocket? _binanceWs;
  final Set<String> _subscribedPairs = {};
  Timer? _wsReconnectTimer;
  final Map<String, DateTime> _metaFetchedAt = {};
  final Duration _metaTtl = const Duration(hours: 24);

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      updatePrices();
    });
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    try {
      _binanceWs?.close();
    } catch (_) {}
    super.onClose();
  }

  Future<void> fetchCurrencies() async {
    try {
      isLoading.value = true;

      final symbols = MappingService.unifiedSymbols;
      final cgIds = symbols
          .map((s) => MappingService.coingeckoIdFor(s))
          .whereType<String>()
          .toList();

      if (cgIds.isEmpty) {
        currencies.clear();
        return;
      }


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

      for (var pair in binancePairs) {
        _ensureWsForPair(pair);
      }

      currencies.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch currencies: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrencyDetails(String unifiedSymbol,
      {int days = 1}) async {
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
          Get.snackbar('Error', 'No mapping for $unifiedSymbol',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }

        final idx = currencies.indexWhere((c) => c.id == unifiedSymbol);
        if (idx != -1) {
          final existing = currencies[idx];
          final cached = existing.chartData?[days.toString()];
          final fetchedMap = _chartFetchedAt[unifiedSymbol];
          final fetchedAt =
              fetchedMap == null ? null : fetchedMap[days.toString()];
          if (cached != null && fetchedAt != null) {
            final age = DateTime.now().difference(fetchedAt);
            if (age <= _chartTtl) {
              selectedCurrency.value = existing;
              return;
            }
          }
        }

        final bPair = MappingService.binancePairFor(unifiedSymbol);
        if (bPair == null) {
          Get.snackbar('Error', 'No Binance mapping for $unifiedSymbol',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }

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
          chartMap[days.toString()] = rawPrices
              .map<List<num>>(
                  (e) => (e as List<dynamic>).map((n) => n as num).toList())
              .toList();

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
        } else {
          final chartMap = <String, List<List<num>>>{};
          chartMap[days.toString()] = rawPrices
              .map<List<num>>(
                  (e) => (e as List<dynamic>).map((n) => n as num).toList())
              .toList();

          final lastPrice =
              rawPrices.isNotEmpty ? rawPrices.last[1].toDouble() : null;

          final model = CurrencyModel(
            id: unifiedSymbol,
            coingeckoId: null,
            binanceSymbol: MappingService.binancePairFor(unifiedSymbol),
            name: unifiedSymbol,
            symbol:
                MappingService.binancePairFor(unifiedSymbol) ?? unifiedSymbol,
            currentPrice: lastPrice,
            marketCap: null,
            volume: null,
            iconUrl: null,
            priceChange24h: null,
            priceChangePercentage24h: null,
            chartData: chartMap,
          );

          currencies.add(model);
          _chartFetchedAt[unifiedSymbol] ??= {};
          _chartFetchedAt[unifiedSymbol]![days.toString()] = DateTime.now();
          selectedCurrency.value = model;
          await _fetchMetadataIfNeeded(unifiedSymbol, coingeckoId: coingeckoId);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to fetch details: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
        _ongoingDetailFetches.remove(key);
      }
    }();

    _ongoingDetailFetches[key] = future;
    await future;
  }

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
          final ra = err.response?.headers.value('Retry-After') ??
              err.response?.headers.value('retry-after');
          if (ra != null) {
            final sec = int.tryParse(ra.toString());
            if (sec != null) {
              await Future.delayed(Duration(seconds: sec));
              continue;
            }
          }
          final waitMs = 500 * (1 << (attempt - 1)); // 500ms,1s,2s
          if (attempt >= maxAttempts) {
            if (!silent) {
              Get.snackbar('Rate limited',
                  'Too many requests to external API. Please try again later.',
                  snackPosition: SnackPosition.BOTTOM);
            }
            return null;
          }
          await Future.delayed(Duration(milliseconds: waitMs));
          continue;
        }
        if (!silent) {
          Get.snackbar('Error', 'Failed request: ${err.message}',
              snackPosition: SnackPosition.BOTTOM);
        }
        return null;
      } catch (err) {
        if (!silent) {
          Get.snackbar('Error', 'Unexpected error: ${err.toString()}',
              snackPosition: SnackPosition.BOTTOM);
        }
        return null;
      }
    }
    return null;
  }

  Future<void> _fetchMetadataIfNeeded(String unified,
      {String? coingeckoId}) async {
    if (coingeckoId == null) return;
    final last = _metaFetchedAt[unified];
    if (last != null && DateTime.now().difference(last) <= _metaTtl) return;

    try {
      final resp = await _retryGet(_dioCG, '/coins/$coingeckoId',
          queryParameters: {
            'localization': 'false',
            'tickers': 'false',
            'market_data': 'true',
            'community_data': 'false',
            'developer_data': 'false',
            'sparkline': 'false',
          },
          silent: true);
      if (resp == null) return;

      final Map<String, dynamic> data = resp as Map<String, dynamic>;
      final String? desc = (data['description']?['en'])?.toString();
      final String? homepage = (data['links']?['homepage'] as List<dynamic>?)
          ?.firstWhere((e) => e != null && e.toString().isNotEmpty,
              orElse: () => null)
          ?.toString();
      final String? logo = (data['image']?['large'])?.toString() ??
          (data['image']?['thumb'])?.toString();
      final int? rank = data['market_cap_rank'] is int
          ? data['market_cap_rank'] as int
          : (data['market_cap_rank'] is num
              ? (data['market_cap_rank'] as num).toInt()
              : null);
      final Map<String, dynamic>? md =
          data['market_data'] as Map<String, dynamic>?;
      final double? ath = md?['ath']?['usd'] is num
          ? (md!['ath']['usd'] as num).toDouble()
          : null;
      final double? atl = md?['atl']?['usd'] is num
          ? (md!['atl']['usd'] as num).toDouble()
          : null;
      final double? circ = md?['circulating_supply'] is num
          ? (md!['circulating_supply'] as num).toDouble()
          : null;
      final double? maxSupply = md?['max_supply'] is num
          ? (md!['max_supply'] as num).toDouble()
          : (md?['max_supply'] != null
              ? double.tryParse(md!['max_supply'].toString())
              : null);

      dynamic p7 = md?['price_change_percentage_7d_in_currency']?['usd'] ??
          md?['price_change_percentage_7d'] ??
          md?['price_change_percentage_7d_in_currency']?['usd'];
      final double? change7d =
          p7 is num ? p7.toDouble() : double.tryParse(p7?.toString() ?? '');

      dynamic p30 = md?['price_change_percentage_30d_in_currency']?['usd'] ??
          md?['price_change_percentage_30d'] ??
          md?['price_change_percentage_30d_in_currency']?['usd'];
      final double? change30d =
          p30 is num ? p30.toDouble() : double.tryParse(p30?.toString() ?? '');

      final String? twitter =
          (data['links']?['twitter_screen_name'])?.toString();
      final String? github =
          (data['links']?['repos_url']?['github'] as List<dynamic>?)
              ?.firstWhere((e) => e != null && e.toString().isNotEmpty,
                  orElse: () => null)
              ?.toString();

      final overview = MarketOverview(
        marketCapRank: rank,
        circulatingSupply: circ,
        maxSupply: maxSupply,
        ath: ath,
        atl: atl,
        change7dPercent: change7d,
        change30dPercent: change30d,
        website: homepage,
        twitter: twitter,
        github: github,
      );

      final idx = currencies.indexWhere((c) => c.id == unified);
      if (idx != -1) {
        final existing = currencies[idx];
        final updated = existing.copyWith(
          logoUrl: logo,
          description: desc,
          homepage: homepage,
          marketCapRank: rank,
          ath: ath,
          atl: atl,
          circulatingSupply: circ,
          marketOverview: overview,
        );
        currencies[idx] = updated;
        if (selectedCurrency.value?.id == unified)
          selectedCurrency.value = updated;
      }

      _metaFetchedAt[unified] = DateTime.now();
    } catch (e) {
    }
  }

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
    _binanceWs = null;

    final streams = pairs.map((p) => '${p.toLowerCase()}@miniTicker').join('/');
    final uri =
        Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams');
    try {
      _binanceWs = await WebSocket.connect(uri.toString());

      _binanceWs!.listen((message) {
        try {
          final envelope =
              jsonDecode(message as String) as Map<String, dynamic>;
          final data = envelope['data'] as Map<String, dynamic>?;
          final sym = data?['s'] as String?;
          final priceStr = (data?['c'] ?? data?['p'])?.toString();
          final price = priceStr != null ? double.tryParse(priceStr) : null;
          if (sym != null && price != null) {
            for (var i = 0; i < currencies.length; i++) {
              final c = currencies[i];
              if (c.binanceSymbol == sym) {
                currencies[i] = c.copyWith(currentPrice: price);
                if (selectedCurrency.value?.id == c.id) {
                  selectedCurrency.value = currencies[i];
                }
                break;
              }
            }
          }
        } catch (_) {}
      }, onDone: () {
        _binanceWs = null;
        _scheduleWsReconnect();
      }, onError: (_) {
        _binanceWs = null;
        _scheduleWsReconnect();
      });
    } catch (_) {
      _binanceWs = null;
      _scheduleWsReconnect();
    }
  }

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

      final Map<String, double> latestPrices = {};
      for (var b in results.whereType<BinanceCurrency>()) {
        final p = double.tryParse(b.price);
        if (p != null) latestPrices[b.symbol] = p;
      }

      bool changed = false;
      for (var i = 0; i < currencies.length; i++) {
        final c = currencies[i];
        final bSym = c.binanceSymbol;
        final newPrice = (bSym != null && latestPrices.containsKey(bSym))
            ? latestPrices[bSym]
            : null;
        if (newPrice != null && newPrice != c.currentPrice) {
          currencies[i] = c.copyWith(currentPrice: newPrice);
          changed = true;
        }
      }
      if (changed) {
      }
    } catch (e) {
    } finally {
      isUpdating.value = false;
    }
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

