import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

class AppColors {
  static const primary = Colors.deepPurple;
  static const white = Colors.white;
  static const transparent = Colors.transparent;

  // Semantic
  static const error = Colors.red;
  static const success = Colors.green;
  static const warning = Colors.orange;
  static const info = Colors.blue;

  // Shades
  static const textSubtle = Colors.grey;
  static final iconSubtle = Colors.grey[400];
  static final textSubtleDark = Colors.grey[600];

  // Backgrounds
  static final errorContainer = Colors.red.withOpacity(0.1);
  static final successContainer = Colors.green.withOpacity(0.1);
}

const categoryColors = [
  Color(0xFFEF5350),
  Color(0xFFEC407A),
  Color(0xFFAB47BC),
  Color(0xFF7E57C2),
  Color(0xFF5C6BC0),
  Color(0xFF42A5F5),
  Color(0xFF26C6DA),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFFFF7043),
];
