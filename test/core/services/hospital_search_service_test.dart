@Tags(['core', 'hospital_chooser'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeyra/core/services/hospital_search_service.dart';
import 'package:zeyra/domain/entities/hospital/hospital_search_result.dart';

import '../../mocks/fake_data/hospital_chooser_fakes.dart';

void main() {
  late MockMaternityUnitRepository mockRepository;
  late HospitalSearchService searchService;

  setUp(() {
    mockRepository = MockMaternityUnitRepository();
    searchService = HospitalSearchService(repository: mockRepository);
  });

  group('[HospitalChooser] HospitalSearchService', () {
    group('search', () {
      test('should return empty results for empty query', () async {
        final results = await searchService.search(
          query: '',
          nearbyUnits: FakeMaternityUnit.batch(5),
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.nearby, isEmpty);
        expect(results.global, isEmpty);
        verifyNever(() => mockRepository.searchByName(any(), limit: any(named: 'limit')));
      });

      test('should return empty results for whitespace-only query', () async {
        final results = await searchService.search(
          query: '   ',
          nearbyUnits: FakeMaternityUnit.batch(5),
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.nearby, isEmpty);
        expect(results.global, isEmpty);
      });

      test('should search nearby units using fuzzy matching', () async {
        final nearbyUnits = [
          FakeMaternityUnit.withName('St Mary\'s Hospital'),
          FakeMaternityUnit.withName('Kings College Hospital'),
          FakeMaternityUnit.withName('Royal London Hospital'),
        ];

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        final results = await searchService.search(
          query: 'Mary',
          nearbyUnits: nearbyUnits,
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.nearby.length, 1);
        expect(results.nearby.first.unit.name, 'St Mary\'s Hospital');
        expect(results.nearby.first.tier, SearchTier.nearby);
      });

      test('should search global database', () async {
        final globalUnits = [
          FakeMaternityUnit.withName('St Mary\'s Hospital Manchester'),
          FakeMaternityUnit.withName('St Mary\'s Hospital Newport'),
        ];

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => globalUnits);

        final results = await searchService.search(
          query: 'Mary',
          nearbyUnits: [],
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.global.length, 2);
        expect(results.global.first.tier, SearchTier.allUk);
        verify(() => mockRepository.searchByName('Mary', limit: any(named: 'limit'))).called(1);
      });

      test('should deduplicate results between tiers', () async {
        final nearbyUnit = FakeMaternityUnit.withName('St Mary\'s Hospital');
        final globalUnits = [
          nearbyUnit, // Same unit
          FakeMaternityUnit.withName('St Mary\'s Hospital Manchester'),
        ];

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => globalUnits);

        final results = await searchService.search(
          query: 'Mary',
          nearbyUnits: [nearbyUnit],
          userLat: 51.5074,
          userLng: -0.1278,
        );

        // Nearby should have the unit
        expect(results.nearby.length, 1);
        // Global should only have the Manchester one (deduplicated)
        expect(results.global.length, 1);
        expect(results.global.first.unit.name, 'St Mary\'s Hospital Manchester');
      });

      test('should limit nearby results', () async {
        final nearbyUnits = List.generate(
          10,
          (i) => FakeMaternityUnit.withName('Hospital $i'),
        );

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        final results = await searchService.search(
          query: 'Hospital',
          nearbyUnits: nearbyUnits,
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(
          results.nearby.length,
          lessThanOrEqualTo(HospitalSearchService.maxNearbyResults),
        );
      });

      test('should limit global results', () async {
        final globalUnits = List.generate(
          20,
          (i) => FakeMaternityUnit.withName('Hospital $i'),
        );

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => globalUnits);

        final results = await searchService.search(
          query: 'Hospital',
          nearbyUnits: [],
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(
          results.global.length,
          lessThanOrEqualTo(HospitalSearchService.maxGlobalResults),
        );
      });

      test('should calculate distance for results', () async {
        final nearbyUnit = FakeMaternityUnit.withLocation(
          name: 'London Hospital',
          latitude: 51.5074,
          longitude: -0.1278,
        );

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        final results = await searchService.search(
          query: 'London',
          nearbyUnits: [nearbyUnit],
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.nearby.first.distanceMiles, isNotNull);
        // Should be very close to 0 since same coordinates
        expect(results.nearby.first.distanceMiles!, lessThan(0.1));
      });

      test('should include score for results', () async {
        final nearbyUnit = FakeMaternityUnit.withName('St Mary\'s Hospital');

        when(() => mockRepository.searchByName(any(), limit: any(named: 'limit')))
            .thenAnswer((_) async => []);

        final results = await searchService.search(
          query: 'St Mary',
          nearbyUnits: [nearbyUnit],
          userLat: 51.5074,
          userLng: -0.1278,
        );

        expect(results.nearby.first.score, greaterThan(0));
        expect(results.nearby.first.score, lessThanOrEqualTo(1.0));
      });
    });
  });
}
