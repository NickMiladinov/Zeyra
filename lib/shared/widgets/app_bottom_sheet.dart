import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/shared/providers/modal_overlay_provider.dart';

/// Duration for bottom sheet entrance animation (slower for elegance)
const Duration _entranceAnimationDuration = AppEffects.durationMedium;

/// Duration for bottom sheet exit animation (faster for responsiveness)
const Duration _exitAnimationDuration = AppEffects.durationNormal;

/// Shared bottom sheet overlay widget providing consistent styling across the app.
/// 
/// Features:
/// - Rounded top corners
/// - Drag handle for swipe-to-dismiss
/// - Optional close button for accessibility
/// - Consistent padding and spacing
/// - Smooth animations
/// - Automatically hides floating banners when visible
/// - Supports both modal and draggable sheet modes
class AppBottomSheet extends StatelessWidget {
  /// The content to display in the bottom sheet
  final Widget child;
  
  /// Optional title displayed at the top
  final String? title;
  
  /// Optional custom style for the title
  final TextStyle? titleStyle;
  
  /// Whether to show a close button in the top right
  /// Recommended for accessibility if swipe gestures may be difficult
  final bool showCloseButton;
  
  /// Custom height for the bottom sheet (default: wraps content)
  final double? height;
  
  /// Whether the bottom sheet is dismissible by tapping outside or swiping down
  final bool isDismissible;
  
  /// Background color of the bottom sheet
  final Color? backgroundColor;
  
  /// Optional scroll controller for use in DraggableScrollableSheet
  /// When provided, the sheet uses sliver layout for better dragging
  final ScrollController? scrollController;
  
  /// Whether to use sliver layout (CustomScrollView) instead of Column
  /// Automatically true when scrollController is provided
  final bool useSliverLayout;
  
  /// Whether to apply padding to the content
  /// Set to false when child handles its own padding (e.g., lists)
  final bool applyContentPadding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.titleStyle,
    this.showCloseButton = false,
    this.height,
    this.isDismissible = true,
    this.backgroundColor,
    this.scrollController,
    bool? useSliverLayout,
    this.applyContentPadding = true,
  }) : useSliverLayout = useSliverLayout ?? scrollController != null;

  /// Show the bottom sheet with standard modal configuration.
  /// 
  /// Automatically notifies the app that a bottom sheet is visible,
  /// which hides floating elements like the kick counter banner.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    TextStyle? titleStyle,
    bool showCloseButton = false,
    double? height,
    bool isDismissible = true,
    Color? backgroundColor,
    bool enableDrag = true,
  }) async {
    // Get the ProviderContainer to update the modal overlay visibility
    final container = ProviderScope.containerOf(context);
    
    // Mark modal overlay as visible
    container.read(modalOverlayNotifierProvider).show();
    
    // Create animation controller for custom animation timing
    // We need a TickerProvider, so we use the Navigator's context
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    
    try {
      return await showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: true,
        useRootNavigator: true,
        // Custom animation durations via route settings
        transitionAnimationController: AnimationController(
          vsync: navigator,
          duration: _entranceAnimationDuration,
          reverseDuration: _exitAnimationDuration,
        ),
        builder: (context) => AppBottomSheet(
          title: title,
          titleStyle: titleStyle,
          showCloseButton: showCloseButton,
          height: height,
          isDismissible: isDismissible,
          backgroundColor: backgroundColor,
          child: child,
        ),
      );
    } finally {
      // Mark modal overlay as hidden when closed
      container.read(modalOverlayNotifierProvider).hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.surface;
    
    final decoration = BoxDecoration(
      color: effectiveBackgroundColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppEffects.radiusXXL),
        topRight: Radius.circular(AppEffects.radiusXXL),
      ),
      boxShadow: AppEffects.shadowLG,
    );
    
    // Use sliver layout for draggable sheets
    if (useSliverLayout) {
      return Container(
        height: height,
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // Drag handle and header
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const _DragHandle(),
                  if (title != null || showCloseButton)
                    _Header(
                      title: title,
                      titleStyle: titleStyle,
                      showCloseButton: showCloseButton,
                    ),
                ],
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: applyContentPadding
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.paddingXL,
                        AppSpacing.paddingSM,
                        AppSpacing.paddingXL,
                        AppSpacing.paddingXL,
                      ),
                      child: child,
                    )
                  : child,
            ),
            
            // Bottom safe area padding
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      );
    }
    
    // Standard column layout for modal sheets
    return Container(
      height: height,
      decoration: decoration,
      child: Column(
        mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Drag handle
          const _DragHandle(),
          
          // Header with optional title and close button
          if (title != null || showCloseButton)
            _Header(
              title: title,
              titleStyle: titleStyle,
              showCloseButton: showCloseButton,
            ),
          
          // Content
          Flexible(
            child: applyContentPadding
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.paddingXL,
                      AppSpacing.paddingSM,
                      AppSpacing.paddingXL,
                      AppSpacing.paddingXL,
                    ),
                    child: child,
                  )
                : child,
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
      width: AppSpacing.dragHandleWidth,
      height: AppSpacing.dragHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey400,
        borderRadius: BorderRadius.circular(AppEffects.radiusSM),
      ),
    );
  }
}

/// Header widget with optional title and close button
class _Header extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final bool showCloseButton;

  const _Header({
    this.title,
    this.titleStyle,
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
                style: titleStyle ?? AppTypography.headlineMedium,
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
