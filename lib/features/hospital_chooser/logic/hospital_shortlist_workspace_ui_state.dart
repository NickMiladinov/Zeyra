import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;

/// UI-only state for the hospital shortlist workspace screen.
///
/// This keeps view interaction flags out of the screen widget class.
class HospitalShortlistWorkspaceUiState {
  final bool hasVisitedOrContactedTopChoices;
  final bool hasMarkedFinalChoiceStep;
  final bool hasRegisteredWithChosenHospital;
  final String? selectingShortlistId;

  const HospitalShortlistWorkspaceUiState({
    this.hasVisitedOrContactedTopChoices = false,
    this.hasMarkedFinalChoiceStep = false,
    this.hasRegisteredWithChosenHospital = false,
    this.selectingShortlistId,
  });

  HospitalShortlistWorkspaceUiState copyWith({
    bool? hasVisitedOrContactedTopChoices,
    bool? hasMarkedFinalChoiceStep,
    bool? hasRegisteredWithChosenHospital,
    String? selectingShortlistId,
    bool clearSelectingShortlistId = false,
  }) {
    return HospitalShortlistWorkspaceUiState(
      hasVisitedOrContactedTopChoices:
          hasVisitedOrContactedTopChoices ??
          this.hasVisitedOrContactedTopChoices,
      hasMarkedFinalChoiceStep:
          hasMarkedFinalChoiceStep ?? this.hasMarkedFinalChoiceStep,
      hasRegisteredWithChosenHospital:
          hasRegisteredWithChosenHospital ??
          this.hasRegisteredWithChosenHospital,
      selectingShortlistId: clearSelectingShortlistId
          ? null
          : (selectingShortlistId ?? this.selectingShortlistId),
    );
  }
}

/// Notifier for workspace-level UI interactions and loading flags.
class HospitalShortlistWorkspaceUiNotifier
    extends StateNotifier<HospitalShortlistWorkspaceUiState> {
  HospitalShortlistWorkspaceUiNotifier()
    : super(const HospitalShortlistWorkspaceUiState());

  void toggleVisitedOrContactedTopChoices() {
    state = state.copyWith(
      hasVisitedOrContactedTopChoices: !state.hasVisitedOrContactedTopChoices,
    );
  }

  void toggleFinalChoiceStep() {
    state = state.copyWith(
      hasMarkedFinalChoiceStep: !state.hasMarkedFinalChoiceStep,
    );
  }

  void toggleRegisteredWithChosenHospital() {
    state = state.copyWith(
      hasRegisteredWithChosenHospital: !state.hasRegisteredWithChosenHospital,
    );
  }

  void startSelectingShortlist(String shortlistId) {
    state = state.copyWith(selectingShortlistId: shortlistId);
  }

  void finishSelectingShortlist() {
    state = state.copyWith(clearSelectingShortlistId: true);
  }
}

/// Provider for shortlist workspace UI-only state.
final hospitalShortlistWorkspaceUiProvider =
    StateNotifierProvider<
      HospitalShortlistWorkspaceUiNotifier,
      HospitalShortlistWorkspaceUiState
    >((ref) => HospitalShortlistWorkspaceUiNotifier());
