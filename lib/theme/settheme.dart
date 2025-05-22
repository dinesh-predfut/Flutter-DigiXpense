import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:digi_xpense/theme/theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Customize Theme Color")),
      body: GridView.count(
        crossAxisCount: 4,
        padding: const EdgeInsets.all(16),
        children: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.brown,
          Colors.teal,
          Colors.indigo,
        ].map((color) {
          return GestureDetector(
            onTap: () => themeNotifier.setColor(color),
            child: Container(
              margin: const EdgeInsets.all(8),
              color: color,
            ),
          );
        }).toList(),
      ),
    );
  }
}
