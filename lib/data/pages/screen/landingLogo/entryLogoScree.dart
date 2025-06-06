import 'dart:async';

import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/core/constant/image.dart';
import 'package:flutter/material.dart';

import '../widget/router/router.dart';

class Logo_Screen extends StatefulWidget {
  const Logo_Screen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<Logo_Screen> {
  @override
  void initState() {
    super.initState();

    // Redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 253, 253),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Images.logo,
                  width: 350, // Adjust size as needed
                  height: 100,
                ),
              
                const Text(
                  "Smarter Business Expense Management",
                  style: TextStyle(
                    fontSize: 12, 
                    color: Color.fromARGB(255, 8, 8, 8),
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
