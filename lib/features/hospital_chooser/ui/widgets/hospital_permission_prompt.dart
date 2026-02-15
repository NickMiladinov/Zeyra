import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';

/// Permission prompt widget for requesting location access.
///
/// Shown when the app needs location permission to find nearby hospitals.
/// Provides options to allow location access or enter postcode manually.
class HospitalPermissionPrompt extends StatelessWidget {
  /// Callback when "Allow Location Access" is tapped.
  final VoidCallback onAllowTap;

  /// Callback when "Enter Postcode Manually" is tapped.
  final VoidCallback onManualTap;

  const HospitalPermissionPrompt({
    super.key,
    required this.onAllowTap,
    required this.onManualTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AppBottomSheet(
        isDismissible: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Find Hospitals Near You',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.gapMD),
            Text(
              'Allow location access to find maternity units nearby, or enter your postcode manually.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.gapXL),
            FilledButton(
              onPressed: onAllowTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.paddingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
                ),
              ),
              child: const Text('Allow Location Access'),
            ),
            const SizedBox(height: AppSpacing.gapMD),
            TextButton(
              onPressed: onManualTap,
              child: Text(
                'Enter Postcode Manually',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
