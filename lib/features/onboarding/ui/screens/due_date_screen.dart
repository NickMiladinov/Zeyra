import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../domain/entities/onboarding/onboarding_data.dart';
import '../../../../shared/widgets/date_picker/custom_date_picker.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 3: Due date / last menstrual period input.
///
/// Features:
/// - Toggle between "Last period" and "Due date" modes
/// - Cupertino-style date picker
/// - Shows calculated estimated due date
/// - Bidirectional calculation (LMP ↔ EDD)
class DueDateScreen extends ConsumerStatefulWidget {
  /// Creates the due date screen.
  const DueDateScreen({super.key});

  @override
  ConsumerState<DueDateScreen> createState() => _DueDateScreenState();
}

class _DueDateScreenState extends ConsumerState<DueDateScreen> {
  /// Whether the user is entering due date (true) or LMP (false).
  bool _isDueDateMode = true;

  /// The currently selected date in the picker.
  late DateTime _selectedDate;

  /// The calculated or entered due date.
  DateTime? _dueDate;

  /// Date format for display.
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Default to 280 days from today (standard pregnancy duration)
    _selectedDate = DateTime.now().add(const Duration(days: 280));
    _dueDate = _selectedDate;

    // Load existing data after async provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifierAsync = ref.read(onboardingNotifierProviderAsync);
      notifierAsync.whenData((notifier) {
        final existingDueDate = notifier.data.dueDate;
        final existingStartDate = notifier.data.startDate;

        if (existingDueDate != null || existingStartDate != null) {
          setState(() {
            // Determine which mode the user was in based on saved data
            // If startDate (LMP) exists, they were in LMP mode
            final wasInLMPMode = existingStartDate != null;
            _isDueDateMode = !wasInLMPMode;

            if (wasInLMPMode) {
              // User was in LMP mode - restore the LMP date
              _selectedDate = existingStartDate;
              _dueDate = existingDueDate ?? _calculateDueDateFromLMP(existingStartDate);
            } else if (existingDueDate != null) {
              // User was in due date mode - restore the due date
              _selectedDate = existingDueDate;
              _dueDate = existingDueDate;
            }
          });
        }
      });
    });
  }

  DateTime _calculateDueDateFromLMP(DateTime lmp) {
    return OnboardingData.calculateDueDateFromLMP(lmp);
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      if (_isDueDateMode) {
        _dueDate = newDate;
      } else {
        _dueDate = _calculateDueDateFromLMP(newDate);
      }
    });
  }

  void _toggleMode(bool isDueDate) {
    if (_isDueDateMode == isDueDate) return;

    setState(() {
      _isDueDateMode = isDueDate;
      // Switch the selected date to match the new mode
      if (isDueDate) {
        // Switching to due date mode: use calculated due date or default
        _selectedDate = _dueDate ?? DateTime.now().add(const Duration(days: 280));
      } else {
        // Switching to last period mode: use 2 weeks ago as default
        _selectedDate = DateTime.now().subtract(const Duration(days: 14));
        // Recalculate due date from this LMP
        _dueDate = _calculateDueDateFromLMP(_selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingAsync = ref.watch(onboardingNotifierProviderAsync);

    return onboardingAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: Text('Error: $error')),
      ),
      data: (notifier) {
        // Calculate progress: screen 3 of 11 (index 2)
        const progress = 2 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.name);
            }
          },
          body: Column(
            children: [
              const SizedBox(height: AppSpacing.gapMD),

              // Mode toggle
              _ModeToggle(
                isDueDateMode: _isDueDateMode,
                onToggle: _toggleMode,
              ),

              const SizedBox(height: AppSpacing.gapXL),

              // Question heading
              Text(
                _isDueDateMode
                    ? 'When is your baby due?'
                    : 'When was your last period?',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.gapXXL),

              // Estimated due date display
              Text(
                'Estimated due date:',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.gapSM),

              // Due date display box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingXXL,
                  vertical: AppSpacing.paddingMD,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: AppEffects.roundedXXL,
                ),
                child: Text(
                  _dueDate != null
                      ? _dateFormat.format(_dueDate!)
                      : '--/--/----',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Date picker
              _buildDatePicker(),

              const Spacer(),
            ],
          ),
          bottomAction: OnboardingPrimaryButton(
            label: 'Continue',
            isEnabled: _dueDate != null,
            onPressed: _dueDate != null
                ? () => _onContinue(notifier)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    // Calculate date range based on mode
    final DateTime minDate;
    final DateTime maxDate;

    if (_isDueDateMode) {
      // Due date: can be from today to about 42 weeks from now
      minDate = DateTime.now();
      maxDate = DateTime.now().add(const Duration(days: 294)); // 42 weeks
    } else {
      // LMP: can be from about 42 weeks ago to today
      minDate = DateTime.now().subtract(const Duration(days: 294));
      maxDate = DateTime.now();
    }

    // Use the current _selectedDate as the default (preserves state)
    return CustomDatePicker(
      key: ValueKey(_isDueDateMode), // Force rebuild when mode changes
      minDate: minDate,
      maxDate: maxDate,
      defaultDate: _selectedDate,
      onDateChanged: _onDateChanged,
    );
  }

  Future<void> _onContinue(dynamic notifier) async {
    if (_dueDate == null) return;

    // Save the dates - notifier handles bidirectional calculation
    if (_isDueDateMode) {
      await notifier.updateDueDate(_dueDate!);
    } else {
      await notifier.updateLMP(_selectedDate);
    }
    await notifier.nextStep();

    if (mounted) {
      context.go(OnboardingRoutes.congratulations);
    }
  }
}

/// Toggle widget for switching between Last Period and Due Date modes.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isDueDateMode,
    required this.onToggle,
  });

  final bool isDueDateMode;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // "Last period" label
        Text(
          'Last period',
          style: AppTypography.bodyMedium.copyWith(
            color: isDueDateMode
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight:
                isDueDateMode ? FontWeight.w400 : FontWeight.w600,
          ),
        ),

        const SizedBox(width: AppSpacing.gapMD),

        // Toggle switch
        GestureDetector(
          onTap: () => onToggle(!isDueDateMode),
          child: AnimatedContainer(
            duration: AppEffects.durationFast,
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppEffects.roundedCircle,
              border: Border.all(
                color: AppColors.backgroundGrey200,
                width: AppSpacing.borderWidthThin,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppEffects.durationFast,
                  curve: AppEffects.curveDefault,
                  left: isDueDateMode ? 26 : 2,
                  top: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      // Coral when due date, teal when last period
                      color: isDueDateMode
                          ? AppColors.secondary
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.gapMD),

        // "Due date" label
        Text(
          'Due date',
          style: AppTypography.bodyMedium.copyWith(
            color: isDueDateMode
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontWeight:
                isDueDateMode ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
