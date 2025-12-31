import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../helpera/constants.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;
  late Box settingsBox;
  final RxInt primaryColorValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    settingsBox = Hive.box(AppConstants.boxSettings);
    isDark.value = settingsBox.get(AppConstants.keyIsDark, defaultValue: false);
    final stored = settingsBox.get(AppConstants.keyPrimaryColor);
    if (stored != null && stored is int) {
      primaryColorValue.value = stored;
    } else {
      primaryColorValue.value = Colors.indigo.value;
      settingsBox.put(AppConstants.keyPrimaryColor, primaryColorValue.value);
    }
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    settingsBox.put(AppConstants.keyIsDark, isDark.value);
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(primaryColorValue.value),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(primaryColorValue.value),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  void setPrimaryColor(Color color) {
    primaryColorValue.value = color.value;
    settingsBox.put(AppConstants.keyPrimaryColor, primaryColorValue.value);
    Get.changeTheme(isDark.value ? darkTheme : lightTheme);
  }
}

