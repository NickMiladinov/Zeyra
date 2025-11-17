import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_effects.dart';

/// Custom radio button widget with proper accessibility and animations.
/// 
/// Usage:
/// ```dart
/// AppRadioButton<String>(
///   value: 'option1',
///   groupValue: selectedValue,
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class AppRadioButton<T> extends StatelessWidget {
  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the group of radio buttons.
  final T? groupValue;

  /// Callback when this radio button is selected.
  final ValueChanged<T?>? onChanged;

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(value) : null,
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
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: _isSelected ? AppColors.primary : AppColors.backgroundGrey500,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: AppEffects.durationFast,
                curve: Curves.easeInOut,
                width: _isSelected ? 12 : 0, // Half of 24px when selected
                height: _isSelected ? 12 : 0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

