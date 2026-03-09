import 'package:diginexa/core/comman/widgets/internetProvider.dart';
import 'package:diginexa/core/comman/widgets/noInternetPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class InternetWrapper extends StatelessWidget {
  final Widget child;

  const InternetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<InternetProvider>(
      builder: (_, internet, _) {
        return Stack(
          children: [
            child,

            /// ✅ INTERNET OVERLAY
            if (!internet.hasInternet)
              const Positioned.fill(
                child: NoInternetScreen(),
              ),
          ],
        );
      },
    );
  }
}