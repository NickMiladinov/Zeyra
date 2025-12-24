import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/contraction_timer/contraction.dart';
import '../../domain/entities/contraction_timer/contraction_intensity.dart';
import '../../domain/entities/contraction_timer/contraction_session.dart';
import '../../domain/entities/contraction_timer/contraction_timer_constants.dart';
import '../../domain/exceptions/contraction_timer_exception.dart';
import '../../domain/repositories/contraction_timer_repository.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../local/app_database.dart';
import '../local/daos/contraction_timer_dao.dart';
import '../mappers/contraction_mapper.dart';
import '../mappers/contraction_session_mapper.dart';

/// Implementation of [ContractionTimerRepository] using Drift for local storage.
/// 
/// Handles mapping between domain entities and database DTOs, UUID generation,
/// timestamp management, and data validation.
class ContractionTimerRepositoryImpl implements ContractionTimerRepository {
  final ContractionTimerDao _dao;
  final PregnancyRepository _pregnancyRepository;
  final LoggingService _logger;
  final Uuid _uuid = const Uuid();

  const ContractionTimerRepositoryImpl({
    required ContractionTimerDao dao,
    required PregnancyRepository pregnancyRepository,
    required LoggingService logger,
  })  : _dao = dao,
        _pregnancyRepository = pregnancyRepository,
        _logger = logger;

  // --------------------------------------------------------------------------
  // Session Management
  // --------------------------------------------------------------------------

  @override
  Future<ContractionSession> createSession() async {
    try {
      final now = DateTime.now();
      final sessionId = _uuid.v4();

      final session = ContractionSessionDto(
        id: sessionId,
        startTimeMillis: now.millisecondsSinceEpoch,
        endTimeMillis: null,
        isActive: true,
        achievedDuration: false,
        durationAchievedAtMillis: null,
        achievedFrequency: false,
        frequencyAchievedAtMillis: null,
        achievedConsistency: false,
        consistencyAchievedAtMillis: null,
        note: null,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      await _dao.insertSession(session);
      _logger.debug('Created contraction session: $sessionId');

      // Return as domain entity
      return ContractionSessionMapper.toDomain(
        ContractionSessionWithContractions(
          session: session,
          contractions: [],
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to create contraction session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ContractionSession?> getActiveSession() async {
    try {
      final sessionDto = await _dao.getActiveSession();
      if (sessionDto == null) return null;

      final contractions = await _dao.getContractionsForSession(sessionDto.id);

      return ContractionSessionMapper.toDomain(
        ContractionSessionWithContractions(
          session: sessionDto,
          contractions: contractions,
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to get active contraction session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> endSession(String sessionId) async {
    try {
      final now = DateTime.now();

      // Stop any active contraction first
      final activeContraction = await _dao.getActiveContraction(sessionId);
      if (activeContraction != null) {
        await _dao.updateContractionFields(
          activeContraction.id,
          ContractionsCompanion(
            endTimeMillis: Value(now.millisecondsSinceEpoch),
            updatedAtMillis: Value(now.millisecondsSinceEpoch),
          ),
        );
      }

      // End the session
      await _dao.updateSessionFields(
        sessionId,
        ContractionSessionsCompanion(
          endTimeMillis: Value(now.millisecondsSinceEpoch),
          isActive: const Value(false),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      _logger.debug('Ended contraction session: $sessionId');
    } catch (e, stackTrace) {
      _logger.error('Failed to end contraction session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      // Delete all contractions first (if not cascade)
      final contractions = await _dao.getContractionsForSession(sessionId);
      for (final contraction in contractions) {
        await _dao.deleteContraction(contraction.id);
      }

      // Delete the session
      await _dao.deleteSession(sessionId);
      _logger.debug('Deleted contraction session: $sessionId');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete contraction session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ContractionSession?> getSession(String sessionId) async {
    try {
      final composite = await _dao.getSessionWithContractions(sessionId);
      if (composite == null) return null;

      return ContractionSessionMapper.toDomain(composite);
    } catch (e, stackTrace) {
      _logger.error('Failed to get contraction session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ContractionSession> updateSessionNote(String sessionId, String? note) async {
    try {
      final now = DateTime.now();

      await _dao.updateSessionFields(
        sessionId,
        ContractionSessionsCompanion(
          note: Value(note),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      final updated = await getSession(sessionId);
      if (updated == null) {
        throw const ContractionTimerException(
          'Session not found after update',
          ContractionTimerErrorType.noActiveSession,
        );
      }

      _logger.debug('Updated session note: $sessionId');
      return updated;
    } catch (e, stackTrace) {
      _logger.error('Failed to update session note', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ContractionSession> updateSessionCriteria(
    String sessionId, {
    bool? achievedDuration,
    DateTime? durationAchievedAt,
    bool? achievedFrequency,
    DateTime? frequencyAchievedAt,
    bool? achievedConsistency,
    DateTime? consistencyAchievedAt,
  }) async {
    try {
      final now = DateTime.now();

      // Build companion with only provided values
      final companion = ContractionSessionsCompanion(
        achievedDuration: achievedDuration != null ? Value(achievedDuration) : const Value.absent(),
        durationAchievedAtMillis: durationAchievedAt != null 
            ? Value(durationAchievedAt.millisecondsSinceEpoch) 
            : const Value.absent(),
        achievedFrequency: achievedFrequency != null ? Value(achievedFrequency) : const Value.absent(),
        frequencyAchievedAtMillis: frequencyAchievedAt != null 
            ? Value(frequencyAchievedAt.millisecondsSinceEpoch) 
            : const Value.absent(),
        achievedConsistency: achievedConsistency != null ? Value(achievedConsistency) : const Value.absent(),
        consistencyAchievedAtMillis: consistencyAchievedAt != null 
            ? Value(consistencyAchievedAt.millisecondsSinceEpoch) 
            : const Value.absent(),
        updatedAtMillis: Value(now.millisecondsSinceEpoch),
      );

      await _dao.updateSessionFields(sessionId, companion);

      final updated = await getSession(sessionId);
      if (updated == null) {
        throw const ContractionTimerException(
          'Session not found after update',
          ContractionTimerErrorType.noActiveSession,
        );
      }

      _logger.debug('Updated session 5-1-1 criteria: $sessionId');
      return updated;
    } catch (e, stackTrace) {
      _logger.error('Failed to update session criteria', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Contraction Operations
  // --------------------------------------------------------------------------

  @override
  Future<Contraction> startContraction(
    String sessionId, {
    ContractionIntensity intensity = ContractionIntensity.moderate,
  }) async {
    try {
      // Check if there's already an active contraction
      final existing = await _dao.getActiveContraction(sessionId);
      if (existing != null) {
        throw const ContractionTimerException(
          'A contraction is already being timed',
          ContractionTimerErrorType.contractionAlreadyActive,
        );
      }

      final now = DateTime.now();
      final contractionId = _uuid.v4();

      final contraction = ContractionDto(
        id: contractionId,
        sessionId: sessionId,
        startTimeMillis: now.millisecondsSinceEpoch,
        endTimeMillis: null,
        intensity: _intensityToInt(intensity),
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      await _dao.insertContraction(contraction);
      _logger.debug('Started contraction: $contractionId');

      return ContractionMapper.toDomain(contraction);
    } catch (e, stackTrace) {
      _logger.error('Failed to start contraction', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Contraction> stopContraction(String contractionId) async {
    try {
      final existing = await _dao.getContractionById(contractionId);
      if (existing == null) {
        throw const ContractionTimerException(
          'Contraction not found',
          ContractionTimerErrorType.contractionNotFound,
        );
      }

      if (existing.endTimeMillis != null) {
        throw const ContractionTimerException(
          'Contraction is not active',
          ContractionTimerErrorType.noActiveContraction,
        );
      }

      final now = DateTime.now();
      final startTime = DateTime.fromMillisecondsSinceEpoch(existing.startTimeMillis);
      final actualDuration = now.difference(startTime);
      
      // Cap duration at maximum threshold (2 minutes)
      final cappedEndTime = actualDuration > ContractionTimerConstants.maxContractionDuration
          ? startTime.add(ContractionTimerConstants.maxContractionDuration)
          : now;
      
      if (actualDuration > ContractionTimerConstants.maxContractionDuration) {
        _logger.debug('Capped contraction duration from ${actualDuration.inSeconds}s to ${ContractionTimerConstants.maxContractionDuration.inSeconds}s');
      }

      await _dao.updateContractionFields(
        contractionId,
        ContractionsCompanion(
          endTimeMillis: Value(cappedEndTime.millisecondsSinceEpoch),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      final updated = await _dao.getContractionById(contractionId);
      if (updated == null) {
        throw const ContractionTimerException(
          'Contraction not found after update',
          ContractionTimerErrorType.contractionNotFound,
        );
      }

      _logger.debug('Stopped contraction: $contractionId');
      return ContractionMapper.toDomain(updated);
    } catch (e, stackTrace) {
      _logger.error('Failed to stop contraction', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Contraction> updateContraction(
    String contractionId, {
    DateTime? startTime,
    Duration? duration,
    ContractionIntensity? intensity,
  }) async {
    try {
      final existing = await _dao.getContractionById(contractionId);
      if (existing == null) {
        throw const ContractionTimerException(
          'Contraction not found',
          ContractionTimerErrorType.contractionNotFound,
        );
      }

      final now = DateTime.now();
      final newStartTime = startTime ?? DateTime.fromMillisecondsSinceEpoch(existing.startTimeMillis);
      
      // Calculate end time from duration if provided
      int? newEndTimeMillis = existing.endTimeMillis;
      if (duration != null) {
        final newEndTime = newStartTime.add(duration);
        
        // Validate that end time is after start time
        if (newEndTime.isBefore(newStartTime)) {
          throw const ContractionTimerException(
            'End time must be after start time',
            ContractionTimerErrorType.invalidContractionData,
          );
        }
        
        newEndTimeMillis = newEndTime.millisecondsSinceEpoch;
      }

      await _dao.updateContractionFields(
        contractionId,
        ContractionsCompanion(
          startTimeMillis: Value(newStartTime.millisecondsSinceEpoch),
          endTimeMillis: Value(newEndTimeMillis),
          intensity: intensity != null ? Value(_intensityToInt(intensity)) : Value(existing.intensity),
          updatedAtMillis: Value(now.millisecondsSinceEpoch),
        ),
      );

      final updated = await _dao.getContractionById(contractionId);
      if (updated == null) {
        throw const ContractionTimerException(
          'Contraction not found after update',
          ContractionTimerErrorType.contractionNotFound,
        );
      }

      _logger.debug('Updated contraction: $contractionId');
      return ContractionMapper.toDomain(updated);
    } catch (e, stackTrace) {
      _logger.error('Failed to update contraction', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteContraction(String contractionId) async {
    try {
      final deleted = await _dao.deleteContraction(contractionId);
      if (deleted == 0) {
        throw const ContractionTimerException(
          'Contraction not found',
          ContractionTimerErrorType.contractionNotFound,
        );
      }

      _logger.debug('Deleted contraction: $contractionId');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete contraction', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // History & Context
  // --------------------------------------------------------------------------

  @override
  Future<List<ContractionSession>> getSessionHistory({
    int? limit,
    DateTime? before,
  }) async {
    try {
      final composites = await _dao.getSessionHistory(
        limit: limit,
        before: before,
      );

      return ContractionSessionMapper.toDomainList(composites);
    } catch (e, stackTrace) {
      _logger.error('Failed to get session history', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<int> deleteSessionsOlderThan(DateTime cutoffDate) async {
    try {
      final deleted = await _dao.deleteSessionsOlderThan(
        cutoffDate.millisecondsSinceEpoch,
      );

      _logger.debug('Deleted $deleted old contraction sessions');
      return deleted;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete old sessions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<int?> getPregnancyWeekForSession(String sessionId) async {
    try {
      // Get the session to retrieve its start time
      final session = await getSession(sessionId);
      if (session == null) {
        _logger.warning('Session not found for pregnancy week calculation');
        return null;
      }

      // Get the active pregnancy
      final pregnancy = await _pregnancyRepository.getActivePregnancy();
      if (pregnancy == null) {
        _logger.debug('No active pregnancy found for week calculation');
        return null;
      }

      // Calculate pregnancy week at the time of the session using domain logic
      return pregnancy.getGestationalWeekAt(session.startTime);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to calculate pregnancy week for session',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // Helper Methods
  // --------------------------------------------------------------------------

  int _intensityToInt(ContractionIntensity intensity) {
    switch (intensity) {
      case ContractionIntensity.mild:
        return 0;
      case ContractionIntensity.moderate:
        return 1;
      case ContractionIntensity.strong:
        return 2;
    }
  }
}

