import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';

/// Header component for the hospital detail overlay.
///
/// Contains a centered drag handle and a close (x) button on the right.
class HospitalDetailHeader extends StatelessWidget {
  /// Callback when the close button is tapped.
  final VoidCallback onClose;

  const HospitalDetailHeader({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.paddingMD,
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.paddingSM,
      ),
      child: Row(
        children: [
          // Centered drag handle
          Expanded(
            child: Center(
              child: Container(
                width: AppSpacing.dragHandleWidth,
                height: AppSpacing.dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey400,
                  borderRadius: BorderRadius.circular(AppEffects.radiusSM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
