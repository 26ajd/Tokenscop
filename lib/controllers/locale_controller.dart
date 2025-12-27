import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../helpera/constants.dart';

class LocaleController extends GetxController {
  final locale = const Locale('en', 'US').obs;
  late Box settingsBox;

  @override
  void onInit() {
    super.onInit();
    settingsBox = Hive.box(AppConstants.boxSettings);
    final savedLang =
        settingsBox.get(AppConstants.keyLanguage, defaultValue: 'en');
    locale.value =
        savedLang == 'ar' ? const Locale('ar', 'SA') : const Locale('en', 'US');
  }

  void changeToEnglish() {
    locale.value = const Locale('en', 'US');
    settingsBox.put(AppConstants.keyLanguage, 'en');
    Get.updateLocale(locale.value);
  }

  void changeToArabic() {
    locale.value = const Locale('ar', 'SA');
    settingsBox.put(AppConstants.keyLanguage, 'ar');
    Get.updateLocale(locale.value);
  }

  bool get isArabic => locale.value.languageCode == 'ar';
}
