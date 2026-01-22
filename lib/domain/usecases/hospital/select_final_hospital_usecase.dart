import '../../repositories/hospital_shortlist_repository.dart';

/// Use case for selecting the final hospital choice.
///
/// Marks one of the shortlisted hospitals as the user's final selection
/// for their birth.
class SelectFinalHospitalUseCase {
  final HospitalShortlistRepository _repository;

  SelectFinalHospitalUseCase({
    required HospitalShortlistRepository repository,
  }) : _repository = repository;

  /// Select a hospital as the final choice.
  ///
  /// [shortlistId] - ID of the shortlist entry to select
  ///
  /// Clears any previously selected hospital.
  Future<void> select(String shortlistId) async {
    return _repository.selectFinalChoice(shortlistId);
  }

  /// Get the currently selected hospital.
  ///
  /// Returns null if no hospital has been selected.
  Future<ShortlistWithUnit?> getSelected() async {
    return _repository.getSelectedHospital();
  }

  /// Clear the current selection.
  Future<void> clearSelection() async {
    return _repository.clearSelection();
  }
}
