import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.gapXL),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAllowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.paddingMD,
                ),
              ),
              child: const Text('Allow Location Access'),
            ),
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
    );
  }
}
