import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/main_providers.dart';
import '../../../../core/services/drive_time_service.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../logic/hospital_detail_state.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDriveTime();
    _initializeDetailState();
  }

  /// Initialize the detail state notifier.
  void _initializeDetailState() {
    // Set the unit in detail state for shortlist management
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hospitalDetailProvider.notifier).setUnit(
            widget.unit,
            userLat: widget.userLat,
            userLng: widget.userLng,
          );
    });
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

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(hospitalDetailProvider);
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
                _buildActionButtons(detailState),
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
                  const SizedBox(height: AppSpacing.gapXL),
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

        // Provider name (if available)
        if (widget.unit.providerName != null &&
            widget.unit.providerName!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.gapXS),
          Text(
            widget.unit.providerName!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],

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
  Widget _buildActionButtons(HospitalDetailState detailState) {
    return Row(
      children: [
        // Save to Shortlist button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(hospitalDetailProvider.notifier).toggleShortlist();
            },
            icon: Icon(
              detailState.isShortlisted
                  ? Icons.favorite
                  : Icons.favorite_border,
              size: AppSpacing.iconXS,
              color: detailState.isShortlisted
                  ? AppColors.error
                  : AppColors.textPrimary,
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
                    ? AppColors.error
                    : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusLG),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapMD),

        // Set as My Hospital button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement set as my hospital functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.paddingMD,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppEffects.radiusLG),
              ),
              elevation: 0,
            ),
            child: Text(
              'Set as My Hospital',
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            color: AppColors.textSecondary,
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
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
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
