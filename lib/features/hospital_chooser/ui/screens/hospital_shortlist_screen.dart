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
import '../../../../domain/repositories/hospital_shortlist_repository.dart';
import '../../logic/hospital_location_state.dart';
import '../../logic/hospital_shortlist_state.dart';
import '../widgets/hospital_detail_overlay.dart';
import '../widgets/hospital_shortlist_explore_card.dart';
import '../widgets/hospital_shortlist_final_choice_section.dart';
import '../widgets/hospital_shortlist_section.dart';

/// Workspace screen for managing shortlisted hospitals and final choice.
class HospitalShortlistScreen extends ConsumerWidget {
  const HospitalShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manageShortlistAsync = ref.watch(manageShortlistUseCaseProvider);
    final selectFinalAsync = ref.watch(selectFinalHospitalUseCaseProvider);

    if (manageShortlistAsync.asData?.value == null ||
        selectFinalAsync.asData?.value == null) {
      return _buildLoadingScaffold(context);
    }

    final shortlistState = ref.watch(hospitalShortlistProvider);
    final hasFinalChoice = shortlistState.selectedHospital != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationNone,
        automaticallyImplyLeading: false,
        title: Text(
          'My Hospital Workspace',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              AppIcons.profile,
              color: AppColors.iconDefault,
              size: AppSpacing.iconMD,
            ),
            onPressed: () => context.push(ToolRoutes.account),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(hospitalShortlistProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.paddingLG,
            AppSpacing.paddingLG,
            AppSpacing.paddingLG,
            AppSpacing.paddingLG + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            HospitalShortlistExploreCard(
              onExploreTap: () => _openExploreHospitals(context),
            ),
            const SizedBox(height: AppSpacing.gapXL),
            HospitalShortlistFinalChoiceSection(
              selectedHospital: shortlistState.selectedHospital,
              onClearSelectionTap: hasFinalChoice
                  ? () => _clearSelection(context, ref)
                  : null,
              onFinalChoiceTap: hasFinalChoice
                  ? (shortlistWithUnit) =>
                        _openHospitalDetails(context, ref, shortlistWithUnit)
                  : null,
            ),
            const SizedBox(height: AppSpacing.gapXL),
            HospitalShortlistSection(
              shortlistedUnits: shortlistState.shortlistedUnits,
              onHospitalTap: (shortlistWithUnit) =>
                  _openHospitalDetails(context, ref, shortlistWithUnit),
              onShortlistTap: (shortlistWithUnit) =>
                  _toggleShortlist(context, ref, shortlistWithUnit),
              onExploreHospitalsTap: () => _openExploreHospitals(context),
            ),
            if (shortlistState.isLoading) ...[
              const SizedBox(height: AppSpacing.gapLG),
              const Center(child: CircularProgressIndicator()),
            ],
            if (shortlistState.error != null) ...[
              const SizedBox(height: AppSpacing.gapLG),
              _InlineErrorCard(message: shortlistState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Scaffold _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationNone,
        automaticallyImplyLeading: false,
        title: Text(
          'My Hospital Workspace',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              AppIcons.profile,
              color: AppColors.iconDefault,
              size: AppSpacing.iconMD,
            ),
            onPressed: () => context.push(ToolRoutes.account),
          ),
        ],
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  void _openExploreHospitals(BuildContext context) {
    context.push(ToolRoutes.hospitalChooserExplore);
  }

  Future<void> _clearSelection(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(hospitalShortlistProvider.notifier)
        .clearSelection();
    if (!success && context.mounted) {
      _showMessage(context, 'Unable to clear final choice. Please try again.');
    }
  }

  Future<void> _toggleShortlist(
    BuildContext context,
    WidgetRef ref,
    ShortlistWithUnit shortlistWithUnit,
  ) async {
    final success = await ref
        .read(hospitalShortlistProvider.notifier)
        .removeFromShortlist(shortlistWithUnit.unit.id);
    if (!success && context.mounted) {
      _showMessage(context, 'Unable to update shortlist. Please try again.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openHospitalDetails(
    BuildContext context,
    WidgetRef ref,
    ShortlistWithUnit shortlistWithUnit,
  ) {
    final locationState = ref.read(hospitalLocationProvider);
    final distanceMiles = locationState.userLocation != null
        ? shortlistWithUnit.unit.distanceFrom(
            locationState.userLocation!.latitude,
            locationState.userLocation!.longitude,
          )
        : null;

    showHospitalDetailOverlay(
      context: context,
      unit: shortlistWithUnit.unit,
      distanceMiles: distanceMiles,
      userLat: locationState.userLocation?.latitude,
      userLng: locationState.userLocation?.longitude,
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  final String message;

  const _InlineErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
        border: Border.all(
          color: AppColors.errorLight,
          width: AppSpacing.borderWidthThin,
        ),
      ),
      child: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.errorDark),
      ),
    );
  }
}
