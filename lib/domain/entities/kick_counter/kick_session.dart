import 'kick.dart';
import 'pause_event.dart';

/// Represents a kick counting session for tracking fetal movements.
/// 
/// A session tracks kicks from start to completion, including pause tracking
/// to calculate accurate active monitoring duration. This data is critical
/// for medical assessment of fetal wellbeing.
class KickSession {
  /// Unique identifier for this session
  final String id;
  
  /// When the session started
  final DateTime startTime;
  
  /// When the session ended (null if still active)
  final DateTime? endTime;
  
  /// Whether this session is currently active
  final bool isActive;
  
  /// All kicks recorded in this session
  final List<Kick> kicks;
  
  /// Timestamp when session was paused (null if not currently paused)
  final DateTime? pausedAt;
  
  /// Total accumulated pause duration across all pause/resume cycles
  final Duration totalPausedDuration;
  
  /// Number of times the user has paused this session (tracking metric)
  final int pauseCount;

  /// Optional note attached to this session
  /// Users can add personal observations about the session
  final String? note;

  /// All pause events recorded in this session
  /// Sorted chronologically by pausedAt timestamp
  final List<PauseEvent> pauseEvents;

  const KickSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.kicks,
    this.pausedAt,
    required this.totalPausedDuration,
    required this.pauseCount,
    this.note,
    this.pauseEvents = const [],
  });

  /// Whether the session is currently paused
  bool get isPaused => pausedAt != null;

  /// Number of kicks recorded in this session
  int get kickCount => kicks.length;

  /// Calculate the active duration (excluding pauses)
  /// 
  /// This is the actual time spent monitoring, which is more medically
  /// relevant than total elapsed time.
  Duration get activeDuration {
    final end = endTime ?? DateTime.now();
    var active = end.difference(startTime) - totalPausedDuration;
    
    // If currently paused, subtract the current pause duration
    // Use 'end' instead of DateTime.now() for ended sessions
    if (pausedAt != null) {
      active -= end.difference(pausedAt!);
    }
    
    return active;
  }

  /// Calculate average time between kicks
  /// 
  /// Returns null if less than 2 kicks (need at least 2 points for average)
  Duration? get averageTimeBetweenKicks {
    if (kicks.length < 2) return null;
    
    final totalDuration = kicks.last.timestamp.difference(kicks.first.timestamp);
    final intervals = kicks.length - 1;
    
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ intervals,
    );
  }

  /// Calculate the duration from session start to the 10th kick.
  /// 
  /// This is the medically relevant metric for kick counting analytics.
  /// Returns null if the session has fewer than 10 kicks.
  /// 
  /// The calculation:
  /// 1. Takes the timestamp of the 10th kick (index 9)
  /// 2. Subtracts the session start time
  /// 3. Subtracts all pause durations that occurred BEFORE the 10th kick
  ///    (i.e., pause events where kickCountAtPause < 10)
  Duration? get durationToTenthKick {
    if (kicks.length < 10) return null;

    // Get the 10th kick (index 9)
    final tenthKick = kicks[9];
    
    // Calculate elapsed time from start to 10th kick
    var duration = tenthKick.timestamp.difference(startTime);
    
    // Subtract pause durations that occurred before the 10th kick
    for (final pauseEvent in pauseEvents) {
      if (pauseEvent.isBeforeTenthKick && pauseEvent.resumedAt != null) {
        duration -= pauseEvent.duration;
      }
    }
    
    return duration;
  }

  /// Create a copy with updated fields
  KickSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    List<Kick>? kicks,
    DateTime? pausedAt,
    Duration? totalPausedDuration,
    int? pauseCount,
    String? note,
    List<PauseEvent>? pauseEvents,
  }) {
    return KickSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      kicks: kicks ?? this.kicks,
      pausedAt: pausedAt ?? this.pausedAt,
      totalPausedDuration: totalPausedDuration ?? this.totalPausedDuration,
      pauseCount: pauseCount ?? this.pauseCount,
      note: note ?? this.note,
      pauseEvents: pauseEvents ?? this.pauseEvents,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KickSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isActive == other.isActive &&
          pausedAt == other.pausedAt &&
          totalPausedDuration == other.totalPausedDuration &&
          pauseCount == other.pauseCount &&
          note == other.note;

  @override
  int get hashCode =>
      id.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      isActive.hashCode ^
      pausedAt.hashCode ^
      totalPausedDuration.hashCode ^
      pauseCount.hashCode ^
      note.hashCode;

  @override
  String toString() =>
      'KickSession(id: $id, startTime: $startTime, endTime: $endTime, '
      'isActive: $isActive, kickCount: $kickCount, pauseCount: $pauseCount, '
      'isPaused: $isPaused, note: $note)';
}

