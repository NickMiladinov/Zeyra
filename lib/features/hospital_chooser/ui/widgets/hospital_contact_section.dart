import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// Displays contact actions and official information links for a maternity unit.
///
/// Includes buttons to call the maternity unit and get directions,
/// as well as links to the NHS hospital page and full CQC report.
class HospitalContactSection extends StatelessWidget {
  /// The maternity unit containing contact information.
  final MaternityUnit unit;

  const HospitalContactSection({
    super.key,
    required this.unit,
  });

  /// Open the phone dialer with the maternity unit's phone number.
  Future<void> _callMaternityUnit() async {
    if (unit.phone == null || unit.phone!.isEmpty) return;

    final uri = Uri.parse('tel:${unit.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Open the maps app with directions to the maternity unit.
  Future<void> _getDirections() async {
    if (unit.latitude == null || unit.longitude == null) return;

    // Use Google Maps URL format that works on both iOS and Android
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${unit.latitude},${unit.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Open the NHS hospital website.
  Future<void> _openWebsite() async {
    if (unit.website == null || unit.website!.isEmpty) return;

    try {
      // Ensure the URL has a proper scheme
      String url = unit.website!;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Silently fail if URL cannot be launched
      debugPrint('Failed to open website: $e');
    }
  }

  /// Open the CQC report page.
  Future<void> _openCqcReport() async {
    if (unit.cqcReportUrl == null || unit.cqcReportUrl!.isEmpty) return;

    try {
      // Ensure the URL has a proper scheme
      String url = unit.cqcReportUrl!;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Silently fail if URL cannot be launched
      debugPrint('Failed to open CQC report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = unit.phone != null && unit.phone!.isNotEmpty;
    final hasLocation = unit.latitude != null && unit.longitude != null;
    final hasWebsite = unit.website != null && unit.website!.isNotEmpty;
    final hasCqcReport =
        unit.cqcReportUrl != null && unit.cqcReportUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact action buttons
        if (hasPhone || hasLocation) ...[
          Row(
            children: [
              // Call button
              if (hasPhone)
                Expanded(
                  child: _ActionButton(
                    icon: AppIcons.phone,
                    label: 'Call Maternity Unit',
                    onTap: _callMaternityUnit,
                    isPrimary: true,
                  ),
                ),
              if (hasPhone && hasLocation) const SizedBox(width: AppSpacing.gapMD),

              // Directions button
              if (hasLocation)
                Expanded(
                  child: _ActionButton(
                    icon: AppIcons.location,
                    label: 'Get Directions',
                    onTap: _getDirections,
                    isPrimary: false,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapXL),
        ],

        // Official information links
        if (hasWebsite || hasCqcReport) ...[
          Text(
            'Official Information',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.gapXL),

          // NHS Hospital Page link
          if (hasWebsite) ...[
            _LinkRow(
              icon: AppIcons.add,
              label: 'Hospital/Maternity Unit Website',
              onTap: _openWebsite,
            ),
            const SizedBox(height: AppSpacing.gapLG),
          ],

          // CQC Report link
          if (hasCqcReport)
            Container(
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: AppSpacing.gapLG),
            _LinkRow(
              icon: AppIcons.file,
              label: 'Full CQC Report',
              onTap: _openCqcReport,
            ),
            const SizedBox(height: AppSpacing.gapXL),
        ],
      ],
    );
  }
}

/// An action button with icon and label.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.secondary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppEffects.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingMD,
            vertical: AppSpacing.paddingMD,
          ),
          decoration: BoxDecoration(
            border: isPrimary
                ? null
                : Border.all(color: AppColors.backgroundGrey500, width: AppSpacing.borderWidthThin),
            borderRadius: BorderRadius.circular(AppEffects.radiusLG),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSpacing.iconXS,
                color: isPrimary ? AppColors.white : AppColors.secondary,
                fill: isPrimary ? 0.0 : 1.0,
              ),
              const SizedBox(width: AppSpacing.gapSM),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? AppColors.white : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row displaying an external link with icon.
class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
        child: Row(
          children: [
            // Icon in a rounded square
            Container(
              width: AppSpacing.iconLG,
              height: AppSpacing.iconLG,
              decoration: BoxDecoration(
                color: AppColors.infoDark,
                borderRadius: BorderRadius.circular(AppEffects.radiusMD),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: AppSpacing.iconSM,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),

            // Label
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // External link icon
            Icon(
              AppIcons.newTab,
              size: AppSpacing.iconXS,
              color: AppColors.iconDefault,
            ),
          ],
        ),
      ),
    );
  }
}
