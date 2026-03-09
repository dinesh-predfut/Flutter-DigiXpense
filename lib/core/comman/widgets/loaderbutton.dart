import 'package:flutter/material.dart';

class CustomLoaderButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled; // ✅ NEW

  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const CustomLoaderButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.disabled = false, // ✅ NEW
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.height = 48,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: (isLoading || disabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey("loader"),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  key: const ValueKey("text"),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
  