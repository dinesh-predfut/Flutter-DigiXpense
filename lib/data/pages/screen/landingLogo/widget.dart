import 'dart:async';
import 'package:flutter/material.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> pages = [
    {
      "title": "Track Expenses",
      "subtitle": "your smart way to track and manage spending.",
      "image": "assets/landing.png",
    },
    {
      "title": "Manage Activity",
      "subtitle": "Monitor your daily expenses easily.",
      "image": "assets/landing2.png",
    },
    {
      "title": "Set Budget Goals",
      "subtitle": "Stay within your budget with smart tracking.",
      "image": "assets/landing3.png",
    },
    {
      "title": "Get Insights",
      "subtitle": "Visualize your spending habits with reports.",
      "image": "assets/landing4.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < pages.length - 1) {
        _currentIndex++;
        _controller.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _currentIndex = 0;
        // _controller.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

   // ignore: deprecated_member_use
   return WillPopScope(
    onWillPop: () async {
      SystemNavigator.pop(); // exits the app
      return false; // prevent further navigation
    },
    child:Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Welcome to digiXpense",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            page['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            page['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Image.asset(
                            page['image']!,
                            height: size.height * 0.35,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Page Indicator
                Positioned(
                  bottom: 160,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: pages.length,
                      effect: WormEffect(
                        dotColor: Colors.grey.shade300,
                        activeDotColor: Colors.purple,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                  ),
                ),

                // Bottom Gradient + Button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF5E0BC6),
                            Color.fromARGB(255, 15, 15, 15)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 247, 6, 166),
                                Color.fromARGB(255, 236, 134, 134)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.signin); // ✅
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Let’s Start",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 40);

    path.quadraticBezierTo(
        size.width * 0.25, 0, size.width * 0.5, 40); // First curve
    path.quadraticBezierTo(
        size.width * 0.75, 80, size.width, 40); // Second curve

    path.lineTo(size.width, 0); // Right corner
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
