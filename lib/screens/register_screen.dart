import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../helpera/constants.dart';
import '../helpera/themes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('register'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'username'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'email'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'first_name'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'last_name'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'password'.tr,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();
                  final email = emailController.text.trim();
                  final first = firstNameController.text.trim();
                  final last = lastNameController.text.trim();
                  if (username.isEmpty || password.isEmpty) {
                    Get.snackbar('Error', 'please_fill_username_password'.tr,
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  await authController.registerLocal(
                    username: username,
                    password: password,
                    email: email.isEmpty ? '$username@example.com' : email,
                    firstName: first.isEmpty ? username : first,
                    lastName: last.isEmpty ? '' : last,
                  );
                },
                child: Text('create_account'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

