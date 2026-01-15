import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/pregnancy/pregnancy.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../logic/pregnancy_data_provider.dart';

// TODO: TEMPORARY SCREEN - For testing pregnancy data only. Will be replaced with proper UI.
/// Temporary screen for testing pregnancy data CRUD operations.
///
/// Features:
/// - Create pregnancy with start date or due date
/// - View gestational age and days remaining
/// - Edit dates with automatic calculation (startDate + 280 days = dueDate)
/// - Delete pregnancy
///
/// This screen is for development/testing purposes only and will be replaced
/// with proper pregnancy management UI in the future.
class PregnancyDataScreen extends ConsumerWidget {
  const PregnancyDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancyAsync = ref.watch(pregnancyDataProvider);

    return Scaffold(
      body: Column(
        children: [
          // App Banner
          AppBanner(
            title: 'Baby',
            bottomSpacing: 0,
          ),

          // Warning Banner
          Container(
            width: double.infinity,
            color: AppColors.warning.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
              vertical: AppSpacing.paddingMD,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'TEMPORARY - For testing only. This screen will be replaced.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: pregnancyAsync.when(
              data: (pregnancy) {
                if (pregnancy == null) {
                  return _EmptyState(
                    onCreatePressed: () {
                      // TEMPORARY: Create default pregnancy with today as start date
                      ref.read(pregnancyDataProvider.notifier).createDefaultPregnancy();
                    },
                  );
                }
                return _PregnancyContent(
                  pregnancy: pregnancy,
                  onEditDueDate: () => _showDatePicker(
                    context,
                    ref,
                    pregnancy,
                  ),
                  onDelete: () => _showDeleteConfirmation(context, ref, pregnancy),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.paddingLG),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Error loading pregnancy data',
                        style: AppTypography.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        error.toString(),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom nav bar is provided by MainShell
    );
  }

  /// TEMPORARY: Simplified date picker - only allows changing due date
  void _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    Pregnancy pregnancy,
  ) async {
    // Due date: 38-42 weeks (266-294 days) after start date
    final firstDate = pregnancy.startDate.add(const Duration(days: 266));
    final lastDate = pregnancy.startDate.add(const Duration(days: 294));
    final currentDate = pregnancy.dueDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate.isBefore(firstDate)
          ? firstDate
          : (currentDate.isAfter(lastDate) ? lastDate : currentDate),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Due Date',
    );

    if (selectedDate != null && context.mounted) {
      ref.read(pregnancyDataProvider.notifier).updateDueDate(
            pregnancy.id,
            selectedDate,
          );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Pregnancy pregnancy,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pregnancy'),
        content: const Text(
          'Are you sure you want to delete this pregnancy data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(pregnancyDataProvider.notifier).deletePregnancy(pregnancy.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no pregnancy exists
/// TEMPORARY: Simplified to just create a default pregnancy
class _EmptyState extends ConsumerWidget {
  final VoidCallback onCreatePressed;

  const _EmptyState({required this.onCreatePressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Pregnancy Data',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'TEMPORARY: Creates default pregnancy with today as start date',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add),
              label: const Text('Create Default Pregnancy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingXL,
                  vertical: AppSpacing.paddingMD,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _showDueDatePicker(context, ref),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Set Custom Due Date'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingXL,
                  vertical: AppSpacing.paddingMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDueDatePicker(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Allow selecting due dates from 20 weeks from now to 45 weeks from now
    final firstDate = today.add(const Duration(days: 140)); // ~20 weeks
    final lastDate = today.add(const Duration(days: 315)); // ~45 weeks

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 280)), // 40 weeks from today
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Due Date',
    );

    if (selectedDate != null && context.mounted) {
      // Calculate start date as 280 days (40 weeks) before due date
      final startDate = selectedDate.subtract(const Duration(days: 280));

      ref.read(pregnancyDataProvider.notifier).createPregnancy(
        startDate: startDate,
        dueDate: selectedDate,
      );
    }
  }
}

/// Content displayed when pregnancy exists
/// TEMPORARY: Simplified to only show due date editing
class _PregnancyContent extends StatelessWidget {
  final Pregnancy pregnancy;
  final VoidCallback onEditDueDate;
  final VoidCallback onDelete;

  const _PregnancyContent({
    required this.pregnancy,
    required this.onEditDueDate,
    required this.onDelete,
  });

  String _formatDateShort(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Week Number - Large Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.paddingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Week',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${pregnancy.gestationalWeek}',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  pregnancy.gestationalAgeFormatted,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Gestational Age Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pregnancy Progress',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Days Elapsed',
                        value: '${DateTime.now().difference(pregnancy.startDate).inDays}',
                        icon: Icons.calendar_month,
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: AppColors.surfaceVariant,
                      ),
                      _StatItem(
                        label: 'Progress',
                        value: '${(pregnancy.progressPercentage * 100).toStringAsFixed(0)}%',
                        icon: Icons.trending_up,
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: AppColors.surfaceVariant,
                      ),
                      _StatItem(
                        label: 'Days Left',
                        value: '${pregnancy.daysRemaining}',
                        icon: Icons.event_available,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // TEMPORARY: Simplified - only show due date button
          Text(
            'Change Due Date',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Due Date Button
          ElevatedButton.icon(
            onPressed: onEditDueDate,
            icon: const Icon(Icons.calendar_today),
            label: Text('Due Date: ${_formatDateShort(pregnancy.dueDate)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLG,
                vertical: AppSpacing.paddingMD,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Info text
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'TEMPORARY: Start date is ${_formatDateShort(pregnancy.startDate)}. Due date range: 38-42 weeks from start.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Delete Button
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Pregnancy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMD),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small stat display widget for showing individual metrics
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
