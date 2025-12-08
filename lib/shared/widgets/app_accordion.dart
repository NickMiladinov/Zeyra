import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';

/// A reusable accordion widget with expandable/collapsible content.
/// 
/// Provides a clean, consistent UI for expandable sections throughout the app.
class AppAccordion extends StatefulWidget {
  /// The title displayed in the accordion header
  final String title;
  
  /// The content displayed when the accordion is expanded
  final Widget child;
  
  /// Whether the accordion is initially expanded
  final bool initiallyExpanded;
  
  /// Optional background color for the accordion
  final Color? backgroundColor;
  
  /// Optional title text style
  final TextStyle? titleStyle;

  const AppAccordion({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.titleStyle,
    super.key,
  });

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: AppEffects.roundedXL,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: AppEffects.roundedLG,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingLG),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: widget.titleStyle ??
                          AppTypography.headlineExtraSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSM),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: AppEffects.durationNormal,
                    curve: AppEffects.curveDefault,
                    child: AppIcons.icon(
                      AppIcons.arrowDown,
                      color: AppColors.iconDefault,
                      size: AppSpacing.iconMD,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          AnimatedSize(
            duration: AppEffects.durationNormal,
            curve: AppEffects.curveDefault,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.paddingLG,
                      right: AppSpacing.paddingLG,
                      bottom: AppSpacing.paddingLG,
                    ),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

