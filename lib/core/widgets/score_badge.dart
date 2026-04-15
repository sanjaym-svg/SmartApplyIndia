import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_colors.dart';

class ScoreBadge extends StatelessWidget {
  final double score;
  final double radius;
  final double lineWidth;
  final bool showLabel;

  const ScoreBadge({
    super.key,
    required this.score,
    this.radius = 28,
    this.lineWidth = 4,
    this.showLabel = true,
  });

  Color get _scoreColor {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  LinearGradient get _scoreGradient {
    if (score >= 75) return AppColors.scoreHighGradient;
    if (score >= 50) return AppColors.scoreMedGradient;
    return AppColors.scoreLowGradient;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: (score / 100).clamp(0.0, 1.0),
          center: Text(
            '${score.toInt()}%',
            style: TextStyle(
              fontSize: radius * 0.42,
              fontWeight: FontWeight.w700,
              color: _scoreColor,
            ),
          ),
          backgroundColor: AppColors.surfaceLight,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1200,
          linearGradient: _scoreGradient,
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            'ATS Match',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
