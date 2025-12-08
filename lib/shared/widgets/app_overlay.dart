import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// A reusable modal overlay widget that displays content in a centered card.
///
/// Features:
/// - Dark semi-transparent background
/// - Centered white card with rounded corners
/// - Optional close button
/// - Smooth fade-in animation
/// - Tap-outside to dismiss (optional)
///
/// Usage:
/// ```dart
/// AppOverlay.show(
///   context: context,
///   child: YourContentWidget(),
/// );
/// ```
class AppOverlay extends StatelessWidget {
  /// The content to display inside the overlay card
  final Widget child;

  /// Whether to show a close button in the top right corner
  final bool showCloseButton;

  /// Whether tapping outside the card dismisses the overlay
  final bool dismissOnTapOutside;

  /// Custom padding for the card content
  final EdgeInsetsGeometry? contentPadding;

  /// Custom width for the overlay card (defaults to screen width - padding)
  final double? width;

  /// Custom maximum height for the overlay card
  final double? maxHeight;

  const AppOverlay({
    super.key,
    required this.child,
    this.showCloseButton = true,
    this.dismissOnTapOutside = true,
    this.contentPadding,
    this.width,
    this.maxHeight,
  });

  /// Show the overlay as a modal dialog
  ///
  /// Returns the result from [Navigator.pop] if the overlay is dismissed
  /// with a value, otherwise returns null.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showCloseButton = true,
    bool dismissOnTapOutside = true,
    EdgeInsetsGeometry? contentPadding,
    double? width,
    double? maxHeight,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible && dismissOnTapOutside,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.overlay,
      transitionDuration: AppEffects.durationNormal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppOverlay(
          showCloseButton: showCloseButton,
          dismissOnTapOutside: dismissOnTapOutside,
          contentPadding: contentPadding,
          width: width,
          maxHeight: maxHeight,
          child: child,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppEffects.curveDefault,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppEffects.curveDefault,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Default card width: screen width minus horizontal padding
    final cardWidth = width ?? (screenWidth - AppSpacing.paddingXXL * 2);

    // Default max height: 85% of screen height
    final cardMaxHeight = maxHeight ?? (screenHeight * 0.85);

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: cardWidth,
            constraints: BoxConstraints(
              maxHeight: cardMaxHeight,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppEffects.roundedXXL,
              boxShadow: AppEffects.shadowLG,
            ),
            child: Stack(
              children: [
                // Content
                SingleChildScrollView(
                  child: Padding(
                    padding: contentPadding ??
                        const EdgeInsets.all(AppSpacing.paddingXL),
                    child: child,
                  ),
                ),

                // Close button
                if (showCloseButton)
                  Positioned(
                    top: AppSpacing.paddingXS,
                    right: AppSpacing.paddingXS,
                    child: IconButton(
                      icon: Icon(
                        AppIcons.close,
                        size: AppSpacing.iconSM,
                        color: AppColors.iconDefault,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: AppSpacing.iconMD,
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

