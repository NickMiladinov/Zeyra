import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../app_database.dart';
import '../models/contraction_session_table.dart';
import '../models/contraction_table.dart';

part 'contraction_timer_dao.g.dart';

/// Data Access Object for contraction timer operations.
/// 
/// Provides type-safe database queries for sessions and contractions,
/// including complex operations like fetching sessions with their contractions.
@DriftAccessor(tables: [ContractionSessions, Contractions])
class ContractionTimerDao extends DatabaseAccessor<AppDatabase>
    with _$ContractionTimerDaoMixin {
  ContractionTimerDao(super.db);

  // --------------------------------------------------------------------------
  // Session CRUD Operations
  // --------------------------------------------------------------------------

  /// Get the currently active session, if one exists.
  /// 
  /// Returns null if no active session is found.
  Future<ContractionSessionDto?> getActiveSession() {
    return (select(contractionSessions)
          ..where((s) => s.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Insert a new session.
  Future<ContractionSessionDto> insertSession(ContractionSessionDto session) {
    return into(contractionSessions).insertReturning(session);
  }

  /// Update an existing session.
  Future<int> updateSession(ContractionSessionDto session) {
    return (update(contractionSessions)..where((s) => s.id.equals(session.id)))
        .write(session.toCompanion(false));
  }

  /// Update specific session fields using a Companion.
  /// 
  /// This allows for partial updates without affecting other fields.
  Future<int> updateSessionFields(String sessionId, ContractionSessionsCompanion companion) {
    return (update(contractionSessions)..where((s) => s.id.equals(sessionId)))
        .write(companion);
  }

  /// Delete a session by ID.
  /// 
  /// Cascade delete will automatically remove all associated contractions.
  Future<int> deleteSession(String sessionId) {
    return (delete(contractionSessions)..where((s) => s.id.equals(sessionId))).go();
  }

  /// Get a session by ID without contractions.
  Future<ContractionSessionDto?> getSessionById(String sessionId) {
    return (select(contractionSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
  }

  /// Get a session with all its contractions.
  Future<ContractionSessionWithContractions?> getSessionWithContractions(String sessionId) async {
    final session = await (select(contractionSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();

    if (session == null) return null;

    final contractionsList = await (select(contractions)
          ..where((c) => c.sessionId.equals(sessionId))
          ..orderBy([(c) => OrderingTerm.asc(c.startTimeMillis)]))
        .get();

    return ContractionSessionWithContractions(
      session: session,
      contractions: contractionsList,
    );
  }

  // --------------------------------------------------------------------------
  // Contraction Operations
  // --------------------------------------------------------------------------

  /// Insert a new contraction.
  Future<ContractionDto> insertContraction(ContractionDto contraction) {
    return into(contractions).insertReturning(contraction);
  }

  /// Update an existing contraction.
  Future<int> updateContraction(ContractionDto contraction) {
    return (update(contractions)..where((c) => c.id.equals(contraction.id)))
        .write(contraction.toCompanion(false));
  }

  /// Update specific contraction fields using a Companion.
  Future<int> updateContractionFields(String contractionId, ContractionsCompanion companion) {
    return (update(contractions)..where((c) => c.id.equals(contractionId)))
        .write(companion);
  }

  /// Delete a contraction by ID.
  Future<int> deleteContraction(String contractionId) {
    return (delete(contractions)..where((c) => c.id.equals(contractionId))).go();
  }

  /// Get a contraction by ID.
  Future<ContractionDto?> getContractionById(String contractionId) {
    return (select(contractions)
          ..where((c) => c.id.equals(contractionId)))
        .getSingleOrNull();
  }

  /// Get all contractions for a session, ordered by start time.
  Future<List<ContractionDto>> getContractionsForSession(String sessionId) {
    return (select(contractions)
          ..where((c) => c.sessionId.equals(sessionId))
          ..orderBy([(c) => OrderingTerm.asc(c.startTimeMillis)]))
        .get();
  }

  /// Get the count of contractions for a session.
  Future<int> getContractionCount(String sessionId) async {
    final countQuery = selectOnly(contractions)
      ..addColumns([contractions.id.count()])
      ..where(contractions.sessionId.equals(sessionId));

    final result = await countQuery.getSingleOrNull();
    return result?.read(contractions.id.count()) ?? 0;
  }

  /// Get the currently active (timing) contraction for a session.
  /// 
  /// Returns null if no active contraction exists.
  Future<ContractionDto?> getActiveContraction(String sessionId) {
    return (select(contractions)
          ..where((c) => c.sessionId.equals(sessionId) & c.endTimeMillis.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  // --------------------------------------------------------------------------
  // History & Pagination
  // --------------------------------------------------------------------------

  /// Get historical sessions with their contractions.
  ///
  /// [limit] - Maximum number of sessions to return
  /// [before] - Only include sessions started before this timestamp
  ///
  /// Returns sessions ordered by startTime descending (most recent first).
  Future<List<ContractionSessionWithContractions>> getSessionHistory({
    int? limit,
    DateTime? before,
  }) async {
    // Build query for sessions
    final query = select(contractionSessions);

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

    // Fetch contractions for each session
    final result = <ContractionSessionWithContractions>[];
    for (final session in sessions) {
      final contractionsList = await getContractionsForSession(session.id);
      result.add(ContractionSessionWithContractions(
        session: session,
        contractions: contractionsList,
      ));
    }

    return result;
  }

  /// Delete sessions older than the specified timestamp.
  ///
  /// [cutoffTimeMillis] - Sessions with startTime before this will be deleted
  ///
  /// Returns the number of sessions deleted.
  /// Cascades to delete all associated contractions.
  Future<int> deleteSessionsOlderThan(int cutoffTimeMillis) {
    return (delete(contractionSessions)
          ..where((s) => s.startTimeMillis.isSmallerThanValue(cutoffTimeMillis)))
        .go();
  }
}

/// Composite data class for a session with its contractions.
/// 
/// Used to return complete session data in a single query operation.
class ContractionSessionWithContractions extends Equatable {
  final ContractionSessionDto session;
  final List<ContractionDto> contractions;

  const ContractionSessionWithContractions({
    required this.session,
    required this.contractions,
  });

  @override
  List<Object?> get props => [session, contractions];

  @override
  String toString() =>
      'ContractionSessionWithContractions(session: ${session.id}, contractions: ${contractions.length})';
}

