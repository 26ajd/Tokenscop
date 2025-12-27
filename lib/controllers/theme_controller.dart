import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../helpera/constants.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;
  late Box settingsBox;

  @override
  void onInit() {
    super.onInit();
    settingsBox = Hive.box(AppConstants.boxSettings);
    isDark.value = settingsBox.get(AppConstants.keyIsDark, defaultValue: false);
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    settingsBox.put(AppConstants.keyIsDark, isDark.value);
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;
}
