import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

enum LegalDocumentType { termsOfService, privacyPolicy }

/// Displays a static legal document in-app.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.documentType});

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final isTerms = documentType == LegalDocumentType.termsOfService;
    final title = isTerms ? 'Terms of Service' : 'Privacy Policy';
    final sections = isTerms ? _termsSections : _privacySections;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
            context.go(AuthRoutes.auth);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: 13 February 2026',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.gapLG),
              for (final section in sections) ...[
                Text(
                  section.title,
                  style: AppTypography.headlineExtraSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSM),
                Text(
                  section.body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapLG),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

const List<_LegalSection> _termsSections = [
  _LegalSection(
    title: '1. Important medical disclaimer',
    body:
        'Zeyra is an informational tool and is not medical advice. Always seek guidance from qualified healthcare professionals for diagnosis, treatment, or urgent concerns.',
  ),
  _LegalSection(
    title: '2. Data sources and accuracy',
    body:
        'Hospital and maternity information may include public-source data (including CQC data). We do not own all source data and cannot guarantee it is complete, up to date, or error free.',
  ),
  _LegalSection(
    title: '3. User responsibility',
    body:
        'You are responsible for verifying critical information directly with hospitals, NHS services, or official providers before making healthcare decisions.',
  ),
  _LegalSection(
    title: '4. Service availability',
    body:
        'This app is provided free of charge and on an "as is" basis. We may update, limit, or discontinue features at any time without notice.',
  ),
  _LegalSection(
    title: '5. Open-source transparency',
    body:
        'The app code is publicly available. Do not treat source availability as a clinical guarantee. You should still verify outputs against trusted medical sources.',
  ),
  _LegalSection(
    title: '6. Limitation of liability',
    body:
        'To the maximum extent permitted by law, we are not liable for losses resulting from reliance on app content, outages, or third-party data inaccuracies.',
  ),
];

const List<_LegalSection> _privacySections = [
  _LegalSection(
    title: '1. What this app stores',
    body:
        'For core functionality, your pregnancy profile and app settings are stored locally on your device. Authentication data is handled by Supabase when you sign in.',
  ),
  _LegalSection(
    title: '2. Analytics and tracking',
    body:
        'At this time, no product analytics SDK is configured. We do not currently run user-behavior analytics for marketing or growth tracking.',
  ),
  _LegalSection(
    title: '3. Error monitoring',
    body:
        'If Sentry is enabled in deployment configuration, crash and error diagnostics may be sent to help improve reliability. Data is scrubbed to reduce personal data exposure.',
  ),
  _LegalSection(
    title: '4. Third-party services',
    body:
        'Certain features call third-party services such as Supabase (authentication/data), Google Maps/Distance Matrix, and postcodes.io. Their own privacy terms also apply.',
  ),
  _LegalSection(
    title: '5. Public health data',
    body:
        'Hospital details may include public data sources such as CQC datasets. Accuracy and timeliness of these sources cannot be guaranteed.',
  ),
  _LegalSection(
    title: '6. Security and contact',
    body:
        'We aim to protect data through secure local storage and encryption where implemented. If you identify a privacy/security issue, please report it through the project repository.',
  ),
];
