import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/locale_controller.dart';
import '../helpera/themes.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSubtle,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              title: Text('theme'.tr),
              trailing: Obx(() => Switch(
                    value: themeController.isDark.value,
                    onChanged: (_) => themeController.toggleTheme(),
                  )),
            ),
            ListTile(
              title: Text('language'.tr),
              trailing: Obx(() => DropdownButton<String>(
                    value: localeController.locale.value.languageCode,
                    items: [
                      DropdownMenuItem(value: 'en', child: Text('english'.tr)),
                      DropdownMenuItem(value: 'ar', child: Text('arabic'.tr)),
                    ],
                    onChanged: (val) {
                      if (val == 'en') {
                        localeController.changeToEnglish();
                      } else {
                        localeController.changeToArabic();
                      }
                    },
                  )),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('accent_color'.tr,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: Obx(() {
                      final current =
                          Color(themeController.primaryColorValue.value);
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryColors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final c = categoryColors[index];
                          final isSelected = c.value == current.value;
                          return GestureDetector(
                            onTap: () => themeController.setPrimaryColor(c),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        width: 3)
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
            ),
            const Divider(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => authController.logout(),
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
                    await authController.deleteAccount();
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
      }),
    );
  }
}

