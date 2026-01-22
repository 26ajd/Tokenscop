// ============================================
// ملف: register_screen.dart
// الوصف: واجهة إنشاء حساب جديد مع الحقول المطلوبة
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../helpera/constants.dart';
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

// ----------------------------
// 5. الخدمات و API
// ----------------------------

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

/// واجهة إنشاء الحساب
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  // التحكم في المدخلات
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  
  // حالة رؤية كلمة المرور
  final RxBool isObscure = true.obs;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('register'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              
              // حقول المدخلات
              _buildTextField(usernameController, 'username'.tr),
              const SizedBox(height: 12),
              _buildTextField(emailController, 'email'.tr),
              const SizedBox(height: 12),
              _buildTextField(firstNameController, 'first_name'.tr),
              const SizedBox(height: 12),
              _buildTextField(lastNameController, 'last_name'.tr),
              const SizedBox(height: 12),
              
              // حقل كلمة المرور مع خيار الإخفاء
              Obx(() => TextField(
                    controller: passwordController,
                    obscureText: isObscure.value,
                    decoration: InputDecoration(
                      labelText: 'password'.tr,
                      suffixIcon: IconButton(
                        icon: Icon(isObscure.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => isObscure.toggle(),
                      ),
                    ),
                  )),
                  
              const SizedBox(height: 24),
              
              // زر إنشاء الحساب
              _buildRegisterButton(authController),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء حقل نصي قياسي
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  /// بناء زر التسجيل مع التحقق من البيانات
  Widget _buildRegisterButton(AuthController authCtrl) {
    return ElevatedButton(
      onPressed: () async {
        final username = usernameController.text.trim();
        final password = passwordController.text.trim();
        final email = emailController.text.trim();
        final first = firstNameController.text.trim();
        final last = lastNameController.text.trim();
        
        if (username.isEmpty || password.isEmpty) {
          Get.snackbar('خطأ', 'please_fill_username_password'.tr, snackPosition: SnackPosition.BOTTOM);
          return;
        }

        await authCtrl.registerLocal(
          username: username,
          password: password,
          email: email.isEmpty ? '$username@example.com' : email,
          firstName: first.isEmpty ? username : first,
          lastName: last.isEmpty ? '' : last,
        );
      },
      child: Text('create_account'.tr),
    );
  }
}

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

