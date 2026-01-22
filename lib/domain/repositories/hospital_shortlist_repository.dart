import '../entities/hospital/hospital_shortlist.dart';
import '../entities/hospital/maternity_unit.dart';

/// Combined entity for a shortlist entry with its associated maternity unit.
class ShortlistWithUnit {
  final HospitalShortlist shortlist;
  final MaternityUnit unit;

  const ShortlistWithUnit({
    required this.shortlist,
    required this.unit,
  });
}

/// Repository interface for hospital shortlist operations.
///
/// Manages the user's shortlisted hospitals and their final selection.
abstract class HospitalShortlistRepository {
  // ---------------------------------------------------------------------------
  // Query Operations
  // ---------------------------------------------------------------------------

  /// Get all shortlisted hospitals with their maternity unit details.
  ///
  /// Returns entries sorted by addedAt (most recent first).
  Future<List<ShortlistWithUnit>> getShortlistWithUnits();

  /// Get the currently selected hospital (final choice).
  ///
  /// Returns null if no hospital has been selected.
  Future<ShortlistWithUnit?> getSelectedHospital();

  /// Check if a maternity unit is in the shortlist.
  Future<bool> isShortlisted(String maternityUnitId);

  /// Get shortlist entry by maternity unit ID.
  ///
  /// Returns null if not in shortlist.
  Future<HospitalShortlist?> getByMaternityUnitId(String maternityUnitId);

  // ---------------------------------------------------------------------------
  // Mutation Operations
  // ---------------------------------------------------------------------------

  /// Add a hospital to the shortlist.
  ///
  /// [maternityUnitId] - ID of the maternity unit to add
  /// [notes] - Optional notes about this hospital
  ///
  /// Returns the created shortlist entry.
  /// Throws if the hospital is already in the shortlist.
  Future<HospitalShortlist> addToShortlist(
    String maternityUnitId, {
    String? notes,
  });

  /// Remove a hospital from the shortlist.
  ///
  /// [id] - ID of the shortlist entry to remove
  ///
  /// If this was the selected hospital, selection is cleared.
  Future<void> removeFromShortlist(String id);

  /// Remove a hospital from the shortlist by maternity unit ID.
  ///
  /// [maternityUnitId] - ID of the maternity unit to remove
  Future<void> removeByMaternityUnitId(String maternityUnitId);

  /// Select a hospital as the final choice.
  ///
  /// [shortlistId] - ID of the shortlist entry to select
  ///
  /// Clears any previously selected hospital.
  Future<void> selectFinalChoice(String shortlistId);

  /// Clear the final selection.
  ///
  /// No hospital will be marked as selected after this.
  Future<void> clearSelection();

  /// Update notes for a shortlist entry.
  ///
  /// [id] - ID of the shortlist entry
  /// [notes] - New notes (null to clear)
  Future<HospitalShortlist> updateNotes(String id, String? notes);
}
