import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digi_xpense/core/comman/widgets/button.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();

  Timer? resendTimer;

  void handleSendLink() async {
    if (!_formKey.currentState!.validate()) return; // ✅ validate before API call

    if (controller.resendCountdown.value == 0) {
      controller.forgotisLoading.value = true;

      try {
        await controller.sendForgetPassword(context);
        startResendCountdown();
      } catch (e) {
        debugPrint("Error sending link: $e");
      } finally {
        controller.forgotisLoading.value = false;
      }
    }
  }

  void startResendCountdown() {
    controller.resendCountdown.value = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (controller.resendCountdown.value > 0) {
        controller.resendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 10, 112),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: keyboardVisible ? 150 : 400,
            child: Image.asset(
              'assets/forgetPassword.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: keyboardVisible
                  ? MediaQuery.of(context).size.height * 0.7
                  : MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: _formKey, // ✅ wrap with Form
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Don’t worry! It happens. Please enter the email associated with your account.",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email address',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: controller.forgotemailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: 'Enter your email',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return "Enter a valid email address";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final bool isLoading = controller.forgotisLoading.value;
                      final bool isButtonDisabled =
                          controller.resendCountdown.value > 0 || isLoading;

                      String buttonText;
                      if (controller.resendCountdown.value > 0) {
                        buttonText =
                            "Resend in ${controller.resendCountdown.value}s";
                      } else {
                        buttonText = "Send Link";
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: buttonText,
                          isLoading: isLoading,
                         onPressed: isButtonDisabled ? () {} : handleSendLink,)

                      );
                    }),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Remember password?",
                            style: TextStyle(color: Colors.black)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signin);
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
