import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import 'onboarding_progress_indicator.dart';

/// A scaffold widget for onboarding screens.
///
/// Provides consistent layout with:
/// - Optional back button
/// - Progress indicator
/// - Content area with proper padding
/// - Bottom action area for primary button
class OnboardingScaffold extends StatelessWidget {
  /// Creates an onboarding scaffold.
  const OnboardingScaffold({
    super.key,
    required this.progress,
    required this.body,
    this.bottomAction,
    this.secondaryAction,
    this.showBackButton = true,
    this.onBack,
  });

  /// Current progress value (0.0 to 1.0).
  final double progress;

  /// The main content of the screen.
  final Widget body;

  /// Optional bottom action widget (typically a button).
  final Widget? bottomAction;

  /// Optional secondary action below the primary button.
  final Widget? secondaryAction;

  /// Whether to show the back button.
  final bool showBackButton;

  /// Callback when back button is pressed.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.paddingMD,
              ),
              child: Row(
                children: [
                  // Back button
                  if (showBackButton)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.of(context).pop(),
                      child: AppIcons.icon(
                        AppIcons.back,
                        color: AppColors.backgroundGrey500,
                        size: AppSpacing.iconLG,
                      ),
                    )
                  else
                    const SizedBox(width: AppSpacing.iconLG, height: AppSpacing.iconLG),

                  const SizedBox(width: AppSpacing.gapMD),

                  // Progress indicator
                  Expanded(
                    child: OnboardingProgressIndicator(progress: progress),
                  ),
                  const SizedBox(width: AppSpacing.gapMD),
                  const SizedBox(width: AppSpacing.iconLG, height: AppSpacing.iconLG),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingHorizontal,
                ),
                child: body,
              ),
            ),

            // Bottom action area
            if (bottomAction != null || secondaryAction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingHorizontal,
                  AppSpacing.paddingMD,
                  AppSpacing.screenPaddingHorizontal,
                  AppSpacing.screenPaddingVertical,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bottomAction != null) bottomAction!,
                    if (secondaryAction != null) ...[
                      const SizedBox(height: AppSpacing.gapLG),
                      secondaryAction!,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
