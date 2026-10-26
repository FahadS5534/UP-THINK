import 'package:flutter/material.dart';

/// Editorial Obsidian & Acid Lime Design System Colors
/// Authoritative palette defined in DESIGN.md
class AppColors {
  AppColors._();

  // Canvas & Base Surfaces
  static const Color canvas = Color(0xFF10110F);
  static const Color background = Color(0xFF131412);
  static const Color surface = Color(0xFF131412);
  static const Color surfaceContainerLowest = Color(0xFF0D0E0D);
  static const Color surfaceContainerLow = Color(0xFF1B1C1A);
  static const Color surfaceContainer = Color(0xFF1F201E);
  static const Color surfaceContainerHigh = Color(0xFF292A28);
  static const Color surfaceContainerHighest = Color(0xFF343533);
  static const Color surfaceBright = Color(0xFF393937);

  // Primary Acid Lime Accent
  static const Color primary = Color(0xFFC8F169);
  static const Color primaryFixed = Color(0xFFC8F169);
  static const Color primaryFixedDim = Color(0xFFADD450);
  static const Color onPrimary = Color(0xFF10110F);
  static const Color onPrimaryFixed = Color(0xFF10110F);
  static const Color primaryContainer = Color(0xFFC8F169);
  static const Color onPrimaryContainer = Color(0xFF263500);

  // Secondary Muted Amber
  static const Color secondary = Color(0xFFD5A879);
  static const Color secondaryFixed = Color(0xFFEDBE8D);
  static const Color onSecondary = Color(0xFF462A06);
  static const Color secondaryContainer = Color(0xFF63421C);
  static const Color onSecondaryContainer = Color(0xFFDEB080);

  // Tertiary Soft Green
  static const Color tertiary = Color(0xFFFFFFFF);
  static const Color tertiaryFixed = Color(0xFFCCEDAC);
  static const Color tertiaryContainer = Color(0xFFCCEDAC);
  static const Color onTertiaryContainer = Color(0xFF506C38);

  // Academic Risk & Diagnostic Severity
  static const Color highRisk = Color(0xFFE98278);
  static const Color highRiskBg = Color(0x26E98278); // 15% opacity
  static const Color highRiskBorder = Color(0x4DE98278);

  static const Color mediumRisk = Color(0xFFE6BC72);
  static const Color mediumRiskBg = Color(0x26E6BC72);
  static const Color mediumRiskBorder = Color(0x4DE6BC72);

  static const Color lowRisk = Color(0xFFA9C98B);
  static const Color lowRiskBg = Color(0x26A9C98B);
  static const Color lowRiskBorder = Color(0x4DA9C98B);

  // Error States
  static const Color error = Color(0xFFE98278);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);

  // Editorial Typography & Text Shades
  static const Color textHighContrast = Color(0xFFF0F0E7);
  static const Color textMediumContrast = Color(0xFFA2A69A);
  static const Color textLowContrast = Color(0xFF70766B);
  static const Color onSurface = Color(0xFFE4E2DE);
  static const Color onSurfaceVariant = Color(0xFFC4C9B2);

  // Glassmorphic Perimeter Strokes & Outlines
  static const Color glassBorder = Color(0x1AEBEFDD); // rgba(235, 239, 221, 0.10)
  static const Color glassBorderHover = Color(0x59C8F169); // rgba(200, 241, 105, 0.35)
  static const Color outline = Color(0xFF8E937E);
  static const Color outlineVariant = Color(0xFF444938);
}
