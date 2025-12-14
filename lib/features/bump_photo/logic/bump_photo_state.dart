import '../../../domain/entities/bump_photo/bump_photo.dart';

/// State class for bump photo feature.
///
/// Contains the list of bump photos and loading/error states.
class BumpPhotoState {
  /// List of bump photos for the current pregnancy
  final List<BumpPhoto> photos;

  /// Whether data is being loaded
  final bool isLoading;

  /// Error message if an operation failed
  final String? error;

  /// Week slots to display (includes both photos and empty slots)
  final List<WeekSlot> weekSlots;

  const BumpPhotoState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
    this.weekSlots = const [],
  });

  BumpPhotoState copyWith({
    List<BumpPhoto>? photos,
    bool? isLoading,
    String? error,
    List<WeekSlot>? weekSlots,
  }) {
    return BumpPhotoState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable update to clear error
      weekSlots: weekSlots ?? this.weekSlots,
    );
  }

  /// Clear error
  BumpPhotoState clearError() {
    return copyWith(error: null);
  }
}

/// Represents a week slot that may or may not have a photo.
class WeekSlot {
  final int weekNumber;
  final BumpPhoto? photo;
  final bool isCurrentWeek;
  final bool isFutureWeek;

  const WeekSlot({
    required this.weekNumber,
    this.photo,
    required this.isCurrentWeek,
    required this.isFutureWeek,
  });

  bool get hasPhoto => photo != null;
  bool get isEmpty => photo == null;
}
