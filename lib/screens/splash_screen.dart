// ============================================
// ملف: splash_screen.dart
// الوصف: واجهة الانطلاق للتطبيق، المسؤولة عن التحقق من حالة تسجيل الدخول والتوجه للشاشة المناسبة
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../helpera/routes.dart';

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

/// واجهة الانطلاق للتطبيق
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// التحقق من حالة المصادقة والتوجه للواجهة التالية
  Future<void> _checkAuthentication() async {
    // تأخير بسيط لعرض الشعار
    await Future.delayed(const Duration(seconds: 2));

    final AuthController authController = Get.find<AuthController>();

    if (authController.isLoggedIn) {
      Get.offAllNamed(AppRoutes.MAIN);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    // تشغيل عملية التحقق بمجرد بناء الواجهة
    _checkAuthentication();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق الأساسي
            Icon(
              Icons.attach_money_sharp,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            
            // اسم التطبيق
            Text(
              'TokenScope App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            
            // مؤشر التحميل
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

