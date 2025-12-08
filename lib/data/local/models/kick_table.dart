import 'package:drift/drift.dart';

import 'kick_session_table.dart';

/// Drift table for individual kicks within a session.
/// 
/// Each kick represents a single detected fetal movement with timestamp,
/// sequence number, and encrypted perceived strength data.
@DataClassName('KickDto')
class Kicks extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to parent session
  /// Cascade delete ensures kicks are removed when session is deleted
  TextColumn get sessionId => text().references(KickSessions, #id, onDelete: KeyAction.cascade)();

  /// Timestamp when the kick was recorded (stored as millis since epoch for precision)
  /// Used for calculating time between kicks and patterns
  IntColumn get timestampMillis => integer()();

  /// Sequential number of this kick within the session (1-indexed)
  /// Used for ordering and "undo last kick" functionality
  IntColumn get sequenceNumber => integer()();

  /// Encrypted perceived movement strength
  /// Stored as encrypted base64 string for medical data privacy
  /// Decrypts to enum: weak, moderate, strong
  TextColumn get perceivedStrength => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionId, sequenceNumber}
      ];
}

