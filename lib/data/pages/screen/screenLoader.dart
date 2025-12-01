import 'package:digi_xpense/core/constant/image.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logo_ScreenLanding extends StatefulWidget {
  const Logo_ScreenLanding({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<Logo_ScreenLanding> {
  @override
  void initState() {
    super.initState();
    // No need for _initApp here since main.dart handles routing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Images.logo,
                  width: 350,
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Smarter Business Expense Management",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
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