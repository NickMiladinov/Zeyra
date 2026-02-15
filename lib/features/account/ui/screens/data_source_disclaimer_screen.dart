import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class DataSourceDisclaimerScreen extends StatelessWidget {
  const DataSourceDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: AppSpacing.elevationNone,
        leading: IconButton(
          icon: const Icon(
            AppIcons.back,
            color: AppColors.iconDefault,
            size: AppSpacing.iconMD,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(ToolRoutes.account);
          },
        ),
        title: const Text('Data Source Disclaimer'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.paddingLG),
          children: [
            Text(
              'Hospital and maternity information in Zeyra may include public datasets (including CQC data) and other third-party sources.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.gapMD),
            Text(
              'We do not guarantee that this data is complete, accurate, or up to date at all times.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.gapMD),
            Text(
              'Always verify critical details directly with your chosen hospital, NHS services, or other official providers before making medical or care decisions.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
