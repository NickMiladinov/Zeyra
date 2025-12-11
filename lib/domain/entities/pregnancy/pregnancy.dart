/// Domain entity representing a pregnancy.
///
/// Tracks pregnancy dates and hospital selection. Uses standard
/// 280-day (40-week) gestation period for date calculations.
class Pregnancy {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to UserProfile
  final String userId;

  /// Last Menstrual Period (LMP) or conception date
  final DateTime startDate;

  /// Expected due date (EDD)
  final DateTime dueDate;

  /// Selected hospital ID (nullable for future implementation)
  final String? selectedHospitalId;

  /// When record was created
  final DateTime createdAt;

  /// When record was last updated
  final DateTime updatedAt;

  const Pregnancy({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.dueDate,
    this.selectedHospitalId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Standard pregnancy duration in days (40 weeks)
  static const int standardDurationDays = 280;

  /// Calculate current gestational week
  ///
  /// Returns the number of completed weeks since startDate.
  /// Returns 0 if startDate is in the future.
  int get gestationalWeek {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;

    final daysSinceStart = now.difference(startDate).inDays;
    return daysSinceStart ~/ 7;
  }

  /// Calculate gestational days within current week (0-6)
  int get gestationalDaysInWeek {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;

    final daysSinceStart = now.difference(startDate).inDays;
    return daysSinceStart % 7;
  }

  /// Get formatted gestational age (e.g., "24w 3d")
  String get gestationalAgeFormatted {
    return '${gestationalWeek}w ${gestationalDaysInWeek}d';
  }

  /// Calculate days remaining until due date
  ///
  /// Returns negative number if past due date.
  int get daysRemaining {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Check if pregnancy is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(dueDate);
  }

  /// Calculate percentage of pregnancy completed (0.0 to 1.0+)
  ///
  /// Can exceed 1.0 if past due date.
  double get progressPercentage {
    final totalDuration = dueDate.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;

    if (totalDuration == 0) return 0.0;
    return (elapsed / totalDuration).clamp(0.0, 1.5);
  }

  /// Create a copy with updated fields
  Pregnancy copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? dueDate,
    String? selectedHospitalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      selectedHospitalId: selectedHospitalId ?? this.selectedHospitalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pregnancy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          startDate == other.startDate &&
          dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ startDate.hashCode ^ dueDate.hashCode;

  @override
  String toString() =>
      'Pregnancy(id: $id, userId: $userId, gestationalAge: $gestationalAgeFormatted, daysRemaining: $daysRemaining)';
}
