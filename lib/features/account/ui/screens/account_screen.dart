import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/main_providers.dart';
import '../../../account/logic/account_notifier.dart';
import '../../../hospital_chooser/logic/hospital_shortlist_state.dart';
import '../../../hospital_chooser/ui/widgets/hospital_shortlist_final_choice_section.dart';

/// Account hub screen for profile, legal links, and account actions.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountNotifierProvider.notifier).refreshIdentity();
    });
  }

  Future<void> _handleSignOut() async {
    final success = await ref.read(accountNotifierProvider.notifier).signOut();
    if (!mounted) return;

    if (success) {
      context.go(AuthRoutes.auth);
      return;
    }

    final error = ref.read(accountNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Could not sign out. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountNotifierProvider);

    final manageShortlistAsync = ref.watch(manageShortlistUseCaseProvider);
    final selectFinalAsync = ref.watch(selectFinalHospitalUseCaseProvider);
    final shortlistReady =
        manageShortlistAsync.asData?.value != null &&
        selectFinalAsync.asData?.value != null;
    final selectedHospital = shortlistReady
        ? ref.watch(hospitalShortlistProvider).selectedHospital
        : null;

    final identity = accountState.identity;
    final email = identity?.email ?? 'No email available';
    final emailParts = email.split('@');
    final displayTitle =
        emailParts.isNotEmpty && emailParts.first.isNotEmpty
        ? emailParts.first
        : 'My account';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
            context.go(ToolRoutes.hospitalChooserExplore);
          },
        ),
        title: Text(
          'Account',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.paddingLG,
          AppSpacing.paddingLG,
          AppSpacing.paddingLG,
          AppSpacing.paddingXL,
        ),
        children: [
          _AccountHeaderCard(
            title: displayTitle,
            subtitle: email,
            onTap: () => context.push(ToolRoutes.accountDetails),
          ),
          const SizedBox(height: AppSpacing.gapLG),
          HospitalShortlistFinalChoiceSection(
            selectedHospital: selectedHospital,
            onClearSelectionTap: null,
            onFinalChoiceTap: null,
            compact: true,
            showClearAction: false,
            title: 'Your Final Choice',
          ),
          const SizedBox(height: AppSpacing.gapLG),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppEffects.roundedXL,
              border: Border.all(
                color: AppColors.border,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            child: Column(
              children: [
                _AccountActionTile(
                  icon: AppIcons.email,
                  label: 'Support & Feedback',
                  onTap: () => context.push(ToolRoutes.accountSupport),
                ),
                _AccountActionTile(
                  icon: AppIcons.file,
                  label: 'Terms of Service',
                  onTap: () => context.push(LegalRoutes.termsOfService),
                ),
                _AccountActionTile(
                  icon: AppIcons.lock,
                  label: 'Privacy Policy',
                  onTap: () => context.push(LegalRoutes.privacyPolicy),
                ),
                _AccountActionTile(
                  icon: AppIcons.infoIcon,
                  label: 'Data Source Disclaimer',
                  onTap: () => context.push(ToolRoutes.dataSourceDisclaimer),
                ),
                _AccountActionTile(
                  icon: AppIcons.person,
                  label: 'Sign Out',
                  isDestructive: true,
                  isLoading: accountState.isBusy,
                  onTap: accountState.isBusy ? null : _handleSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  const _AccountHeaderCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppEffects.roundedXL,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppEffects.roundedXL,
          border: Border.all(
            color: AppColors.border,
            width: AppSpacing.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.profile,
                color: AppColors.primaryDark,
                size: AppSpacing.iconLG,
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineExtraSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapXS),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.arrowForward,
              color: AppColors.iconDefault,
              size: AppSpacing.iconMD,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  const _AccountActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMD),
      leading: Icon(icon, color: color, size: AppSpacing.iconMD),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: color,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: AppSpacing.iconSM,
              height: AppSpacing.iconSM,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              AppIcons.arrowForward,
              color: isDestructive ? AppColors.error : AppColors.iconDefault,
            ),
      onTap: onTap,
    );
  }
}
