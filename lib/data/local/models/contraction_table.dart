import 'package:drift/drift.dart';

/// Drift table for individual contractions.
/// 
/// Stores contraction timing data including start/end times and intensity.
/// Each contraction is linked to a session via foreign key.
@DataClassName('ContractionDto')
class Contractions extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to the session this contraction belongs to
  /// Links to ContractionSessions.id
  TextColumn get sessionId => text()();

  /// When the contraction started (stored as millis since epoch for precision)
  IntColumn get startTimeMillis => integer()();

  /// When the contraction ended (null if currently active/being timed)
  IntColumn get endTimeMillis => integer().nullable()();

  /// Perceived intensity as reported by user
  /// Stored as integer: 0 = mild, 1 = moderate, 2 = strong
  /// Maps to ContractionIntensity enum
  IntColumn get intensity => integer().withDefault(const Constant(1))(); // Default: moderate

  /// Timestamp when record was created (stored as millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// Timestamp when record was last updated (stored as millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};

  // Foreign key constraint (optional, for referential integrity)
  // Note: Drift will automatically cascade deletes if configured in database
}

