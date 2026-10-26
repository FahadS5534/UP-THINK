import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_panel.dart';

/// Reusable Analytical Metric Card
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? subtitle;
  final Widget? trailingIcon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.subtitle,
    this.trailingIcon,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTypography.labelSm.copyWith(
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              ?trailingIcon,
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textHighContrast,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit!,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textMediumContrast,
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.bodySm.copyWith(
                fontSize: 11,
                color: AppColors.textLowContrast,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
