import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/kick_session_table.dart';
import '../models/kick_table.dart';
import 'package:equatable/equatable.dart';

part 'kick_counter_dao.g.dart';

/// Data Access Object for kick counter operations.
/// 
/// Provides type-safe database queries for sessions and kicks,
/// including complex operations like fetching sessions with their kicks.
@DriftAccessor(tables: [KickSessions, Kicks])
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

  /// Get a session with all its kicks.
  Future<KickSessionWithKicks?> getSessionWithKicks(String sessionId) async {
    final session = await (select(kickSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();

    if (session == null) return null;

    final kicksList = await (select(kicks)
          ..where((k) => k.sessionId.equals(sessionId))
          ..orderBy([(k) => OrderingTerm.asc(k.sequenceNumber)]))
        .get();

    return KickSessionWithKicks(
      session: session,
      kicks: kicksList,
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

    // Fetch kicks for each session
    final result = <KickSessionWithKicks>[];
    for (final session in sessions) {
      final kicksList = await getKicksForSession(session.id);
      result.add(KickSessionWithKicks(
        session: session,
        kicks: kicksList,
      ));
    }

    return result;
  }
}

/// Composite data class for a session with its kicks.
/// 
/// Used to return complete session data in a single query operation.
class KickSessionWithKicks extends Equatable {
  final KickSessionDto session;
  final List<KickDto> kicks;

  const KickSessionWithKicks({
    required this.session,
    required this.kicks,
  });

  @override
  List<Object?> get props => [session, kicks];

  @override
  String toString() =>
      'KickSessionWithKicks(session: ${session.id}, kicks: ${kicks.length})';
}

