import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../core/monitoring/logging_service.dart';
import '../../domain/entities/hospital/hospital_shortlist.dart';
import '../../domain/repositories/hospital_shortlist_repository.dart';
import '../local/app_database.dart';
import '../local/daos/hospital_shortlist_dao.dart';
import '../mappers/hospital_shortlist_mapper.dart';

/// Implementation of HospitalShortlistRepository.
///
/// Manages the user's shortlisted hospitals using local Drift database.
class HospitalShortlistRepositoryImpl implements HospitalShortlistRepository {
  final HospitalShortlistDao _dao;
  final LoggingService _logger;
  final Uuid _uuid;

  HospitalShortlistRepositoryImpl({
    required HospitalShortlistDao dao,
    required LoggingService logger,
    Uuid? uuid,
  })  : _dao = dao,
        _logger = logger,
        _uuid = uuid ?? const Uuid();

  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  @override
  Future<List<ShortlistWithUnit>> getShortlistWithUnits() async {
    _logger.debug('Getting shortlist with units');

    try {
      final dtos = await _dao.getShortlistWithUnits();
      return HospitalShortlistMapper.toShortlistWithUnitList(dtos);
    } catch (e, stackTrace) {
      _logger.error('Error getting shortlist', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<ShortlistWithUnit?> getSelectedHospital() async {
    _logger.debug('Getting selected hospital');

    try {
      final dto = await _dao.getSelectedWithUnit();
      if (dto == null) return null;
      return HospitalShortlistMapper.toShortlistWithUnit(dto);
    } catch (e, stackTrace) {
      _logger.error('Error getting selected hospital', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isShortlisted(String maternityUnitId) async {
    return _dao.isShortlisted(maternityUnitId);
  }

  @override
  Future<HospitalShortlist?> getByMaternityUnitId(String maternityUnitId) async {
    final dto = await _dao.getByMaternityUnitId(maternityUnitId);
    if (dto == null) return null;
    return HospitalShortlistMapper.toDomain(dto);
  }

  // ---------------------------------------------------------------------------
  // Mutation Operations
  // ---------------------------------------------------------------------------

  @override
  Future<HospitalShortlist> addToShortlist(
    String maternityUnitId, {
    String? notes,
  }) async {
    _logger.debug('Adding to shortlist', data: {'maternityUnitId': maternityUnitId});

    try {
      // Check if already shortlisted
      final existing = await _dao.getByMaternityUnitId(maternityUnitId);
      if (existing != null) {
        _logger.warning('Hospital already in shortlist');
        return HospitalShortlistMapper.toDomain(existing);
      }

      // Create new shortlist entry
      final now = DateTime.now();
      final dto = HospitalShortlistDto(
        id: _uuid.v4(),
        maternityUnitId: maternityUnitId,
        addedAtMillis: now.millisecondsSinceEpoch,
        isSelected: false,
        notes: notes,
      );

      final inserted = await _dao.insertShortlist(dto);

      _logger.info('Added hospital to shortlist');
      _logger.logDatabaseOperation('INSERT', table: 'hospital_shortlists', success: true);

      return HospitalShortlistMapper.toDomain(inserted);
    } catch (e, stackTrace) {
      _logger.error('Error adding to shortlist', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('INSERT', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeFromShortlist(String id) async {
    _logger.debug('Removing from shortlist', data: {'id': id});

    try {
      await _dao.deleteShortlist(id);
      _logger.info('Removed hospital from shortlist');
      _logger.logDatabaseOperation('DELETE', table: 'hospital_shortlists', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error removing from shortlist', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('DELETE', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeByMaternityUnitId(String maternityUnitId) async {
    _logger.debug('Removing from shortlist by unit ID', data: {'maternityUnitId': maternityUnitId});

    try {
      await _dao.deleteByMaternityUnitId(maternityUnitId);
      _logger.info('Removed hospital from shortlist');
      _logger.logDatabaseOperation('DELETE', table: 'hospital_shortlists', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error removing from shortlist', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('DELETE', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> selectFinalChoice(String shortlistId) async {
    _logger.debug('Selecting final hospital', data: {'shortlistId': shortlistId});

    try {
      await _dao.selectHospital(shortlistId);
      _logger.info('Selected hospital as final choice');
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error selecting hospital', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<void> clearSelection() async {
    _logger.debug('Clearing hospital selection');

    try {
      await _dao.clearAllSelections();
      _logger.info('Cleared hospital selection');
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: true);
    } catch (e, stackTrace) {
      _logger.error('Error clearing selection', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }

  @override
  Future<HospitalShortlist> updateNotes(String id, String? notes) async {
    _logger.debug('Updating shortlist notes', data: {'id': id});

    try {
      await _dao.updateShortlistFields(
        id,
        HospitalShortlistsCompanion(notes: drift.Value(notes)),
      );

      final updated = await _dao.getById(id);
      if (updated == null) {
        throw Exception('Shortlist entry not found after update');
      }

      _logger.info('Updated shortlist notes');
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: true);

      return HospitalShortlistMapper.toDomain(updated);
    } catch (e, stackTrace) {
      _logger.error('Error updating notes', error: e, stackTrace: stackTrace);
      _logger.logDatabaseOperation('UPDATE', table: 'hospital_shortlists', success: false, error: e);
      rethrow;
    }
  }
}
