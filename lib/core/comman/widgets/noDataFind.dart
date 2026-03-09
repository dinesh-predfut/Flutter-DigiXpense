import 'package:flutter/material.dart';

class CommonNoDataWidget extends StatefulWidget {
  final String? message;
  final IconData? icon;

  const CommonNoDataWidget({
    Key? key,
    this.message,
    this.icon,
  }) : super(key: key);

  @override
  State<CommonNoDataWidget> createState() => _CommonNoDataWidgetState();
}

class _CommonNoDataWidgetState extends State<CommonNoDataWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A11CB),
                      Color(0xFF2575FC),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  widget.icon ?? Icons.inbox_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              widget.message ?? "No Data Available",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Looks like there’s nothing here yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}