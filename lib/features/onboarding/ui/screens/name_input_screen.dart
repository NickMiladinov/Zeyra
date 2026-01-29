import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../logic/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

/// Screen 2: Name input screen.
///
/// Features:
/// - "What's your name?" heading
/// - Text input field with coral accent
/// - Zeyra mascot image
/// - Dynamic button: "Hi!" when empty (disabled), "Hi, [Name]!" when filled
class NameInputScreen extends ConsumerStatefulWidget {
  /// Creates the name input screen.
  const NameInputScreen({super.key});

  @override
  ConsumerState<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends ConsumerState<NameInputScreen> {
  late TextEditingController _nameController;
  String _currentName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Load existing name from state after async provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifierAsync = ref.read(onboardingNotifierProviderAsync);
      notifierAsync.whenData((notifier) {
        final existingName = notifier.data.firstName ?? '';
        if (existingName.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = existingName;
          setState(() => _currentName = existingName);
        }
      });
    });

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() => _currentName = _nameController.text.trim());
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
        // Calculate progress: screen 2 of 11 (index 1)
        const progress = 1 / 10; // 10% progress

        final hasName = _currentName.isNotEmpty;
        final buttonLabel = hasName ? 'Hi, $_currentName!' : 'Hi!';

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.welcome);
            }
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.gapXL),

              // Question heading
              Text(
                "What's your name?",
                style: AppTypography.headlineLarge,
              ),

              const SizedBox(height: AppSpacing.gapXL),

              // Name input field with coral cursor
              TextField(
                controller: _nameController,
                autofocus: true,
                cursorColor: AppColors.primary,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 36,
                ),
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: AppTypography.displayMedium.copyWith(
                    color: AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                    fontSize: 36,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                    bottom: AppSpacing.paddingSM,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                onSubmitted: hasName
                    ? (_) => _onContinue(notifier)
                    : null,
              ),

              // Mascot image - takes remaining space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.paddingXL,
                    ),
                    child: Image.asset(
                      'assets/images/OnboardingWelcome.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomAction: AnimatedSwitcher(
            duration: AppEffects.durationFast,
            child: OnboardingPrimaryButton(
              key: ValueKey(hasName),
              label: buttonLabel,
              isEnabled: hasName,
              onPressed: hasName ? () => _onContinue(notifier) : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onContinue(dynamic notifier) async {
    // Save the name
    await notifier.updateName(_currentName);
    await notifier.nextStep();

    if (mounted) {
      context.go(OnboardingRoutes.dueDate);
    }
  }
}
