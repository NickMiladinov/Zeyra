/// Lightweight fuzzy search utility for hospital names.
///
/// Provides fast, zero-dependency fuzzy matching with a scoring cascade
/// optimized for autocomplete UX. Scores range from 0.0 to 1.0.
///
/// Scoring priority (highest to lowest):
/// 1. Exact match (1.0)
/// 2. Prefix match (0.95) - "St Mar" → "St Mary's Hospital"
/// 3. Multi-token sequential prefix (0.90) - "st mary" → "St Mary's Hospital"
/// 4. Word-boundary match (0.85) - "mary" → "St Mary's Hospital"
/// 5. Multi-token word-boundary match (0.75) - all tokens match word starts
/// 6. Contains match (0.7) - substring anywhere
/// 7. All tokens present (0.6) - all query words found
/// 8. Fuzzy token match (0.3-0.5) - 1-char typo tolerance
class FuzzySearch {
  /// Minimum score to be considered a match.
  static const double minScoreThreshold = 0.3;

  /// Search a list of items using fuzzy matching.
  ///
  /// [items] - The list to search
  /// [query] - The search query
  /// [getText] - Function to extract searchable text from each item
  ///
  /// Returns items sorted by relevance score (highest first).
  /// Items below [minScoreThreshold] are excluded.
  static List<T> search<T>({
    required List<T> items,
    required String query,
    required String Function(T) getText,
  }) {
    if (query.isEmpty) return items;

    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return items;

    // Score each item
    final scored = <({T item, double score})>[];

    for (final item in items) {
      final text = normalize(getText(item));
      final score = calculateScore(normalizedQuery, text);

      if (score >= minScoreThreshold) {
        scored.add((item: item, score: score));
      }
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.map((e) => e.item).toList();
  }

  /// Search and return items with their scores.
  ///
  /// Useful when you need to access the relevance score for each result.
  static List<({T item, double score})> searchWithScores<T>({
    required List<T> items,
    required String query,
    required String Function(T) getText,
  }) {
    if (query.isEmpty) {
      return items.map((item) => (item: item, score: 1.0)).toList();
    }

    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) {
      return items.map((item) => (item: item, score: 1.0)).toList();
    }

    // Score each item
    final scored = <({T item, double score})>[];

    for (final item in items) {
      final text = normalize(getText(item));
      final score = calculateScore(normalizedQuery, text);

      if (score >= minScoreThreshold) {
        scored.add((item: item, score: score));
      }
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored;
  }

  /// Normalize text for comparison.
  ///
  /// - Converts to lowercase
  /// - Normalizes apostrophes
  /// - Removes punctuation
  /// - Collapses whitespace
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[''`]"), "'") // Normalize apostrophes
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Calculate match score between query and text.
  ///
  /// Returns 0.0 to 1.0 (higher = better match).
  static double calculateScore(String query, String text) {
    // Empty checks
    if (query.isEmpty || text.isEmpty) return 0.0;

    // Exact match
    if (text == query) return 1.0;

    // Prefix match (very high value for autocomplete UX)
    if (text.startsWith(query)) return 0.95;

    final words = text.split(' ');
    final queryTokens = query.split(' ').where((t) => t.isNotEmpty).toList();

    // Multi-token sequential prefix match
    // "st mary" → "st marys hospital" (query tokens appear in order at start)
    if (queryTokens.length > 1) {
      final score = _calculateSequentialPrefixScore(queryTokens, words);
      if (score > 0) return score;
    }

    // Word-boundary prefix match (single token)
    // "mary" matches start of word in "St Mary's Hospital"
    for (final word in words) {
      if (word.startsWith(query)) return 0.85;
    }

    // Multi-token word-boundary match
    // All tokens match word starts (any order)
    if (queryTokens.length > 1) {
      final matchCount = _countWordBoundaryMatches(queryTokens, words);
      if (matchCount == queryTokens.length) {
        return 0.75;
      }
    }

    // Contains match
    if (text.contains(query)) return 0.7;

    // Token matching: all query words must be present
    if (queryTokens.length > 1) {
      final allTokensPresent = queryTokens.every(
        (token) => text.contains(token),
      );
      if (allTokensPresent) return 0.6;
    }

    // Fuzzy token matching with tolerance
    // Check if each query token has a close match in text
    if (queryTokens.isNotEmpty) {
      int matchedTokens = 0;
      for (final queryToken in queryTokens) {
        for (final textWord in words) {
          if (_fuzzyTokenMatch(queryToken, textWord)) {
            matchedTokens++;
            break;
          }
        }
      }
      if (matchedTokens == queryTokens.length) {
        return 0.5;
      }
      if (matchedTokens > 0) {
        return 0.3 * (matchedTokens / queryTokens.length);
      }
    }

    // Single token fuzzy match
    if (queryTokens.length == 1) {
      for (final textWord in words) {
        if (_fuzzyTokenMatch(query, textWord)) {
          return 0.4;
        }
      }
    }

    return 0.0;
  }

  /// Calculate score for sequential prefix matching.
  ///
  /// Checks if query tokens match the beginning of text words in sequence.
  /// "st mary" matching "st marys hospital" gets 0.90
  /// "st mary" matching "st marys birth centre" gets 0.90
  /// Returns 0.0 if not a sequential prefix match.
  static double _calculateSequentialPrefixScore(
    List<String> queryTokens,
    List<String> textWords,
  ) {
    if (textWords.length < queryTokens.length) return 0.0;

    // Check if query tokens match text words from the beginning
    int matchedCount = 0;
    bool isSequential = true;

    for (int i = 0; i < queryTokens.length && i < textWords.length; i++) {
      final queryToken = queryTokens[i];
      final textWord = textWords[i];

      // Each query token should be a prefix of the corresponding text word
      if (textWord.startsWith(queryToken)) {
        matchedCount++;
      } else {
        isSequential = false;
        break;
      }
    }

    if (isSequential && matchedCount == queryTokens.length) {
      // Full sequential prefix match
      return 0.90;
    }

    return 0.0;
  }

  /// Count how many query tokens match word boundaries in text.
  static int _countWordBoundaryMatches(
    List<String> queryTokens,
    List<String> textWords,
  ) {
    int matchCount = 0;
    final usedWords = <int>{};

    for (final queryToken in queryTokens) {
      for (int i = 0; i < textWords.length; i++) {
        if (usedWords.contains(i)) continue;
        if (textWords[i].startsWith(queryToken)) {
          matchCount++;
          usedWords.add(i);
          break;
        }
      }
    }

    return matchCount;
  }

  /// Check if two tokens are a fuzzy match (1 character tolerance).
  ///
  /// For short tokens (< 3 chars), requires prefix match.
  /// For longer tokens, allows 1 character difference.
  static bool _fuzzyTokenMatch(String query, String text) {
    // For very short queries, require prefix match
    if (query.length < 3) {
      return text.startsWith(query);
    }

    // Allow 1 character difference for tokens >= 3 chars
    if ((query.length - text.length).abs() > 1) return false;

    int differences = 0;
    final maxLen = query.length > text.length ? query.length : text.length;

    for (int i = 0; i < maxLen && differences <= 1; i++) {
      final qChar = i < query.length ? query[i] : '';
      final tChar = i < text.length ? text[i] : '';
      if (qChar != tChar) differences++;
    }

    return differences <= 1;
  }
}
