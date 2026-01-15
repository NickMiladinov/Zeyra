import 'contraction.dart';

/// Represents a contraction timing session for tracking labor progress.
/// 
/// A session tracks contractions from start to completion. The session provides
/// computed analytics including 5-1-1 rule achievement, frequency patterns,
/// and duration statistics. This data is critical for medical assessment of labor.
class ContractionSession {
  /// Unique identifier for this session
  final String id;
  
  /// When the session started (first contraction or user initiated)
  final DateTime startTime;
  
  /// When the session ended (null if still active)
  final DateTime? endTime;
  
  /// Whether this session is currently active
  final bool isActive;
  
  /// All contractions recorded in this session, sorted by startTime
  final List<Contraction> contractions;
  
  /// Optional note attached to this session
  /// Users can add observations about labor progression
  final String? note;
  
  /// Whether the duration criterion was achieved (≥ 1 minute contractions)
  /// Set to true when contractions consistently meet the 45+ second threshold
  final bool achievedDuration;
  
  /// Timestamp when the duration criterion was first achieved
  final DateTime? durationAchievedAt;
  
  /// Whether the frequency criterion was achieved (≤ 5 minutes apart)
  /// Set to true when contractions are consistently 6 minutes or less apart
  final bool achievedFrequency;
  
  /// Timestamp when the frequency criterion was first achieved
  final DateTime? frequencyAchievedAt;
  
  /// Whether the consistency criterion was achieved (pattern maintained for 1 hour)
  /// Set to true when the valid pattern has been sustained for 60 minutes
  final bool achievedConsistency;
  
  /// Timestamp when the consistency criterion was first achieved
  final DateTime? consistencyAchievedAt;
  
  /// Convenience getter: all three 5-1-1 criteria achieved
  bool get achieved511Alert => achievedDuration && achievedFrequency && achievedConsistency;

  const ContractionSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.isActive,
    this.contractions = const [],
    this.note,
    this.achievedDuration = false,
    this.durationAchievedAt,
    this.achievedFrequency = false,
    this.frequencyAchievedAt,
    this.achievedConsistency = false,
    this.consistencyAchievedAt,
  });

  /// Number of contractions recorded in this session
  int get contractionCount => contractions.length;

  /// Total session duration from start to end (or now if active)
  /// 
  /// This is NOT the sum of contraction durations, but rather the
  /// elapsed time of the monitoring session.
  Duration get totalDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Sum of all completed contraction durations
  /// 
  /// This represents the total time spent in active contractions,
  /// useful for calculating contraction-to-rest ratio.
  Duration get totalContractionTime {
    return contractions.fold<Duration>(
      Duration.zero,
      (sum, contraction) {
        final duration = contraction.duration;
        return duration != null ? sum + duration : sum;
      },
    );
  }

  /// Currently active (timing) contraction, if any
  Contraction? get activeContraction {
    try {
      return contractions.firstWhere((c) => c.isActive);
    } catch (_) {
      return null;
    }
  }

  /// The most recent completed contraction (excluding any active contraction)
  /// 
  /// Returns null if no completed contractions exist.
  /// Contractions are sorted by startTime, so this returns the last completed one.
  Contraction? get lastCompletedContraction {
    final completed = contractions.where((c) => !c.isActive).toList();
    if (completed.isEmpty) return null;
    // Since contractions are sorted by startTime ascending, take the last one
    return completed.last;
  }

  /// Calculate average time between contraction starts
  /// 
  /// Returns null if less than 2 contractions (need at least 2 for frequency).
  /// Frequency is measured start-to-start.
  Duration? get averageFrequency {
    if (contractions.length < 2) return null;
    
    // Sort by start time to ensure correct order
    final sorted = List<Contraction>.from(contractions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    var totalInterval = Duration.zero;
    for (var i = 1; i < sorted.length; i++) {
      totalInterval += sorted[i].startTime.difference(sorted[i - 1].startTime);
    }
    
    final intervals = sorted.length - 1;
    return Duration(
      milliseconds: totalInterval.inMilliseconds ~/ intervals,
    );
  }

  /// Calculate average contraction duration
  /// 
  /// Returns null if no completed contractions exist.
  /// Only counts contractions with endTime set.
  Duration? get averageDuration {
    final completed = contractions.where((c) => c.duration != null).toList();
    if (completed.isEmpty) return null;
    
    var totalDuration = Duration.zero;
    for (final contraction in completed) {
      totalDuration += contraction.duration!;
    }
    
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ completed.length,
    );
  }

  /// Get the longest contraction duration in this session
  /// 
  /// Returns null if no completed contractions exist.
  Duration? get longestContraction {
    final completed = contractions.where((c) => c.duration != null).toList();
    if (completed.isEmpty) return null;
    
    return completed.map((c) => c.duration!).reduce(
      (a, b) => a > b ? a : b,
    );
  }

  /// Get the shortest time between two contraction starts
  /// 
  /// Returns null if less than 2 contractions.
  Duration? get closestFrequency {
    if (contractions.length < 2) return null;
    
    // Sort by start time
    final sorted = List<Contraction>.from(contractions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    Duration? shortest;
    for (var i = 1; i < sorted.length; i++) {
      final interval = sorted[i].startTime.difference(sorted[i - 1].startTime);
      if (shortest == null || interval < shortest) {
        shortest = interval;
      }
    }
    
    return shortest;
  }

  /// Calculate average contraction duration for the last hour
  /// 
  /// Returns null if no completed contractions in the last hour.
  /// Only counts contractions with endTime set that started within the last 60 minutes
  /// from the session end time (or now if session is still active).
  Duration? get averageDurationLastHour {
    final referenceTime = endTime ?? DateTime.now();
    final oneHourAgo = referenceTime.subtract(const Duration(hours: 1));
    
    final recentCompleted = contractions.where((c) => 
      c.duration != null && 
      c.startTime.isAfter(oneHourAgo)
    ).toList();
    
    if (recentCompleted.isEmpty) return null;
    
    var totalDuration = Duration.zero;
    for (final contraction in recentCompleted) {
      totalDuration += contraction.duration!;
    }
    
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ recentCompleted.length,
    );
  }

  /// Calculate average time between contraction starts for the last hour
  /// 
  /// Returns null if less than 2 contractions in the last hour.
  /// Only considers contractions that started within the last 60 minutes
  /// from the session end time (or now if session is still active).
  /// Frequency is measured start-to-start.
  Duration? get averageFrequencyLastHour {
    final referenceTime = endTime ?? DateTime.now();
    final oneHourAgo = referenceTime.subtract(const Duration(hours: 1));
    
    final recentContractions = contractions.where((c) => 
      c.startTime.isAfter(oneHourAgo)
    ).toList();
    
    if (recentContractions.length < 2) return null;
    
    // Sort by start time to ensure correct order
    final sorted = List<Contraction>.from(recentContractions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    var totalInterval = Duration.zero;
    for (var i = 1; i < sorted.length; i++) {
      totalInterval += sorted[i].startTime.difference(sorted[i - 1].startTime);
    }
    
    final intervals = sorted.length - 1;
    return Duration(
      milliseconds: totalInterval.inMilliseconds ~/ intervals,
    );
  }

  /// Create a copy with updated fields
  ContractionSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    List<Contraction>? contractions,
    String? note,
    bool? achievedDuration,
    DateTime? durationAchievedAt,
    bool? achievedFrequency,
    DateTime? frequencyAchievedAt,
    bool? achievedConsistency,
    DateTime? consistencyAchievedAt,
  }) {
    return ContractionSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      contractions: contractions ?? this.contractions,
      note: note ?? this.note,
      achievedDuration: achievedDuration ?? this.achievedDuration,
      durationAchievedAt: durationAchievedAt ?? this.durationAchievedAt,
      achievedFrequency: achievedFrequency ?? this.achievedFrequency,
      frequencyAchievedAt: frequencyAchievedAt ?? this.frequencyAchievedAt,
      achievedConsistency: achievedConsistency ?? this.achievedConsistency,
      consistencyAchievedAt: consistencyAchievedAt ?? this.consistencyAchievedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractionSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isActive == other.isActive &&
          note == other.note &&
          achievedDuration == other.achievedDuration &&
          durationAchievedAt == other.durationAchievedAt &&
          achievedFrequency == other.achievedFrequency &&
          frequencyAchievedAt == other.frequencyAchievedAt &&
          achievedConsistency == other.achievedConsistency &&
          consistencyAchievedAt == other.consistencyAchievedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      isActive.hashCode ^
      note.hashCode ^
      achievedDuration.hashCode ^
      durationAchievedAt.hashCode ^
      achievedFrequency.hashCode ^
      frequencyAchievedAt.hashCode ^
      achievedConsistency.hashCode ^
      consistencyAchievedAt.hashCode;

  @override
  String toString() =>
      'ContractionSession(id: $id, startTime: $startTime, endTime: $endTime, '
      'isActive: $isActive, contractionCount: $contractionCount, '
      'achieved511Alert: $achieved511Alert, '
      'achievedDuration: $achievedDuration, achievedFrequency: $achievedFrequency, '
      'achievedConsistency: $achievedConsistency, note: $note)';
}

