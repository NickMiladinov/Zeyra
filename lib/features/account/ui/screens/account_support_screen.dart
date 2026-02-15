import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class AccountSupportScreen extends StatefulWidget {
  const AccountSupportScreen({super.key});

  @override
  State<AccountSupportScreen> createState() => _AccountSupportScreenState();
}

class _AccountSupportScreenState extends State<AccountSupportScreen> {
  static const String _supportEmail = 'zeyraapp@gmail.com';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add feedback before sending.')),
      );
      return;
    }

    setState(() => _isSending = true);

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Zeyra feedback',
        'body': feedback,
      },
    );

    final launched = await launchUrl(uri);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open your email app. Please email us directly.'),
        ),
      );
      return;
    }

    _feedbackController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
          'Support & Feedback',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact email',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapXS),
                Text(
                  _supportEmail,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gapLG),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send feedback',
                  style: AppTypography.headlineExtraSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSM),
                TextField(
                  controller: _feedbackController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Tell us what can be improved...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.gapMD),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSending ? null : _sendFeedback,
                    child: _isSending
                        ? const SizedBox(
                            width: AppSpacing.iconSM,
                            height: AppSpacing.iconSM,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send via email'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
