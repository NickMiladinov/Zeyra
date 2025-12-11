import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/pregnancy/pregnancy.dart';
import '../../domain/exceptions/pregnancy_exception.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../local/daos/pregnancy_dao.dart';
import '../mappers/pregnancy_mapper.dart';

/// Implementation of PregnancyRepository using Drift.
class PregnancyRepositoryImpl implements PregnancyRepository {
  final PregnancyDao _dao;
  final LoggingService _logger;

  PregnancyRepositoryImpl({
    required PregnancyDao dao,
    required LoggingService logger,
  })  : _dao = dao,
        _logger = logger;

  @override
  Future<Pregnancy?> getActivePregnancy() async {
    final dto = await _dao.getActivePregnancy();
    if (dto == null) return null;

    return PregnancyMapper.toDomain(dto);
  }

  @override
  Future<Pregnancy?> getPregnancyById(String id) async {
    final dto = await _dao.getPregnancyById(id);
    if (dto == null) return null;

    return PregnancyMapper.toDomain(dto);
  }

  @override
  Future<List<Pregnancy>> getAllPregnancies() async {
    final dtos = await _dao.getAllPregnancies();
    return dtos.map((dto) => PregnancyMapper.toDomain(dto)).toList();
  }

  @override
  Future<Pregnancy> createPregnancy(Pregnancy pregnancy) async {
    _logger.debug('Creating pregnancy');

    try {
      // Validate dates
      _validatePregnancyDates(pregnancy.startDate, pregnancy.dueDate);

      final dto = PregnancyMapper.toDto(pregnancy);
      final insertedDto = await _dao.insertPregnancy(dto);

      _logger.info('Pregnancy created successfully');
      _logger.logDatabaseOperation('INSERT',
          table: 'pregnancies', success: true);

      // Return the inserted DTO mapped back to domain entity
      // to ensure database-generated fields are included
      return PregnancyMapper.toDomain(insertedDto);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create pregnancy',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('INSERT',
          table: 'pregnancies', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<Pregnancy> updatePregnancy(Pregnancy pregnancy) async {
    _logger.debug('Updating pregnancy');

    try {
      // Validate dates
      _validatePregnancyDates(pregnancy.startDate, pregnancy.dueDate);

      // Update updatedAt timestamp
      final updatedPregnancy = pregnancy.copyWith(
        updatedAt: DateTime.now(),
      );

      final dto = PregnancyMapper.toDto(updatedPregnancy);
      await _dao.updatePregnancy(dto);

      _logger.info('Pregnancy updated successfully');
      _logger.logDatabaseOperation('UPDATE',
          table: 'pregnancies', success: true);

      return updatedPregnancy;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update pregnancy',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('UPDATE',
          table: 'pregnancies', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> deletePregnancy(String pregnancyId) async {
    _logger.debug('Deleting pregnancy');

    try {
      await _dao.deletePregnancy(pregnancyId);

      _logger.info('Pregnancy deleted successfully');
      _logger.logDatabaseOperation('DELETE',
          table: 'pregnancies', success: true);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete pregnancy',
        error: e,
        stackTrace: stackTrace,
      );
      _logger.logDatabaseOperation('DELETE',
          table: 'pregnancies', success: false, error: e);
      rethrow;
    }
  }

  /// Validate pregnancy dates.
  void _validatePregnancyDates(DateTime startDate, DateTime dueDate) {
    final now = DateTime.now();

    // Start date should not be in the future
    if (startDate.isAfter(now)) {
      throw const PregnancyException(
        'Start date cannot be in the future.',
        PregnancyErrorType.invalidStartDate,
      );
    }

    // Start date should be within reasonable range (max 42 weeks ago)
    final maxStartDate = now.subtract(const Duration(days: 294)); // 42 weeks
    if (startDate.isBefore(maxStartDate)) {
      throw const PregnancyException(
        'Start date is too far in the past (max 42 weeks).',
        PregnancyErrorType.invalidStartDate,
      );
    }

    // Due date must be after start date
    if (dueDate.isBefore(startDate)) {
      throw const PregnancyException(
        'Due date must be after start date.',
        PregnancyErrorType.invalidDueDate,
      );
    }

    // Date range should be realistic (38-42 weeks / 266-294 days)
    final duration = dueDate.difference(startDate).inDays;
    if (duration < 266 || duration > 294) {
      throw PregnancyException(
        'Pregnancy duration must be between 38-42 weeks (266-294 days). Got $duration days.',
        PregnancyErrorType.unrealisticDateRange,
      );
    }
  }
}
