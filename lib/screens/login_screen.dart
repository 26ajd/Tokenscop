// ============================================
// ملف: login_screen.dart
// الوصف: واجهة تسجيل الدخول التي تدعم السمات واللغات المختلفة
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
import '../helpera/constants.dart';
import '../helpera/themes.dart';
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
// يتم جلب المتحكمات عبر Get.find للحفاظ على الحالة العالمية

// ----------------------------
// 5. الخدمات و API
// ----------------------------

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// واجهة تسجيل الدخول الرئيسية
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // المتحكمات والتحكم في المدخلات
  final usernameController = TextEditingController(text: AppConstants.demoUsername);
  final passwordController = TextEditingController(text: AppConstants.demoPassword);
  
  // حالة رؤية كلمة المرور (تفاعلية)
  final RxBool isObscure = true.obs;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // شريط الإعدادات العلوية (اللغة والثيم)
            _buildSettingsBar(themeController, localeController),
            
            // محتوى الواجهة المركزية
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogo(context),
                    const SizedBox(height: 32),
                    _buildWelcomeText(context),
                    const SizedBox(height: 48),
                    _buildLoginForm(context),
                    const SizedBox(height: 32),
                    _buildLoginButton(authController),
                    const SizedBox(height: 12),
                    _buildCreateAccountButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء زر تبديل اللغة والثيم
  Widget _buildSettingsBar(ThemeController themeCtrl, LocaleController localeCtrl) {
    return Positioned(
      top: 16,
      right: 16,
      child: Row(
        children: [
          Obx(() => IconButton(
                icon: Icon(themeCtrl.isDark.value ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeCtrl.toggleTheme(),
              )),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
                value: localeCtrl.locale.value.languageCode,
                underline: Container(),
                icon: const Icon(Icons.language),
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
        ],
      ),
    );
  }

  /// بناء شعار التطبيق
  Widget _buildLogo(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.attach_money_sharp,
        size: 80,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// بناء نصوص الترحيب
  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          'welcome_back'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'login_subtitle'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSubtle,
              ),
        ),
      ],
    );
  }

  /// بناء نموذج تسجيل الدخول (الحقول)
  Widget _buildLoginForm(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'username'.tr,
                hintText: 'username_hint'.tr,
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => TextField(
                  controller: passwordController,
                  obscureText: isObscure.value,
                  decoration: InputDecoration(
                    labelText: 'password'.tr,
                    hintText: 'password_hint'.tr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(isObscure.value ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => isObscure.toggle(),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// بناء زر الدخول
  Widget _buildLoginButton(AuthController authCtrl) {
    return Obx(() => SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: authCtrl.isLoading.value
                ? null
                : () => authCtrl.login(usernameController.text.trim(), passwordController.text.trim()),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: authCtrl.isLoading.value
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('login'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ));
  }

  /// بناء زر إنشاء حساب جديد
  Widget _buildCreateAccountButton() {
    return Center(
      child: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.REGISTER),
        child: Text('create_account'.tr),
      ),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

