import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_typography.dart';

/// Shared dialog widget with two action buttons.
/// 
/// Provides consistent styling for confirmation and decision dialogs across the app.
class AppDialog extends StatelessWidget {
  /// Dialog title
  final String title;
  
  /// Dialog message/content
  final String message;
  
  /// Label for the primary action button (typically on the right)
  final String primaryActionLabel;
  
  /// Label for the secondary action button (typically on the left)
  final String secondaryActionLabel;
  
  /// Callback when primary action is pressed (returns true)
  final VoidCallback? onPrimaryAction;
  
  /// Callback when secondary action is pressed (returns false)
  final VoidCallback? onSecondaryAction;
  
  /// Whether the primary action is destructive (uses error color)
  final bool isPrimaryDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.isPrimaryDestructive = false,
  });

  /// Show a two-option dialog
  /// 
  /// Returns `true` if primary action selected, `false` if secondary, `null` if dismissed
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String primaryActionLabel,
    required String secondaryActionLabel,
    bool isPrimaryDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        primaryActionLabel: primaryActionLabel,
        secondaryActionLabel: secondaryActionLabel,
        isPrimaryDestructive: isPrimaryDestructive,
        onPrimaryAction: () => Navigator.pop(context, true),
        onSecondaryAction: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppTypography.headlineSmall,
      ),
      content: Text(
        message,
        style: AppTypography.bodyLarge,
      ),
      actions: [
        // Secondary action (left button)
        TextButton(
          onPressed: onSecondaryAction ?? () => Navigator.pop(context, false),
          child: Text(
            secondaryActionLabel,
            style: AppTypography.labelLarge,
          ),
        ),
        
        // Primary action (right button)
        TextButton(
          onPressed: onPrimaryAction ?? () => Navigator.pop(context, true),
          style: isPrimaryDestructive
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(
            primaryActionLabel,
            style: AppTypography.labelLarge.copyWith(
              color: isPrimaryDestructive ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

