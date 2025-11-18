import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Currently selected tab index (0-4)
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppEffects.shadowTop,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildNavItem(
            index: 0,
            icon: AppIcons.today,
            label: 'Today',
          ),
          _buildNavItem(
            index: 1,
            icon: AppIcons.myHealth,
            label: 'My Health',
          ),
          _buildNavItem(
            index: 2,
            // Baby uses custom SVG icon
            iconWidget: currentIndex == 2
                ? AppIcons.babyActive()
                : AppIcons.baby(),
            label: 'Baby',
          ),
          _buildNavItem(
            index: 3,
            icon: AppIcons.tools,
            label: 'Tools',
          ),
          _buildNavItem(
            index: 4,
            icon: AppIcons.more,
            label: 'More',
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    Widget? iconWidget,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    final Color textColor = isActive ? AppColors.primary : AppColors.textSecondary;
    final Color iconColor = isActive ? AppColors.primary : AppColors.backgroundGrey500;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            SizedBox(
              width: AppSpacing.iconSM,
              height: AppSpacing.iconSM,
              child: iconWidget ??
                  (icon != null
                      ? Icon(
                          icon,
                          size: AppSpacing.iconSM,
                          color: iconColor,
                          fill: isActive ? 1.0 : 0.0,
                        )
                      : const SizedBox.shrink()),
            ),
            SizedBox(height: AppSpacing.xs),
            // Label
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

