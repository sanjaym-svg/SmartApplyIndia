import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/job_model.dart';
import '../theme/app_colors.dart';
import 'score_badge.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final int index;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onBookmark,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Company + Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      job.company.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Score badge
                ScoreBadge(score: job.matchScore, radius: 24, lineWidth: 3.5),
              ],
            ),
            const SizedBox(height: 14),
            // Location + Salary + Time
            Row(
              children: [
                const Icon(Iconsax.location, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    job.location,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Iconsax.money_2, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  job.salaryRange,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const Spacer(),
                Text(
                  job.timeAgo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags row
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (job.isRemote)
                        _buildTag('Remote', AppColors.tagRemote),
                      if (job.isFresher)
                        _buildTag('Fresher', AppColors.tagFresher),
                      ...job.tags.take(3).map(
                            (tag) =>
                                _buildTag(tag, AppColors.primary),
                          ),
                    ],
                  ),
                ),
                // Bookmark
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    job.isBookmarked ? Iconsax.bookmark_25 : Iconsax.bookmark,
                    color: job.isBookmarked ? AppColors.accent : AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: (index * 80).ms,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 400.ms,
          delay: (index * 80).ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
