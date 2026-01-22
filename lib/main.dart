// ============================================
// ملف: main.dart
// الوصف: نقطة الانطلاق للتطبيق، تهيئة الخدمات، وإعداد GetMaterialApp
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
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

/// تهيئة الخدمات الأساسية قبل تشغيل التطبيق
Future<void> _initializeServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.boxSettings);

  // حقن المتحكمات الأساسية (Global Controllers)
  Get.put(ThemeController(), permanent: true);
  Get.put(LocaleController(), permanent: true);
  Get.put(AuthController(), permanent: true);
}

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// الويدجت الجذري للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeCtrl = Get.find<ThemeController>();
      
      return GetMaterialApp(
        title: 'TokenScope App',
        debugShowCheckedModeBanner: false,
        
        // إعدادات الثيمات
        theme: themeCtrl.lightTheme,
        darkTheme: themeCtrl.darkTheme,
        themeMode: themeCtrl.themeMode,
        
        // إعدادات اللغات والترجمة
        translations: AppTranslations(),
        locale: Get.find<LocaleController>().locale.value,
        fallbackLocale: const Locale('en', 'US'),
        
        // إعدادات المسارات (Routing)
        initialRoute: AppRoutes.SPLASH,
        getPages: AppPages.pages,
      );
    });
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

void main() async {
  // تنفيذ التهيئة
  await _initializeServices();
  
  // تشغيل واجهة المستخدم
  runApp(const MyApp());
}

