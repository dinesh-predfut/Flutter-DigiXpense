import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      controller.loadSavedCredentials();
    controller.emailController.addListener(() => setState(() {}));
    controller.passwordController.addListener(() => setState(() {}));
  }

  bool get isFormValid {
    final email = controller.emailController.text.trim();
    final password = controller.passwordController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && password.isNotEmpty;
  }

  void handleLogin() async {
    setState(() {
      controller.isLoadingLogin.value = true;
    });
    await controller.signIn(context);
    setState(() {
      controller.isLoadingLogin.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, AppRoutes.login);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 10, 112),
        body: 
            LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
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
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: AbsorbPointer(
                              absorbing: controller.isLoadingLogin.value,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  const Text("Login",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    style:
                                        const TextStyle(color: Colors.black),
                                    controller: controller.emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email address',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      floatingLabelStyle:
                                          TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    style:
                                        const TextStyle(color: Colors.black),
                                    controller:
                                        controller.passwordController,
                                    obscureText:
                                        !controller.passwordVisible,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      floatingLabelStyle:
                                          const TextStyle(color: Colors.black),
                                      border: const OutlineInputBorder(),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.black,
                                        ),
                                        onPressed: () => setState(() =>
                                            controller.passwordVisible =
                                                !controller.passwordVisible),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: Colors.indigo,
                                        checkColor: Colors.white,
                                        value: controller.rememberMe,
                                        onChanged: controller
                                                .isLoadingLogin.value
                                            ? null
                                            : (value) {
                                                setState(() => controller
                                                        .rememberMe =
                                                    value ?? false);
                                                controller.saveCredentials();
                                              },
                                      ),
                                      const Text("Remember me",
                                          style: TextStyle(
                                              color: Colors.black)),
                                      const Spacer(),
                                      TextButton(
                                        onPressed:
                                            controller.isLoadingLogin.value
                                                ? null
                                                : () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes
                                                          .forgetPasswordurl,
                                                    );
                                                  },
                                        child: const Text("Forgot password?",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 42, 2, 117))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Obx(() {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: GradientButton(
                                        text: controller.isLoadingLogin.value
                                            ? "Logging in..."
                                            : "Log in",
                                        isLoading:
                                            controller.isLoadingLogin.value,
                                        onPressed: isFormValid
                                            ? handleLogin
                                            : () {},
                                        disabled: !isFormValid ||
                                            controller.isLoadingLogin.value,
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                  const Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text("Or",
                                            style: TextStyle(
                                                color: Colors.black)),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Text("Don’t have an account? ",
                                          style: TextStyle(
                                              color: Colors.black)),
                                      GestureDetector(
                                        onTap:
                                            controller.isLoadingLogin.value
                                                ? null
                                                : () {
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
        
      ),
    );
  }
}
