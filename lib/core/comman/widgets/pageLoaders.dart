import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoaderPage extends StatefulWidget {
  const SkeletonLoaderPage({super.key});

  @override
  State<SkeletonLoaderPage> createState() => _SkeletonLoaderPageState();
}

class _SkeletonLoaderPageState extends State<SkeletonLoaderPage> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isActive) {
      return const Center(
        child: Text(
          "Loading took too long...",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
            baseColor: theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            highlightColor: theme.brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header block
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(height: 24),

                /// Title
                Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 16),

                /// Paragraph lines
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
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                /// Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}