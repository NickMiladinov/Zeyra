@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/data/local/app_database.dart';
import 'package:zeyra/data/mappers/sync_metadata_mapper.dart';
import 'package:zeyra/domain/entities/hospital/sync_metadata.dart';

import '../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] SyncMetadataMapper - toDomain', () {
    test('should map SyncMetadataDto to domain', () {
      // Arrange
      final now = DateTime.now();
      final dto = SyncMetadataDto(
        id: 'maternity_units',
        lastSyncAtMillis: now.millisecondsSinceEpoch,
        lastSyncStatus: 'success',
        lastSyncCount: 500,
        lastError: null,
        dataVersionCode: 2,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // Act
      final domain = SyncMetadataMapper.toDomain(dto);

      // Assert
      expect(domain.id, 'maternity_units');
      expect(domain.lastSyncStatus, SyncStatus.success);
      expect(domain.lastSyncCount, 500);
      expect(domain.dataVersionCode, 2);
    });

    test('should parse sync status from string', () {
      // Arrange
      final now = DateTime.now();
      final dto = SyncMetadataDto(
        id: 'test',
        lastSyncAtMillis: now.millisecondsSinceEpoch,
        lastSyncStatus: 'preload_complete',
        lastSyncCount: 100,
        dataVersionCode: 1,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // Act
      final domain = SyncMetadataMapper.toDomain(dto);

      // Assert
      expect(domain.lastSyncStatus, SyncStatus.preloadComplete);
    });

    test('should handle null lastSyncAtMillis', () {
      // Arrange
      final now = DateTime.now();
      final dto = SyncMetadataDto(
        id: 'test',
        lastSyncAtMillis: null,
        lastSyncStatus: 'never',
        lastSyncCount: 0,
        dataVersionCode: 0,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // Act
      final domain = SyncMetadataMapper.toDomain(dto);

      // Assert
      expect(domain.lastSyncAt, isNull);
      expect(domain.hasEverSynced, false);
    });

    test('should handle lastError', () {
      // Arrange
      final now = DateTime.now();
      final dto = SyncMetadataDto(
        id: 'test',
        lastSyncAtMillis: now.millisecondsSinceEpoch,
        lastSyncStatus: 'failed',
        lastSyncCount: 0,
        lastError: 'Connection timeout',
        dataVersionCode: 1,
        createdAtMillis: now.millisecondsSinceEpoch,
        updatedAtMillis: now.millisecondsSinceEpoch,
      );

      // Act
      final domain = SyncMetadataMapper.toDomain(dto);

      // Assert
      expect(domain.lastError, 'Connection timeout');
      expect(domain.lastSyncStatus, SyncStatus.failed);
    });
  });

  group('[HospitalChooser] SyncMetadataMapper - toDto', () {
    test('should map domain to SyncMetadataDto', () {
      // Arrange
      final entity = FakeSyncMetadata.simple(
        id: 'maternity_units',
        status: SyncStatus.success,
        lastSyncCount: 500,
      );

      // Act
      final dto = SyncMetadataMapper.toDto(entity);

      // Assert
      expect(dto.id, 'maternity_units');
      expect(dto.lastSyncStatus, 'success');
      expect(dto.lastSyncCount, 500);
    });

    test('should convert status to db string', () {
      // Arrange
      final entity = FakeSyncMetadata.preloadComplete();

      // Act
      final dto = SyncMetadataMapper.toDto(entity);

      // Assert
      expect(dto.lastSyncStatus, 'preload_complete');
    });

    test('should handle null lastSyncAt', () {
      // Arrange
      final entity = FakeSyncMetadata.neverSynced();

      // Act
      final dto = SyncMetadataMapper.toDto(entity);

      // Assert
      expect(dto.lastSyncAtMillis, isNull);
    });

    test('should round-trip correctly', () {
      // Arrange
      final original = FakeSyncMetadata.simple(
        id: 'test',
        status: SyncStatus.success,
        lastSyncCount: 250,
        dataVersionCode: 3,
      );

      // Act
      final dto = SyncMetadataMapper.toDto(original);
      final roundTripped = SyncMetadataMapper.toDomain(dto);

      // Assert
      expect(roundTripped.id, original.id);
      expect(roundTripped.lastSyncStatus, original.lastSyncStatus);
      expect(roundTripped.lastSyncCount, original.lastSyncCount);
      expect(roundTripped.dataVersionCode, original.dataVersionCode);
    });
  });
}
