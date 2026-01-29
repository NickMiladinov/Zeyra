import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

/// Floating toggle button to switch between map and list views.
///
/// Displays at the bottom center of the screen with a dark background
/// and appropriate icon based on the target view.
class HospitalViewToggleButton extends StatelessWidget {
  /// The target view when tapped.
  final HospitalViewType targetView;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  const HospitalViewToggleButton({
    super.key,
    required this.targetView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMapTarget = targetView == HospitalViewType.map;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
        boxShadow: AppEffects.shadowSM,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: AppSpacing.paddingSM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMapTarget ? AppIcons.map : AppIcons.overview,
                  color: AppColors.white,
                  size: AppSpacing.iconSM,
                ),
                const SizedBox(width: AppSpacing.gapSM),
                Text(
                  isMapTarget ? 'Map View' : 'List View',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enum for hospital view types.
enum HospitalViewType {
  /// Map view showing pins on a Google Map.
  map,

  /// List view showing hospitals in a scrollable list.
  list,
}
