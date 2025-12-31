import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpera/routes.dart';
import '../controllers/currency_controller.dart';
import '../models/currency_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CurrencyController controller = Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>()
      : Get.put(CurrencyController());
  final TextEditingController searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _search = searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _onRefresh() async {
    await controller.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          Obx(() {
            if (controller.isUpdating.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.updatePrices,
            );
          })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'search_hint'.tr,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.currencies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              var list = controller.currencies.toList();

              if (_search.isNotEmpty) {
                list = list
                    .where((c) =>
                        c.name.toLowerCase().contains(_search) ||
                        c.symbol.toLowerCase().contains(_search) ||
                        c.id.toLowerCase().contains(_search))
                    .toList();
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final CurrencyModel item = list[index];
                    final price = item.currentPrice;
                    final change = item.priceChangePercentage24h ?? 0.0;
                    final changeColor = change >= 0 ? Colors.green : Colors.red;

                    return ListTile(
                      onTap: () async {
                        await Get.toNamed(AppRoutes.CRYPTO_DETAILS,
                            arguments: item.id);
                      },
                      leading: item.iconUrl != null
                          ? Image.network(item.iconUrl!, width: 40, height: 40)
                          : CircleAvatar(
                              child: Text(item.symbol.substring(0, 1))),
                      title: Text('${item.name} (${item.symbol})'),
                      subtitle: Text(item.marketCap != null
                          ? '${'mcap'.tr}: \$${(item.marketCap! / 1e9).toStringAsFixed(2)}B'
                          : ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (price != null)
                            Text('\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${change.toStringAsFixed(2)}%',
                            style: TextStyle(color: changeColor),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: list.length,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

