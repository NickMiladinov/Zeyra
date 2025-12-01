import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/encryption_service.dart';
import '../../domain/entities/kick_counter/kick.dart';
import '../../domain/entities/kick_counter/kick_session.dart';
import '../../domain/repositories/kick_counter_repository.dart';
import '../local/app_database.dart';
import '../local/daos/kick_counter_dao.dart';
import '../mappers/kick_session_mapper.dart';

/// Implementation of KickCounterRepository using Drift and encryption.
/// 
/// Handles all kick counter data operations with encrypted storage
/// of sensitive medical data (perceived movement strength).
class KickCounterRepositoryImpl implements KickCounterRepository {
  final KickCounterDao _dao;
  final EncryptionService _encryptionService;
  final Uuid _uuid;

  KickCounterRepositoryImpl({
    required KickCounterDao dao,
    required EncryptionService encryptionService,
    Uuid? uuid,
  })  : _dao = dao,
        _encryptionService = encryptionService,
        _uuid = uuid ?? const Uuid();

  // --------------------------------------------------------------------------
  // Session Management
  // --------------------------------------------------------------------------

  @override
  Future<KickSession> createSession() async {
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
    );
  }

  @override
  Future<KickSession?> getActiveSession() async {
    final sessionDto = await _dao.getActiveSession();
    if (sessionDto == null) return null;

    // Get session with kicks
    final sessionWithKicks = await _dao.getSessionWithKicks(sessionDto.id);
    if (sessionWithKicks == null) return null;

    // Decrypt all kicks
    final decryptedKicks = <Kick>[];
    for (final kickDto in sessionWithKicks.kicks) {
      final decryptedStrength =
          await _encryptionService.decrypt(kickDto.perceivedStrength);
      decryptedKicks.add(
        KickSessionMapper.kickToDomain(kickDto, decryptedStrength),
      );
    }

    // Decrypt note if present
    String? decryptedNote;
    if (sessionWithKicks.session.note != null) {
      decryptedNote = await _encryptionService.decrypt(sessionWithKicks.session.note!);
    }

    // Build session with decrypted kicks
    return KickSession(
      id: sessionWithKicks.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(
          sessionWithKicks.session.startTimeMillis),
      endTime: sessionWithKicks.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.endTimeMillis!)
          : null,
      isActive: sessionWithKicks.session.isActive,
      kicks: decryptedKicks,
      pausedAt: sessionWithKicks.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: sessionWithKicks.session.totalPausedMillis,
      ),
      pauseCount: sessionWithKicks.session.pauseCount,
      note: decryptedNote,
    );
  }

  @override
  Future<void> endSession(String sessionId) async {
    final sessionDto = await _dao.getSessionWithKicks(sessionId);
    if (sessionDto == null) return;

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
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _dao.deleteSession(sessionId);
  }

  @override
  Future<KickSession?> getSession(String sessionId) async {
    final sessionWithKicks = await _dao.getSessionWithKicks(sessionId);
    if (sessionWithKicks == null) return null;

    // Decrypt all kicks
    final decryptedKicks = <Kick>[];
    for (final kickDto in sessionWithKicks.kicks) {
      final decryptedStrength =
          await _encryptionService.decrypt(kickDto.perceivedStrength);
      decryptedKicks.add(
        KickSessionMapper.kickToDomain(kickDto, decryptedStrength),
      );
    }

    // Decrypt note if present
    String? decryptedNote;
    if (sessionWithKicks.session.note != null) {
      decryptedNote = await _encryptionService.decrypt(sessionWithKicks.session.note!);
    }

    // Build session with decrypted kicks
    return KickSession(
      id: sessionWithKicks.session.id,
      startTime: DateTime.fromMillisecondsSinceEpoch(
          sessionWithKicks.session.startTimeMillis),
      endTime: sessionWithKicks.session.endTimeMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.endTimeMillis!)
          : null,
      isActive: sessionWithKicks.session.isActive,
      kicks: decryptedKicks,
      pausedAt: sessionWithKicks.session.pausedAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(
              sessionWithKicks.session.pausedAtMillis!)
          : null,
      totalPausedDuration: Duration(
        milliseconds: sessionWithKicks.session.totalPausedMillis,
      ),
      pauseCount: sessionWithKicks.session.pauseCount,
      note: decryptedNote,
    );
  }

  @override
  Future<KickSession> updateSessionNote(String sessionId, String? note) async {
    // Encrypt note if present
    String? encryptedNote;
    if (note != null && note.isNotEmpty) {
      encryptedNote = await _encryptionService.encrypt(note);
    }

    // Update session
    final now = DateTime.now();
    await _dao.updateSessionFields(
      sessionId,
      KickSessionsCompanion(
        note: Value(encryptedNote),
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
    return _dao.transaction(() async {
      // Get current kick count to determine sequence number
      final kickCount = await _dao.getKickCount(sessionId);

      // Encrypt strength
      final encryptedStrength = await _encryptionService.encrypt(
        KickSessionMapper.movementStrengthToString(strength),
      );

      // Create kick DTO
      final now = DateTime.now();
      final kickDto = KickDto(
        id: _uuid.v4(),
        sessionId: sessionId,
        timestampMillis: now.millisecondsSinceEpoch,
        sequenceNumber: kickCount + 1,
        perceivedStrength: encryptedStrength,
      );

      await _dao.insertKick(kickDto);
      await _dao.updateSessionFields(
        sessionId,
        KickSessionsCompanion(
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      // Return domain entity
      return Kick(
        id: kickDto.id,
        sessionId: kickDto.sessionId,
        timestamp: DateTime.fromMillisecondsSinceEpoch(kickDto.timestampMillis),
        sequenceNumber: kickDto.sequenceNumber,
        perceivedStrength: strength,
      );
    });
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
    final sessionDto = await _dao.getSessionWithKicks(sessionId);
    if (sessionDto == null) return;

    // Only set pausedAt if not already paused
    if (sessionDto.session.pausedAtMillis != null) return;

    final now = DateTime.now();
    await _dao.updateSessionFields(
      sessionId,
      KickSessionsCompanion(
        pausedAtMillis: Value(now.millisecondsSinceEpoch),
        updatedAtMillis: Value(now.millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    final sessionDto = await _dao.getSessionWithKicks(sessionId);
    if (sessionDto == null) return;

    final pausedAtMillis = sessionDto.session.pausedAtMillis;
    if (pausedAtMillis == null) return; // Not paused, nothing to do

    // Calculate elapsed pause duration
    final now = DateTime.now();
    final pausedAt = DateTime.fromMillisecondsSinceEpoch(pausedAtMillis);
    final pauseDuration = now.difference(pausedAt);

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

    // Decrypt all sessions
    final decryptedSessions = <KickSession>[];
    for (final sessionWithKicks in sessionsWithKicks) {
      // Decrypt all kicks for this session
      final decryptedKicks = <Kick>[];
      for (final kickDto in sessionWithKicks.kicks) {
        final decryptedStrength =
            await _encryptionService.decrypt(kickDto.perceivedStrength);
        decryptedKicks.add(
          KickSessionMapper.kickToDomain(kickDto, decryptedStrength),
        );
      }

      // Decrypt note if present
      String? decryptedNote;
      if (sessionWithKicks.session.note != null) {
        decryptedNote = await _encryptionService.decrypt(sessionWithKicks.session.note!);
      }

      // Build session with decrypted kicks
      decryptedSessions.add(KickSession(
        id: sessionWithKicks.session.id,
        startTime: DateTime.fromMillisecondsSinceEpoch(
            sessionWithKicks.session.startTimeMillis),
        endTime: sessionWithKicks.session.endTimeMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(
                sessionWithKicks.session.endTimeMillis!)
            : null,
        isActive: sessionWithKicks.session.isActive,
        kicks: decryptedKicks,
        pausedAt: sessionWithKicks.session.pausedAtMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(
                sessionWithKicks.session.pausedAtMillis!)
            : null,
        totalPausedDuration: Duration(
          milliseconds: sessionWithKicks.session.totalPausedMillis,
        ),
        pauseCount: sessionWithKicks.session.pauseCount,
        note: decryptedNote,
      ));
    }

    return decryptedSessions;
  }

  @override
  Future<int?> getPregnancyWeekForSession(String sessionId) async {
    // TODO: Implement pregnancy week calculation from pregnancy profile
    // This requires integration with pregnancy profile repository
    // For now, return null
    return null;
  }
}

