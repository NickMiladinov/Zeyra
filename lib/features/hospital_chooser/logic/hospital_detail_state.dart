import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/main_providers.dart';
import '../../../domain/entities/hospital/maternity_unit.dart';
import '../../../domain/usecases/hospital/get_unit_detail_usecase.dart';
import '../../../domain/usecases/hospital/manage_shortlist_usecase.dart';

// ----------------------------------------------------------------------------
// State Classes
// ----------------------------------------------------------------------------

/// State for the hospital detail screen.
class HospitalDetailState {
  /// The maternity unit being viewed.
  final MaternityUnit? unit;

  /// Whether this unit is in the user's shortlist.
  final bool isShortlisted;

  /// Distance from user's location in miles.
  final double? distanceMiles;

  /// Whether data is loading.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  const HospitalDetailState({
    this.unit,
    this.isShortlisted = false,
    this.distanceMiles,
    this.isLoading = false,
    this.error,
  });

  /// Whether the unit has been loaded.
  bool get hasUnit => unit != null;

  HospitalDetailState copyWith({
    MaternityUnit? unit,
    bool? isShortlisted,
    double? distanceMiles,
    bool? isLoading,
    String? error,
  }) {
    return HospitalDetailState(
      unit: unit ?? this.unit,
      isShortlisted: isShortlisted ?? this.isShortlisted,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ----------------------------------------------------------------------------
// Notifier
// ----------------------------------------------------------------------------

/// Notifier for managing hospital detail state.
class HospitalDetailNotifier extends StateNotifier<HospitalDetailState> {
  final GetUnitDetailUseCase _getDetail;
  final ManageShortlistUseCase _manageShortlist;
  int _shortlistStatusRequestId = 0;

  HospitalDetailNotifier({
    required GetUnitDetailUseCase getDetail,
    required ManageShortlistUseCase manageShortlist,
  })  : _getDetail = getDetail,
        _manageShortlist = manageShortlist,
        super(const HospitalDetailState());

  /// Load unit details.
  Future<void> loadUnit(
    String unitId, {
    double? userLat,
    double? userLng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final unit = await _getDetail.execute(unitId);
      if (unit == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Hospital not found',
        );
        return;
      }

      // Calculate distance if user location provided
      double? distance;
      if (userLat != null && userLng != null) {
        distance = unit.distanceFrom(userLat, userLng);
      }

      // Check shortlist status
      final isShortlisted = await _manageShortlist.isShortlisted(unitId);

      state = state.copyWith(
        unit: unit,
        isShortlisted: isShortlisted,
        distanceMiles: distance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set unit directly (when coming from map/list).
  void setUnit(
    MaternityUnit unit, {
    double? userLat,
    double? userLng,
  }) {
    double? distance;
    if (userLat != null && userLng != null) {
      distance = unit.distanceFrom(userLat, userLng);
    }

    state = state.copyWith(
      unit: unit,
      distanceMiles: distance,
    );

    // Check shortlist status in background
    _checkShortlistStatus(unit.id);
  }

  Future<void> _checkShortlistStatus(String unitId) async {
    final requestId = ++_shortlistStatusRequestId;
    try {
      final isShortlisted = await _manageShortlist.isShortlisted(unitId);
      if (requestId != _shortlistStatusRequestId) return;
      if (state.unit?.id != unitId) return;
      state = state.copyWith(isShortlisted: isShortlisted);
    } catch (_) {
      // Silently ignore
    }
  }

  /// Toggle shortlist status.
  Future<bool> toggleShortlist() async {
    if (state.unit == null) return false;

    // Invalidate pending status checks so stale async responses
    // cannot overwrite an explicit user tap result.
    _shortlistStatusRequestId++;

    try {
      final result = await _manageShortlist.toggleShortlist(state.unit!.id);
      state = state.copyWith(isShortlisted: result);
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return state.isShortlisted;
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear all state (when navigating away).
  void clear() {
    state = const HospitalDetailState();
  }
}

// ----------------------------------------------------------------------------
// Provider
// ----------------------------------------------------------------------------

/// Provider for hospital detail state.
final hospitalDetailProvider =
    StateNotifierProvider<HospitalDetailNotifier, HospitalDetailState>((ref) {
  final getDetailAsync = ref.watch(getUnitDetailUseCaseProvider);
  final manageShortlistAsync = ref.watch(manageShortlistUseCaseProvider);

  if (!getDetailAsync.hasValue || !manageShortlistAsync.hasValue) {
    throw StateError(
      'hospitalDetailProvider accessed before dependencies are ready.',
    );
  }

  return HospitalDetailNotifier(
    getDetail: getDetailAsync.requireValue,
    manageShortlist: manageShortlistAsync.requireValue,
  );
});
