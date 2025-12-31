import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../controllers/currency_controller.dart';
import '../models/currency_model.dart';
import '../services/number_utils.dart';

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
  int? _touchedIndex;
  double? _touchedPrice;
  int? _touchedTimestamp;

  @override
  void initState() {
    super.initState();
    unifiedSymbol = Get.arguments as String;
    tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCurrencyDetails(unifiedSymbol, days: 1);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget buildChart(List<List<num>> data) {
    if (data.isEmpty) {
      return Center(child: Text('no_chart_data'.tr));
    }
    final List<int> timestamps = [];
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final row = data[i];
      if (row.isEmpty) continue;
      var ts = row[0].toInt();
      if (ts < 100000000000) ts = ts * 1000; // seconds -> ms
      timestamps.add(ts);
      final price = (row.length >= 2) ? row[1].toDouble() : 0.0;
      spots.add(FlSpot(i.toDouble(), price));
    }

    if (spots.isEmpty) return Center(child: Text('no_chart_data'.tr));

    final minX = 0.0;
    final maxX = (spots.length - 1).toDouble();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    String formatXLabelByIndex(double x) {
      int idx = x.round();
      if (idx < 0) idx = 0;
      if (idx >= timestamps.length) idx = timestamps.length - 1;
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[idx]).toLocal();
      final span = timestamps.last - timestamps.first;
      if (span <= 24 * 3600 * 1000) {
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      }
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$m/$d';
    }

    final count = spots.length;
    final int xStep = (count > 4) ? ((count - 1) ~/ 4) : 1;
    final double interval = xStep.toDouble();

    SideTitles bottomTitles() => SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: interval,
          getTitlesWidget: (value, meta) {
            final idx = value.round();
            if (idx < 0 || idx >= timestamps.length)
              return const SizedBox.shrink();
            if (idx % xStep != 0) return const SizedBox.shrink();
            final txt = formatXLabelByIndex(value);
            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Transform.rotate(
                angle: -math.pi / 8, // slight rotation to help long labels fit
                child: Text(txt,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ),
            );
          },
        );


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  color: Theme.of(context).colorScheme.primary,
                  belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2)),
                ),
              ],
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 3.0),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchCallback: (event, resp) {
                  if (event == null ||
                      resp == null ||
                      resp.lineBarSpots == null) return;
                  if (event is FlLongPressEnd ||
                      event is FlPanEndEvent ||
                      !event.isInterestedForInteractions) {
                    setState(() {
                      _touchedIndex = null;
                      _touchedPrice = null;
                      _touchedTimestamp = null;
                    });
                    return;
                  }
                  final spot = resp.lineBarSpots!.first;
                  final idx = spot.x.toInt();
                  if (idx >= 0 && idx < timestamps.length) {
                    setState(() {
                      _touchedIndex = idx;
                      _touchedPrice = spot.y;
                      _touchedTimestamp = timestamps[idx];
                    });
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    final t = formatXLabelByIndex(s.x);
                    return LineTooltipItem('${formatCurrencyShort(s.y)}\n$t',
                        const TextStyle(color: Colors.white, fontSize: 12));
                  }).toList(),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: bottomTitles()),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: Directionality.of(context) == TextDirection.rtl
                      ? SideTitles(
                          showTitles: true,
                          reservedSize: 56,
                          interval: (maxY - minY) > 0
                              ? (maxY - minY) / 3.0
                              : (maxY.abs() > 0 ? maxY / 3.0 : 1.0),
                          getTitlesWidget: (value, meta) {
                            final txt = formatCurrencyShort(value);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(txt,
                                  style: const TextStyle(fontSize: 11)),
                            );
                          },
                        )
                      : const SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: Directionality.of(context) == TextDirection.rtl
                      ? const SideTitles(showTitles: false)
                      : SideTitles(
                          showTitles: true,
                          reservedSize: 56,
                          interval: (maxY - minY) > 0
                              ? (maxY - minY) / 3.0
                              : (maxY.abs() > 0 ? maxY / 3.0 : 1.0),
                          getTitlesWidget: (value, meta) {
                            final txt = formatCurrencyShort(value);
                            return Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(txt,
                                  style: const TextStyle(fontSize: 11)),
                            );
                          },
                        ),
                ),
              ),
              borderData: FlBorderData(show: false),
            )),
          ),
        ],
      ),
    );
  }

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

  Future<void> _fetchForDays(int days) async {
    await controller.fetchCurrencyDetails(unifiedSymbol, days: days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final sel = controller.selectedCurrency.value ??
              controller.currencies
                  .firstWhereOrNull((c) => c.id == unifiedSymbol);
          return Text(sel?.name ?? unifiedSymbol);
        }),
      ),
      body: Obx(() {
        final CurrencyModel? model = controller.selectedCurrency.value ??
            controller.currencies
                .firstWhereOrNull((c) => c.id == unifiedSymbol);

        if (model == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final price = model.currentPrice;
        final change = model.priceChangePercentage24h ?? 0.0;
        final changeColor = change >= 0 ? Colors.green : Colors.red;

        final chart1 = model.chartData?['1'] ?? [];
        final chart7 = model.chartData?['7'] ?? [];
        final chart30 = model.chartData?['30'] ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: model.iconUrl != null
                    ? SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            model.iconUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                CircleAvatar(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(child: Text(model.symbol.substring(0, 1))),
                title: Text('${model.name} (${model.symbol})'),
                subtitle: Text(model.marketCap != null
                    ? '${'mcap'.tr}: \$${model.marketCap!.toStringAsFixed(0)}'
                    : ''),
                trailing: SizedBox(
                  height: 44,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (price != null)
                          Text(formatCurrencyShort(price),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${change.toStringAsFixed(2)}%',
                            style: TextStyle(color: changeColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: 'period_1d'.tr),
                  Tab(text: 'period_7d'.tr),
                  Tab(text: 'period_30d'.tr),
                ],
                onTap: (index) {
                  final days = index == 0
                      ? 1
                      : index == 1
                          ? 7
                          : 30;
                  _fetchForDays(days);
                },
              ),
              SizedBox(
                height: 260,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    chart1.isNotEmpty
                        ? buildChart(chart1)
                        : Center(child: Text('no_1d_data'.tr)),
                    chart7.isNotEmpty
                        ? buildChart(chart7)
                        : Center(child: Text('no_7d_data'.tr)),
                    chart30.isNotEmpty
                        ? buildChart(chart30)
                        : Center(child: Text('no_30d_data'.tr)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (model.marketOverview != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('market_overview'.tr,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _buildOverviewRow(
                              'market_cap_rank'.tr,
                              model.marketOverview!.marketCapRank != null
                                  ? '#${model.marketOverview!.marketCapRank}'
                                  : 'N/A'),
                          _buildOverviewRow(
                              'circulating_supply'.tr,
                              formatNumberShort(
                                  model.marketOverview!.circulatingSupply)),
                          _buildOverviewRow('ath'.tr,
                              formatCurrencyShort(model.marketOverview!.ath)),
                          _buildOverviewRow('atl'.tr,
                              formatCurrencyShort(model.marketOverview!.atl)),
                          _buildOverviewRow(
                              'change_7d'.tr,
                              model.marketOverview!.change7dPercent != null
                                  ? '${model.marketOverview!.change7dPercent!.toStringAsFixed(2)}%'
                                  : 'N/A'),
                          _buildOverviewRow(
                              'change_30d'.tr,
                              model.marketOverview!.change30dPercent != null
                                  ? '${model.marketOverview!.change30dPercent!.toStringAsFixed(2)}%'
                                  : 'N/A'),
                          const SizedBox(height: 8),
                          Text('links'.tr,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 6),
                          if (model.marketOverview!.website != null)
                            Text(
                                '${'website'.tr}: ${model.marketOverview!.website}'),
                          if (model.marketOverview!.twitter != null)
                            Text(
                                '${'twitter'.tr}: @${model.marketOverview!.twitter}'),
                          if (model.marketOverview!.github != null)
                            Text(
                                '${'github'.tr}: ${model.marketOverview!.github}'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

