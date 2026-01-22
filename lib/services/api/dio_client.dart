// ============================================
// ملف: dio_client.dart
// الوصف: عميل Dio المركزي للتعامل مع طلبات API مع اعتراض الطلبات والأخطاء
// التاريخ: 2024
// ============================================

// ----------------------------
// 1. الاستيرادات
// ----------------------------
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // مضاف لدعم الألوان في Snackbar
import 'package:get/get.dart' as getx;
import 'package:hive_flutter/hive_flutter.dart';
import '../../helpera/constants.dart';

// ----------------------------
// 2. الثوابت والإعدادات
// ----------------------------
// يتم جلب الإعدادات من AppConstants

// ----------------------------
// 3. النماذج والفئات
// ----------------------------

/// فئة مخصصة لمعالجة أخطاء API
class ApiError {
  final String message;
  final int? statusCode;

  ApiError({required this.message, this.statusCode});
}

// ----------------------------
// 4. المتحكمات وإدارة الحالة
// ----------------------------
// لا يوجد متحكمات في هذا الملف

// ----------------------------
// 5. الخدمات و API
// ----------------------------

/// عميل Dio للتعامل مع الطلبات الشبكية
/// يطبق نمط Singleton لضمان وجود نسخة واحدة في التطبيق
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _initializeDio();
  }

  /// تهيئة إعدادات Dio و Interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConstants.apiConnectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.apiReceiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
    
    // إضافة LogInterceptor للتصحيح في وضع التطوير
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  /// معالجة الطلب قبل إرساله (إضافة التوكن مثلاً)
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final settingsBox = Hive.box(AppConstants.boxSettings);
    final token = settingsBox.get(AppConstants.keyToken);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  /// معالجة الاستجابة فور وصولها
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  /// معالجة الأخطاء بشكل موحد
  void _onError(DioException e, ErrorInterceptorHandler handler) {
    String errorMessage = _handleDioError(e);
    
    // عرض رسالة خطأ للمستخدم باستخدام GetX
    getx.Get.snackbar(
      'خطأ في الاتصال',
      errorMessage,
      snackPosition: getx.SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    
    return handler.next(e);
  }

  /// تحويل أخطاء Dio إلى رسائل مفهومة بالعربية
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالخادم';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال الطلب';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال البيانات';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      default:
        return 'حدث خطأ غير متوقع في الاتصال';
    }
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400: return 'طلب غير صالح';
      case 401: return 'غير مصرح لك بالوصول';
      case 403: return 'الوصول ممنوع';
      case 404: return 'المورد غير موجود';
      case 500: return 'خطأ داخلي في الخادم';
      default: return 'فشل الاتصال: $statusCode';
    }
  }

  /// طلب GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  /// طلب POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}

// ----------------------------
// 6. الويدجتات والعناصر البصرية
// ----------------------------

// ----------------------------
// 7. إعداد التطبيق الرئيسي
// ----------------------------

