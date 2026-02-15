import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../account/logic/account_notifier.dart';

/// Detailed account management screen.
class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  ConsumerState<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountNotifierProvider.notifier).refreshIdentity();
    });
  }

  Future<void> _deleteAccount() async {
    final success = await ref.read(accountNotifierProvider.notifier).deleteAccount();
    if (!mounted) return;

    if (success) {
      context.go(AuthRoutes.auth);
      return;
    }

    final error = ref.read(accountNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Could not delete account right now. Please try again.',
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all local data for this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    final identity = state.identity;
    final providerLabel = identity?.providerLabel ?? 'OAuth';
    final email = identity?.email ?? 'No email available';

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
            context.go(ToolRoutes.account);
          },
        ),
        title: Text(
          'Account Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
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
                _InfoRow(label: 'Provider', value: providerLabel),
                const SizedBox(height: AppSpacing.gapMD),
                _InfoRow(label: 'Email', value: email),
              ],
            ),
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
                ListTile(
                  leading: const Icon(AppIcons.delete, color: AppColors.error),
                  title: Text(
                    'Delete Account',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: state.isBusy
                      ? const SizedBox(
                          width: AppSpacing.iconSM,
                          height: AppSpacing.iconSM,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          AppIcons.arrowForward,
                          color: AppColors.error,
                        ),
                  onTap: state.isBusy ? null : _confirmDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapMD),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
