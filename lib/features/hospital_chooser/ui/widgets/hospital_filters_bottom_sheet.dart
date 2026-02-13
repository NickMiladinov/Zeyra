import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';
import '../../../../domain/entities/hospital/maternity_unit.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet for filtering hospital results.
///
/// Allows users to filter by CQC rating and optionally distance.
class HospitalFiltersBottomSheet extends StatefulWidget {
  /// Current filter criteria.
  final HospitalFilterCriteria currentFilters;

  /// Callback when filters are applied.
  final void Function(HospitalFilterCriteria filters) onApply;
  
  /// Whether to show the distance filter (only for list view).
  final bool showDistanceFilter;

  const HospitalFiltersBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
    this.showDistanceFilter = false,
  });

  @override
  State<HospitalFiltersBottomSheet> createState() =>
      _HospitalFiltersBottomSheetState();
}

class _HospitalFiltersBottomSheetState
    extends State<HospitalFiltersBottomSheet> {
  late Set<CqcRating> _selectedRatings;
  late double _maxDistance;

  /// Min/max distance in miles for the slider.
  static const double _minDistance = 0.1;
  static const double _maxDistanceLimit = 50.0;
  
  /// Distance milestones for custom slider scale.
  /// These define the key points and their positions on the slider (0-1).
  /// This puts commonly used distances (1-5mi) in the first ~50% of the slider.
  static const List<(double distance, double position)> _milestones = [
    (0.1, 0.0),   // Min
    (0.5, 0.10),  // Half mile
    (1.0, 0.20),  // 1 mile
    (2.0, 0.30),  // 2 miles at 30%
    (3.0, 0.38),  // 3 miles
    (5.0, 0.50),  // 5 miles at 50%
    (10.0, 0.65), // 10 miles
    (15.0, 0.75), // 15 miles (default)
    (25.0, 0.85), // 25 miles
    (50.0, 1.0),  // Max
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current filters - use a copy of the set
    _selectedRatings = Set.from(widget.currentFilters.allowedRatings);
    _maxDistance = widget.currentFilters.maxDistanceMiles.clamp(_minDistance, _maxDistanceLimit);
  }

  /// Toggle a rating selection.
  void _toggleRating(CqcRating rating) {
    setState(() {
      if (_selectedRatings.contains(rating)) {
        // Don't allow deselecting all
        if (_selectedRatings.length > 1) {
          _selectedRatings.remove(rating);
        }
      } else {
        _selectedRatings.add(rating);
      }
    });
  }

  /// Reset filters to defaults.
  void _resetFilters() {
    setState(() {
      _selectedRatings = Set.from(HospitalFilterCriteria.allRatings);
      _maxDistance = 15.0; // Default distance
    });
  }

  /// Apply the filters and close the sheet.
  void _applyFilters() {
    final newFilters = widget.currentFilters.copyWith(
      allowedRatings: Set.from(_selectedRatings),
      maxDistanceMiles: _maxDistance,
    );
    widget.onApply(newFilters);
    Navigator.pop(context);
  }
  
  /// Convert distance value to slider position (0-1) using milestone interpolation.
  double _distanceToSlider(double distance) {
    final clampedDistance = distance.clamp(_minDistance, _maxDistanceLimit);
    
    // Find the two milestones we're between
    for (int i = 0; i < _milestones.length - 1; i++) {
      final (d1, p1) = _milestones[i];
      final (d2, p2) = _milestones[i + 1];
      
      if (clampedDistance >= d1 && clampedDistance <= d2) {
        // Linear interpolation between the two milestones
        final t = (clampedDistance - d1) / (d2 - d1);
        return p1 + t * (p2 - p1);
      }
    }
    
    return 1.0; // Fallback to max
  }
  
  /// Convert slider position (0-1) to distance using milestone interpolation.
  double _sliderToDistance(double sliderValue) {
    final clampedValue = sliderValue.clamp(0.0, 1.0);
    
    // Find the two milestones we're between
    for (int i = 0; i < _milestones.length - 1; i++) {
      final (d1, p1) = _milestones[i];
      final (d2, p2) = _milestones[i + 1];
      
      if (clampedValue >= p1 && clampedValue <= p2) {
        // Linear interpolation between the two milestones
        final t = (clampedValue - p1) / (p2 - p1);
        return d1 + t * (d2 - d1);
      }
    }
    
    return _maxDistanceLimit; // Fallback to max
  }
  
  /// Format distance for display (shows decimal for values < 5).
  String _formatDistance(double distance) {
    if (distance < 5) {
      return distance.toStringAsFixed(1);
    }
    return distance.round().toString();
  }
  
  /// Round distance to sensible values based on magnitude.
  double _roundDistance(double distance) {
    if (distance < 1) {
      // Round to 0.1 increments
      return (distance * 10).round() / 10;
    } else if (distance < 5) {
      // Round to 0.5 increments
      return (distance * 2).round() / 2;
    } else {
      // Round to whole numbers
      return distance.roundToDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      applyContentPadding: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset all',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gapXL),

            // CQC Rating section
            Text(
              'CQC Rating',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.gapMD),

            // Rating chips grid
            _buildRatingGrid(),
            
            // Distance section (only shown in list view)
            if (widget.showDistanceFilter) ...[
              const SizedBox(height: AppSpacing.gapXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Up to ${_formatDistance(_maxDistance)}mi',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapSM),
              
              // Distance slider - exponential scale from 0.1 to 50 miles
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.backgroundGrey200,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                    elevation: 2,
                  ),
                ),
                child: Slider(
                  value: _distanceToSlider(_maxDistance),
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      final rawDistance = _sliderToDistance(value);
                      _maxDistance = _roundDistance(rawDistance);
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.gapXL),

            // Apply button
            FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppEffects.radiusCircle),
                ),
              ),
              child: const Text('Show Hospitals'),
            ),
            const SizedBox(height: AppSpacing.gapMD),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingGrid() {
    return Column(
      children: [
        // First row: Outstanding and Good
        Row(
          children: [
            Expanded(
              child: _RatingChip(
                rating: CqcRating.outstanding,
                isSelected: _selectedRatings.contains(CqcRating.outstanding),
                onTap: () => _toggleRating(CqcRating.outstanding),
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: _RatingChip(
                rating: CqcRating.good,
                isSelected: _selectedRatings.contains(CqcRating.good),
                onTap: () => _toggleRating(CqcRating.good),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gapMD),
        // Second row: Requires Improvement and Inadequate
        Row(
          children: [
            Expanded(
              child: _RatingChip(
                rating: CqcRating.requiresImprovement,
                isSelected:
                    _selectedRatings.contains(CqcRating.requiresImprovement),
                onTap: () => _toggleRating(CqcRating.requiresImprovement),
              ),
            ),
            const SizedBox(width: AppSpacing.gapMD),
            Expanded(
              child: _RatingChip(
                rating: CqcRating.inadequate,
                isSelected: _selectedRatings.contains(CqcRating.inadequate),
                onTap: () => _toggleRating(CqcRating.inadequate),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A selectable chip for CQC rating.
class _RatingChip extends StatelessWidget {
  final CqcRating rating;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingChip({
    required this.rating,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (rating) {
      case CqcRating.outstanding:
        return AppIcons.starRating;
      case CqcRating.good:
        return AppIcons.checkIcon;
      case CqcRating.requiresImprovement:
        return AppIcons.infoIcon;
      case CqcRating.inadequate:
        return AppIcons.warningIcon;
      case CqcRating.notRated:
        return AppIcons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.paddingMD,
          horizontal: AppSpacing.paddingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppEffects.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: AppSpacing.borderWidthThin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              color: isSelected ? AppColors.textPrimary: AppColors.iconDefault,
              size: AppSpacing.iconSM,
            ),
            const SizedBox(height: AppSpacing.gapXS),
            Text(
              rating.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
