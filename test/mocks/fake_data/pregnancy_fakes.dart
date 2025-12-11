import 'package:mocktail/mocktail.dart';
import 'package:zeyra/domain/entities/pregnancy/pregnancy.dart';
import 'package:zeyra/domain/repositories/pregnancy_repository.dart';
import 'package:zeyra/domain/repositories/user_profile_repository.dart';

// ----------------------------------------------------------------------------
// Fake Data Builders for Pregnancy
// ----------------------------------------------------------------------------

/// Fake data builders for Pregnancy entities.
class FakePregnancy {
  /// Create a simple pregnancy with default or custom values.
  static Pregnancy simple({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? dueDate,
    String? selectedHospitalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    final defaultStartDate = now.subtract(const Duration(days: 140)); // 20 weeks ago
    final defaultDueDate = defaultStartDate.add(const Duration(days: 280)); // 280 days from start

    return Pregnancy(
      id: id ?? 'pregnancy-1',
      userId: userId ?? 'user-1',
      startDate: startDate ?? defaultStartDate,
      dueDate: dueDate ?? defaultDueDate,
      selectedHospitalId: selectedHospitalId,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Create a pregnancy at a specific week.
  static Pregnancy atWeek(int weeks, {int days = 0}) {
    final now = DateTime.now();
    final totalDays = weeks * 7 + days;
    final startDate = now.subtract(Duration(days: totalDays));
    final dueDate = startDate.add(const Duration(days: 280));

    return simple(
      startDate: startDate,
      dueDate: dueDate,
    );
  }

  /// Create a pregnancy that's overdue.
  static Pregnancy overdue({int daysOverdue = 5}) {
    final now = DateTime.now();
    final dueDate = now.subtract(Duration(days: daysOverdue));
    final startDate = dueDate.subtract(const Duration(days: 280));

    return simple(
      startDate: startDate,
      dueDate: dueDate,
    );
  }

  /// Create a pregnancy in first trimester (0-13 weeks).
  static Pregnancy firstTrimester() {
    return atWeek(8); // 8 weeks
  }

  /// Create a pregnancy in second trimester (14-27 weeks).
  static Pregnancy secondTrimester() {
    return atWeek(20); // 20 weeks
  }

  /// Create a pregnancy in third trimester (28-40 weeks).
  static Pregnancy thirdTrimester() {
    return atWeek(35); // 35 weeks
  }

  /// Create a pregnancy at the minimum duration (38 weeks / 266 days).
  static Pregnancy minDuration() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 266));
    final dueDate = startDate.add(const Duration(days: 266));

    return simple(
      startDate: startDate,
      dueDate: dueDate,
    );
  }

  /// Create a pregnancy at the maximum duration (42 weeks / 294 days).
  static Pregnancy maxDuration() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 294));
    final dueDate = startDate.add(const Duration(days: 294));

    return simple(
      startDate: startDate,
      dueDate: dueDate,
    );
  }

  /// Create a pregnancy with a specific hospital selected.
  static Pregnancy withHospital(String hospitalId) {
    return simple(selectedHospitalId: hospitalId);
  }

  /// Create a pregnancy due today.
  static Pregnancy dueToday() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 280));

    return simple(
      startDate: startDate,
      dueDate: now,
    );
  }
}

// ----------------------------------------------------------------------------
// Mock Classes for Pregnancy
// ----------------------------------------------------------------------------

/// Mock implementation of PregnancyRepository for testing.
class MockPregnancyRepository extends Mock implements PregnancyRepository {}

/// Mock implementation of UserProfileRepository for testing.
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
