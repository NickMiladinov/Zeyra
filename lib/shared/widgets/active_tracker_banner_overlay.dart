import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/shared/providers/active_tracker_coordinator.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_banner_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_active_session_screen.dart';
import 'package:zeyra/features/kick_counter/ui/widgets/kick_counter_banner.dart';
import 'package:zeyra/features/contraction_timer/logic/contraction_timer_banner_provider.dart';
import 'package:zeyra/features/contraction_timer/ui/screens/contraction_active_session_screen.dart';
import 'package:zeyra/features/contraction_timer/ui/widgets/contraction_timer_banner.dart';

/// Unified overlay widget that displays the appropriate active tracker banner.
/// 
/// Shows either the kick counter or contraction timer banner depending on
/// which tracker is currently active. Only one can be active at a time,
/// as enforced by [activeTrackerProvider].
/// 
/// The banner automatically hides when bottom sheets are shown via
/// [isModalOverlayVisibleProvider], ensuring proper z-ordering.
/// 
/// Usage in MaterialApp.builder:
/// ```dart
/// builder: (context, child) {
///   return ActiveTrackerBannerOverlay(
///     navigatorKey: navigatorKey,
///     child: child ?? const SizedBox.shrink(),
///   );
/// }
/// ```
class ActiveTrackerBannerOverlay extends ConsumerStatefulWidget {
  const ActiveTrackerBannerOverlay({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  /// The main app content
  final Widget child;
  
  /// Navigator key for navigation (needed when overlay is at MaterialApp.builder level)
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<ActiveTrackerBannerOverlay> createState() => _ActiveTrackerBannerOverlayState();
}

class _ActiveTrackerBannerOverlayState extends ConsumerState<ActiveTrackerBannerOverlay>
    with TickerProviderStateMixin {
  /// Key for the banner to track its position
  final GlobalKey _bannerKey = GlobalKey();
  
  /// Controller for the expand animation when tapping the banner
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  /// Controller for entrance/exit animation
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

  /// Handle banner tap - animate and navigate to appropriate active session
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
    
    // Navigate to appropriate active session with slide-up animation
    final navigator = widget.navigatorKey.currentState;
    if (mounted && navigator != null) {
      Widget targetScreen;
      if (trackerType == ActiveTrackerType.kickCounter) {
        targetScreen = const KickActiveSessionScreen();
      } else {
        targetScreen = const ContractionActiveSessionScreen();
      }
      
      await navigator.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: AppEffects.durationSlow,
          reverseTransitionDuration: AppEffects.durationSlow,
        ),
      );
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
    // Determine which banner should be shown (if any)
    final shouldShowKickBanner = ref.watch(shouldShowKickCounterBannerProvider);
    final shouldShowContractionBanner = ref.watch(shouldShowContractionTimerBannerProvider);
    
    // Determine active tracker type for the banner
    ActiveTrackerType? activeType;
    if (shouldShowKickBanner) {
      activeType = ActiveTrackerType.kickCounter;
    } else if (shouldShowContractionBanner) {
      activeType = ActiveTrackerType.contractionTimer;
    }
    
    final shouldShowBanner = activeType != null;
    
    // Trigger entrance/exit animation when visibility or type changes
    if (shouldShowBanner != _previousShouldShow || activeType != _previousTrackerType) {
      _previousShouldShow = shouldShowBanner;
      _previousTrackerType = activeType;
      
      if (shouldShowBanner) {
        _entranceController.forward();
      } else if (!_isExpanding) {
        _entranceController.reverse();
      }
    }
    
    return Stack(
      children: [
        // Main app content
        widget.child,
        
        // Floating banner positioned above bottom nav
        if (shouldShowBanner || _entranceController.isAnimating)
          Positioned(
            left: 0,
            right: 0,
            // Position above bottom nav bar (which itself is above safe area)
            bottom: MediaQuery.of(context).padding.bottom + 
                    AppSpacing.bottomNavHeight + 
                    AppSpacing.paddingMD,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_expandController, _entranceController]),
                builder: (context, child) {
                  final isExpanding = _expandController.isAnimating || _isExpanding;
                  
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: isExpanding ? _opacityAnimation : _fadeAnimation,
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
    );
  }
  
  /// Build the appropriate banner widget based on tracker type
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

