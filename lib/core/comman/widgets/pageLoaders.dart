import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shimmer/shimmer.dart';

class SkeletonLoaderPage extends StatefulWidget {
  const SkeletonLoaderPage({super.key});

  @override
  State<SkeletonLoaderPage> createState() => _SkeletonLoaderPageState();
}

class _SkeletonLoaderPageState extends State<SkeletonLoaderPage> {
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    // Auto stop the shimmer after 10 seconds
    // Future.delayed(const Duration(seconds: 40), () {
    //   if (mounted) {
    //     setState(() {
    //       _isActive = false;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) {
      return const Center(
        child: Text(
          "Loading took too long...",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200, // 👈 background color here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header block
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),

              // Title placeholder
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),

              // Paragraph placeholder lines
              ...List.generate(6, (index) {
                double lineWidth = index.isEven
                    ? MediaQuery.of(context).size.width * 0.9
                    : MediaQuery.of(context).size.width * 0.7;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    height: 14,
                    width: lineWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Bottom buttons placeholder
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
