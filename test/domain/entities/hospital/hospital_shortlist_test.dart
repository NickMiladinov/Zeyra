@Tags(['hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  group('[HospitalChooser] HospitalShortlist Entity', () {
    test('should create shortlist with all required fields', () {
      final shortlist = FakeHospitalShortlist.simple(
        id: 'test-id',
        maternityUnitId: 'unit-123',
      );

      expect(shortlist.id, 'test-id');
      expect(shortlist.maternityUnitId, 'unit-123');
      expect(shortlist.isSelected, false);
      expect(shortlist.addedAt, isNotNull);
    });

    test('should handle optional notes field', () {
      final withNotes = FakeHospitalShortlist.withNotes(
        notes: 'Great hospital!',
        id: 'test-id',
      );
      final withoutNotes = FakeHospitalShortlist.simple(id: 'test-id-2');

      expect(withNotes.notes, 'Great hospital!');
      expect(withoutNotes.notes, isNull);
    });

    test('should copyWith update isSelected field', () {
      final original = FakeHospitalShortlist.simple(id: 'test-id');
      final updated = original.copyWith(isSelected: true);

      expect(original.isSelected, false);
      expect(updated.isSelected, true);
      expect(updated.id, original.id);
    });

    test('should copyWith update notes field', () {
      final original = FakeHospitalShortlist.simple(id: 'test-id');
      final updated = original.copyWith(notes: 'Updated notes');

      expect(original.notes, isNull);
      expect(updated.notes, 'Updated notes');
    });

    test('should have equality based on id', () {
      final shortlist1 = FakeHospitalShortlist.simple(id: 'same-id');
      final shortlist2 = FakeHospitalShortlist.simple(id: 'same-id');
      final shortlist3 = FakeHospitalShortlist.simple(id: 'different-id');

      expect(shortlist1, equals(shortlist2));
      expect(shortlist1, isNot(equals(shortlist3)));
    });

    test('should generate correct hashCode', () {
      final shortlist1 = FakeHospitalShortlist.simple(id: 'same-id');
      final shortlist2 = FakeHospitalShortlist.simple(id: 'same-id');

      expect(shortlist1.hashCode, equals(shortlist2.hashCode));
    });
  });

  group('[HospitalChooser] Selected Shortlist', () {
    test('should create selected shortlist entry', () {
      final selected = FakeHospitalShortlist.selected(
        id: 'test-id',
        maternityUnitId: 'unit-123',
      );

      expect(selected.isSelected, true);
    });

    test('should copyWith clear selection', () {
      final selected = FakeHospitalShortlist.selected(id: 'test-id');
      final cleared = selected.copyWith(isSelected: false);

      expect(cleared.isSelected, false);
    });
  });
}
