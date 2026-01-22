// ============================================
// ملف: main_screen.dart
// الوصف: الشاشة الرئيسية التي تحتوي على شريط التنقل السفلي والتبديل بين الواجهات
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_view.dart';
import 'profile_screen.dart';
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

/// واجهة التحكم الرئيسية بالتنقل
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام RxInt للتحكم في الفهرس الحالي بشكل تفاعلي
    final RxInt currentIndex = 0.obs;

    final List<Widget> pages = [
      HomeView(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // التبديل بين الصفحات مع الحفاظ على حالتها
      body: Obx(() => IndexedStack(
            index: currentIndex.value,
            children: pages,
          )),
          
      // شريط التنقل السفلي
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) {
              currentIndex.value = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.list),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: 'profile'.tr,
              ),
            ],
          )),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

