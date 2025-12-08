import 'package:drift/drift.dart';

/// Drift table for kick counting sessions.
/// 
/// Stores session metadata including start/end times, active status,
/// and pause tracking fields. Each session is a discrete period of
/// kick counting with medical relevance.
@DataClassName('KickSessionDto')
class KickSessions extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// When the session started (stored as millis since epoch for precision)
  IntColumn get startTimeMillis => integer()();

  /// When the session ended (null if still active)
  IntColumn get endTimeMillis => integer().nullable()();

  /// Whether this session is currently active
  /// Active sessions appear in the UI and prevent new session creation
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Timestamp when session was paused (null if not currently paused)
  /// When paused, kick recording is disabled but session remains active
  IntColumn get pausedAtMillis => integer().nullable()();

  /// Total accumulated pause duration in milliseconds
  /// Updated each time the session is resumed
  IntColumn get totalPausedMillis =>
      integer().withDefault(const Constant(0))();

  /// Number of times the user has paused this session
  /// Tracking metric for understanding user behavior patterns
  IntColumn get pauseCount => integer().withDefault(const Constant(0))();

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

