import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/main_providers.dart';
import '../../../../core/services/drive_time_service.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';

/// A preview bottom sheet that shows when a hospital is selected.
///
/// Displays hospital name, distance/drive time, CQC ratings preview,
/// and a "Show More Details" button.
class HospitalPreviewSheet extends ConsumerStatefulWidget {
  /// The maternity unit to display.
  final MaternityUnit unit;

  /// Distance from user in miles (calculated via Haversine).
  final double? distanceMiles;

  /// User's origin coordinates for drive time calculation.
  final double? userLat;
  final double? userLng;

  /// Callback when "Show More Details" is tapped.
  final VoidCallback onShowDetails;

  /// Callback when the sheet is dismissed.
  final VoidCallback? onDismiss;

  const HospitalPreviewSheet({
    super.key,
    required this.unit,
    this.distanceMiles,
    this.userLat,
    this.userLng,
    required this.onShowDetails,
    this.onDismiss,
  });

  @override
  ConsumerState<HospitalPreviewSheet> createState() =>
      _HospitalPreviewSheetState();
}

class _HospitalPreviewSheetState extends ConsumerState<HospitalPreviewSheet> {
  /// Drive time result from the API.
  DriveTimeResult? _driveTime;

  /// Whether drive time is loading.
  bool _isLoadingDriveTime = false;

  @override
  void initState() {
    super.initState();
    _fetchDriveTime();
  }

  @override
  void didUpdateWidget(HospitalPreviewSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch drive time if the unit changes
    if (oldWidget.unit.id != widget.unit.id) {
      _fetchDriveTime();
    }
  }

  /// Fetch drive time from the API.
  Future<void> _fetchDriveTime() async {
    // Need valid origin and destination coordinates
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppEffects.roundedTopXXL,
        boxShadow: AppEffects.shadowLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const _DragHandle(),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.paddingXL,
              AppSpacing.paddingSM,
              AppSpacing.paddingXL,
              AppSpacing.paddingXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hospital name
                Text(
                  widget.unit.name,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.gapMD),

                // Distance and drive time row
                _buildDistanceRow(),
                const SizedBox(height: AppSpacing.gapXL),

                // CQC Ratings section
                _buildRatingsSection(),
                const SizedBox(height: AppSpacing.gapXL),

                // Show More Details button
                _buildDetailsButton(),
              ],
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build the distance and drive time row.
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_car_outlined,
          color: AppColors.textSecondary,
          size: AppSpacing.iconXS,
        ),
        const SizedBox(width: AppSpacing.gapSM),
        if (_isLoadingDriveTime && widget.distanceMiles != null)
          // Show distance with loading indicator for drive time
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
    );
  }

  /// Build the CQC ratings section.
  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Official CQC Ratings',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.gapMD),

        // Rating rows
        _RatingRow(
          label: 'Overall',
          rating: widget.unit.overallRatingEnum,
        ),
        const SizedBox(height: AppSpacing.gapSM),
        _RatingRow(
          label: 'Safe',
          rating: CqcRating.fromString(widget.unit.ratingSafe),
        ),
        const SizedBox(height: AppSpacing.gapSM),
        _RatingRow(
          label: 'Caring',
          rating: CqcRating.fromString(widget.unit.ratingCaring),
        ),
      ],
    );
  }

  /// Build the "Show More Details" button.
  Widget _buildDetailsButton() {
    return ElevatedButton(
      onPressed: widget.onShowDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusLG),
        ),
        elevation: 0,
      ),
      child: Text(
        'Show More Details',
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Drag handle widget for the bottom sheet.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.marginMD,
        bottom: AppSpacing.marginSM,
      ),
      width: AppSpacing.dragHandleWidth,
      height: AppSpacing.dragHandleHeight,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey400,
        borderRadius: BorderRadius.circular(AppEffects.radiusSM),
      ),
    );
  }
}

/// A row displaying a rating category and its value.
class _RatingRow extends StatelessWidget {
  final String label;
  final CqcRating rating;

  const _RatingRow({
    required this.label,
    required this.rating,
  });

  /// Get the color for the rating badge.
  Color _getBadgeColor() {
    switch (rating) {
      case CqcRating.outstanding:
        return AppColors.primary;
      case CqcRating.good:
        return AppColors.primary; // Solid teal for Good rating
      case CqcRating.requiresImprovement:
        return AppColors.warning;
      case CqcRating.inadequate:
        return AppColors.error;
      case CqcRating.notRated:
        return AppColors.backgroundGrey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMD,
        vertical: AppSpacing.paddingSM + 2, // Slightly taller rows to match design
      ),
      decoration: BoxDecoration(
        color: AppColors.background, // Lighter background to match design
        borderRadius: BorderRadius.circular(AppEffects.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingSM,
              vertical: AppSpacing.paddingXS,
            ),
            decoration: BoxDecoration(
              color: _getBadgeColor(),
              borderRadius: BorderRadius.circular(AppEffects.radiusSM),
            ),
            child: Text(
              rating.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
