import 'package:flutter/material.dart';


class ScaffoldWithNav extends StatefulWidget {
 final List<Widget> pages;
  const ScaffoldWithNav({super.key, required this.pages});

  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
