@Tags(['core'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/utils/fuzzy_search.dart';

void main() {
  group('[Core] FuzzySearch', () {
    group('normalize', () {
      test('should convert to lowercase', () {
        expect(FuzzySearch.normalize('HOSPITAL'), 'hospital');
        expect(FuzzySearch.normalize('St Mary'), 'st mary');
      });

      test('should normalize apostrophes', () {
        expect(FuzzySearch.normalize("St Mary's"), 'st marys');
        expect(FuzzySearch.normalize("St Mary`s"), 'st marys');
        expect(FuzzySearch.normalize("St Mary's"), 'st marys');
      });

      test('should remove punctuation', () {
        expect(FuzzySearch.normalize('Hospital, London'), 'hospital london');
        expect(FuzzySearch.normalize('NHS-Trust'), 'nhstrust');
      });

      test('should collapse whitespace', () {
        expect(FuzzySearch.normalize('St   Mary   Hospital'), 'st mary hospital');
        expect(FuzzySearch.normalize('  Hospital  '), 'hospital');
      });

      test('should handle empty string', () {
        expect(FuzzySearch.normalize(''), '');
        expect(FuzzySearch.normalize('   '), '');
      });
    });

    group('calculateScore', () {
      test('should return 1.0 for exact match', () {
        expect(FuzzySearch.calculateScore('hospital', 'hospital'), 1.0);
        expect(FuzzySearch.calculateScore('st marys', 'st marys'), 1.0);
      });

      test('should return 0.95 for prefix match', () {
        expect(FuzzySearch.calculateScore('st mary', 'st marys hospital'), 0.95);
        expect(FuzzySearch.calculateScore('kings', 'kings college hospital'), 0.95);
      });

      test('should return 0.85 for word-boundary match', () {
        expect(FuzzySearch.calculateScore('mary', 'st marys hospital'), 0.85);
        expect(FuzzySearch.calculateScore('college', 'kings college hospital'), 0.85);
      });

      test('should return 0.7 for contains match', () {
        expect(FuzzySearch.calculateScore('ary', 'st marys hospital'), 0.7);
        expect(FuzzySearch.calculateScore('olle', 'kings college hospital'), 0.7);
      });

      test('should return 0.75 for multi-token word-boundary match', () {
        // "kings hospital" matches word boundaries in "kings college hospital"
        expect(
          FuzzySearch.calculateScore('kings hospital', 'kings college hospital'),
          0.75,
        );
      });

      test('should return 0.6 for all tokens present (non-boundary)', () {
        // "coll hosp" contains tokens that are substrings but don't start words
        expect(
          FuzzySearch.calculateScore('olle hosp', 'kings college hospital'),
          0.6,
        );
      });

      test('should return 0.0 for no match', () {
        expect(FuzzySearch.calculateScore('xyz', 'st marys hospital'), 0.0);
        expect(FuzzySearch.calculateScore('clinic', 'kings college hospital'), 0.0);
      });

      test('should return 0.0 for empty strings', () {
        expect(FuzzySearch.calculateScore('', 'hospital'), 0.0);
        expect(FuzzySearch.calculateScore('hospital', ''), 0.0);
      });
    });

    group('search', () {
      final testItems = [
        'St Mary\'s Hospital',
        'Kings College Hospital',
        'Royal London Hospital',
        'Chelsea and Westminster Hospital',
        'University College London Hospital',
      ];

      test('should return all items for empty query', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: '',
          getText: (item) => item,
        );

        expect(results.length, testItems.length);
      });

      test('should find exact matches first', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'Kings College Hospital',
          getText: (item) => item,
        );

        expect(results.isNotEmpty, true);
        expect(results.first, 'Kings College Hospital');
      });

      test('should find prefix matches', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'St Mary',
          getText: (item) => item,
        );

        expect(results.isNotEmpty, true);
        expect(results.first, 'St Mary\'s Hospital');
      });

      test('should find word-boundary matches', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'College',
          getText: (item) => item,
        );

        expect(results.isNotEmpty, true);
        // Should find both Kings College and University College
        expect(
          results.any((r) => r.contains('Kings College')),
          true,
        );
        expect(
          results.any((r) => r.contains('University College')),
          true,
        );
      });

      test('should filter out non-matching items', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'Birmingham',
          getText: (item) => item,
        );

        expect(results, isEmpty);
      });

      test('should handle case insensitivity', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'KINGS',
          getText: (item) => item,
        );

        expect(results.isNotEmpty, true);
        expect(results.first, 'Kings College Hospital');
      });

      test('should sort by relevance score', () {
        final results = FuzzySearch.search(
          items: testItems,
          query: 'London',
          getText: (item) => item,
        );

        // Should find Royal London (word boundary) and University College London
        expect(results.length, greaterThanOrEqualTo(2));
        // Royal London should come first (word boundary vs contains)
        expect(results.first, 'Royal London Hospital');
      });
    });

    group('searchWithScores', () {
      final testItems = ['Apple', 'Banana', 'Apricot'];

      test('should return items with scores', () {
        final results = FuzzySearch.searchWithScores(
          items: testItems,
          query: 'Ap',
          getText: (item) => item,
        );

        expect(results.isNotEmpty, true);
        expect(results.first.score, greaterThan(0));
        expect(results.first.item, isNotNull);
      });

      test('should return score of 1.0 for empty query', () {
        final results = FuzzySearch.searchWithScores(
          items: testItems,
          query: '',
          getText: (item) => item,
        );

        expect(results.length, testItems.length);
        for (final result in results) {
          expect(result.score, 1.0);
        }
      });

      test('should filter items below threshold', () {
        final results = FuzzySearch.searchWithScores(
          items: testItems,
          query: 'xyz',
          getText: (item) => item,
        );

        expect(results, isEmpty);
      });
    });

    group('fuzzy token matching', () {
      test('should match via contains when query is substring', () {
        // "king" should match "kings" via word boundary
        final items = ['Kings College Hospital'];
        final results = FuzzySearch.search(
          items: items,
          query: 'king',
          getText: (item) => item,
        );
        expect(results.isNotEmpty, true);
        expect(results.first, 'Kings College Hospital');
      });

      test('should require prefix for short tokens', () {
        // Short tokens (< 3 chars) should require prefix match
        final scoreMatch = FuzzySearch.calculateScore('st', 'st marys');
        final scoreNoMatch = FuzzySearch.calculateScore('ts', 'st marys');

        expect(scoreMatch, greaterThan(0));
        expect(scoreNoMatch, 0.0);
      });

      test('should match multi-word queries where all tokens are present', () {
        // "kings hospital" should match "kings college hospital"
        // Both tokens match word boundaries, so score is 0.75
        final score = FuzzySearch.calculateScore('kings hospital', 'kings college hospital');
        expect(score, 0.75); // Multi-token word-boundary match
      });
    });
  });
}
