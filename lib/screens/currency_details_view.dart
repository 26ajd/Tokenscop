// ============================================
// ملف: currency_details_view.dart
// الوصف: واجهة تفاصيل العملة، عرض الرسوم البيانية الإحصائية والمعلومات السوقية
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../controllers/currency_controller.dart';
import '../models/currency_model.dart';
import '../services/number_utils.dart';

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

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// واجهة تفاصيل العملة
/// تعرض الرسوم البيانية لفترات زمنية مختلفة ومعلومات السوق الكاملة
class CurrencyDetailsView extends StatefulWidget {
  const CurrencyDetailsView({super.key});

  @override
  State<CurrencyDetailsView> createState() => _CurrencyDetailsViewState();
}

class _CurrencyDetailsViewState extends State<CurrencyDetailsView>
    with SingleTickerProviderStateMixin {
  final CurrencyController controller = Get.find<CurrencyController>();
  late final String unifiedSymbol;
  late TabController tabController;
  
  // متغيرات تتبع اللمس في الرسم البياني
  int? _touchedIndex;
  double? _touchedPrice;
  int? _touchedTimestamp;

  @override
  void initState() {
    super.initState();
    unifiedSymbol = Get.arguments as String;
    tabController = TabController(length: 3, vsync: this);
    
    // جلب البيانات الأولية (مدة يوم واحد) عند تشغيل الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrencyDetails(unifiedSymbol, days: 1);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// بناء الرسم البياني بناءً على البيانات المقدمة
  Widget _buildChart(List<List<num>> data) {
    if (data.isEmpty) {
      return Center(child: Text('no_chart_data'.tr));
    }
    
    final List<int> timestamps = [];
    final spots = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      final row = data[i];
      if (row.isEmpty) continue;
      var ts = row[0].toInt();
      if (ts < 100000000000) ts = ts * 1000; // تحويل من ثوانٍ إلى ميلي ثانية
      timestamps.add(ts);
      final price = (row.length >= 2) ? row[1].toDouble() : 0.0;
      spots.add(FlSpot(i.toDouble(), price));
    }

    if (spots.isEmpty) return Center(child: Text('no_chart_data'.tr));

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: const FlDotData(show: false),
              color: Theme.of(context).colorScheme.primary,
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3.0,
          ),
          lineTouchData: _getLineTouchData(timestamps),
          titlesData: _getTitlesData(context, minY, maxY, timestamps),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  /// إعدادات التفاعل باللمس للرسم البياني
  LineTouchData _getLineTouchData(List<int> timestamps) {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchCallback: (event, resp) {
        if (event == null || resp == null || resp.lineBarSpots == null) return;
        if (event is FlLongPressEnd || event is FlPanEndEvent || !event.isInterestedForInteractions) {
          if (mounted) {
            setState(() {
              _touchedIndex = null;
              _touchedPrice = null;
              _touchedTimestamp = null;
            });
          }
          return;
        }
        final spot = resp.lineBarSpots!.first;
        final idx = spot.x.toInt();
        if (idx >= 0 && idx < timestamps.length) {
          if (mounted) {
            setState(() {
              _touchedIndex = idx;
              _touchedPrice = spot.y;
              _touchedTimestamp = timestamps[idx];
            });
          }
        }
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) => spots.map((s) {
          final t = _formatXLabelByIndex(s.x, timestamps);
          return LineTooltipItem(
            '${formatCurrencyShort(s.y)}\n$t',
            const TextStyle(color: Colors.white, fontSize: 12),
          );
        }).toList(),
      ),
    );
  }

  /// إعدادات العناوين والمحاور للرسم البياني
  FlTitlesData _getTitlesData(BuildContext context, double minY, double maxY, List<int> timestamps) {
    final xStep = (timestamps.length > 4) ? ((timestamps.length - 1) ~/ 4) : 1;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: xStep.toDouble(),
          getTitlesWidget: (value, meta) {
            final idx = value.round();
            if (idx < 0 || idx >= timestamps.length || idx % xStep != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Transform.rotate(
                angle: -math.pi / 8,
                child: Text(
                  _formatXLabelByIndex(value, timestamps),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: isRtl ? _getSideTitles(minY, maxY) : const SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: !isRtl ? _getSideTitles(minY, maxY) : const SideTitles(showTitles: false),
      ),
    );
  }

  /// بناء العناوين الجانبية (الأسعار)
  SideTitles _getSideTitles(double minY, double maxY) {
    return SideTitles(
      showTitles: true,
      reservedSize: 56,
      interval: (maxY - minY) > 0 ? (maxY - minY) / 3.0 : (maxY.abs() > 0 ? maxY / 3.0 : 1.0),
      getTitlesWidget: (value, meta) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Text(formatCurrencyShort(value), style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  /// تنسيق ملصق المحور السيني (الوقت)
  String _formatXLabelByIndex(double x, List<int> timestamps) {
    int idx = x.round().clamp(0, timestamps.length - 1);
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[idx]).toLocal();
    final span = timestamps.last - timestamps.first;
    
    if (span <= 24 * 3600 * 1000) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  /// بناء صف من معلومات نظرة عامة على السوق
  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final sel = controller.selectedCurrency.value ??
              controller.currencies.firstWhereOrNull((c) => c.id == unifiedSymbol);
          return Text(sel?.name ?? unifiedSymbol);
        }),
      ),
      body: Obx(() {
        final model = controller.selectedCurrency.value ??
            controller.currencies.firstWhereOrNull((c) => c.id == unifiedSymbol);

        if (model == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(model),
              const SizedBox(height: 8),
              _buildChartSection(model),
              const SizedBox(height: 12),
              if (model.marketOverview != null) _buildMarketOverview(model),
            ],
          ),
        );
      }),
    );
  }

  /// بناء رأس الصفحة (الاسم، السعر، التغير)
  Widget _buildHeader(CurrencyModel model) {
    final price = model.currentPrice;
    final change = model.priceChangePercentage24h ?? 0.0;
    final changeColor = change >= 0 ? Colors.green : Colors.red;

    return ListTile(
      leading: model.iconUrl != null
          ? SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  model.iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const CircleAvatar(child: Icon(Icons.image_not_supported)),
                ),
              ),
            )
          : CircleAvatar(child: Text(model.symbol.substring(0, 1))),
      title: Text('${model.name} (${model.symbol})'),
      subtitle: Text(model.marketCap != null ? '${'mcap'.tr}: \$${model.marketCap!.toStringAsFixed(0)}' : ''),
      trailing: SizedBox(
        height: 56,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price != null)
                Text(
                  formatCurrencyShort(price),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              Text(
                '${change.toStringAsFixed(2)}%',
                style: TextStyle(color: changeColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء قسم الرسم البياني مع التبويبات الزمنية
  Widget _buildChartSection(CurrencyModel model) {
    final chart1 = model.chartData?['1'] ?? [];
    final chart7 = model.chartData?['7'] ?? [];
    final chart30 = model.chartData?['30'] ?? [];

    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: 'period_1d'.tr),
            Tab(text: 'period_7d'.tr),
            Tab(text: 'period_30d'.tr),
          ],
          onTap: (index) {
            final days = index == 0 ? 1 : index == 1 ? 7 : 30;
            controller.fetchCurrencyDetails(unifiedSymbol, days: days);
          },
        ),
        SizedBox(
          height: 260,
          child: TabBarView(
            controller: tabController,
            children: [
              chart1.isNotEmpty ? _buildChart(chart1) : Center(child: Text('no_1d_data'.tr)),
              chart7.isNotEmpty ? _buildChart(chart7) : Center(child: Text('no_7d_data'.tr)),
              chart30.isNotEmpty ? _buildChart(chart30) : Center(child: Text('no_30d_data'.tr)),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء نظرة عامة على السوق
  Widget _buildMarketOverview(CurrencyModel model) {
    final ov = model.marketOverview!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('market_overview'.tr, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildOverviewRow('market_cap_rank'.tr, ov.marketCapRank != null ? '#${ov.marketCapRank}' : 'N/A'),
              _buildOverviewRow('circulating_supply'.tr, formatNumberShort(ov.circulatingSupply)),
              _buildOverviewRow('ath'.tr, formatCurrencyShort(ov.ath)),
              _buildOverviewRow('atl'.tr, formatCurrencyShort(ov.atl)),
              _buildOverviewRow('change_7d'.tr, ov.change7dPercent != null ? '${ov.change7dPercent!.toStringAsFixed(2)}%' : 'N/A'),
              const SizedBox(height: 8),
              Text('links'.tr, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              if (ov.website != null) Text('${'website'.tr}: ${ov.website}'),
              if (ov.twitter != null) Text('${'twitter'.tr}: @${ov.twitter}'),
              if (ov.github != null) Text('${'github'.tr}: ${ov.github}'),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

