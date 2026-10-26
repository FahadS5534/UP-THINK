import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Editorial Obsidian & Acid Lime Typography System
/// Headings, Metrics & Labels: Space Grotesk
/// Body & Longform: DM Sans
class AppTypography {
  AppTypography._();

  // Space Grotesk Styles
  static TextStyle displayLg = GoogleFonts.spaceGrotesk(
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 64 / 56,
    letterSpacing: -1.68,
    color: AppColors.textHighContrast,
  );

  static TextStyle displayLgMobile = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: AppColors.textHighContrast,
  );

  static TextStyle headlineLg = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 40 / 32,
    letterSpacing: -0.64,
    color: AppColors.textHighContrast,
  );

  static TextStyle headlineLgMobile = GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 32 / 26,
    letterSpacing: -0.26,
    color: AppColors.textHighContrast,
  );

  static TextStyle headlineMd = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 30 / 24,
    letterSpacing: -0.24,
    color: AppColors.textHighContrast,
  );

  static TextStyle headlineSm = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 26 / 20,
    color: AppColors.textHighContrast,
  );

  static TextStyle metricNumeral = GoogleFonts.spaceGrotesk(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 48 / 44,
    letterSpacing: -0.88,
    color: AppColors.textHighContrast,
  );

  static TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 16 / 13,
    letterSpacing: 0.26,
    color: AppColors.textHighContrast,
  );

  static TextStyle labelSm = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.66,
    color: AppColors.textMediumContrast,
  );

  // DM Sans Body Styles
  static TextStyle bodyLg = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textHighContrast,
  );

  static TextStyle bodyMd = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textHighContrast,
  );

  static TextStyle bodySm = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textMediumContrast,
  );
}
