import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_effects.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/di/main_providers.dart';
import '../../logic/onboarding_providers.dart';

/// Screen 10: Paywall screen with RevenueCat integration.
///
/// Displays subscription offerings fetched from RevenueCat and handles
/// purchases. The screen shows a hero image, subscription plans, and
/// purchase/restore buttons.
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates the paywall screen.
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;
  bool _isLoadingOfferings = true;
  bool _showAllPlans = false;
  String? _errorMessage;

  Offerings? _offerings;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  /// Load offerings from RevenueCat.
  Future<void> _loadOfferings() async {
    setState(() {
      _isLoadingOfferings = true;
      _errorMessage = null;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);

      if (!paymentService.isInitialized) {
        // RevenueCat not initialized - show mock data for development
        setState(() {
          _isLoadingOfferings = false;
          _errorMessage = null;
        });
        return;
      }

      final offerings = await paymentService.getOfferings();

      setState(() {
        _offerings = offerings;
        _isLoadingOfferings = false;

        // Select the annual package by default (or first available)
        if (offerings.current != null) {
          _selectedPackage = offerings.current!.annual ??
              offerings.current!.monthly ??
              offerings.current!.availablePackages.firstOrNull;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingOfferings = false;
        _errorMessage = 'Unable to load subscription options. Please try again.';
      });
    }
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
      data: (notifier) => _buildPaywall(context, notifier),
    );
  }

  Widget _buildPaywall(BuildContext context, dynamic notifier) {
    // Get the top padding to extend image behind status bar
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero image section (extends behind status bar)
                  _buildHeroSection(topPadding),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPaddingHorizontal,
                    ),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          'Your Digital Midwife,\nin Your Pocket',
                          style: AppTypography.displayMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 34,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.gapXS),

                        // Subtitle
                        Text(
                          'Never stress about "what\'s next." Get a personalized 9-month journey and NHS medical insights.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.gapXXL),

                        // Subscription options
                        if (_isLoadingOfferings)
                          _buildLoadingPlans()
                        else if (_errorMessage != null)
                          _buildErrorPlans()
                        else
                          _buildSubscriptionPlans(),

                        const SizedBox(height: AppSpacing.gapMD),

                        // Show more plans toggle
                        _buildShowMorePlans(),

                        const SizedBox(height: AppSpacing.gapXL),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action area (fixed, with SafeArea for bottom)
          SafeArea(
            top: false,
            child: _buildBottomActions(notifier),
          ),
        ],
      ),
    );
  }

  /// Build the hero image section with journey timeline.
  ///
  /// [topPadding] is the system status bar height to extend the image behind it.
  Widget _buildHeroSection(double topPadding) {
    return SizedBox(
      // Add top padding to the height so image extends behind status bar
      height: 340 + topPadding,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero image (fills entire section including status bar area)
          Positioned.fill(
            child: Image.asset(
              'assets/images/OnboardingPaywall.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state for plans.
  Widget _buildLoadingPlans() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey50,
        borderRadius: AppEffects.roundedLG,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error state for plans.
  Widget _buildErrorPlans() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey50,
        borderRadius: AppEffects.roundedLG,
      ),
      child: Column(
        children: [
          Icon(
            Symbols.error_outline_rounded,
            color: AppColors.error,
            size: AppSpacing.iconXL,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.gapMD),
          TextButton(
            onPressed: _loadOfferings,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Build subscription plans from RevenueCat offerings or mock data.
  Widget _buildSubscriptionPlans() {
    final currentOffering = _offerings?.current;
    final packages = currentOffering?.availablePackages ?? [];

    // If RevenueCat is not available, show mock data for development
    if (packages.isEmpty) {
      return _buildMockSubscriptionPlans();
    }

    // Show annual package prominently (or first package)
    final annualPackage = currentOffering?.annual;

    // Primary plan (annual or first available)
    final primaryPackage = annualPackage ?? packages.firstOrNull;

    if (primaryPackage == null) {
      return _buildMockSubscriptionPlans();
    }

    return Column(
      children: [
        // Primary plan card
        _buildPlanCard(
          package: primaryPackage,
          isSelected: _selectedPackage?.identifier == primaryPackage.identifier,
          isMostPopular: primaryPackage.packageType == PackageType.annual,
          onTap: () => setState(() => _selectedPackage = primaryPackage),
        ),

        // Additional plans (shown when expanded)
        if (_showAllPlans) ...[
          const SizedBox(height: AppSpacing.gapMD),
          ...packages
              .where((p) => p.identifier != primaryPackage.identifier)
              .map((package) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.gapMD),
                    child: _buildPlanCard(
                      package: package,
                      isSelected:
                          _selectedPackage?.identifier == package.identifier,
                      isMostPopular: false,
                      onTap: () => setState(() => _selectedPackage = package),
                    ),
                  )),
        ],
      ],
    );
  }

  /// Build mock subscription plans for development.
  Widget _buildMockSubscriptionPlans() {
    return Column(
      children: [
        // Annual plan (mock)
        _buildMockPlanCard(
          title: 'The Full Journey',
          subtitle: '12 mo - £47.99',
          price: '£3.99',
          priceUnit: 'per month',
          isSelected: true,
          isMostPopular: true,
          onTap: () {},
        ),

        if (_showAllPlans) ...[
          const SizedBox(height: AppSpacing.gapMD),
          _buildMockPlanCard(
            title: 'Monthly',
            subtitle: 'Billed monthly',
            price: '£7.99',
            priceUnit: 'per month',
            isSelected: false,
            isMostPopular: false,
            onTap: () {},
          ),
        ],
      ],
    );
  }

  /// Build a subscription plan card from RevenueCat package.
  Widget _buildPlanCard({
    required Package package,
    required bool isSelected,
    required bool isMostPopular,
    required VoidCallback onTap,
  }) {
    final product = package.storeProduct;
    final introPrice = product.introductoryPrice;

    // Determine plan title based on package type
    String title;
    switch (package.packageType) {
      case PackageType.annual:
        title = 'The Full Journey';
      case PackageType.sixMonth:
        title = 'Half Year';
      case PackageType.threeMonth:
        title = 'Quarterly';
      case PackageType.twoMonth:
        title = 'Two Months';
      case PackageType.monthly:
        title = 'Monthly';
      case PackageType.weekly:
        title = 'Weekly';
      case PackageType.lifetime:
        title = 'Lifetime';
      default:
        title = product.title;
    }

    // Calculate monthly price for annual plans
    String priceDisplay = product.priceString;
    String priceUnit = '';
    String? subtitle;

    if (package.packageType == PackageType.annual) {
      // Show monthly equivalent for annual
      final monthlyEquivalent = product.price / 12;
      priceDisplay = product.currencyCode == 'GBP'
          ? '£${monthlyEquivalent.toStringAsFixed(2)}'
          : '${product.currencyCode} ${monthlyEquivalent.toStringAsFixed(2)}';
      priceUnit = 'per month';
      subtitle = '12 mo - ${product.priceString}';
    } else if (package.packageType == PackageType.monthly) {
      priceUnit = 'per month';
    }

    return _buildMockPlanCard(
      title: title,
      subtitle: subtitle,
      price: priceDisplay,
      priceUnit: priceUnit,
      isSelected: isSelected,
      isMostPopular: isMostPopular,
      hasFreeTrial: introPrice != null,
      freeTrialDuration: introPrice?.periodNumberOfUnits != null
          ? '${introPrice!.periodNumberOfUnits}-day free trial'
          : null,
      onTap: onTap,
    );
  }

  /// Build a mock plan card UI.
  Widget _buildMockPlanCard({
    required String title,
    String? subtitle,
    required String price,
    required String priceUnit,
    required bool isSelected,
    required bool isMostPopular,
    bool hasFreeTrial = false,
    String? freeTrialDuration,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppEffects.durationFast,
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.backgroundSecondaryVerySubtle
              : AppColors.white,
          borderRadius: AppEffects.roundedLG,
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected
                ? AppSpacing.borderWidthMedium
                : AppSpacing.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most popular badge
            if (isMostPopular)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.gapSM),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.paddingMD,
                  vertical: AppSpacing.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: AppEffects.roundedCircle,
                ),
                child: Text(
                  'Most Popular',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Plan info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.gapXS),
                        Text(
                          subtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (priceUnit.isNotEmpty)
                      Text(
                        priceUnit,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build "Show more plans" toggle.
  Widget _buildShowMorePlans() {
    return GestureDetector(
      onTap: () => setState(() => _showAllPlans = !_showAllPlans),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _showAllPlans ? 'Show fewer plans' : 'Show more plans',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.gapXS),
          Icon(
            _showAllPlans
                ? Symbols.keyboard_arrow_up_rounded
                : Symbols.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: AppSpacing.iconSM,
          ),
        ],
      ),
    );
  }

  /// Build bottom action buttons.
  Widget _buildBottomActions(dynamic notifier) {
    // Determine CTA text based on trial availability
    String ctaText = 'Start my 3-day free trial';
    
    if (_selectedPackage != null) {
      final introPrice = _selectedPackage!.storeProduct.introductoryPrice;
      if (introPrice != null && introPrice.periodNumberOfUnits > 0) {
        ctaText = 'Start my ${introPrice.periodNumberOfUnits}-day free trial';
      } else {
        ctaText = 'Subscribe Now';
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.paddingMD,
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.paddingXL,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppEffects.shadowTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeightXXL,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handlePurchase(notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppEffects.roundedCircle,
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: AppSpacing.iconSM,
                      height: AppSpacing.iconSM,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      ctaText,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: AppSpacing.gapMD),

          // No payment now text
          Text(
            'No payment now. Cancel anytime.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
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
  }

  /// Handle purchase flow.
  Future<void> _handlePurchase(dynamic notifier) async {
    setState(() => _isLoading = true);

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // If RevenueCat is not initialized, use mock flow
      if (!paymentService.isInitialized || _selectedPackage == null) {
        // Mock: Mark purchase as complete without real transaction
        await notifier.mockPurchaseComplete();
        await notifier.nextStep();

        if (mounted) {
          context.go(OnboardingRoutes.auth);
        }
        return;
      }

      // Real purchase flow
      final success = await notifier.purchasePackage(_selectedPackage!);

      if (success && mounted) {
        await notifier.nextStep();
        context.go(OnboardingRoutes.auth);
      }
      // If not successful, error is handled by the notifier and shown via state
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle restore purchases flow.
  Future<void> _handleRestore(dynamic notifier) async {
    setState(() => _isLoading = true);

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // If RevenueCat is not initialized, use mock flow
      if (!paymentService.isInitialized) {
        await notifier.mockPurchaseComplete();
        await notifier.nextStep();

        if (mounted) {
          context.go(OnboardingRoutes.auth);
        }
        return;
      }

      // Real restore flow
      final success = await notifier.restorePurchases();

      if (success && mounted) {
        await notifier.nextStep();
        context.go(OnboardingRoutes.auth);
      } else if (mounted) {
        // Show "no purchases found" message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No previous purchases found.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
