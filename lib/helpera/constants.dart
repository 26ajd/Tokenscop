class AppConstants {
  // API
  static const String apiBaseUrl = 'https://dummyjson.com';
  static const int apiConnectTimeout = 10; // seconds
  static const int apiReceiveTimeout = 10; // seconds
  static const String loginEndpoint = '/auth/login';

  // Hive Boxes
  static const String boxTasks = 'tasks';
  static const String boxCategories = 'categories';
  static const String boxSettings = 'settings';

  // Hive Keys
  static const String keyToken = 'accessToken';
  static const String keyUser = 'user_data';
  static const String keyIsDark = 'isDark';
  static const String keyLanguage = 'language';

  // Defaults / Demo
  static const String demoUsername = 'emilys';
  static const String demoPassword = 'emilyspass';
}
