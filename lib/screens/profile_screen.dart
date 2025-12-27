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
                backgroundImage: NetworkImage(user.image),
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
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
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
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
          ],
        );
      }),
    );
  }
}
