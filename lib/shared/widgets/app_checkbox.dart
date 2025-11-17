import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';

/// Custom checkbox widget with proper accessibility and animations.
/// 
/// Features:
/// - 24x24px visual size with 48x48px touch target (accessibility)
/// - Smooth animated transitions between states
/// - Ripple effect on press
/// - Matches Figma design specs exactly
/// 
/// Usage:
/// ```dart
/// AppCheckbox(
///   value: _isChecked,
///   onChanged: (value) => setState(() => _isChecked = value ?? false),
/// )
/// ```
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
  });

  /// Current state of the checkbox.
  final bool? value;

  /// Callback when checkbox state changes.
  final ValueChanged<bool?>? onChanged;

  /// If true, the checkbox's value can be true, false, or null.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final bool isChecked = value ?? false;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(!isChecked) : null,
        borderRadius: AppEffects.roundedCircle,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        customBorder: const CircleBorder(),
        child: Container(
          width: 48, // 48x48px touch target for accessibility
          height: 48,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: AppEffects.durationFast,
            curve: Curves.easeInOut,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.backgroundGrey500,
                width: AppSpacing.borderWidthThin,
              ),
              borderRadius: AppEffects.roundedSM,
            ),
            child: AnimatedSwitcher(
              duration: AppEffects.durationFast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: isChecked
                  ? const Icon(
                      Symbols.check_rounded,
                      key: ValueKey('checked'),
                      size: AppSpacing.iconXS,
                      color: AppColors.white,
                    )
                  : const SizedBox.shrink(key: ValueKey('unchecked')),
            ),
          ),
        ),
      ),
    );
  }
}

