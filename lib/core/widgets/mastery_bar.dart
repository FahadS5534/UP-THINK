import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Mastery Progress Bar with optional 75% goal indicator
class MasteryBar extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final double height;
  final Color? barColor;
  final Color backgroundColor;
  final bool showTargetGoal;
  final double targetPercentage;

  const MasteryBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.barColor,
    this.backgroundColor = AppColors.surfaceContainerHighest,
    this.showTargetGoal = false,
    this.targetPercentage = 75.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = barColor ??
        (percentage >= 75
            ? AppColors.primary
            : percentage >= 50
                ? AppColors.mediumRisk
                : AppColors.highRisk);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final fillWidth = (totalWidth * (percentage / 100.0)).clamp(0.0, totalWidth);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              width: totalWidth,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progress fill
            Container(
              width: fillWidth,
              height: height,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Target Goal Line
            if (showTargetGoal) ...[
              Positioned(
                left: totalWidth * (targetPercentage / 100.0),
                top: -4,
                bottom: -4,
                child: Container(
                  width: 2,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Linear topic mastery item with topic name, percentage label, delta, and bar
class TopicMasteryRow extends StatelessWidget {
  final String title;
  final double percentage;
  final double? delta;
  final Color? color;

  const TopicMasteryRow({
    super.key,
    required this.title,
    required this.percentage,
    this.delta,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (percentage >= 75
            ? AppColors.lowRisk
            : percentage >= 50
                ? AppColors.mediumRisk
                : AppColors.highRisk);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHighContrast,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: effectiveColor,
                  ),
                ),
                if (delta != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    delta! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: delta! >= 0 ? AppColors.primary : AppColors.highRisk,
                  ),
                  Text(
                    '${delta!.abs().toInt()}%',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: delta! >= 0 ? AppColors.primary : AppColors.highRisk,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        MasteryBar(
          percentage: percentage,
          height: 6,
          barColor: effectiveColor,
        ),
      ],
    );
  }
}
