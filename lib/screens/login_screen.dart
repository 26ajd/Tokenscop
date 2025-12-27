import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/locale_controller.dart';
import '../helpera/constants.dart';
import '../helpera/themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController =
      TextEditingController(text: AppConstants.demoUsername);
  final TextEditingController passwordController =
      TextEditingController(text: AppConstants.demoPassword);

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top Controls (Theme/Language)
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  Obx(() => IconButton(
                        icon: Icon(themeController.isDark.value
                            ? Icons.light_mode
                            : Icons.dark_mode),
                        onPressed: () => themeController.toggleTheme(),
                      )),
                  const SizedBox(width: 8),
                  Obx(() => DropdownButton<String>(
                        value: localeController.locale.value.languageCode,
                        underline: Container(), // Remove underline
                        icon: const Icon(Icons.language),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('EN')),
                          DropdownMenuItem(value: 'ar', child: Text('AR')),
                        ],
                        onChanged: (val) {
                          if (val == 'en') {
                            localeController.changeToEnglish();
                          } else {
                            localeController.changeToArabic();
                          }
                        },
                      )),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon/Logo
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome Text
                    Text(
                      'welcome_back'.tr,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'login_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSubtle,
                          ),
                    ),
                    const SizedBox(height: 48),

                    // Inputs Card
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'username'.tr,
                                hintText: 'username_hint'.tr,
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'password'.tr,
                                hintText: 'password_hint'.tr,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                              ),
                              obscureText: _isObscure,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    Obx(() => SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () {
                                    authController.login(
                                      usernameController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: authController.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'login'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
