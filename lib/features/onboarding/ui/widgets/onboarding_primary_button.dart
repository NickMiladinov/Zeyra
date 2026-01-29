import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Primary action button for onboarding screens.
///
/// Features a coral/salmon background with white text and a right arrow icon.
/// Supports enabled/disabled states with proper visual feedback.
class OnboardingPrimaryButton extends StatelessWidget {
  /// Creates an onboarding primary button.
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  /// Button text label.
  final String label;

  /// Callback when button is pressed. Null if disabled.
  final VoidCallback? onPressed;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Whether to show a loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    return AnimatedContainer(
      duration: AppEffects.durationFast,
      height: AppSpacing.buttonHeightXXL,
      decoration: BoxDecoration(
        color: effectiveEnabled
            ? AppColors.primary
            : AppColors.backgroundGrey100,
        borderRadius: AppEffects.roundedCircle,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          borderRadius: AppEffects.roundedCircle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingXL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: AppSpacing.iconSM,
                    height: AppSpacing.iconSM,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSpacing.borderWidthMedium,
                      color: effectiveEnabled
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSM),
                ],
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: effectiveEnabled
                        ? AppColors.textLight
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.gapSM),
                Icon(
                  Symbols.arrow_right_alt_rounded,
                  color: effectiveEnabled
                      ? AppColors.textLight
                      : AppColors.textSecondary,
                  size: AppSpacing.iconSM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
