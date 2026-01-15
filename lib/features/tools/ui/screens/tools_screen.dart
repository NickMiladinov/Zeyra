import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_banner.dart';
import '../../../../shared/widgets/app_card.dart';

/// Tools screen showing the grid of available tools.
///
/// Navigation is handled by go_router - no nested Navigator needed.
/// The bottom navigation bar is provided by [MainShell].
class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  static const String routeName = '/tools';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppBanner(
              title: 'Plan & Tools',
              titleStyle: AppTypography.headlineLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: AppSpacing.paddingLG,
              right: AppSpacing.paddingLG,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.paddingLG,
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tool = _tools[index];
                  return _ToolCard(tool: tool);
                },
                childCount: _tools.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.gapXL,
                crossAxisSpacing: AppSpacing.gapLG,
                childAspectRatio: 0.85,
              ),
            ),
          ),
        ],
      ),
      // Bottom nav bar is provided by MainShell
    );
  }

  static final List<_ToolData> _tools = [
    _ToolData(
      title: 'Kick Counter',
      subtitle: 'Track Movements',
      icon: null,
      isBabyIcon: true,
      color: const Color(0xFFD9EAD3),
      route: ToolRoutes.kickCounter,
    ),
    _ToolData(
      title: 'Bump Diary',
      subtitle: 'Watch Your Growth',
      icon: AppIcons.camera,
      color: const Color(0xFFCFE2F3),
      route: ToolRoutes.bumpDiary,
    ),
    _ToolData(
      title: 'Contraction Timer',
      subtitle: 'Time Your Surges',
      icon: Symbols.timer_rounded,
      color: const Color(0xFF8DB6C6),
      route: ToolRoutes.contractionTimer,
    ),
    _ToolData(
      title: 'Appointment Hub',
      subtitle: 'Visits & Calendar',
      icon: AppIcons.appointment,
      color: const Color(0xFFE6B8AF),
    ),
    _ToolData(
      title: 'Birth Plan',
      subtitle: 'Prepare Preferences',
      icon: AppIcons.birthPlan,
      color: const Color(0xFFA2C8B9),
    ),
    _ToolData(
      title: 'Hospital Chooser',
      subtitle: 'Find Your Birth Place',
      icon: AppIcons.hospital,
      color: const Color(0xFFB8D8D8),
    ),
    _ToolData(
      title: 'AI Assistant',
      subtitle: 'Ask a Question',
      icon: AppIcons.chat,
      color: const Color(0xFFD0E0E3),
    ),
    _ToolData(
      title: 'Shopping Lists',
      subtitle: 'Get Essentials Ready',
      icon: Symbols.shopping_basket_rounded,
      color: const Color(0xFFEAD1DC),
    ),
  ];
}

class _ToolData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final bool isBabyIcon;
  final Color color;
  /// Route path for navigation (uses go_router).
  final String? route;

  _ToolData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.isBabyIcon = false,
    required this.color,
    this.route,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolData tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        if (tool.route != null) {
          context.push(tool.route!);
        }
      },
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon Placeholder
          Expanded(
            flex: 2,
            child: Center(
              child: tool.isBabyIcon
                  ? AppIcons.babyActive(size: 48)
                  : Icon(
                      tool.icon,
                      size: 48,
                      color: AppColors.primary, // Using primary for now as placeholder color
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.gapSM),
          // Title
          Text(
            tool.title,
            style: AppTypography.headlineExtraSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.gapXS),
          // Subtitle
          Text(
            tool.subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.gapSM),
        ],
      ),
    );
  }
}
