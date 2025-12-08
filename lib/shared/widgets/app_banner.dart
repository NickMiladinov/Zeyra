import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.title,
    this.titleStyle,
    this.leadingIcon,
    this.onLeadingPressed,
    this.trailingIcon,
    this.onTrailingPressed,
    this.bottomSpacing,
  });

  final String title;
  final TextStyle? titleStyle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  
  /// Spacing below the banner. Defaults to [AppSpacing.paddingXL] if null.
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing ?? AppSpacing.paddingXL),
      child: Container(
        color: AppColors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppSpacing.paddingLG,
          bottom: AppSpacing.paddingLG,
          left: AppSpacing.paddingLG,
          right: AppSpacing.paddingLG,
        ),
        child: Row(
          children: [
            // Leading Icon
            _buildIcon(leadingIcon, onLeadingPressed),

            // Title
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? AppTypography.headlineSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Trailing Icon
            _buildIcon(trailingIcon, onTrailingPressed),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData? icon, VoidCallback? onPressed) {
    if (icon == null) {
      return SizedBox(width: AppSpacing.iconMD);
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: AppSpacing.iconMD,
        color: AppColors.primary, // Assuming primary color for actions
      ),
    );
  }
}
