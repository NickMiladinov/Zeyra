import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeyra/app/theme/app_effects.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/features/kick_counter/logic/kick_counter_banner_provider.dart';
import 'package:zeyra/features/kick_counter/ui/screens/kick_active_session_screen.dart';
import 'package:zeyra/features/kick_counter/ui/widgets/kick_counter_banner.dart';

/// Global overlay widget that displays the kick counter banner.
/// 
/// Wrap this around your app's main content to show the floating banner
/// when the user has an active kick counter session and navigates away
/// from the active session screen.
/// 
/// Usage:
/// ```dart
/// KickCounterBannerOverlay(
///   child: MainScreen(),
/// )
/// ```
class KickCounterBannerOverlay extends ConsumerStatefulWidget {
  const KickCounterBannerOverlay({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  /// The main app content
  final Widget child;
  
  /// Navigator key for navigation (needed when overlay is at MaterialApp.builder level)
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<KickCounterBannerOverlay> createState() => _KickCounterBannerOverlayState();
}

class _KickCounterBannerOverlayState extends ConsumerState<KickCounterBannerOverlay>
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

  /// Handle banner tap - animate and navigate to active session
  void _onBannerTap() async {
    if (_isExpanding) return;
    
    setState(() {
      _isExpanding = true;
    });
    
    // Start expand/scale animation
    await _expandController.forward();
    
    // Hide banner before navigating
    ref.read(kickCounterBannerProvider.notifier).hide();
    
    // Navigate to active session with slide-up animation
    // Use navigatorKey since overlay is at MaterialApp.builder level (above Navigator)
    final navigator = widget.navigatorKey.currentState;
    if (mounted && navigator != null) {
      await navigator.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const KickActiveSessionScreen(),
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
    final shouldShowBanner = ref.watch(shouldShowKickCounterBannerProvider);
    
    // Trigger entrance/exit animation when visibility changes
    if (shouldShowBanner != _previousShouldShow) {
      _previousShouldShow = shouldShowBanner;
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
            // The Scaffold positions bottomNavigationBar above safe area, so:
            // banner bottom = safe_area + bottom_nav_height + gap
            bottom: MediaQuery.of(context).padding.bottom + 
                    AppSpacing.bottomNavHeight + 
                    AppSpacing.paddingMD,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_expandController, _entranceController]),
                builder: (context, child) {
                  // Combine entrance and expand animations
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
                child: KickCounterBanner(
                  key: _bannerKey,
                  onTap: _onBannerTap,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
