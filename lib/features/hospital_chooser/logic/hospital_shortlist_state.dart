import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../domain/repositories/hospital_shortlist_repository.dart';
import '../../../domain/usecases/hospital/manage_shortlist_usecase.dart';
import '../../../domain/usecases/hospital/select_final_hospital_usecase.dart';

// ----------------------------------------------------------------------------
// State Classes
// ----------------------------------------------------------------------------

/// State for the hospital shortlist (workspace) screen.
class HospitalShortlistState {
  /// List of shortlisted hospitals with their unit details.
  final List<ShortlistWithUnit> shortlistedUnits;

  /// Currently selected hospital (final choice).
  final ShortlistWithUnit? selectedHospital;

  /// Whether data is loading.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  const HospitalShortlistState({
    this.shortlistedUnits = const [],
    this.selectedHospital,
    this.isLoading = false,
    this.error,
  });

  /// Number of shortlisted hospitals.
  int get count => shortlistedUnits.length;

  /// Whether the shortlist is empty.
  bool get isEmpty => shortlistedUnits.isEmpty;

  /// Whether a final choice has been made.
  bool get hasSelection => selectedHospital != null;

  HospitalShortlistState copyWith({
    List<ShortlistWithUnit>? shortlistedUnits,
    ShortlistWithUnit? selectedHospital,
    bool? isLoading,
    String? error,
  }) {
    return HospitalShortlistState(
      shortlistedUnits: shortlistedUnits ?? this.shortlistedUnits,
      selectedHospital: selectedHospital ?? this.selectedHospital,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Copy with cleared selection.
  HospitalShortlistState clearSelection() {
    return HospitalShortlistState(
      shortlistedUnits: shortlistedUnits,
      selectedHospital: null,
      isLoading: isLoading,
      error: error,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

/// Notifier for managing hospital shortlist state.
class HospitalShortlistNotifier extends StateNotifier<HospitalShortlistState> {
  final ManageShortlistUseCase _manageShortlist;
  final SelectFinalHospitalUseCase _selectFinal;

  HospitalShortlistNotifier({
    required ManageShortlistUseCase manageShortlist,
    required SelectFinalHospitalUseCase selectFinal,
  })  : _manageShortlist = manageShortlist,
        _selectFinal = selectFinal,
        super(const HospitalShortlistState()) {
    _loadShortlist();
  }

  /// Load the shortlist from repository.
  Future<void> _loadShortlist() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shortlist = await _manageShortlist.getShortlist();
      final selected = await _selectFinal.getSelected();

      state = state.copyWith(
        shortlistedUnits: shortlist,
        selectedHospital: selected,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh the shortlist.
  Future<void> refresh() async {
    await _loadShortlist();
  }

  /// Check if a hospital is shortlisted.
  Future<bool> isShortlisted(String maternityUnitId) async {
    return _manageShortlist.isShortlisted(maternityUnitId);
  }

  /// Add a hospital to the shortlist.
  Future<bool> addToShortlist(String maternityUnitId, {String? notes}) async {
    try {
      await _manageShortlist.addToShortlist(maternityUnitId, notes: notes);
      await _loadShortlist();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Remove a hospital from the shortlist.
  Future<bool> removeFromShortlist(String maternityUnitId) async {
    try {
      await _manageShortlist.removeFromShortlist(maternityUnitId);
      await _loadShortlist();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle a hospital's shortlist status.
  Future<bool> toggleShortlist(String maternityUnitId) async {
    try {
      final result = await _manageShortlist.toggleShortlist(maternityUnitId);
      await _loadShortlist();
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Select a hospital as the final choice.
  Future<bool> selectFinalChoice(String shortlistId) async {
    try {
      await _selectFinal.select(shortlistId);
      await _loadShortlist();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear the final selection.
  Future<bool> clearSelection() async {
    try {
      await _selectFinal.clearSelection();
      state = state.clearSelection();
      await _loadShortlist();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update notes for a shortlisted hospital.
  Future<bool> updateNotes(String maternityUnitId, String? notes) async {
    try {
      await _manageShortlist.updateNotes(maternityUnitId, notes);
      await _loadShortlist();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ----------------------------------------------------------------------------
// Provider
// ----------------------------------------------------------------------------

/// Provider for hospital shortlist state.
final hospitalShortlistProvider =
    StateNotifierProvider<HospitalShortlistNotifier, HospitalShortlistState>((ref) {
  final manageShortlistAsync = ref.watch(manageShortlistUseCaseProvider);
  final selectFinalAsync = ref.watch(selectFinalHospitalUseCaseProvider);

  if (!manageShortlistAsync.hasValue || !selectFinalAsync.hasValue) {
    throw StateError(
      'hospitalShortlistProvider accessed before dependencies are ready.',
    );
  }

  return HospitalShortlistNotifier(
    manageShortlist: manageShortlistAsync.requireValue,
    selectFinal: selectFinalAsync.requireValue,
  );
});
