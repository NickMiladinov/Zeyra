import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// Shared bottom sheet overlay widget providing consistent styling across the app.
/// 
/// Features:
/// - Rounded top corners
/// - Drag handle for swipe-to-dismiss
/// - Optional close button for accessibility
/// - Consistent padding and spacing
/// - Smooth animations
class AppBottomSheet extends StatelessWidget {
  /// The content to display in the bottom sheet
  final Widget child;
  
  /// Optional title displayed at the top
  final String? title;
  
  /// Whether to show a close button in the top right
  /// Recommended for accessibility if swipe gestures may be difficult
  final bool showCloseButton;
  
  /// Custom height for the bottom sheet (default: wraps content)
  final double? height;
  
  /// Whether the bottom sheet is dismissible by tapping outside or swiping down
  final bool isDismissible;
  
  /// Background color of the bottom sheet
  final Color? backgroundColor;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = false,
    this.height,
    this.isDismissible = true,
    this.backgroundColor,
  });

  /// Show the bottom sheet with standard modal configuration
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showCloseButton = false,
    double? height,
    bool isDismissible = true,
    Color? backgroundColor,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        title: title,
        showCloseButton: showCloseButton,
        height: height,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppEffects.radiusXXL),
          topRight: Radius.circular(AppEffects.radiusXXL),
        ),
        boxShadow: AppEffects.shadowLG,
      ),
      child: Column(
        mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Drag handle
          const _DragHandle(),
          
          // Header with optional title and close button
          if (title != null || showCloseButton)
            _Header(
              title: title,
              showCloseButton: showCloseButton,
            ),
          
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.paddingXL,
                AppSpacing.paddingSM,
                AppSpacing.paddingXL,
                AppSpacing.paddingXL,
              ),
              child: child,
            ),
          ),
          
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Drag handle widget for swipe-to-dismiss gesture
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.marginMD,
        bottom: AppSpacing.marginSM,
      ),
      width: 40.0,
      height: 4.0,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppEffects.radiusSM),
      ),
    );
  }
}

/// Header widget with optional title and close button
class _Header extends StatelessWidget {
  final String? title;
  final bool showCloseButton;

  const _Header({
    this.title,
    required this.showCloseButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingXL,
        vertical: AppSpacing.paddingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTypography.headlineMedium,
              ),
            )
          else
            const Spacer(),
          
          if (showCloseButton)
            IconButton(
              icon: const Icon(AppIcons.close),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.iconDefault,
              iconSize: AppSpacing.iconMD,
            ),
        ],
      ),
    );
  }
}

