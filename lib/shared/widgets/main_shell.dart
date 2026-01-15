import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_effects.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/router/routes.dart';
import '../../shared/providers/active_tracker_coordinator.dart';
import '../../features/kick_counter/logic/kick_counter_banner_provider.dart';
import '../../features/kick_counter/ui/widgets/kick_counter_banner.dart';
import '../../features/contraction_timer/logic/contraction_timer_banner_provider.dart';
import '../../features/contraction_timer/ui/widgets/contraction_timer_banner.dart';
import 'app_bottom_nav_bar.dart';

/// Main shell widget that provides the bottom navigation bar.
///
/// This widget wraps the [StatefulNavigationShell] from go_router to provide
/// a persistent bottom navigation bar across all main tabs.
///
/// The shell preserves the state of each tab using [StatefulShellRoute.indexedStack].
class MainShell extends ConsumerStatefulWidget {
  /// The navigation shell provided by go_router's StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  /// Key for the banner to track its position.
  final GlobalKey _bannerKey = GlobalKey();

  /// Controller for the expand animation when tapping the banner.
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  /// Controller for entrance/exit animation.
  late AnimationController _entranceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanding = false;
  bool _previousShouldShow = false;
  ActiveTrackerType? _previousTrackerType;

  @override
  void initState() {
    super.initState();

    // Expand animation controller (when tapping banner to open session)
    _expandController = AnimationController(
      duration: AppEffects.durationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Entrance animation controller
    _entranceController = AnimationController(
      duration: AppEffects.durationNormal,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  /// Handle banner tap - animate and navigate to appropriate active session.
  void _onBannerTap(ActiveTrackerType trackerType) async {
    if (_isExpanding) return;

    setState(() {
      _isExpanding = true;
    });

    // Start expand/scale animation
    await _expandController.forward();

    // Hide the appropriate banner before navigating
    if (trackerType == ActiveTrackerType.kickCounter) {
      ref.read(kickCounterBannerProvider.notifier).hide();
    } else if (trackerType == ActiveTrackerType.contractionTimer) {
      ref.read(contractionTimerBannerProvider.notifier).hide();
    }

    // Navigate to appropriate active session using go_router
    if (mounted) {
      if (trackerType == ActiveTrackerType.kickCounter) {
        context.push(ToolRoutes.kickCounterActive);
      } else {
        context.push(ToolRoutes.contractionTimerActive);
      }
    }

    // Reset animation state
    _expandController.reset();
    _entranceController.reset();
    setState(() {
      _isExpanding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check for active sessions and ensure banners are visible when returning to main shell
    // This handles the case where user navigated away from active session via tab switch
    final activeTracker = ref.watch(activeTrackerProvider);
    
    // If there's an active session but banner is not showing, restore it
    // This happens when user navigates away from active session screen via tab tap
    if (activeTracker == ActiveTrackerType.kickCounter) {
      if (!ref.read(kickCounterBannerProvider)) {
        // Use post-frame callback to avoid state changes during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(kickCounterBannerProvider.notifier).show();
        });
      }
    } else if (activeTracker == ActiveTrackerType.contractionTimer) {
      if (!ref.read(contractionTimerBannerProvider)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(contractionTimerBannerProvider.notifier).show();
        });
      }
    }

    // Determine which banner should be shown (if any)
    final shouldShowKickBanner = ref.watch(shouldShowKickCounterBannerProvider);
    final shouldShowContractionBanner =
        ref.watch(shouldShowContractionTimerBannerProvider);

    // Determine active tracker type for the banner
    ActiveTrackerType? activeType;
    if (shouldShowKickBanner) {
      activeType = ActiveTrackerType.kickCounter;
    } else if (shouldShowContractionBanner) {
      activeType = ActiveTrackerType.contractionTimer;
    }

    final shouldShowBanner = activeType != null;

    // Trigger entrance/exit animation when visibility or type changes
    if (shouldShowBanner != _previousShouldShow ||
        activeType != _previousTrackerType) {
      _previousShouldShow = shouldShowBanner;
      _previousTrackerType = activeType;

      if (shouldShowBanner) {
        _entranceController.forward();
      } else if (!_isExpanding) {
        _entranceController.reverse();
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content from navigation shell
          widget.navigationShell,

          // Floating banner positioned above bottom nav
          if (shouldShowBanner || _entranceController.isAnimating)
            Positioned(
              left: 0,
              right: 0,
              // Position above bottom nav bar
              // Note: Safe area is handled by Scaffold's bottomNavigationBar, so we
              // only need to add the nav bar height plus a small margin
              bottom: AppSpacing.paddingXXL,
              child: Center(
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_expandController, _entranceController]),
                  builder: (context, child) {
                    final isExpanding =
                        _expandController.isAnimating || _isExpanding;

                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity:
                            isExpanding ? _opacityAnimation : _fadeAnimation,
                        child: Transform.scale(
                          scale: isExpanding ? _scaleAnimation.value : 1.0,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildBanner(activeType),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          // Use goBranch to switch tabs while preserving state
          // initialLocation: true will go to the tab's initial route if already on that tab
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  /// Build the appropriate banner widget based on tracker type.
  Widget _buildBanner(ActiveTrackerType? trackerType) {
    if (trackerType == ActiveTrackerType.kickCounter) {
      return KickCounterBanner(
        key: _bannerKey,
        onTap: () => _onBannerTap(ActiveTrackerType.kickCounter),
      );
    } else if (trackerType == ActiveTrackerType.contractionTimer) {
      return ContractionTimerBanner(
        key: _bannerKey,
        onTap: () => _onBannerTap(ActiveTrackerType.contractionTimer),
      );
    }

    // Fallback - should not happen but prevents crash
    return const SizedBox.shrink();
  }
}
