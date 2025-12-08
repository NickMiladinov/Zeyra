import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';

/// Application typography system.
/// 
/// Uses bundled fonts: Manrope (headings) and IBM Plex Sans (body text).
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES (bundled variable fonts)
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
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Display Medium
  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Display Small
  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // HEADLINE STYLES (Large headings)
  // ============================================================================
  /// Headline Large - Main screen titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - Section headers
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Small - Subsection headers
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Headline Extra Small - Subsection headers
  static const TextStyle headlineExtraSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BODY STYLES (Default text)
  // ============================================================================
  /// Body Large - Main content text (larger)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Medium - Standard body text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Small - Secondary body text
  static const TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFontFamily,
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
  static const TextStyle labelLarge = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Medium - Standard buttons, tabs
  static const TextStyle labelMedium = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Label Small - Small buttons, captions
  static const TextStyle labelSmall = TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12, // 16px line height
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // UTILITY METHODS (Optional text style modifiers)
  // ============================================================================

  // Example style modifiers you could add:
  // static TextStyle bold(TextStyle style) => style.copyWith(fontWeight: FontWeight.w700);
  // static TextStyle medium(TextStyle style) => style.copyWith(fontWeight: FontWeight.w500);
  // static TextStyle light(TextStyle style) => style.copyWith(fontWeight: FontWeight.w300);
}
