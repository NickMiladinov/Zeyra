import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/main_providers.dart';
import '../../../../core/services/drive_time_service.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../logic/hospital_detail_state.dart';
import '../../logic/hospital_shortlist_state.dart';
import 'cqc_rating_section.dart';
import 'hospital_contact_section.dart';
import 'hospital_detail_header.dart';
import 'place_rating_section.dart';
import 'questions_to_ask_section.dart';

/// Full-screen bottom overlay displaying detailed maternity unit information.
///
/// This overlay expands from the HospitalPreviewSheet and displays:
/// - Map preview
/// - Hospital identity and address
/// - Action buttons (shortlist, set as my hospital)
/// - Distance and travel time
/// - CQC ratings
/// - Questions to ask on tour
/// - PLACE ratings
/// - Contact actions and official links
class HospitalDetailOverlay extends ConsumerStatefulWidget {
  /// The maternity unit to display.
  final MaternityUnit unit;

  /// Distance from user in miles (calculated via Haversine).
  final double? distanceMiles;

  /// User's origin coordinates for drive time calculation.
  final double? userLat;
  final double? userLng;

  /// Scroll controller for the draggable sheet.
  final ScrollController scrollController;

  /// Callback when the overlay is closed.
  final VoidCallback onClose;

  const HospitalDetailOverlay({
    super.key,
    required this.unit,
    this.distanceMiles,
    this.userLat,
    this.userLng,
    required this.scrollController,
    required this.onClose,
  });

  @override
  ConsumerState<HospitalDetailOverlay> createState() =>
      _HospitalDetailOverlayState();
}

class _HospitalDetailOverlayState extends ConsumerState<HospitalDetailOverlay> {
  /// Drive time result from the API.
  DriveTimeResult? _driveTime;

  /// Whether drive time is loading.
  bool _isLoadingDriveTime = false;

  /// Whether final hospital selection action is in progress.
  bool _isSettingFinalChoice = false;
  bool _hasInitializedDetailState = false;

  @override
  void initState() {
    super.initState();
    _fetchDriveTime();
  }

  /// Initialize the detail state notifier.
  void _initializeDetailState() {
    // Set the unit in detail state for shortlist management
    ref
        .read(hospitalDetailProvider.notifier)
        .setUnit(
          widget.unit,
          userLat: widget.userLat,
          userLng: widget.userLng,
        );
  }

  bool _areDetailDependenciesReady() {
    final getDetailAsync = ref.read(getUnitDetailUseCaseProvider);
    final manageShortlistAsync = ref.read(manageShortlistUseCaseProvider);
    return getDetailAsync.hasValue && manageShortlistAsync.hasValue;
  }

  /// Fetch drive time from the API.
  Future<void> _fetchDriveTime() async {
    if (widget.userLat == null ||
        widget.userLng == null ||
        widget.unit.latitude == null ||
        widget.unit.longitude == null) {
      return;
    }

    setState(() {
      _isLoadingDriveTime = true;
      _driveTime = null;
    });

    final driveTimeService = ref.read(driveTimeServiceProvider);
    final result = await driveTimeService.getDriveTime(
      originLat: widget.userLat!,
      originLng: widget.userLng!,
      destLat: widget.unit.latitude!,
      destLng: widget.unit.longitude!,
    );

    if (mounted) {
      setState(() {
        _driveTime = result;
        _isLoadingDriveTime = false;
      });
    }
  }

  Future<void> _toggleShortlist() async {
    final wasShortlisted = ref.read(hospitalDetailProvider).isShortlisted;
    final isShortlisted = await ref
        .read(hospitalDetailProvider.notifier)
        .toggleShortlist();
    await ref.read(hospitalShortlistProvider.notifier).refresh();

    // toggleShortlist() returns the new shortlist state, not a success flag.
    // A successful "remove" returns false, so we validate by state change.
    final didChange = isShortlisted != wasShortlisted;
    if (!didChange && mounted) {
      _showMessage('Unable to update shortlist. Please try again.');
    }
  }

  Future<void> _setAsMyHospital() async {
    if (_isSettingFinalChoice) return;

    setState(() {
      _isSettingFinalChoice = true;
    });

    try {
      final detailNotifier = ref.read(hospitalDetailProvider.notifier);
      var isShortlisted = ref.read(hospitalDetailProvider).isShortlisted;

      // A hospital must exist in shortlist before it can be selected as final.
      if (!isShortlisted) {
        isShortlisted = await detailNotifier.toggleShortlist();
      }

      if (!isShortlisted) {
        _showMessage('Unable to shortlist this hospital. Please try again.');
        return;
      }

      final shortlistNotifier = ref.read(hospitalShortlistProvider.notifier);
      await shortlistNotifier.refresh();

      final shortlistState = ref.read(hospitalShortlistProvider);
      final shortlistId = _findShortlistIdForUnit(
        shortlistState,
        widget.unit.id,
      );

      if (shortlistId == null) {
        _showMessage('Unable to find this hospital in your shortlist.');
        return;
      }

      final selected = await shortlistNotifier.selectFinalChoice(shortlistId);
      if (!selected) {
        _showMessage('Unable to set final choice. Please try again.');
        return;
      }

      _showMessage('Hospital set as your final choice.');
    } finally {
      if (mounted) {
        setState(() {
          _isSettingFinalChoice = false;
        });
      }
    }
  }

  Future<void> _clearFinalChoice() async {
    if (_isSettingFinalChoice) return;

    setState(() {
      _isSettingFinalChoice = true;
    });

    try {
      final success = await ref
          .read(hospitalShortlistProvider.notifier)
          .clearSelection();
      if (!success) {
        _showMessage('Unable to clear final choice. Please try again.');
        return;
      }

      _showMessage('Final choice cleared.');
    } finally {
      if (mounted) {
        setState(() {
          _isSettingFinalChoice = false;
        });
      }
    }
  }

  String? _findShortlistIdForUnit(
    HospitalShortlistState state,
    String maternityUnitId,
  ) {
    for (final entry in state.shortlistedUnits) {
      if (entry.unit.id == maternityUnitId) {
        return entry.shortlist.id;
      }
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final getDetailAsync = ref.watch(getUnitDetailUseCaseProvider);
    final manageShortlistAsync = ref.watch(manageShortlistUseCaseProvider);
    final isDetailReady = getDetailAsync.hasValue && manageShortlistAsync.hasValue;

    if (isDetailReady && !_hasInitializedDetailState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasInitializedDetailState) return;
        if (!_areDetailDependenciesReady()) return;
        _initializeDetailState();
        _hasInitializedDetailState = true;
      });
    }

    final detailState = isDetailReady
        ? ref.watch(hospitalDetailProvider)
        : const HospitalDetailState();
    final shortlistState = ref.watch(hospitalShortlistProvider);
    final isCurrentUnitFinalChoice =
        shortlistState.selectedHospital?.unit.id == widget.unit.id;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppEffects.roundedTopXXL,
      ),
      // Use CustomScrollView so the drag handle is part of the scrollable area
      // This allows dragging on the header to expand/collapse the sheet
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          // Header with drag handle and close button (part of scroll view)
          SliverToBoxAdapter(
            child: HospitalDetailHeader(onClose: widget.onClose),
          ),

          // Main content
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingHorizontal,
              AppSpacing.paddingSM,
              AppSpacing.screenPaddingHorizontal,
              AppSpacing.paddingXL + bottomPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Hospital identity
                _buildHospitalIdentity(),
                const SizedBox(height: AppSpacing.gapLG),

                // 2. Action buttons
                _buildActionButtons(
                  detailState,
                  isEnabled: isDetailReady && _hasInitializedDetailState,
                  isCurrentUnitFinalChoice: isCurrentUnitFinalChoice,
                ),
                const SizedBox(height: AppSpacing.gapLG),

                // 3. Distance and travel
                _buildDistanceRow(),
                const SizedBox(height: AppSpacing.gapXL),

                // 4. CQC Ratings section
                CqcRatingSection(unit: widget.unit),
                const SizedBox(height: AppSpacing.gapXL),

                // 5. Questions to Ask section
                QuestionsToAskSection(unit: widget.unit),
                const SizedBox(height: AppSpacing.gapXL),

                // 6. PLACE Ratings section (only if data available)
                if (widget.unit.hasPlaceData) ...[
                  PlaceRatingSection(unit: widget.unit),
                  const SizedBox(height: AppSpacing.gapXXL),
                ],

                // 7. Contact actions and links
                HospitalContactSection(unit: widget.unit),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the hospital identity section.
  Widget _buildHospitalIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hospital name
        Text(
          widget.unit.name,
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.gapSM),

        // Address
        Text(
          widget.unit.formattedAddress,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        // NHS badge
        if (widget.unit.isNhs) ...[
          const SizedBox(height: AppSpacing.gapMD),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingMD,
              vertical: AppSpacing.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.infoDark,
              borderRadius: BorderRadius.circular(AppEffects.radiusSM),
            ),
            child: Text(
              'NHS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build the action buttons row.
  Widget _buildActionButtons(
    HospitalDetailState detailState, {
    required bool isEnabled,
    required bool isCurrentUnitFinalChoice,
  }) {
    return Row(
      children: [
        // Save to Shortlist button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isEnabled ? _toggleShortlist : null,
            icon: Icon(
              AppIcons.favorite,
              size: AppSpacing.iconXS,
              color: detailState.isShortlisted
                  ? AppColors.primaryDark
                  : AppColors.textPrimary,
              fill: detailState.isShortlisted ? 1.0 : 0.0,
            ),
            label: Text(
              detailState.isShortlisted ? 'Saved' : 'Save to Shortlist',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.paddingMD,
              ),
              side: BorderSide(
                color: detailState.isShortlisted
                    ? AppColors.primaryDark
                    : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapMD),

        // Set as My Hospital button
        Expanded(
          child: ElevatedButton(
            onPressed: !isEnabled || _isSettingFinalChoice
                ? null
                : (isCurrentUnitFinalChoice
                      ? _clearFinalChoice
                      : _setAsMyHospital),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentUnitFinalChoice
                  ? AppColors.error
                  : AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.paddingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
              ),
              elevation: 0,
            ),
            child: _isSettingFinalChoice
                ? SizedBox(
                    width: AppSpacing.iconXXS,
                    height: AppSpacing.iconXXS,
                    child: const CircularProgressIndicator(
                      strokeWidth: AppSpacing.borderWidthThin,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    isCurrentUnitFinalChoice
                        ? 'Clear Final Choice'
                        : 'Set as My Hospital',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Build the distance and travel time row.
  Widget _buildDistanceRow() {
    final distanceText = widget.distanceMiles != null
        ? '${widget.distanceMiles!.toStringAsFixed(1)} miles'
        : null;

    final driveTimeText = _driveTime != null
        ? '~${_driveTime!.durationMinutes} min drive'
        : null;

    // Build the display text
    String displayText;
    if (distanceText != null && driveTimeText != null) {
      displayText = '$distanceText • $driveTimeText';
    } else if (distanceText != null) {
      displayText = distanceText;
    } else {
      displayText = 'Distance unknown';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.directionsCar,
            color: AppColors.primaryDark,
            size: AppSpacing.iconXS,
          ),
          const SizedBox(width: AppSpacing.gapSM),
          if (_isLoadingDriveTime && widget.distanceMiles != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.distanceMiles!.toStringAsFixed(1)} miles • ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(
                  width: AppSpacing.iconXXS,
                  height: AppSpacing.iconXXS,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.borderWidthMedium,
                    color: AppColors.iconDefault,
                  ),
                ),
              ],
            )
          else
            Text(
              displayText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows the hospital detail overlay as an expandable modal bottom sheet.
///
/// The overlay starts at 50% height and can be expanded to full screen.
/// Tapping outside the overlay dismisses it.
void showHospitalDetailOverlay({
  required BuildContext context,
  required MaternityUnit unit,
  double? distanceMiles,
  double? userLat,
  double? userLng,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    isDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // Prevent taps on the sheet from dismissing
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        snapSizes: const [0.5, 0.95],
        builder: (context, scrollController) => HospitalDetailOverlay(
          unit: unit,
          distanceMiles: distanceMiles,
          userLat: userLat,
          userLng: userLng,
          scrollController: scrollController,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}
