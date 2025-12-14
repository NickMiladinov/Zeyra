/// Domain entity representing a bump photo.
///
/// Pure domain entity with no dependencies on Flutter or database layers.
/// Each bump photo represents a weekly pregnancy photo with optional note.
class BumpPhoto {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to Pregnancy
  final String pregnancyId;

  /// Week number (1-42)
  final int weekNumber;

  /// Local file path to the photo (nullable to support notes without photos)
  final String? filePath;

  /// Optional user note about this week
  final String? note;

  /// When the photo was taken/added
  final DateTime photoDate;

  /// When record was created
  final DateTime createdAt;

  /// When record was last updated
  final DateTime updatedAt;

  const BumpPhoto({
    required this.id,
    required this.pregnancyId,
    required this.weekNumber,
    this.filePath,
    this.note,
    required this.photoDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  BumpPhoto copyWith({
    String? id,
    String? pregnancyId,
    int? weekNumber,
    String? filePath,
    String? note,
    DateTime? photoDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BumpPhoto(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      weekNumber: weekNumber ?? this.weekNumber,
      filePath: filePath ?? this.filePath,
      note: note ?? this.note,
      photoDate: photoDate ?? this.photoDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BumpPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BumpPhoto(id: $id, pregnancyId: $pregnancyId, weekNumber: $weekNumber, filePath: $filePath)';
}
