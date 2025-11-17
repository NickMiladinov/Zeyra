import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';

/// Application visual effects system.
/// 
/// Import your Figma effects here (shadows, borders, corner radius, etc.)
class AppEffects {
  // Prevent instantiation
  AppEffects._();

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  /// Border radius scale
  static const double radiusNone = 0.0;
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 9999.0; // Fully rounded
  
  /// Commonly used border radius values
  static BorderRadius get roundedNone => BorderRadius.circular(radiusNone);
  static BorderRadius get roundedXS => BorderRadius.circular(radiusXS);
  static BorderRadius get roundedSM => BorderRadius.circular(radiusSM);
  static BorderRadius get roundedMD => BorderRadius.circular(radiusMD);
  static BorderRadius get roundedLG => BorderRadius.circular(radiusLG);
  static BorderRadius get roundedXL => BorderRadius.circular(radiusXL);
  static BorderRadius get roundedXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get roundedCircle => BorderRadius.circular(radiusCircle);
  
  /// Top-only rounded corners (for cards with actions at bottom)
  static BorderRadius get roundedTopXL => const BorderRadius.only(
    topLeft: Radius.circular(radiusXL),
    topRight: Radius.circular(radiusXL),
  );
  
  static BorderRadius get roundedTopLG => const BorderRadius.only(
    topLeft: Radius.circular(radiusLG),
    topRight: Radius.circular(radiusLG),
  );
  
  /// Bottom-only rounded corners
  static BorderRadius get roundedBottomXL => const BorderRadius.only(
    bottomLeft: Radius.circular(radiusXL),
    bottomRight: Radius.circular(radiusXL),
  );
  
  static BorderRadius get roundedBottomLG => const BorderRadius.only(
    bottomLeft: Radius.circular(radiusLG),
    bottomRight: Radius.circular(radiusLG),
  );

  // ============================================================================
  // SHADOWS (Box Shadows)
  // ============================================================================
  /// Shadow for subtle elevation
  static List<BoxShadow> get shadowXS => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 4,
      spreadRadius: -1.0,
    ),
  ];

  /// Shadow for low elevation (cards)
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2.0,
    ),
  ];

  /// Shadow for medium elevation (raised buttons, dialogs)
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2.0,
    ),
  ];

  /// Shadow for high elevation (FAB, app bar)
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.15),
      offset: const Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -3.0,
    ),
  ];

  // ============================================================================
  // BORDERS
  // ============================================================================
  /// Default border
  static Border get borderDefault => Border.all(
    color: AppColors.border,
    width: AppSpacing.borderWidthThin,
  );

  /// Thick border
  static Border get borderThick => Border.all(
    color: AppColors.border,
    width: AppSpacing.borderWidthThick,
  );

  /// Primary colored border
  static Border get borderPrimary => Border.all(
    color: AppColors.primary,
    width: AppSpacing.borderWidthMedium,
  );

  /// Error colored border
  static Border get borderError => Border.all(
    color: AppColors.error,
    width: AppSpacing.borderWidthMedium,
  );

  /// Border side for use in OutlineInputBorder, etc.
  static BorderSide get borderSideDefault => const BorderSide(
    color: AppColors.border,
    width: AppSpacing.borderWidthThin,
  );

  static BorderSide get borderSideFocused => const BorderSide(
    color: AppColors.primary,
    width: AppSpacing.borderWidthMedium,
  );

  static BorderSide get borderSideError => const BorderSide(
    color: AppColors.error,
    width: AppSpacing.borderWidthMedium,
  );

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  /// Linear gradient - primary
  static LinearGradient get gradientPrimary => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryDark,
    ],
  );

  /// Linear gradient - secondary
  static LinearGradient get gradientSecondary => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondary,
      AppColors.secondaryDark,
    ],
  );

  // TODO: Add custom gradients from Figma
  // Example:
  // static LinearGradient get gradientHero => const LinearGradient(
  //   begin: Alignment.topCenter,
  //   end: Alignment.bottomCenter,
  //   colors: [Color(0xFF...), Color(0xFF...)],
  // );

  // ============================================================================
  // BLURS (Backdrop filters)
  // ============================================================================
  /// Blur values for frosted glass effects
  static const double blurNone = 0.0;
  static const double blurLight = 4.0; // TODO: Replace
  static const double blurMedium = 8.0; // TODO: Replace
  static const double blurHeavy = 16.0; // TODO: Replace

  // ============================================================================
  // OPACITY
  // ============================================================================
  /// Standard opacity levels
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.54;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // ============================================================================
  // TRANSITIONS / ANIMATIONS
  // ============================================================================
  /// Animation durations
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  /// Animation curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveBounce = Curves.bounceOut;

  // ============================================================================
  // DIVIDERS
  // ============================================================================
  /// Standard divider
  static Widget get dividerHorizontal => Divider(
    color: AppColors.divider,
    thickness: AppSpacing.borderWidthThin,
    height: AppSpacing.borderWidthThin,
  );

  static Widget get dividerVertical => VerticalDivider(
    color: AppColors.divider,
    thickness: AppSpacing.borderWidthThin,
    width: AppSpacing.borderWidthThin,
  );
}

