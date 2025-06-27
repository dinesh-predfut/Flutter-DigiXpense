import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:flutter/material.dart';

class FullPageLoader extends StatelessWidget {
  const FullPageLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          // color: Colors.black.withOpacity(0.3),
          width: double.infinity,
          height: double.infinity,
        ),
        // Center loader with shadow
        Center(
          child: Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 6,
              color: AppColors.gradientEnd,
            ),
          ),
        ),
      ],
    );
  }
}
