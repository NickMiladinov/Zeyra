import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/bump_photo_provider.dart';
import '../../logic/bump_photo_state.dart';
import '../widgets/bump_week_card.dart';
import 'bump_photo_edit_screen.dart';

import 'package:zeyra/app/theme/app_colors.dart';
import 'package:zeyra/app/theme/app_icons.dart';
import 'package:zeyra/app/theme/app_spacing.dart';
import 'package:zeyra/app/theme/app_typography.dart';
import 'package:zeyra/shared/widgets/app_bottom_nav_bar.dart';
import 'package:zeyra/shared/providers/navigation_provider.dart';

/// Main bump diary screen showing all week photos.
///
/// Displays a scrollable list of week cards with photos or empty placeholders.
class BumpDiaryScreen extends ConsumerWidget {
  const BumpDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(bumpPhotoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationNone,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: AppColors.iconDefault),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Bump Diary',
          style: AppTypography.headlineSmall,
        ),
      ),
      body: stateAsync.when(
        data: (state) => _buildBody(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load bump diary: $error',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.gapLG),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(bumpPhotoProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3, // Tools tab
        onTap: (index) {
          final navService = NavigationService(context, ref);
          navService.navigateToTab(index);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, BumpPhotoState state) {
    if (state.isLoading && state.weekSlots.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: AppTypography.bodyLarge.copyWith(color: AppColors.error)),
            const SizedBox(height: AppSpacing.gapLG),
            ElevatedButton(
              onPressed: () {
                ref.read(bumpPhotoProvider.notifier).loadPhotos();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Bump diary should always show at least the current week
    if (state.weekSlots.isEmpty) {
      return Center(
        child: Text(
          'Loading your bump diary...',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapXL),
      itemCount: state.weekSlots.length,
      itemBuilder: (context, index) {
        final slot = state.weekSlots[index];
        final isLatest = index == 0; // First item is the latest week (since reversed)
        return BumpWeekCard(
          slot: slot,
          isLatest: isLatest,
          onTap: () => _navigateToEdit(context, slot.weekNumber),
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context, int weekNumber) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BumpPhotoEditScreen(weekNumber: weekNumber),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
