import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Location bar showing current postcode with change option.
///
/// Displays the user's current location (postcode) and provides
/// a button to change it.
class HospitalLocationBar extends StatelessWidget {
  /// The user's postcode (e.g., "SW1A 1AA").
  final String? postcode;

  /// Whether location is currently being loaded.
  final bool isLoading;

  /// Callback when "Change" button is tapped.
  final VoidCallback onChangeTap;

  const HospitalLocationBar({
    super.key,
    this.postcode,
    this.isLoading = false,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingLG,
        vertical: AppSpacing.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.backgroundGrey100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.gapSM),
          Expanded(
            child: isLoading
                ? const Text('Getting location...')
                : Text(
                    postcode ?? 'Location not set',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          TextButton(
            onPressed: onChangeTap,
            child: Text(
              'Change',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
