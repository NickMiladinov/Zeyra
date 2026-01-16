import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/date_picker/custom_date_picker.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 8: Birth Date input screen.
///
/// Features:
/// - "Lastly, what is your birth date?" heading with "birth date" underlined
/// - "This helps me tailor your insights." continuation
/// - Cupertino-style date picker
class BirthDateScreen extends ConsumerStatefulWidget {
  /// Creates the birth date screen.
  const BirthDateScreen({super.key});

  @override
  ConsumerState<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends ConsumerState<BirthDateScreen> {
  /// The currently selected birth date.
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to a reasonable age (25 years ago)
    _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));

    // Load existing data after async provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifierAsync = ref.read(onboardingNotifierProviderAsync);
      notifierAsync.whenData((notifier) {
        final existingBirthDate = notifier.data.dateOfBirth;
        if (existingBirthDate != null) {
          setState(() => _selectedDate = existingBirthDate);
        }
      });
    });
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
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
        // Calculate progress: screen 8 of 11 (index 7)
        const progress = 7 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.valueProp3);
            }
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.gapMD),

              // Mixed heading with underlined "birth date"
              _buildHeading(),

              const Spacer(),

              // Date picker
              _buildDatePicker(),

              const Spacer(),
            ],
          ),
          bottomAction: OnboardingPrimaryButton(
            label: 'Continue',
            onPressed: () => _onContinue(notifier),
          ),
        );
      },
    );
  }

  Widget _buildHeading() {
    final baseStyle = AppTypography.headlineLarge.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Lastly, what is your ',
            style: baseStyle,
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: UnderlinedText(
              text: 'birth date',
              style: baseStyle.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          TextSpan(
            text: '? This helps me tailor your insights.',
            style: baseStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    // Birth date constraints: must be at least 18 years old, max 100 years ago
    final minDate = DateTime.now().subtract(const Duration(days: 365 * 100));
    final maxDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    final defaultDate = DateTime.now().subtract(const Duration(days: 365 * 25));

    return CustomDatePicker(
      minDate: minDate,
      maxDate: maxDate,
      defaultDate: defaultDate,
      height: 220,
      onDateChanged: _onDateChanged,
    );
  }

  Future<void> _onContinue(dynamic notifier) async {
    await notifier.updateBirthDate(_selectedDate);
    await notifier.nextStep();

    if (mounted) {
      context.go(OnboardingRoutes.notifications);
    }
  }
}
