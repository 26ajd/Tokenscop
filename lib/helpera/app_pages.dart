import 'package:get/get.dart';
import '../screens/currency_details_view.dart';
import '../screens/splash_screen.dart';
import 'routes.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_screen.dart';
import '../controllers/auth_controller.dart';
import '../screens/home_view.dart';
import '../controllers/currency_controller.dart';

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
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: AppRoutes.CRYPTO,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CurrencyController());
      }),
    ),
    GetPage(
      name: AppRoutes.CRYPTO_DETAILS,
      page: () => const CurrencyDetailsView(),
    ),
  ];
}

