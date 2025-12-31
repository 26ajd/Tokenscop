import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/theme_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/auth_controller.dart';
import 'helpera/themes.dart';
import 'helpera/translations.dart';
import 'helpera/routes.dart';
import 'helpera/app_pages.dart';
import 'helpera/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.boxSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());
    Get.put(LocaleController());
    Get.put(AuthController());

    return Obx(() {
      final themeCtrl = Get.find<ThemeController>();
      return GetMaterialApp(
        title: 'TokenScope App',
        debugShowCheckedModeBanner: false,
        theme: themeCtrl.lightTheme,
        darkTheme: themeCtrl.darkTheme,
        themeMode: themeCtrl.themeMode,
        translations: AppTranslations(),
        locale: Get.find<LocaleController>().locale.value,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppRoutes.SPLASH,
        getPages: AppPages.pages,
      );
    });
  }
}

