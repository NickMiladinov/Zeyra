import 'package:drift/drift.dart';

/// Drift table for contraction timing sessions.
/// 
/// Stores session metadata including start/end times, active status,
/// and 5-1-1 alert achievement flags. Each session is a discrete period
/// of contraction timing with medical relevance.
@DataClassName('ContractionSessionDto')
class ContractionSessions extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// When the session started (stored as millis since epoch for precision)
  IntColumn get startTimeMillis => integer()();

  /// When the session ended (null if still active)
  IntColumn get endTimeMillis => integer().nullable()();

  /// Whether this session is currently active
  /// Active sessions appear in the UI and prevent new session creation
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Whether duration criterion achieved (contractions >= 1 min)
  BoolColumn get achievedDuration => boolean().withDefault(const Constant(false))();

  /// When duration criterion was first achieved
  IntColumn get durationAchievedAtMillis => integer().nullable()();

  /// Whether frequency criterion achieved (contractions <= 5 min apart)
  BoolColumn get achievedFrequency => boolean().withDefault(const Constant(false))();

  /// When frequency criterion was first achieved
  IntColumn get frequencyAchievedAtMillis => integer().nullable()();

  /// Whether consistency criterion achieved (pattern for 1 hour)
  BoolColumn get achievedConsistency => boolean().withDefault(const Constant(false))();

  /// When consistency criterion was first achieved
  IntColumn get consistencyAchievedAtMillis => integer().nullable()();

  /// Optional encrypted note attached to this session
  /// Users can add personal observations about the session
  TextColumn get note => text().nullable()();

  /// Timestamp when record was created (stored as millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// Timestamp when record was last updated (stored as millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

