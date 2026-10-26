import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum GapSeverity { high, medium, low }

/// Reusable Academic Severity Badge / Chip
class SeverityBadge extends StatelessWidget {
  final GapSeverity severity;
  final String? customLabel;
  final bool showDot;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.customLabel,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String defaultLabel;

    switch (severity) {
      case GapSeverity.high:
        textColor = AppColors.highRisk;
        bgColor = AppColors.highRiskBg;
        borderColor = AppColors.highRiskBorder;
        defaultLabel = 'HIGH RISK';
        break;
      case GapSeverity.medium:
        textColor = AppColors.mediumRisk;
        bgColor = AppColors.mediumRiskBg;
        borderColor = AppColors.mediumRiskBorder;
        defaultLabel = 'MEDIUM RISK';
        break;
      case GapSeverity.low:
        textColor = AppColors.lowRisk;
        bgColor = AppColors.lowRiskBg;
        borderColor = AppColors.lowRiskBorder;
        defaultLabel = 'LOW RISK';
        break;
    }

    final label = customLabel ?? defaultLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSm.copyWith(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
