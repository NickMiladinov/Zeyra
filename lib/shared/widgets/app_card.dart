import 'package:flutter/material.dart';
import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppEffects.roundedXL,
        boxShadow: AppEffects.shadowSM,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppEffects.roundedXL,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppEffects.roundedXL,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.paddingLG),
            child: child,
          ),
        ),
      ),
    );
  }
}

