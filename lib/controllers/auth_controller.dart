// ============================================
// ملف: auth_controller.dart
// الوصف: المتحكم المسؤول عن عمليات المصادقة، تسجيل الدخول، والتحكم في بيانات المستخدم
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../services/api/dio_client.dart';
import '../helpera/routes.dart';
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

/// متحكم المصادقة
/// يدير حالة تسجيل الدخول وبيانات المستخدم المسجل
class AuthController extends GetxController {
  // --- العملاء والمصادر (Internal Dependencies) ---
  final _dioClient = DioClient();
  final _settingsBox = Hive.box(AppConstants.boxSettings);

  // --- متغيرات الحالة (Reactive State) ---
  final isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  /// تحميل بيانات المستخدم المخزنة محلياً عند تشغيل التطبيق
  void _loadUserFromStorage() {
    final userJson = _settingsBox.get(AppConstants.keyUser);
    if (userJson != null) {
      try {
        currentUser.value = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        Get.log('فشل في تحليل بيانات المستخدم: $e');
      }
    }
  }

  /// التحقق من حالة تسجيل الدخول
  bool get isLoggedIn => _settingsBox.get(AppConstants.keyToken) != null;

  // ----------------------------
  // 5. الخدمات و API
  // ----------------------------

  /// عملية تسجيل الدخول عبر API
  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await _dioClient.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final token = response.data[AppConstants.keyToken];
        if (token != null) {
          // حفظ التوكن
          await _settingsBox.put(AppConstants.keyToken, token);

          // حفظ بيانات المستخدم
          final user = UserModel.fromJson(response.data);
          await _settingsBox.put(AppConstants.keyUser, jsonEncode(user.toJson()));
          currentUser.value = user;

          // الانتقال للواجهة الرئيسية
          Get.offAllNamed(AppRoutes.MAIN);
          
          Get.snackbar(
            'تم تسجيل الدخول',
            'مرحباً بك مجدداً',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ في الدخول',
        'فشل تسجيل الدخول: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج وحذف البيانات
  Future<void> logout() async {
    await _settingsBox.delete(AppConstants.keyToken);
    await _settingsBox.delete(AppConstants.keyUser);
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  /// حذف الحساب (تجريبي)
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _settingsBox.delete(AppConstants.keyToken);
      await _settingsBox.delete(AppConstants.keyUser);
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
      
      Get.snackbar(
        'حذف الحساب',
        'account_deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successContainer,
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'delete_failed'.tr + ': ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل حساب محلي (لأغراض التجربة)
  Future<void> registerLocal({
    required String username,
    required String password,
    required String email,
    String firstName = '',
    String lastName = '',
  }) async {
    try {
      isLoading.value = true;
      final token = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000);

      final user = UserModel(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: '',
        image: '',
      );

      await _settingsBox.put(AppConstants.keyToken, token);
      await _settingsBox.put(AppConstants.keyUser, jsonEncode(user.toJson()));
      currentUser.value = user;

      Get.offAllNamed(AppRoutes.MAIN);
      
      Get.snackbar(
        'تم بنجاح',
        'تم إنشاء حساب محلي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successContainer,
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إنشاء الحساب: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------
