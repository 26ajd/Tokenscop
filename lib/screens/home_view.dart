// ============================================
// ملف: home_view.dart
// الوصف: واجهة العرض الرئيسية لقائمة العملات الرقمية مع ميزة البحث والتحديث
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpera/routes.dart';
import '../controllers/currency_controller.dart';
import '../models/currency_model.dart';

// ----------------------------
// 2. الثوابت والإعدادات
// ----------------------------

// ----------------------------
// 3. النماذج والفئات
// ----------------------------

// ----------------------------
// 4. المتحكمات وإدارة الحالة
// ----------------------------
// يتم استخدام CurrencyController المرفق بالذاكرة

// ----------------------------
// 5. الخدمات و API
// ----------------------------

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// واجهة العرض الرئيسية
/// تعرض قائمة العملات الرقمية وتسمح بالبحث والتحديث المباشر
class HomeView extends StatelessWidget {
  HomeView({super.key});

  // استرجاع نسخة المتحكم
  final CurrencyController controller = Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>()
      : Get.put(CurrencyController());

  // تحكم البحث
  final TextEditingController searchController = TextEditingController();

  /// تحديث البيانات يدوياً عند السحب لأسفل
  Future<void> _onRefresh() async {
    await controller.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          // عرض مؤشر التحديث أو زر التحديث
          Obx(() {
            if (controller.isUpdating.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
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
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => controller.searchQuery.value = value.trim(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'search_hint'.tr,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.searchQuery.value = '';
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // قائمة العملات التفاعلية
          Expanded(
            child: Obx(() {
              // حالة التحميل الأولية
              if (controller.isLoading.value && controller.currencies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // جلب القائمة المصفاة من المتحكم
              final list = controller.filteredCurrencies;

              if (list.isEmpty) {
                return Center(child: Text('no_results'.tr));
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final CurrencyModel item = list[index];
                    return _buildCurrencyTile(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر عملة واحد في القائمة
  Widget _buildCurrencyTile(CurrencyModel item) {
    final price = item.currentPrice;
    final change = item.priceChangePercentage24h ?? 0.0;
    final changeColor = change >= 0 ? Colors.green : Colors.red;

    return ListTile(
      onTap: () => Get.toNamed(AppRoutes.CRYPTO_DETAILS, arguments: item.id),
      leading: item.iconUrl != null
          ? Image.network(
              item.iconUrl!,
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin),
            )
          : CircleAvatar(child: Text(item.symbol.substring(0, 1))),
      title: Text('${item.name} (${item.symbol})'),
      subtitle: Text(
        item.marketCap != null
            ? '${'mcap'.tr}: \$${(item.marketCap! / 1e9).toStringAsFixed(2)}B'
            : '',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (price != null)
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 4),
          Text(
            '${change.toStringAsFixed(2)}%',
            style: TextStyle(color: changeColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

