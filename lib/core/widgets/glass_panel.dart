import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Restrained Dark Glassmorphic Container Panel
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool hasGlow;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 1.0,
    this.onTap,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: content,
      );
    }

    return content;
  }
}
