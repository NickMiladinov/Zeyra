@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/domain/entities/hospital/sync_metadata.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] SyncStatus Enum', () {
    test('should parse status from string', () {
      expect(SyncStatus.fromString('never'), SyncStatus.never);
      expect(SyncStatus.fromString('preload_complete'), SyncStatus.preloadComplete);
      expect(SyncStatus.fromString('success'), SyncStatus.success);
      expect(SyncStatus.fromString('failed'), SyncStatus.failed);
      expect(SyncStatus.fromString('partial'), SyncStatus.partial);
      expect(SyncStatus.fromString('in_progress'), SyncStatus.inProgress);
    });

    test('should return never for null or unknown', () {
      expect(SyncStatus.fromString(null), SyncStatus.never);
      expect(SyncStatus.fromString('unknown'), SyncStatus.never);
      expect(SyncStatus.fromString(''), SyncStatus.never);
    });

    test('should convert to db string correctly', () {
      expect(SyncStatus.never.toDbString(), 'never');
      expect(SyncStatus.preloadComplete.toDbString(), 'preload_complete');
      expect(SyncStatus.success.toDbString(), 'success');
      expect(SyncStatus.failed.toDbString(), 'failed');
      expect(SyncStatus.partial.toDbString(), 'partial');
      expect(SyncStatus.inProgress.toDbString(), 'in_progress');
    });

    test('should round-trip correctly', () {
      for (final status in SyncStatus.values) {
        final dbString = status.toDbString();
        final parsed = SyncStatus.fromString(dbString);
        expect(parsed, status);
      }
    });
  });

  group('[HospitalChooser] SyncMetadata Computed Properties', () {
    test('should return hasEverSynced true when lastSyncAt set', () {
      final synced = FakeSyncMetadata.simple();
      final neverSynced = FakeSyncMetadata.neverSynced();

      expect(synced.hasEverSynced, true);
      expect(neverSynced.hasEverSynced, false);
    });

    test('should return wasLastSyncSuccessful correctly', () {
      final success = FakeSyncMetadata.simple(status: SyncStatus.success);
      final failed = FakeSyncMetadata.failed();
      final preload = FakeSyncMetadata.preloadComplete();

      expect(success.wasLastSyncSuccessful, true);
      expect(preload.wasLastSyncSuccessful, true);
      expect(failed.wasLastSyncSuccessful, false);
    });

    test('should copyWith update fields correctly', () {
      final original = FakeSyncMetadata.simple(
        id: 'test-id',
        status: SyncStatus.success,
      );

      final updated = original.copyWith(
        lastSyncStatus: SyncStatus.failed,
        lastError: 'Network error',
      );

      expect(updated.lastSyncStatus, SyncStatus.failed);
      expect(updated.lastError, 'Network error');
      expect(updated.id, original.id);
    });

    test('should have equality based on id', () {
      final metadata1 = FakeSyncMetadata.simple(id: 'same-id');
      final metadata2 = FakeSyncMetadata.simple(id: 'same-id');
      final metadata3 = FakeSyncMetadata.simple(id: 'different-id');

      expect(metadata1, equals(metadata2));
      expect(metadata1, isNot(equals(metadata3)));
    });
  });

  group('[HospitalChooser] SyncMetadata Factory Methods', () {
    test('should create never synced metadata', () {
      final metadata = FakeSyncMetadata.neverSynced();

      expect(metadata.lastSyncAt, isNull);
      expect(metadata.lastSyncStatus, SyncStatus.never);
      expect(metadata.lastSyncCount, 0);
      expect(metadata.dataVersionCode, 0);
    });

    test('should create preload complete metadata', () {
      final metadata = FakeSyncMetadata.preloadComplete(count: 500, version: 2);

      expect(metadata.lastSyncStatus, SyncStatus.preloadComplete);
      expect(metadata.lastSyncCount, 500);
      expect(metadata.dataVersionCode, 2);
    });

    test('should create failed metadata with error', () {
      final metadata = FakeSyncMetadata.failed(error: 'Connection timeout');

      expect(metadata.lastSyncStatus, SyncStatus.failed);
      expect(metadata.lastError, 'Connection timeout');
    });
  });
}
