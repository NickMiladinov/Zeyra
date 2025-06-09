import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/features/file_upload/data/models/medical_file_model.dart';

void main() {
  // --- Helper Variables ---
  final now = DateTime.now();
  final nowIso = now.toUtc().toIso8601String();
  final later = now.add(const Duration(days: 1));
  final laterIso = later.toUtc().toIso8601String();

  final fullMap = {
    'id': 'full-id-123',
    'user_id': 'user-abc',
    'original_filename': 'full_report.pdf',
    'file_type': 'pdf',
    'created_at': nowIso,
    'encrypted_path': '/secure/full_report.pdf.enc',
    'file_size_bytes': 2048,
    'version': 2,
    'last_modified_at': nowIso,
    'deleted_at': laterIso,
  };

  final minimalMap = {
    'id': 'minimal-id-456',
    'user_id': 'user-xyz',
    'original_filename': 'minimal_note.txt',
    'file_type': null,
    'created_at': nowIso,
    'encrypted_path': '/secure/minimal_note.txt.enc',
    'file_size_bytes': null,
    'version': 1,
    'last_modified_at': nowIso,
    'deleted_at': null,
  };

  group('Object Instantiation & Serialization', () {
    test('Test 1 (fromMap - Full Data)', () {
      final medicalFile = MedicalFile.fromMap(fullMap);

      expect(medicalFile.id, fullMap['id']);
      expect(medicalFile.userId, fullMap['user_id']);
      expect(medicalFile.originalFilename, fullMap['original_filename']);
      expect(medicalFile.fileType, fullMap['file_type']);
      expect(medicalFile.createdAt, DateTime.parse(fullMap['created_at'] as String));
      expect(medicalFile.encryptedPath, fullMap['encrypted_path']);
      expect(medicalFile.fileSize, fullMap['file_size_bytes']);
      expect(medicalFile.version, fullMap['version']);
      expect(medicalFile.lastModifiedAt, DateTime.parse(fullMap['last_modified_at'] as String));
      expect(medicalFile.deletedAt, DateTime.parse(fullMap['deleted_at'] as String));
    });

    test('Test 2 (fromMap - Nullable Fields)', () {
      final medicalFile = MedicalFile.fromMap(minimalMap);

      expect(medicalFile.fileType, isNull);
      expect(medicalFile.fileSize, isNull);
      expect(medicalFile.deletedAt, isNull);
    });

    test('Test 3 (fromMap - Type Mismatch)', () {
      final badMap = Map<String, dynamic>.from(fullMap);
      badMap['id'] = 123; // Incorrect type

      expect(
        () => MedicalFile.fromMap(badMap),
        throwsA(isA<TypeError>()),
      );
    });

    test('Test 4 (toMap - Full Data)', () {
      final medicalFile = MedicalFile(
        id: 'full-id-123',
        userId: 'user-abc',
        originalFilename: 'full_report.pdf',
        fileType: 'pdf',
        createdAt: now,
        encryptedPath: '/secure/full_report.pdf.enc',
        fileSize: 2048,
        version: 2,
        lastModifiedAt: now,
        deletedAt: later,
      );

      final map = medicalFile.toMap();
      expect(map, equals(fullMap));
    });

    test('Test 5 (toMap - Nullable Fields)', () {
      final medicalFile = MedicalFile(
        id: 'minimal-id-456',
        userId: 'user-xyz',
        originalFilename: 'minimal_note.txt',
        createdAt: now,
        encryptedPath: '/secure/minimal_note.txt.enc',
        version: 1,
        lastModifiedAt: now,
        // Nullable fields are omitted
      );

      final map = medicalFile.toMap();
      expect(map, equals(minimalMap));
    });
  });

  group('copyWith Method', () {
    final originalFile = MedicalFile.fromMap(fullMap);

    test('Test 1 (copyWith - Single Field)', () {
      final updatedFile = originalFile.copyWith(version: 3);

      expect(updatedFile.version, 3);
      expect(updatedFile.id, originalFile.id); // Ensure others are unchanged
      expect(identical(originalFile, updatedFile), isFalse);
      expect(originalFile.version, 2, reason: "Original object should not be mutated");
    });

    test('Test 2 (copyWith - Multiple Fields)', () {
      final updatedFile = originalFile.copyWith(
        version: 3,
        lastModifiedAt: later,
        deletedAt: later,
      );

      expect(updatedFile.version, 3);
      expect(updatedFile.lastModifiedAt, later);
      expect(updatedFile.deletedAt, later);
    });

    test('Test 3 (copyWith - No Arguments)', () {
      final copy = originalFile.copyWith();

      expect(copy, equals(originalFile));
      expect(identical(copy, originalFile), isFalse);
    });
  });

  group('Equality and hashCode', () {
    test('Test 1 (Equality - Identical Objects)', () {
      final fileA = MedicalFile.fromMap(fullMap);
      final fileB = MedicalFile.fromMap(fullMap);

      expect(fileA, equals(fileB));
    });

    test('Test 2 (Equality - Different Objects)', () {
      final fileA = MedicalFile.fromMap(fullMap);
      final fileB = fileA.copyWith(version: 99);

      expect(fileA, isNot(equals(fileB)));
    });

    test('Test 3 (hashCode - Consistency)', () {
      final fileA = MedicalFile.fromMap(fullMap);
      final fileB = MedicalFile.fromMap(fullMap);

      expect(fileA.hashCode, equals(fileB.hashCode));
    });
  });

  group('Computed Properties (Getters)', () {
    final baseFile = MedicalFile.fromMap(minimalMap);

    test('Test 1 (fileSizeFormatted - Bytes)', () {
      final file = baseFile.copyWith(fileSize: 800);
      expect(file.fileSizeFormatted, "800 B");
    });

    test('Test 2 (fileSizeFormatted - Kilobytes)', () {
      final file = baseFile.copyWith(fileSize: 1536);
      expect(file.fileSizeFormatted, "1.5 KB");
    });

    test('Test 3 (fileSizeFormatted - Megabytes)', () {
      final file = baseFile.copyWith(fileSize: 2097152);
      expect(file.fileSizeFormatted, "2.0 MB");
    });

    test('Test 4 (fileSizeFormatted - Edge Cases)', () {
      expect(baseFile.copyWith(fileSize: null).fileSizeFormatted, "N/A");
      expect(baseFile.copyWith(fileSize: 0).fileSizeFormatted, "0 B");
      expect(baseFile.copyWith(fileSize: 1023).fileSizeFormatted, "1023 B");
    });

    test('Test 5 (isImage - Image Types)', () {
      expect(baseFile.copyWith(fileType: 'jpg').isImage, isTrue);
      expect(baseFile.copyWith(fileType: 'png').isImage, isTrue);
      expect(baseFile.copyWith(fileType: 'gif').isImage, isTrue);
      expect(baseFile.copyWith(fileType: 'heic').isImage, isTrue);
    });

    test('Test 6 (isImage - Case Insensitivity)', () {
      expect(baseFile.copyWith(fileType: 'JPG').isImage, isTrue);
      expect(baseFile.copyWith(fileType: 'PnG').isImage, isTrue);
    });

    test('Test 7 (isImage - Non-Image Types)', () {
      expect(baseFile.copyWith(fileType: 'pdf').isImage, isFalse);
      expect(baseFile.copyWith(fileType: 'docx').isImage, isFalse);
      expect(baseFile.copyWith(fileType: null).isImage, isFalse);
    });
  });
} 