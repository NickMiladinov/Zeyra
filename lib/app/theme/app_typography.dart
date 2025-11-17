import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeyra/app/theme/app_colors.dart';

/// Application typography system.
/// 
/// Uses Google Fonts for Manrope (headings) and IBM Plex Sans (body text).
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES (via Google Fonts)
  // ============================================================================
  /// Primary font family for the app (Manrope)
  static const String primaryFontFamily = 'Manrope';
  
  /// Secondary font family (IBM Plex Sans)
  static const String secondaryFontFamily = 'IBM Plex Sans';
  
  /// Monospace font for code or data display
  static const String monospaceFontFamily = 'Courier New';

  // ============================================================================
  // DISPLAY STYLES (Largest text)
  // ============================================================================
  /// Display Large - Used for hero sections, onboarding
  static TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.3, // Line height ratio (Figma line height / font size)
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Display Medium
  static TextStyle displayMedium = GoogleFonts.manrope(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // HEADLINE STYLES (Large headings)
  // ============================================================================
  /// Headline Large - Main screen titles
  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - Section headers
  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Small - Subsection headers
  static TextStyle headlineSmall = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Extra Small - Subsection headers
  static TextStyle headlineExtraSmall = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BODY STYLES (Default text)
  // ============================================================================
  /// Body Large - Main content text (larger)
  static TextStyle bodyLarge = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Medium - Standard body text
  static TextStyle bodyMedium = GoogleFonts.ibmPlexSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Small - Secondary body text
  static TextStyle bodySmall = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // LABEL STYLES (Buttons, tabs, form labels)
  // ============================================================================
  /// Label Large - Large buttons, prominent labels
  static TextStyle labelLarge = GoogleFonts.ibmPlexSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Medium - Standard buttons, tabs
  static TextStyle labelMedium = GoogleFonts.ibmPlexSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Small - Small buttons, chips, badges
  static TextStyle labelSmall = GoogleFonts.ibmPlexSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // CUSTOM APP-SPECIFIC STYLES
  // ============================================================================
  /// Add custom text styles specific to your pregnancy health app
  
  // Example: Biomarker value display
  // static TextStyle biomarkerValue = const TextStyle(
  //   fontFamily: primaryFontFamily,
  //   fontSize: 32,
  //   fontWeight: FontWeight.w700,
  //   color: AppColors.primary,
  // );
  
  // Example: Week counter
  // static TextStyle weekCounter = const TextStyle(
  //   fontFamily: primaryFontFamily,
  //   fontSize: 48,
  //   fontWeight: FontWeight.w800,
  //   color: AppColors.primary,
  // );
  
  // Example: Timeline date
  // static TextStyle timelineDate = const TextStyle(
  //   fontFamily: primaryFontFamily,
  //   fontSize: 10,
  //   fontWeight: FontWeight.w500,
  //   letterSpacing: 1.0,
  //   color: AppColors.textSecondary,
  // );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  /// Helper to create a text style with a specific color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Helper to create a text style with a specific weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Helper to create a text style with a specific size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

