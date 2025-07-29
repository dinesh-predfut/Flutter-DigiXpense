import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/data/service.dart';

import '../widget/router/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(Controller());
  @override
  void initState() {
    super.initState();
    controller.emailController.addListener(() => setState(() {}));
    controller.passwordController.addListener(() => setState(() {}));
  }

  void handleLogin() async {
    setState(() {
      // controller.isLoading = true;
    });
    controller.signIn(context);
  }

  @override
  Widget build(BuildContext context) {
    // detect keyboard status
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100; 
     return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog instead of redirecting to login
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
      },
      child:Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 10, 112),
        body: Stack(
          children: [
            // Background Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: keyboardVisible ? 150 : 400,
              child: Image.asset(
                'assets/loginLogo.png',
                fit: BoxFit.cover,
              ),
            ),

            // Login Form Container
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: keyboardVisible
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Text("Login",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller.passwordController,
                      obscureText: !controller.passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(controller.passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => controller
                              .passwordVisible = !controller.passwordVisible),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: controller.rememberMe,
                          onChanged: (value) => setState(
                              () => controller.rememberMe = value ?? false),
                        ),
                        const Text("Remember me"),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.forgetPasswordurl);
                          },
                          child: const Text("Forgot password?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return SizedBox(
                        width: double.infinity, // Make button full width
                        child: GradientButton(
                          text: "Log in",
                          isLoading: controller.isLoadingLogin.value,
                          onPressed: handleLogin,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Or"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don’t have an account? "),
                        GestureDetector(
                          onTap: () {
                            controller.launchURL(
                                'https://app.digixpense.com/auth/register');
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ))
  );}
}
