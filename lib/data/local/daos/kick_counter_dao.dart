import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/kick_session_table.dart';
import '../models/kick_table.dart';
import '../models/pause_event_table.dart';
import 'package:equatable/equatable.dart';

part 'kick_counter_dao.g.dart';

/// Data Access Object for kick counter operations.
/// 
/// Provides type-safe database queries for sessions, kicks, and pause events,
/// including complex operations like fetching sessions with their kicks and pause events.
@DriftAccessor(tables: [KickSessions, Kicks, PauseEvents])
class KickCounterDao extends DatabaseAccessor<AppDatabase>
    with _$KickCounterDaoMixin {
  KickCounterDao(super.db);

  // --------------------------------------------------------------------------
  // Session CRUD Operations
  // --------------------------------------------------------------------------

  /// Get the currently active session, if one exists.
  /// 
  /// Returns null if no active session is found.
  Future<KickSessionDto?> getActiveSession() {
    return (select(kickSessions)
          ..where((s) => s.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Insert a new session.
  Future<KickSessionDto> insertSession(KickSessionDto session) {
    return into(kickSessions).insertReturning(session);
  }

  /// Update an existing session.
  Future<int> updateSession(KickSessionDto session) {
    return (update(kickSessions)..where((s) => s.id.equals(session.id)))
        .write(session.toCompanion(false));
  }

  /// Update specific session fields using a Companion.
  /// 
  /// This allows for partial updates without affecting other fields.
  Future<int> updateSessionFields(String sessionId, KickSessionsCompanion companion) {
    return (update(kickSessions)..where((s) => s.id.equals(sessionId)))
        .write(companion);
  }

  /// Delete a session by ID.
  /// 
  /// Cascade delete will automatically remove all associated kicks.
  Future<int> deleteSession(String sessionId) {
    return (delete(kickSessions)..where((s) => s.id.equals(sessionId))).go();
  }

  /// Get a session by ID without kicks.
  Future<KickSessionDto?> getSessionById(String sessionId) {
    return (select(kickSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
  }

  /// Get a session with all its kicks and pause events.
  Future<KickSessionWithKicks?> getSessionWithKicks(String sessionId) async {
    final session = await (select(kickSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();

    if (session == null) return null;

    final kicksList = await (select(kicks)
          ..where((k) => k.sessionId.equals(sessionId))
          ..orderBy([(k) => OrderingTerm.asc(k.sequenceNumber)]))
        .get();

    final pauseEventsList = await getPauseEventsForSession(sessionId);

    return KickSessionWithKicks(
      session: session,
      kicks: kicksList,
      pauseEvents: pauseEventsList,
    );
  }

  // --------------------------------------------------------------------------
  // Kick Operations
  // --------------------------------------------------------------------------

  /// Insert a new kick.
  Future<KickDto> insertKick(KickDto kick) {
    return into(kicks).insertReturning(kick);
  }

  /// Delete the kick with the highest sequence number for a session.
  /// 
  /// Used for undo functionality - removes the most recent kick.
  Future<int> deleteLastKick(String sessionId) async {
    final lastKick = await (select(kicks)
          ..where((k) => k.sessionId.equals(sessionId))
          ..orderBy([(k) => OrderingTerm.desc(k.sequenceNumber)])
          ..limit(1))
        .getSingleOrNull();

    if (lastKick == null) return 0;

    return (delete(kicks)..where((k) => k.id.equals(lastKick.id))).go();
  }

  /// Get all kicks for a session, ordered by sequence number.
  Future<List<KickDto>> getKicksForSession(String sessionId) {
    return (select(kicks)
          ..where((k) => k.sessionId.equals(sessionId))
          ..orderBy([(k) => OrderingTerm.asc(k.sequenceNumber)]))
        .get();
  }

  /// Get the count of kicks for a session.
  Future<int> getKickCount(String sessionId) async {
    final countQuery = selectOnly(kicks)
      ..addColumns([kicks.id.count()])
      ..where(kicks.sessionId.equals(sessionId));

    final result = await countQuery.getSingleOrNull();
    return result?.read(kicks.id.count()) ?? 0;
  }

  // --------------------------------------------------------------------------
  // Pause Event Operations
  // --------------------------------------------------------------------------

  /// Insert a new pause event.
  Future<PauseEventDto> insertPauseEvent(PauseEventDto pauseEvent) {
    return into(pauseEvents).insertReturning(pauseEvent);
  }

  /// Update an existing pause event with resume timestamp.
  Future<int> updatePauseEventResumed(String pauseEventId, int resumedAtMillis, int updatedAtMillis) {
    return (update(pauseEvents)..where((p) => p.id.equals(pauseEventId)))
        .write(PauseEventsCompanion(
          resumedAtMillis: Value(resumedAtMillis),
          updatedAtMillis: Value(updatedAtMillis),
        ));
  }

  /// Get all pause events for a session, ordered by pause time.
  Future<List<PauseEventDto>> getPauseEventsForSession(String sessionId) {
    return (select(pauseEvents)
          ..where((p) => p.sessionId.equals(sessionId))
          ..orderBy([(p) => OrderingTerm.asc(p.pausedAtMillis)]))
        .get();
  }

  /// Get the currently active (unresolved) pause event for a session.
  /// 
  /// Returns null if no active pause event exists.
  Future<PauseEventDto?> getActivePauseEvent(String sessionId) {
    return (select(pauseEvents)
          ..where((p) => p.sessionId.equals(sessionId) & p.resumedAtMillis.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  // --------------------------------------------------------------------------
  // History & Pagination
  // --------------------------------------------------------------------------

  /// Get historical sessions with their kicks.
  /// 
  /// [limit] - Maximum number of sessions to return
  /// [before] - Only include sessions started before this timestamp
  /// 
  /// Returns sessions ordered by startTime descending (most recent first).
  Future<List<KickSessionWithKicks>> getSessionHistory({
    int? limit,
    DateTime? before,
  }) async {
    // Build query for sessions
    final query = select(kickSessions);
    
    // Apply filters
    query.where((s) => s.isActive.equals(false));
    if (before != null) {
      query.where((s) => s.startTimeMillis.isSmallerThanValue(before.millisecondsSinceEpoch));
    }
    
    // Order by most recent first, using createdAt as tiebreaker
    query.orderBy([
      (s) => OrderingTerm.desc(s.startTimeMillis),
      (s) => OrderingTerm.desc(s.createdAtMillis),
    ]);
    
    // Apply limit if provided
    if (limit != null) {
      query.limit(limit);
    }

    final sessions = await query.get();

    // Fetch kicks and pause events for each session
    final result = <KickSessionWithKicks>[];
    for (final session in sessions) {
      final kicksList = await getKicksForSession(session.id);
      final pauseEventsList = await getPauseEventsForSession(session.id);
      result.add(KickSessionWithKicks(
        session: session,
        kicks: kicksList,
        pauseEvents: pauseEventsList,
      ));
    }

    return result;
  }
}

/// Composite data class for a session with its kicks and pause events.
/// 
/// Used to return complete session data in a single query operation.
class KickSessionWithKicks extends Equatable {
  final KickSessionDto session;
  final List<KickDto> kicks;
  final List<PauseEventDto> pauseEvents;

  const KickSessionWithKicks({
    required this.session,
    required this.kicks,
    this.pauseEvents = const [],
  });

  @override
  List<Object?> get props => [session, kicks, pauseEvents];

  @override
  String toString() =>
      'KickSessionWithKicks(session: ${session.id}, kicks: ${kicks.length}, pauseEvents: ${pauseEvents.length})';
}

