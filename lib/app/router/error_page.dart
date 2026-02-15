import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'routes.dart';

/// Error page displayed when navigation fails or route is not found.
///
/// Provides a user-friendly error message and a button to return to the
/// hospital map flow.
class ErrorPage extends StatelessWidget {
  /// The error that caused this page to be displayed.
  final Exception? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingXL),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.gapXL),
                Text(
                  'Page Not Found',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapMD),
                Text(
                  'The page you\'re looking for doesn\'t exist or has been moved.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapXL),
                ElevatedButton(
                  onPressed: () => context.go(ToolRoutes.hospitalChooserExplore),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.paddingXL,
                      vertical: AppSpacing.paddingMD,
                    ),
                  ),
                  child: Text(
                    'Go to Hospital Map',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
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
