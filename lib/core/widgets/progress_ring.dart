import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable Circular Progress Ring
class ProgressRing extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final String? centerLabel;
  final String? centerSubLabel;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.strokeWidth = 8,
    this.progressColor = AppColors.primary,
    this.trackColor = AppColors.surfaceContainerHighest,
    this.centerLabel,
    this.centerSubLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: trackColor,
            ),
          ),
          if (centerLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (centerSubLabel != null)
                  Text(
                    centerSubLabel!.toUpperCase(),
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 9,
                      color: AppColors.textMediumContrast,
                      letterSpacing: 0.8,
                    ),
                  ),
                Text(
                  centerLabel!,
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: size > 80 ? 18 : 14,
                    color: AppColors.textHighContrast,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
