import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final int itemCount;

  const ShimmerLoading({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.card,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
