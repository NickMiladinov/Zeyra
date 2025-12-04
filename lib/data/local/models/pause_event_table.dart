import 'package:drift/drift.dart';

import 'kick_session_table.dart';

/// Drift table for pause events within kick counting sessions.
/// 
/// Tracks each pause/resume cycle with timestamps to enable accurate
/// calculation of time-to-10-kicks by excluding pause durations that
/// occurred before the 10th kick.
@DataClassName('PauseEventDto')
class PauseEvents extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to parent session
  /// Cascade delete ensures pause events are removed when session is deleted
  TextColumn get sessionId => text().references(KickSessions, #id, onDelete: KeyAction.cascade)();

  /// Timestamp when the session was paused (stored as millis since epoch)
  IntColumn get pausedAtMillis => integer()();

  /// Timestamp when the session was resumed (null if still paused or session ended while paused)
  /// Stored as millis since epoch for precision
  IntColumn get resumedAtMillis => integer().nullable()();

  /// Number of kicks recorded BEFORE this pause started
  /// Used to determine which pauses should be excluded from time-to-10 calculation
  IntColumn get kickCountAtPause => integer()();

  /// Timestamp when record was created (stored as millis since epoch)
  IntColumn get createdAtMillis => integer()();

  /// Timestamp when record was last updated (stored as millis since epoch)
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

