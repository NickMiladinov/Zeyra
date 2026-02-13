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
import '../../logic/hospital_shortlist_state.dart';
import '../../logic/hospital_shortlist_workspace_ui_state.dart';
import '../widgets/hospital_detail_overlay.dart';
import '../widgets/hospital_shortlist_checklist_section.dart';
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

    if (!manageShortlistAsync.hasValue || !selectFinalAsync.hasValue) {
      return _buildLoadingScaffold(context);
    }

    final shortlistState = ref.watch(hospitalShortlistProvider);
    final workspaceUiState = ref.watch(hospitalShortlistWorkspaceUiProvider);
    final workspaceUiNotifier = ref.read(
      hospitalShortlistWorkspaceUiProvider.notifier,
    );

    final hasShortlist = shortlistState.shortlistedUnits.isNotEmpty;
    final hasFinalChoice = shortlistState.selectedHospital != null;
    final hasCompletedFinalChoiceStep =
        hasFinalChoice || workspaceUiState.hasMarkedFinalChoiceStep;

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Hospital Workspace',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
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
            HospitalShortlistChecklistSection(
              hasShortlist: hasShortlist,
              hasFinalChoice: hasFinalChoice,
              hasVisitedOrContactedTopChoices:
                  workspaceUiState.hasVisitedOrContactedTopChoices,
              hasMarkedFinalChoiceStep: hasCompletedFinalChoiceStep,
              hasRegisteredWithChosenHospital:
                  workspaceUiState.hasRegisteredWithChosenHospital,
              onCreateShortlistTap: hasShortlist
                  ? null
                  : () => _openExploreHospitals(context),
              onVisitedOrContactedTap:
                  workspaceUiNotifier.toggleVisitedOrContactedTopChoices,
              onFinalChoiceStepTap: hasFinalChoice
                  ? null
                  : workspaceUiNotifier.toggleFinalChoiceStep,
              onRegisteredTap:
                  workspaceUiNotifier.toggleRegisteredWithChosenHospital,
            ),
            const SizedBox(height: AppSpacing.gapXL),
            HospitalShortlistFinalChoiceSection(
              selectedHospital: shortlistState.selectedHospital,
              onClearSelectionTap: hasFinalChoice
                  ? () => _clearSelection(context, ref)
                  : null,
              onFinalChoiceTap: hasFinalChoice
                  ? (shortlistWithUnit) =>
                        _openHospitalDetails(context, shortlistWithUnit)
                  : null,
            ),
            const SizedBox(height: AppSpacing.gapXL),
            HospitalShortlistSection(
              shortlistedUnits: shortlistState.shortlistedUnits,
              selectingShortlistId: workspaceUiState.selectingShortlistId,
              selectedShortlistId:
                  shortlistState.selectedHospital?.shortlist.id,
              onSetFinalChoiceTap: (shortlistWithUnit) =>
                  _setFinalChoice(context, ref, shortlistWithUnit),
              onHospitalTap: (shortlistWithUnit) =>
                  _openHospitalDetails(context, shortlistWithUnit),
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
        leading: IconButton(
          icon: const Icon(
            AppIcons.back,
            color: AppColors.iconDefault,
            size: AppSpacing.iconMD,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Hospital Workspace',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  void _openExploreHospitals(BuildContext context) {
    context.push(ToolRoutes.hospitalChooserExplore);
  }

  Future<void> _setFinalChoice(
    BuildContext context,
    WidgetRef ref,
    ShortlistWithUnit shortlistWithUnit,
  ) async {
    final workspaceUiNotifier = ref.read(
      hospitalShortlistWorkspaceUiProvider.notifier,
    );
    final workspaceUiState = ref.read(hospitalShortlistWorkspaceUiProvider);
    if (workspaceUiState.selectingShortlistId != null) return;

    workspaceUiNotifier.startSelectingShortlist(shortlistWithUnit.shortlist.id);

    final success = await ref
        .read(hospitalShortlistProvider.notifier)
        .selectFinalChoice(shortlistWithUnit.shortlist.id);

    workspaceUiNotifier.finishSelectingShortlist();

    if (!success && context.mounted) {
      _showMessage(context, 'Unable to set final choice. Please try again.');
    }
  }

  Future<void> _clearSelection(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(hospitalShortlistProvider.notifier)
        .clearSelection();
    if (!success && context.mounted) {
      _showMessage(context, 'Unable to clear final choice. Please try again.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openHospitalDetails(
    BuildContext context,
    ShortlistWithUnit shortlistWithUnit,
  ) {
    showHospitalDetailOverlay(context: context, unit: shortlistWithUnit.unit);
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
