import 'package:diginexa/core/comman/widgets/internetProvider.dart' show InternetProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final internet = Provider.of<InternetProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off,
                size: 90, color: Colors.grey),

            const SizedBox(height: 20),

            const Text(
              "No Internet Connection",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("Please check your mobile data or WiFi"),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                internet.checkInternet();
              },
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}