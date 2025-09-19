import 'package:flutter/material.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool disabled; // ✅ NEW: optional disabled flag

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.disabled = false, // ✅ default is false
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0, // ✅ dim button when disabled
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? [Colors.grey.shade400, Colors.grey.shade500] // ✅ Disabled gradient
                : [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          borderRadius: AppColors.borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppColors.borderRadius,
            onTap: isDisabled ? null : onPressed, // ✅ Prevent taps if disabled
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
