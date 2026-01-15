import 'package:flutter/material.dart';

/// Application color palette.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================
  /// Primary brand color
  static const Color primary = Color(0xff4db6ac);
  
  /// Primary color variants
  static const Color primaryLight = Color(0xffe6f4f4);
  static const Color primaryDark = Color(0xFF00897B);
  
  // ============================================================================
  // SECONDARY COLORS
  // ============================================================================
  /// Secondary/accent color
  static const Color secondary = Color(0xFFFFAB91);
  /// Secondary color variants
  static const Color secondaryLight = Color(0xFFFFCCBC);
  static const Color secondaryDark = Color(0xFFF48A6A);

  // ============================================================================
  // NEUTRAL/GRAYSCALE
  // ============================================================================
  /// Background colors
  static const Color background = Color(0xFFF7F8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0); // For chips, inactive states
  static const Color backgroundGrey50 = Color(0xFFEEEEEE);
  static const Color backgroundGrey100 = Color(0xFFE0E0E0);
  static const Color backgroundGrey400 = Color(0xFFBDBDBD);
  static const Color backgroundGrey500 = Color(0xFF8D8D8D);
  static const Color backgroundGrey600 = Color(0xFF7E7E7E);
  static const Color backgroundPrimarySubtle = Color(0xFFE0F2F1);
  static const Color backgroundPrimaryVerySubtle = Color(0xFFF1F9F8);
  static const Color backgroundSecondarySubtle = Color(0xFFFFECE5);
  static const Color backgroundSecondaryVerySubtle = Color(0xFFFFEFEB);

  /// Overlay colors (20% opacity for subtle backgrounds/inactive states)
  static const Color primaryOverlay = Color(0x334DB6AC); // Primary with 20% opacity
  static const Color secondaryOverlay = Color(0x33FFAB91); // Secondary with 20% opacity
  static const Color successOverlay = Color(0x332E7D32); // Success with 20% opacity

  
  /// Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF808080);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFE0E0E0);
  
  /// Border and divider colors
  static const Color border = backgroundGrey100;
  static const Color borderPrimary = Color.fromARGB(52, 77, 182, 172);
  static const Color borderSecondary = Color.fromARGB(52, 255, 171, 145);
  static const Color divider = backgroundGrey100;

  // ============================================================================
  // SEMANTIC COLORS (Status/Feedback)
  // ============================================================================
  /// Success color (e.g., confirmations, positive states)
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF2E7D32);
  
  /// Warning color (e.g., alerts, caution)
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFED6C02);
  
  /// Error color (e.g., errors, destructive actions)
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  /// Info color (e.g., informational messages)
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ============================================================================
  // PREGNANCY/HEALTH APP SPECIFIC COLORS
  // ============================================================================
  /// Colors specific to your pregnancy health app
  /// Add custom colors for biomarkers, timeline, baby visualization, etc.
  
  // Example: Biomarker status colors
  // static const Color biomarkerNormal = Color(0xFF4CAF50);
  // static const Color biomarkerWarning = Color(0xFFFF9800);
  // static const Color biomarkerCritical = Color(0xFFF44336);
  
  // Example: Trimester colors
  // static const Color trimester1 = Color(0xFFE8F5E9);
  // static const Color trimester2 = Color(0xFFFFF3E0);
  // static const Color trimester3 = Color(0xFFFCE4EC);
  
  // Example: Timeline visualization
  // static const Color timelinePast = Color(0xFF9E9E9E);
  // static const Color timelineCurrent = Color(0xFF008080);
  // static const Color timelineFuture = Color(0xFFE0E0E0);

  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  /// Semi-transparent overlays for modals, dialogs, etc.
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xCC000000); // 80% black

  // ============================================================================
  // UTILITY COLORS
  // ============================================================================
  /// Pure white and black
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  /// Transparent
  static const Color transparent = Color(0x00000000);

  // Icon colors
  static const Color iconPrimary = primary;
  static const Color iconSecondary = secondary;
  static const Color iconDefault = backgroundGrey500;
  static const Color iconDark = textPrimary;
  static const Color iconLight = white;
  static const Color iconError = error;
  static const Color iconSuccess = success;
  static const Color iconWarning = warning;
  static const Color iconInfo = info;
}

