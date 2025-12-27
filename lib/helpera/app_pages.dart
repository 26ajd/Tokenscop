import 'package:get/get.dart';
import 'routes.dart';
import '../screens/task_list_screen.dart';
import '../screens/category_list_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../controllers/task_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/auth_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TaskController());
        Get.lazyPut(() => CategoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.TASKS,
      page: () => const TaskListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TaskController());
        Get.lazyPut(() => CategoryController());
      }),
    ),
    GetPage(
      name: AppRoutes.CATEGORIES,
      page: () => const CategoryListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CategoryController());
        Get.lazyPut(() => TaskController());
      }),
    ),
  ];
}
