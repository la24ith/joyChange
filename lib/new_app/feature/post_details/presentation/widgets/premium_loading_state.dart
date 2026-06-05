// lib/features/post_details/presentation/widgets/premium_loading_state.dart

import 'package:flutter/material.dart';
import '../animations/shimmer_loading.dart';

class PremiumLoadingState extends StatelessWidget {
  const PremiumLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            flexibleSpace: const ShimmerLoading(
              child: SizedBox.expand(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading(
                    width: double.infinity,
                    height: 32,
                    borderRadius: 8,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const ShimmerLoading(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerLoading(
                              width: 120,
                              height: 14,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 8),
                            const ShimmerLoading(
                              width: 80,
                              height: 12,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const ShimmerLoading(
                        width: 60,
                        height: 24,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(
                        width: double.infinity,
                        height: index == 0 ? 18 : 14,
                        borderRadius: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
