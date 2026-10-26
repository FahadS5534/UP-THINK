import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Upthink Restrained Geometric Logo / Wordmark
/// A crisp geometric node lattice emblem paired with editorial typography
class UpthinkLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final String? subtitle;

  const UpthinkLogo({
    super.key,
    this.size = 28,
    this.showWordmark = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Geometric Node Lattice Icon
        CustomPaint(
          size: Size(size, size),
          painter: _UpthinkGeometricPainter(),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UPTHINK',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  height: 1.0,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.textHighContrast,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _UpthinkGeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final subtleLinePaint = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final limeFill = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final darkFill = Paint()
      ..color = AppColors.canvas
      ..style = PaintingStyle.fill;

    // Outer equilateral triangle frame / node lattice
    final pTop = Offset(w * 0.5, h * 0.15);
    final pLeft = Offset(w * 0.15, h * 0.85);
    final pRight = Offset(w * 0.85, h * 0.85);
    final pCenter = Offset(w * 0.5, h * 0.55);

    // Connecting vectors
    canvas.drawLine(pTop, pLeft, linePaint);
    canvas.drawLine(pLeft, pRight, linePaint);
    canvas.drawLine(pRight, pTop, subtleLinePaint);
    canvas.drawLine(pTop, pCenter, linePaint);
    canvas.drawLine(pCenter, pLeft, subtleLinePaint);
    canvas.drawLine(pCenter, pRight, linePaint);

    // Nodes
    final rNode = w * 0.12;
    canvas.drawCircle(pTop, rNode, limeFill);
    canvas.drawCircle(pLeft, rNode, limeFill);
    canvas.drawCircle(pLeft, rNode * 0.5, darkFill);
    canvas.drawCircle(pRight, rNode, limeFill);
    canvas.drawCircle(pCenter, rNode * 0.8, darkFill);
    canvas.drawCircle(pCenter, rNode * 0.8, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
