import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/domain/entities/kick_counter/kick.dart';
import 'package:zeyra/shared/widgets/app_bottom_sheet.dart';

/// Overlay for rating the intensity of a recorded movement.
/// 
/// Shown immediately after user records a kick to capture movement strength.
/// Can be dismissed without selection to use default (moderate) intensity.
class RateIntensityOverlay extends StatelessWidget {
  /// Callback when user selects an intensity or dismisses without selection
  final Function(MovementStrength intensity) onIntensitySelected;

  const RateIntensityOverlay({
    super.key,
    required this.onIntensitySelected,
  });

  /// Show the rate intensity overlay
  static Future<MovementStrength?> show({
    required BuildContext context,
  }) async {
    return await AppBottomSheet.show<MovementStrength>(
      context: context,
      child: const _RateIntensityContent(),
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _RateIntensityContent();
  }
}

class _RateIntensityContent extends StatelessWidget {
  const _RateIntensityContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Rate Intensity',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.gapSM),
        
        // Subtitle
        Text(
          'How strong was that movement?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapXL),
        
        // Intensity options
        _IntensityButton(
          intensity: MovementStrength.weak,
          label: 'Mild',
          color: AppColors.primary.withValues(alpha: 0.1), // Light teal
          textColor: AppColors.primary,
          onTap: () => Navigator.of(context).pop(MovementStrength.weak),
        ),
        const SizedBox(height: AppSpacing.gapMD),
        
        _IntensityButton(
          intensity: MovementStrength.moderate,
          label: 'Moderate',
          color: AppColors.secondary.withValues(alpha: 0.1), // Light peach
          textColor: AppColors.secondary,
          onTap: () => Navigator.of(context).pop(MovementStrength.moderate),
        ),
        const SizedBox(height: AppSpacing.gapMD),
        
        _IntensityButton(
          intensity: MovementStrength.strong,
          label: 'Strong',
          color: AppColors.error.withValues(alpha: 0.1), // Light red/pink
          textColor: AppColors.error,
          onTap: () => Navigator.of(context).pop(MovementStrength.strong),
        ),
      ],
    );
  }
}

class _IntensityButton extends StatelessWidget {
  final MovementStrength intensity;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _IntensityButton({
    required this.intensity,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.paddingLG,
            horizontal: AppSpacing.paddingXL,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppEffects.radiusLG),
            border: Border.all(
              color: textColor,
              width: AppSpacing.borderWidthThin,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelLarge.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

