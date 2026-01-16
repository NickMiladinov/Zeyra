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

/// Screen 10: Paywall screen (mandatory - cannot skip).
///
/// TODO: Integrate with RevenueCat for real purchases.
/// Currently uses a mock implementation that skips to auth.
///
/// When implementing:
/// 1. Call `notifier.getOfferings()` to fetch packages
/// 2. Display subscription options with pricing
/// 3. Call `notifier.purchasePackage(package)` on purchase
/// 4. Call `notifier.restorePurchases()` for restore button
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates the paywall screen.
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

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
        // Calculate progress: screen 10 of 11 (index 9)
        const progress = 9 / 10;

        return OnboardingScaffold(
          progress: progress,
          onBack: () async {
            await notifier.previousStep();
            if (context.mounted) {
              context.go(OnboardingRoutes.notifications);
            }
          },
          body: Column(
            children: [
              const SizedBox(height: AppSpacing.gapXL),

              // Paywall image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: AppEffects.roundedXL,
                  child: Image.asset(
                    'assets/images/OnboardingPaywall.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.gapXL),

              // Subscription info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Zeyra Premium',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.gapMD),

                    Text(
                      'Get unlimited access to all features including AI assistant, personalised insights, and premium content.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    // TODO: Replace with real pricing from RevenueCat
                    _buildMockPricing(),
                  ],
                ),
              ),
            ],
          ),
          bottomAction: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subscribe button (mock)
              OnboardingPrimaryButton(
                label: 'Start Free Trial',
                isLoading: _isLoading,
                onPressed: () => _handleMockPurchase(notifier),
              ),

              const SizedBox(height: AppSpacing.gapMD),

              // Restore purchases link
              GestureDetector(
                onTap: () => _handleRestore(notifier),
                child: Text(
                  'Restore Purchases',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockPricing() {
    // TODO: Replace with real pricing from RevenueCat offerings
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondarySubtle,
        borderRadius: AppEffects.roundedLG,
        border: Border.all(
          color: AppColors.secondary,
          width: AppSpacing.borderWidthMedium,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Annual',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '7 days free, then £49.99/year',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingMD,
              vertical: AppSpacing.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: AppEffects.roundedCircle,
            ),
            child: Text(
              'Best Value',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TODO: Replace with real RevenueCat purchase flow.
  Future<void> _handleMockPurchase(dynamic notifier) async {
    setState(() => _isLoading = true);

    try {
      // Mock: Mark purchase as complete without real transaction
      await notifier.mockPurchaseComplete();
      await notifier.nextStep();

      if (mounted) {
        context.go(OnboardingRoutes.auth);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// TODO: Replace with real RevenueCat restore flow.
  Future<void> _handleRestore(dynamic notifier) async {
    setState(() => _isLoading = true);

    try {
      // In real implementation: await notifier.restorePurchases();
      // For now, just mock it
      await notifier.mockPurchaseComplete();
      await notifier.nextStep();

      if (mounted) {
        context.go(OnboardingRoutes.auth);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
