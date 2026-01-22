// ============================================
// ملف: image_service.dart
// الوصف: خدمة معالجة روابط الصور، خاصة لحل مشاكل CORS في متصفحات الويب
// التاريخ: 2024
// ============================================

import 'package:flutter/foundation.dart';

class ImageService {
  /// بروكسي مجاني لتجاوز قيود CORS (لأغراض التطوير)
  static const String _corsProxy = 'https://corsproxy.io/?';

  /// معالجة الرابط ليناسب المنصة الحالية
  static String getImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) return '';
    
    // إذا كنان في بيئة الويب، نقوم بإضافة البروكسي لتجاوز CORS
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(originalUrl)}';
    }
    
    return originalUrl;
  }
}
