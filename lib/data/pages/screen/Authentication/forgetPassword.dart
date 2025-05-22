import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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

  void handlesend() async {
    setState(() {
      controller.forgotisLoading = true;
    });
    controller.sendForgetPassword(context);
  }

  @override
  Widget build(BuildContext context) {
    // detect keyboard status
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 100;

    return Scaffold(
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
                'assets/forgetPassword.png',
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
                    : MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Text("Forget Password",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold,color: Colors.black)),
                    const SizedBox(height: 10),
                    const Text(
                        "Don’t worry! It happens. Please enter the email associated with your account.",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.forgotemailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: 'Enter your email',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Make button full width
                      child: GradientButton(
                        text: "Send Link",
                        isLoading: controller.forgotisLoading,
                        onPressed: handlesend,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                        mainAxisAlignment:MainAxisAlignment.center ,
                        children: [
                          const Text("Remember password?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.signin); // ✅
                            },
                            child: const Text("Login"),
                          ),
                        ],
                      ),
                    
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
