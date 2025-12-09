import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/kick_counter/kick.dart';
import '../../domain/entities/kick_counter/kick_session.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../local/app_database.dart';
import '../local/daos/kick_counter_dao.dart';
import '../mappers/kick_session_mapper.dart';
import '../mappers/pause_event_mapper.dart';

/// Implementation of KickCounterRepository using Drift with SQLCipher encryption.
///
/// Handles all kick counter data operations. Data is protected by SQLCipher
/// full database encryption - no field-level encryption is needed.
///
/// **Security:** The entire database is encrypted with AES-256 via SQLCipher.
/// See [AppDatabase.encrypted] for encryption configuration details.
class KickCounterRepositoryImpl implements KickCounterRepository {
  final KickCounterDao _dao;
  final LoggingService _logger;
  final Uuid _uuid;

  KickCounterRepositoryImpl({
    required KickCounterDao dao,
    required LoggingService logger,
    Uuid? uuid,
  })  : _dao = dao,
        _logger = logger,
        _uuid = uuid ?? const Uuid();

  // --------------------------------------------------------------------------
  // Session Management
  // --------------------------------------------------------------------------

  @override
  Future<KickSession> createSession() async {
    _logger.debug('Creating new kick session');

    try {
      final now = DateTime.now();
      final session = KickSessionDto(
        id: _uuid.v4(),
        startTimeMillis: now.millisecondsSinceEpoch,
        endTimeMillis: null,
        isActive: true,
        pausedAtMillis: null,
        totalPausedMillis: 0,
        pauseCount: 0,
        note: null,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      await _dao.insertSession(session);

      _logger.info('Kick session created successfully');
      _logger.logDatabaseOperation('INSERT', table: 'kick_sessions', success: true);

      // Return domain entity with empty kicks list
      return KickSession(
        id: session.id,
        startTime: DateTime.fromMillisecondsSinceEpoch(session.startTimeMillis),
        endTime: session.endTimeMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(session.endTimeMillis!)
            : null,
        isActive: session.isActive,
        kicks: const [],
        pausedAt: session.pausedAtMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(session.pausedAtMillis!)
            : null,
        totalPausedDuration: Duration(milliseconds: session.totalPausedMillis),
        pauseCount: session.pauseCount,
        note: null,
        pauseEvents: const [],
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create kick session',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('INSERT', table: 'kick_sessions', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<KickSession?> getActiveSession() async {
    final sessionDto = await _dao.getActiveSession();
    if (sessionDto == null) return null;

    // Get session with kicks
    final sessionWithKicks = await _dao.getSessionWithKicks(sessionDto.id);
    if (sessionWithKicks == null) return null;

    // Map kicks to domain entities (no decryption needed - SQLCipher handles it)
    final kicks = sessionWithKicks.kicks
        .map((kickDto) => KickSessionMapper.kickToDomain(kickDto))
        .toList();

    // Map pause events to domain entities
    final pauseEvents = PauseEventMapper.toDomainList(sessionWithKicks.pauseEvents);

    // Build session with kicks and pause events
    return KickSession(
      id: sessionWithKicks.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(
          sessionWithKicks.session.startTimeMillis),
      endTime: sessionWithKicks.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.endTimeMillis!)
          : null,
      isActive: sessionWithKicks.session.isActive,
      kicks: kicks,
      pausedAt: sessionWithKicks.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: sessionWithKicks.session.totalPausedMillis,
      ),
      pauseCount: sessionWithKicks.session.pauseCount,
      note: sessionWithKicks.session.note,
      pauseEvents: pauseEvents,
    );
  }

  @override
  Future<void> endSession(String sessionId) async {
    _logger.debug('Ending kick session');

    try {
      final sessionDto = await _dao.getSessionWithKicks(sessionId);
      if (sessionDto == null) {
        _logger.warning('Attempted to end non-existent session');
        return;
      }

      final now = DateTime.now();

      // If session is currently paused, add remaining pause time before ending
      int additionalPauseMillis = 0;
      if (sessionDto.session.pausedAtMillis != null) {
        final pausedAt = DateTime.fromMillisecondsSinceEpoch(
            sessionDto.session.pausedAtMillis!);
        additionalPauseMillis = now.difference(pausedAt).inMilliseconds;
      }

      await _dao.updateSessionFields(
        sessionId,
        KickSessionsCompanion(
          endTimeMillis: Value(now.millisecondsSinceEpoch),
          isActive: const Value(false),
          pausedAtMillis: const Value(null), // Clear pausedAt when ending
          totalPausedMillis: Value(
            sessionDto.session.totalPausedMillis + additionalPauseMillis,
          ),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      _logger.info('Kick session ended successfully', data: {
        'kick_count': sessionDto.kicks.length,
      });
      _logger.logDatabaseOperation('UPDATE', table: 'kick_sessions', success: true);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to end kick session',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPDATE', table: 'kick_sessions', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _dao.deleteSession(sessionId);
  }

  @override
  Future<KickSession?> getSession(String sessionId) async {
    final sessionWithKicks = await _dao.getSessionWithKicks(sessionId);
    if (sessionWithKicks == null) return null;

    // Map kicks to domain entities (no decryption needed - SQLCipher handles it)
    final kicks = sessionWithKicks.kicks
        .map((kickDto) => KickSessionMapper.kickToDomain(kickDto))
        .toList();

    // Build session with kicks
    return KickSession(
      id: sessionWithKicks.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(
          sessionWithKicks.session.startTimeMillis),
      endTime: sessionWithKicks.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.endTimeMillis!)
          : null,
      isActive: sessionWithKicks.session.isActive,
      kicks: kicks,
      pausedAt: sessionWithKicks.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: sessionWithKicks.session.totalPausedMillis,
      ),
      pauseCount: sessionWithKicks.session.pauseCount,
      note: sessionWithKicks.session.note,
    );
  }

  @override
  Future<KickSession> updateSessionNote(String sessionId, String? note) async {
    // Update session (note is stored as plaintext - SQLCipher encrypts the DB)
    // Treat empty string as null (clearing the note)
    final normalizedNote = (note == null || note.isEmpty) ? null : note;

    final now = DateTime.now();
    await _dao.updateSessionFields(
      sessionId,
      KickSessionsCompanion(
        note: Value(normalizedNote),
        updatedAtMillis: Value(now.millisecondsSinceEpoch),
      ),
    );

    // Fetch and return updated session
    final updatedSession = await getSession(sessionId);
    if (updatedSession == null) {
      throw Exception('Session not found after update: $sessionId');
    }
    return updatedSession;
  }

  // --------------------------------------------------------------------------
  // Kick Operations
  // --------------------------------------------------------------------------

  @override
  Future<Kick> addKick(String sessionId, MovementStrength strength) async {
    _logger.debug('Adding kick to session');

    try {
      return await _dao.transaction(() async {
        // Get current kick count to determine sequence number
        final kickCount = await _dao.getKickCount(sessionId);

        // Create kick DTO (strength stored as plaintext - SQLCipher encrypts the DB)
        final now = DateTime.now();
        final kickDto = KickDto(
          id: _uuid.v4(),
          sessionId: sessionId,
          timestampMillis: now.millisecondsSinceEpoch,
          sequenceNumber: kickCount + 1,
          perceivedStrength: KickSessionMapper.movementStrengthToString(strength),
        );

        await _dao.insertKick(kickDto);
        await _dao.updateSessionFields(
          sessionId,
          KickSessionsCompanion(
            updatedAtMillis: Value(now.millisecondsSinceEpoch),
          ),
        );

        _logger.debug('Kick added successfully', data: {
          'sequence_number': kickCount + 1,
        });
        _logger.logDatabaseOperation('INSERT', table: 'kicks', success: true);

        // Return domain entity
        return Kick(
          id: kickDto.id,
          sessionId: kickDto.sessionId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(kickDto.timestampMillis),
          sequenceNumber: kickDto.sequenceNumber,
          perceivedStrength: strength,
        );
      });
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to add kick',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('INSERT', table: 'kicks', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeLastKick(String sessionId) async {
    await _dao.deleteLastKick(sessionId);
  }

  // --------------------------------------------------------------------------
  // Pause Operations
  // --------------------------------------------------------------------------

  @override
  Future<void> pauseSession(String sessionId) async {
    return _dao.transaction(() async {
      final sessionDto = await _dao.getSessionWithKicks(sessionId);
      if (sessionDto == null) return;

      // Only set pausedAt if not already paused
      if (sessionDto.session.pausedAtMillis != null) return;

      final now = DateTime.now();

      // Create pause event record
      final pauseEventDto = PauseEventDto(
        id: _uuid.v4(),
        sessionId: sessionId,
        pausedAtMillis: now.millisecondsSinceEpoch,
        resumedAtMillis: null, // Will be set on resume
        kickCountAtPause: sessionDto.kicks.length,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      await _dao.insertPauseEvent(pauseEventDto);

      await _dao.updateSessionFields(
        sessionId,
        KickSessionsCompanion(
          pausedAtMillis: Value(now.millisecondsSinceEpoch),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );
    });
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    return _dao.transaction(() async {
      final sessionDto = await _dao.getSessionWithKicks(sessionId);
      if (sessionDto == null) return;

      final pausedAtMillis = sessionDto.session.pausedAtMillis;
      if (pausedAtMillis == null) return; // Not paused, nothing to do

      // Calculate elapsed pause duration
      final now = DateTime.now();
      final pausedAt = DateTime.fromMillisecondsSinceEpoch(pausedAtMillis);
      final pauseDuration = now.difference(pausedAt);

      // Update the active pause event with resume timestamp
      final activePauseEvent = await _dao.getActivePauseEvent(sessionId);
      if (activePauseEvent != null) {
        await _dao.updatePauseEventResumed(
          activePauseEvent.id,
          now.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
      }

      // Update session with accumulated pause time
      await _dao.updateSessionFields(
        sessionId,
        KickSessionsCompanion(
          pausedAtMillis: const Value(null), // Clear pausedAt
          totalPausedMillis: Value(
            sessionDto.session.totalPausedMillis + pauseDuration.inMilliseconds,
          ),
          pauseCount: Value(sessionDto.session.pauseCount + 1),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );
    });
  }

  // --------------------------------------------------------------------------
  // History & Context
  // --------------------------------------------------------------------------

  @override
  Future<List<KickSession>> getSessionHistory({
    int? limit,
    DateTime? before,
  }) async {
    final sessionsWithKicks = await _dao.getSessionHistory(
      limit: limit,
      before: before,
    );

    // Map all sessions to domain entities (no decryption needed - SQLCipher handles it)
    return sessionsWithKicks.map((sessionWithKicks) {
      // Map kicks to domain entities
      final kicks = sessionWithKicks.kicks
          .map((kickDto) => KickSessionMapper.kickToDomain(kickDto))
          .toList();

      // Map pause events to domain entities
      final pauseEvents = PauseEventMapper.toDomainList(sessionWithKicks.pauseEvents);

      // Build session with kicks and pause events
      return KickSession(
        id: sessionWithKicks.session.id,
        startTime: DateTime.fromMillisecondsSinceEpoch(
            sessionWithKicks.session.startTimeMillis),
        endTime: sessionWithKicks.session.endTimeMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(
                sessionWithKicks.session.endTimeMillis!)
            : null,
        isActive: sessionWithKicks.session.isActive,
        kicks: kicks,
        pausedAt: sessionWithKicks.session.pausedAtMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(
                sessionWithKicks.session.pausedAtMillis!)
            : null,
        totalPausedDuration: Duration(
          milliseconds: sessionWithKicks.session.totalPausedMillis,
        ),
        pauseCount: sessionWithKicks.session.pauseCount,
        note: sessionWithKicks.session.note,
        pauseEvents: pauseEvents,
      );
    }).toList();
  }

  @override
  Future<int> deleteSessionsOlderThan(DateTime cutoffDate) async {
    _logger.debug('Deleting sessions older than cutoff date');

    try {
      final deletedCount = await _dao.deleteSessionsOlderThan(
        cutoffDate.millisecondsSinceEpoch,
      );

      _logger.info('Deleted old kick sessions', data: {
        'count': deletedCount,
        'cutoff_date': cutoffDate.toIso8601String(),
      });
      _logger.logDatabaseOperation('DELETE', table: 'kick_sessions', success: true);

      return deletedCount;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete old kick sessions',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('DELETE', table: 'kick_sessions', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<int?> getPregnancyWeekForSession(String sessionId) async {
    // TODO: Implement pregnancy week calculation from pregnancy profile
    // This requires integration with pregnancy profile repository
    // For now, return null
    return null;
  }
}
