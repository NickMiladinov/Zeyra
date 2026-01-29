import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';

/// A linear progress indicator for the onboarding flow.
///
/// Shows current progress as a filled portion of a horizontal bar.
class OnboardingProgressIndicator extends StatelessWidget {
  /// Creates an onboarding progress indicator.
  ///
  /// [progress] should be between 0.0 and 1.0.
  const OnboardingProgressIndicator({
    super.key,
    required this.progress,
  });

  /// Current progress value (0.0 to 1.0).
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final filledWidth = totalWidth * progress.clamp(0.0, 1.0);

        return Container(
          height: AppSpacing.xs,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: AppEffects.roundedCircle,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: AppEffects.durationNormal,
              curve: AppEffects.curveDefault,
              width: filledWidth,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppEffects.roundedCircle,
              ),
            ),
          ),
        );
      },
    );
  }
}
