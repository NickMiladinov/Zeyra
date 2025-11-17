import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Main application theme.
/// 
/// This file combines all theme elements (colors, typography, spacing, effects)
/// into a cohesive Material 3 ThemeData object.
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ----------------------------------------------------------------------------
      // COLOR SCHEME
      // ----------------------------------------------------------------------------
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,
        
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
      ),

      // ----------------------------------------------------------------------------
      // SCAFFOLD
      // ----------------------------------------------------------------------------
      scaffoldBackgroundColor: AppColors.background,

      // ----------------------------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationSM,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineLarge.copyWith(
          color: AppColors.white,
        ),
        toolbarHeight: AppSpacing.appBarHeight,
      ),

      // ----------------------------------------------------------------------------
      // CARD
      // ----------------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSpacing.elevationXS,
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedXL,
        ),
        margin: const EdgeInsets.all(AppSpacing.marginLG),
      ),

      // ----------------------------------------------------------------------------
      // FILLED BUTTON (Primary Button - No Elevation)
      // ----------------------------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXL, 
            vertical: AppSpacing.paddingMD,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: AppEffects.roundedCircle,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ----------------------------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: AppSpacing.elevationSM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXXL, 
            vertical: AppSpacing.paddingLG,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: AppEffects.roundedCircle,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ----------------------------------------------------------------------------
      // TEXT BUTTON
      // ----------------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXL, 
            vertical: AppSpacing.paddingMD,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: AppEffects.roundedCircle,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ----------------------------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: AppEffects.borderSideDefault,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXXL, 
            vertical: AppSpacing.paddingLG,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: AppEffects.roundedCircle,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ----------------------------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSpacing.elevationSM,
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedCircle,
        ),
      ),

      // ----------------------------------------------------------------------------
      // INPUT DECORATION (Text Fields)
      // ----------------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingLG,
          vertical: AppSpacing.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: AppEffects.roundedLG,
          borderSide: AppEffects.borderSideDefault,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppEffects.roundedLG,
          borderSide: AppEffects.borderSideDefault,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppEffects.roundedMD,
          borderSide: AppEffects.borderSideFocused,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppEffects.roundedMD,
          borderSide: AppEffects.borderSideError,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppEffects.roundedMD,
          borderSide: AppEffects.borderSideError,
        ),
        labelStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // ----------------------------------------------------------------------------
      // BOTTOM NAVIGATION BAR
      // ----------------------------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: AppSpacing.elevationLG,
        type: BottomNavigationBarType.fixed,
      ),

      // ----------------------------------------------------------------------------
      // DIALOG
      // ----------------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationXL,
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedXL,
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ----------------------------------------------------------------------------
      // DIVIDER
      // ----------------------------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: AppSpacing.borderWidthThin,
        space: AppSpacing.marginMD,
      ),

      // ----------------------------------------------------------------------------
      // LIST TILE
      // ----------------------------------------------------------------------------
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingSM,
        ),
        iconColor: AppColors.primary,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.bodyLarge,
        subtitleTextStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedMD,
        ),
      ),

      // ----------------------------------------------------------------------------
      // SWITCH
      // ----------------------------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          // Thumb is always white/light grey
          return AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary; // ON state: primary teal
          }
          return AppColors.backgroundGrey100; // OFF state: light grey
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent), // No border
        splashRadius: 0, // Remove splash effect for cleaner look
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary.withValues(alpha: 0.1); // Subtle press effect
          }
          return Colors.transparent;
        }),
      ),

      // ----------------------------------------------------------------------------
      // SLIDER
      // ----------------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryOverlay,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        valueIndicatorColor: AppColors.primary,
        activeTickMarkColor: AppColors.white,
        inactiveTickMarkColor: AppColors.backgroundGrey500,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      ),
      
      // ----------------------------------------------------------------------------
      // CHECKBOX
      // ----------------------------------------------------------------------------
      // ⚠️ DO NOT USE Material's Checkbox widget directly.
      // Use AppCheckbox from shared/widgets/app_checkbox.dart instead.
      // The checkbox theme has been intentionally removed to enforce custom widget usage.

      // ----------------------------------------------------------------------------
      // RADIO BUTTON
      // ----------------------------------------------------------------------------
      // ⚠️ DO NOT USE Material's Radio widget directly.
      // Use AppRadioButton from shared/widgets/app_radio_button.dart instead.
      // The radio theme has been intentionally removed to enforce custom widget usage.

      // ----------------------------------------------------------------------------
      // CHIP
      // ----------------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.white, // Selected label color
        ),
        checkmarkColor: AppColors.white,
        surfaceTintColor: Colors.transparent, // Remove Material 3 tint
        shadowColor: Colors.transparent, // Remove shadow
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingSM,
          vertical: AppSpacing.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppEffects.roundedCircle,
        ),
      ).copyWith(
        // Use primary color for press/hover effects instead of secondary (peach)
        color: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // ----------------------------------------------------------------------------
      // ICON THEME
      // ----------------------------------------------------------------------------
      iconTheme: const IconThemeData(
        color: AppIcons.defaultColor, // Grey by default
        size: AppSpacing.iconSM,
        weight: AppIcons.defaultWeight, // 300
        fill: AppIcons.defaultFill, // Outlined (0)
        opticalSize: AppIcons.defaultOpticalSize,
      ),
      
      primaryIconTheme: const IconThemeData(
        color: AppColors.white, // White icons on primary-colored surfaces
        size: AppSpacing.iconSM,
        weight: AppIcons.defaultWeight,
        fill: AppIcons.defaultFill,
        opticalSize: AppIcons.defaultOpticalSize,
      ),

      // ----------------------------------------------------------------------------
      // TEXT THEME
      // ----------------------------------------------------------------------------
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // ----------------------------------------------------------------------------
      // FONT FAMILY
      // ----------------------------------------------------------------------------
      fontFamily: AppTypography.secondaryFontFamily,
    );
  }

  // ============================================================================
  // DARK THEME (Optional - Add if needed)
  // ============================================================================
  // TODO: Implement dark theme if your app supports it
  // static ThemeData get darkTheme {
  //   return ThemeData(
  //     useMaterial3: true,
  //     brightness: Brightness.dark,
  //     // ... similar structure to lightTheme but with dark colors
  //   );
  // }
}

