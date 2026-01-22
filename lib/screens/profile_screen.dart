// ============================================
// ملف: profile_screen.dart
// الوصف: واجهة الملف الشخصي للمستخدم، عرض الإحصائيات، وتغيير الإعدادات (اللغة، الثيم، اللون)
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/locale_controller.dart';
import '../helpera/themes.dart';

// ----------------------------
// 2. الثوابت والإعدادات
// ----------------------------

// ----------------------------
// 3. النماذج والفئات
// ----------------------------

// ----------------------------
// 4. المتحكمات وإدارة الحالة
// ----------------------------
// يتم جلب المتحكمات عبر Get.find للحفاظ على الحالة العالمية

// ----------------------------
// 5. الخدمات و API
// ----------------------------

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// واجهة الملف الشخصي والإعدادات
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Obx(() {
        final user = authController.currentUser.value;
        
        if (user == null) {
          // إذا كان المستخدم غير موجود رغم الدخول (حالة تعليق)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text('loading'.tr),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => authController.logout(),
                  child: Text('logout'.tr),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // قسم معلومات المستخدم العليا
            _buildUserHeader(context, user),
            const SizedBox(height: 32),
            const Divider(),

            // قسم إعدادات التطبيق
            _buildThemeSwitch(themeController),
            _buildLanguagePicker(localeController),
            const SizedBox(height: 12),
            _buildAccentColorPicker(context, themeController),
            
            const Divider(),
            const SizedBox(height: 16),

            // قسم العمليات (تسجيل الخروج وحذف الحساب)
            _buildActionButtons(authController),
          ],
        );
      }),
    );
  }

  /// بناء رأس الصفحة مع الصورة والاسم
  Widget _buildUserHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSubtle),
        ),
      ],
    );
  }

  /// بناء مفتاح تبديل المظهر (Dark/Light)
  Widget _buildThemeSwitch(ThemeController themeCtrl) {
    return ListTile(
      title: Text('theme'.tr),
      trailing: Obx(() => Switch(
            value: themeCtrl.isDark.value,
            onChanged: (_) => themeCtrl.toggleTheme(),
          )),
    );
  }

  /// بناء قائمة اختيار اللغة
  Widget _buildLanguagePicker(LocaleController localeCtrl) {
    return ListTile(
      title: Text('language'.tr),
      trailing: Obx(() => DropdownButton<String>(
            value: localeCtrl.locale.value.languageCode,
            items: [
              DropdownMenuItem(value: 'en', child: Text('english'.tr)),
              DropdownMenuItem(value: 'ar', child: Text('arabic'.tr)),
            ],
            onChanged: (val) {
              if (val == 'en') {
                localeCtrl.changeToEnglish();
              } else {
                localeCtrl.changeToArabic();
              }
            },
          )),
    );
  }

  /// بناء منتقي لون السمة الأساسي
  Widget _buildAccentColorPicker(BuildContext context, ThemeController themeCtrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('accent_color'.tr, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: Obx(() {
              final current = Color(themeCtrl.primaryColorValue.value);
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categoryColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = categoryColors[index];
                  final isSelected = c.value == current.value;
                  return GestureDetector(
                    onTap: () => themeCtrl.setPrimaryColor(c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 3)
                            : null,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// بناء أزرار العمليات (خروج وحذف)
  Widget _buildActionButtons(AuthController authCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => authCtrl.logout(),
          icon: const Icon(Icons.logout),
          label: Text('logout'.tr),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.errorContainer,
            foregroundColor: AppColors.error,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            Get.defaultDialog(
              title: 'confirm'.tr,
              middleText: 'delete_account_confirm'.tr,
              textConfirm: 'yes'.tr,
              textCancel: 'no'.tr,
              onConfirm: () async {
                Get.back();
                await authCtrl.deleteAccount();
              },
            );
          },
          icon: const Icon(Icons.delete_forever),
          label: Text('delete_account'.tr),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.errorContainer,
            foregroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

