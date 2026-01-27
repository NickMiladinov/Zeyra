import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/hospital/hospital_filter_criteria.dart';

/// Search bar with filter button for hospital search.
///
/// Displays a search input field with a clear button (when text is present)
/// and a filter button that indicates when filters are active.
class HospitalSearchBar extends StatefulWidget {
  /// Controller for the search text field.
  final TextEditingController controller;

  /// Focus node for the search text field.
  final FocusNode? focusNode;

  /// Current filter criteria (used to show active filter indicator).
  final HospitalFilterCriteria filters;

  /// Callback when filter button is tapped.
  final VoidCallback onFilterTap;

  /// Callback when clear button is tapped.
  final VoidCallback? onClear;

  const HospitalSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.filters,
    required this.onFilterTap,
    this.onClear,
  });

  @override
  State<HospitalSearchBar> createState() => _HospitalSearchBarState();
}

class _HospitalSearchBarState extends State<HospitalSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: true,
              decoration: InputDecoration(
                hintText: 'Search by hospital name...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                // Show clear button when there's text
                suffixIcon: _hasText
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: widget.onClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingMD,
                  vertical: AppSpacing.paddingSM,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapSM),
        // Filter button
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.paddingMD),
                child: Icon(
                  Icons.tune,
                  color: widget.filters.hasActiveFilters
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
