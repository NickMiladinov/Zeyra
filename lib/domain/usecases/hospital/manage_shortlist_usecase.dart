import '../../entities/hospital/hospital_shortlist.dart';
import '../../repositories/hospital_shortlist_repository.dart';

/// Use case for managing the hospital shortlist.
///
/// Handles adding, removing, and querying shortlisted hospitals.
class ManageShortlistUseCase {
  final HospitalShortlistRepository _repository;

  ManageShortlistUseCase({
    required HospitalShortlistRepository repository,
  }) : _repository = repository;

  /// Get all shortlisted hospitals with their details.
  Future<List<ShortlistWithUnit>> getShortlist() async {
    return _repository.getShortlistWithUnits();
  }

  /// Check if a hospital is in the shortlist.
  Future<bool> isShortlisted(String maternityUnitId) async {
    return _repository.isShortlisted(maternityUnitId);
  }

  /// Add a hospital to the shortlist.
  ///
  /// [maternityUnitId] - ID of the maternity unit to add
  /// [notes] - Optional notes about this hospital
  ///
  /// Returns the created shortlist entry.
  Future<HospitalShortlist> addToShortlist(
    String maternityUnitId, {
    String? notes,
  }) async {
    return _repository.addToShortlist(maternityUnitId, notes: notes);
  }

  /// Remove a hospital from the shortlist.
  ///
  /// [maternityUnitId] - ID of the maternity unit to remove
  Future<void> removeFromShortlist(String maternityUnitId) async {
    return _repository.removeByMaternityUnitId(maternityUnitId);
  }

  /// Toggle a hospital's shortlist status.
  ///
  /// Adds if not in shortlist, removes if already in shortlist.
  /// Returns true if hospital is now in shortlist, false if removed.
  Future<bool> toggleShortlist(String maternityUnitId) async {
    final isCurrentlyShortlisted = await _repository.isShortlisted(maternityUnitId);

    if (isCurrentlyShortlisted) {
      await _repository.removeByMaternityUnitId(maternityUnitId);
      return false;
    } else {
      await _repository.addToShortlist(maternityUnitId);
      return true;
    }
  }

  /// Update notes for a shortlisted hospital.
  ///
  /// [maternityUnitId] - ID of the maternity unit
  /// [notes] - New notes (null to clear)
  Future<HospitalShortlist?> updateNotes(
    String maternityUnitId,
    String? notes,
  ) async {
    final shortlist = await _repository.getByMaternityUnitId(maternityUnitId);
    if (shortlist == null) return null;

    return _repository.updateNotes(shortlist.id, notes);
  }
}
