import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeyra/core/di/main_providers.dart';
import 'package:zeyra/domain/entities/pregnancy/pregnancy.dart';
import 'package:zeyra/domain/entities/user_profile/gender.dart';

/// Provider for the active pregnancy.
///
/// Returns the most recent pregnancy for the current user, or null if none exists.
final activePregnancyProvider = FutureProvider<Pregnancy?>((ref) async {
  final getActivePregnancyUseCase = await ref.watch(getActivePregnancyUseCaseProvider.future);

  try {
    return await getActivePregnancyUseCase.execute();
  } catch (e) {
    // Return null if no active pregnancy found (expected case)
    return null;
  }
});

/// State notifier for managing pregnancy data operations.
class PregnancyDataNotifier extends StateNotifier<AsyncValue<Pregnancy?>> {
  PregnancyDataNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadActivePregnancy();
  }

  final Ref _ref;

  /// Load the active pregnancy
  Future<void> _loadActivePregnancy() async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final getActivePregnancyUseCase = await _ref.read(getActivePregnancyUseCaseProvider.future);
      final pregnancy = await getActivePregnancyUseCase.execute();
      if (!mounted) return;
      state = AsyncValue.data(pregnancy);
    } catch (e) {
      // No active pregnancy is not an error - just null data
      if (!mounted) return;
      state = const AsyncValue.data(null);
    }
  }

  /// Create a new pregnancy
  ///
  /// TEMPORARY: Auto-creates user profile if it doesn't exist to handle foreign key constraint.
  /// This will be replaced with proper onboarding flow later.
  Future<void> createPregnancy({
    required DateTime startDate,
    required DateTime dueDate,
  }) async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw StateError('User must be authenticated to create pregnancy');
      }

      // TEMPORARY: Ensure user profile exists (for foreign key constraint)
      final getUserProfileUseCase = await _ref.read(getUserProfileUseCaseProvider.future);
      if (!mounted) return;
      var profile = await getUserProfileUseCase.execute();

      if (profile == null) {
        if (!mounted) return;
        // User profile doesn't exist, create it with temporary placeholder values
        final createUserProfileUseCase = await _ref.read(createUserProfileUseCaseProvider.future);
        profile = await createUserProfileUseCase.execute(
          authId: user.id,
          email: user.email ?? 'temp@example.com',
          firstName: 'Temp', // TODO: Replace with proper onboarding
          lastName: 'User', // TODO: Replace with proper onboarding
          dateOfBirth: DateTime(1990, 1, 1), // TODO: Replace with proper onboarding
          gender: Gender.female, // TODO: Replace with proper onboarding
          schemaVersion: 2, // Current database schema version
        );
      }

      if (!mounted) return;
      final userProfileId = profile.id;

      final createUseCase = await _ref.read(createPregnancyUseCaseProvider.future);

      final created = await createUseCase.execute(
        userId: userProfileId,
        startDate: startDate,
        dueDate: dueDate,
        selectedHospitalId: null,
      );

      if (!mounted) return;
      state = AsyncValue.data(created);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
      // Rethrow to let UI handle the error
      rethrow;
    }
  }

  /// TEMPORARY: Create a default pregnancy with today as start date
  /// This simplifies the temporary testing flow
  Future<void> createDefaultPregnancy() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = today.add(const Duration(days: 280)); // 40 weeks

    await createPregnancy(
      startDate: today,
      dueDate: dueDate,
    );
  }

  /// Update pregnancy start date (auto-calculates due date)
  Future<void> updateStartDate(String pregnancyId, DateTime newStartDate) async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final updateUseCase = await _ref.read(updatePregnancyStartDateUseCaseProvider.future);
      final updated = await updateUseCase.execute(pregnancyId, newStartDate);
      if (!mounted) return;
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update pregnancy due date (auto-calculates start date)
  Future<void> updateDueDate(String pregnancyId, DateTime newDueDate) async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final updateUseCase = await _ref.read(updatePregnancyDueDateUseCaseProvider.future);
      final updated = await updateUseCase.execute(pregnancyId, newDueDate);
      if (!mounted) return;
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete a pregnancy
  Future<void> deletePregnancy(String pregnancyId) async {
    if (!mounted) return;
    state = const AsyncValue.loading();

    try {
      final deleteUseCase = await _ref.read(deletePregnancyUseCaseProvider.future);
      await deleteUseCase.execute(pregnancyId);
      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Refresh the active pregnancy
  Future<void> refresh() async {
    if (!mounted) return;
    await _loadActivePregnancy();
  }
}

/// Provider for pregnancy data state management.
final pregnancyDataProvider = StateNotifierProvider<PregnancyDataNotifier, AsyncValue<Pregnancy?>>((ref) {
  return PregnancyDataNotifier(ref);
});
