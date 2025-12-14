import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/photo_file_service.dart';
import 'package:zeyra/domain/entities/bump_photo/bump_photo.dart';
import 'package:zeyra/domain/repositories/bump_photo_repository.dart';

/// Mock classes
class MockBumpPhotoRepository extends Mock implements BumpPhotoRepository {}
class MockPhotoFileService extends Mock implements PhotoFileService {}

/// Fake data builders for bump photo testing.
class BumpPhotoFakes {
  /// Create a fake bump photo with default values.
  static BumpPhoto bumpPhoto({
    String? id,
    String? pregnancyId,
    int? weekNumber,
    String? filePath,
    String? note,
    DateTime? photoDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return BumpPhoto(
      id: id ?? 'test-photo-id',
      pregnancyId: pregnancyId ?? 'test-pregnancy-id',
      weekNumber: weekNumber ?? 20,
      filePath: filePath ?? '/test/path/20.jpg',
      note: note,
      photoDate: photoDate ?? now,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Create a list of fake bump photos.
  static List<BumpPhoto> bumpPhotoList(int count, {String? pregnancyId}) {
    return List.generate(
      count,
      (index) => bumpPhoto(
        id: 'photo-$index',
        pregnancyId: pregnancyId ?? 'test-pregnancy-id',
        weekNumber: index + 1,
        filePath: '/test/path/${index + 1}.jpg',
        note: index % 2 == 0 ? 'Note for week ${index + 1}' : null,
      ),
    );
  }

  /// Create a bump photo for a specific week.
  static BumpPhoto forWeek(int weekNumber, {String? pregnancyId, String? note}) {
    return bumpPhoto(
      id: 'photo-week-$weekNumber',
      pregnancyId: pregnancyId ?? 'test-pregnancy-id',
      weekNumber: weekNumber,
      filePath: '/test/path/$weekNumber.jpg',
      note: note,
    );
  }

  /// Create a note-only entry (no photo file) for a specific week.
  ///
  /// Used to test note-only scenarios where filePath is null.
  static BumpPhoto noteOnly(int weekNumber, {String? pregnancyId, String? note}) {
    final now = DateTime.now();
    return BumpPhoto(
      id: 'note-only-week-$weekNumber',
      pregnancyId: pregnancyId ?? 'test-pregnancy-id',
      weekNumber: weekNumber,
      filePath: null, // Note-only entry has no file
      note: note,
      photoDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a bump photo with both photo and note.
  static BumpPhoto withPhotoAndNote(
    int weekNumber, {
    String? pregnancyId,
    required String note,
    String? filePath,
  }) {
    return bumpPhoto(
      id: 'photo-note-week-$weekNumber',
      pregnancyId: pregnancyId ?? 'test-pregnancy-id',
      weekNumber: weekNumber,
      filePath: filePath ?? '/test/path/$weekNumber.jpg',
      note: note,
    );
  }
}
