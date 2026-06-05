// lib/features/weight_tracking/presentation/widgets/weight_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WeightSkeleton extends StatelessWidget {
  const WeightSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSkeletonCard(height: 180),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 120),
          const SizedBox(height: 16),
          _buildSkeletonGrid(),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 300),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 80),
          const SizedBox(height: 16),
          _buildSkeletonCard(height: 80),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => _buildSkeletonCard(height: 100)),
    );
  }
}
