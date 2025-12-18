import 'package:mocktail/mocktail.dart';
import 'package:zeyra/data/local/daos/contraction_timer_dao.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_intensity.dart';
import 'package:zeyra/domain/entities/contraction_timer/contraction_session.dart';
import 'package:zeyra/domain/entities/contraction_timer/rule_511_status.dart';
import 'package:zeyra/domain/repositories/contraction_timer_repository.dart';

// ----------------------------------------------------------------------------
// Fake Data Builders
// ----------------------------------------------------------------------------

/// Fake data builders for Contraction entities.
class FakeContraction {
  /// Create a simple contraction with default or custom values.
  static Contraction simple({
    String? id,
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    ContractionIntensity? intensity,
  }) {
    final start = startTime ?? DateTime.now().subtract(const Duration(minutes: 30));
    final end = endTime;
    
    return Contraction(
      id: id ?? 'contraction-1',
      sessionId: sessionId ?? 'session-1',
      startTime: start,
      endTime: end,
      intensity: intensity ?? ContractionIntensity.moderate,
    );
  }

  /// Create an active contraction (no end time).
  static Contraction active({
    String? id,
    String? sessionId,
    DateTime? startTime,
    ContractionIntensity? intensity,
  }) {
    return Contraction(
      id: id ?? 'contraction-active',
      sessionId: sessionId ?? 'session-1',
      startTime: startTime ?? DateTime.now().subtract(const Duration(minutes: 5)),
      endTime: null,
      intensity: intensity ?? ContractionIntensity.moderate,
    );
  }

  /// Create a completed contraction with specific duration.
  static Contraction completed({
    String? id,
    String? sessionId,
    DateTime? startTime,
    required Duration duration,
    ContractionIntensity? intensity,
  }) {
    final start = startTime ?? DateTime.now().subtract(const Duration(minutes: 30));
    return Contraction(
      id: id ?? 'contraction-completed',
      sessionId: sessionId ?? 'session-1',
      startTime: start,
      endTime: start.add(duration),
      intensity: intensity ?? ContractionIntensity.moderate,
    );
  }

  /// Generate a batch of contractions with sequential times.
  /// 
  /// [count] - Number of contractions to generate
  /// [startTime] - Start time of first contraction
  /// [frequency] - Time between contraction starts (default 5 minutes)
  /// [duration] - Duration of each contraction (default 60 seconds)
  /// [sessionId] - Session ID for all contractions
  static List<Contraction> batch(
    int count, {
    DateTime? startTime,
    Duration? frequency,
    Duration? duration,
    String? sessionId,
  }) {
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: count * 5 + 10));
    final freq = frequency ?? const Duration(minutes: 5);
    final dur = duration ?? const Duration(seconds: 60);

    return List.generate(
      count,
      (index) {
        final contractionStart = start.add(Duration(minutes: index * freq.inMinutes));
        return Contraction(
          id: 'contraction-${index + 1}',
          sessionId: sessionId ?? 'session-1',
          startTime: contractionStart,
          endTime: contractionStart.add(dur),
          intensity: ContractionIntensity.values[index % 3],
        );
      },
    );
  }

  /// Create batch of contractions that meet 5-1-1 rule criteria.
  /// 
  /// Creates 6+ contractions, each >= 45s duration, <= 6 minutes apart.
  static List<Contraction> meeting511Rule({
    int count = 6,
    DateTime? startTime,
    String? sessionId,
  }) {
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: count * 5 + 10));

    return List.generate(
      count,
      (index) {
        final contractionStart = start.add(Duration(minutes: index * 5));
        return Contraction(
          id: 'contraction-511-${index + 1}',
          sessionId: sessionId ?? 'session-1',
          startTime: contractionStart,
          endTime: contractionStart.add(const Duration(seconds: 50)),
          intensity: ContractionIntensity.moderate,
        );
      },
    );
  }

  /// Create batch of weak contractions (< 30 seconds).
  static List<Contraction> weak({
    int count = 3,
    DateTime? startTime,
    String? sessionId,
  }) {
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: count * 5 + 10));

    return List.generate(
      count,
      (index) {
        final contractionStart = start.add(Duration(minutes: index * 5));
        return Contraction(
          id: 'contraction-weak-${index + 1}',
          sessionId: sessionId ?? 'session-1',
          startTime: contractionStart,
          endTime: contractionStart.add(const Duration(seconds: 25)),
          intensity: ContractionIntensity.mild,
        );
      },
    );
  }

  /// Create batch of contractions with specified gaps for frequency testing.
  /// 
  /// [gaps] - List of durations between contractions
  static List<Contraction> withGaps({
    required List<Duration> gaps,
    DateTime? startTime,
    Duration? duration,
    String? sessionId,
  }) {
    // Calculate total time needed and start from that far in the past
    final totalMinutes = gaps.fold<int>(0, (sum, gap) => sum + gap.inMinutes) + 10;
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: totalMinutes));
    final dur = duration ?? const Duration(seconds: 50);
    
    final contractions = <Contraction>[];
    DateTime currentTime = start;
    
    for (int i = 0; i <= gaps.length; i++) {
      contractions.add(Contraction(
        id: 'contraction-gap-${i + 1}',
        sessionId: sessionId ?? 'session-1',
        startTime: currentTime,
        endTime: currentTime.add(dur),
        intensity: ContractionIntensity.moderate,
      ));
      
      if (i < gaps.length) {
        currentTime = currentTime.add(gaps[i]);
      }
    }
    
    return contractions;
  }

  /// Create batch with mixed durations for testing validity thresholds.
  static List<Contraction> mixedDurations({
    required List<Duration> durations,
    DateTime? startTime,
    Duration frequency = const Duration(minutes: 5),
    String? sessionId,
  }) {
    final totalMinutes = durations.length * frequency.inMinutes + 10;
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: totalMinutes));
    
    return List.generate(
      durations.length,
      (index) {
        final contractionStart = start.add(Duration(minutes: index * frequency.inMinutes));
        return Contraction(
          id: 'contraction-mixed-${index + 1}',
          sessionId: sessionId ?? 'session-1',
          startTime: contractionStart,
          endTime: contractionStart.add(durations[index]),
          intensity: ContractionIntensity.moderate,
        );
      },
    );
  }
}

/// Fake data builders for ContractionSession entities.
class FakeContractionSession {
  /// Create a simple session with default or custom values.
  static ContractionSession simple({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    List<Contraction>? contractions,
    String? note,
    bool achievedDuration = false,
    DateTime? durationAchievedAt,
    bool achievedFrequency = false,
    DateTime? frequencyAchievedAt,
    bool achievedConsistency = false,
    DateTime? consistencyAchievedAt,
  }) {
    return ContractionSession(
      id: id ?? 'session-1',
      startTime: startTime ?? DateTime.now().subtract(const Duration(hours: 1)),
      endTime: endTime,
      isActive: isActive ?? true,
      contractions: contractions ?? const [],
      note: note,
      achievedDuration: achievedDuration,
      durationAchievedAt: durationAchievedAt,
      achievedFrequency: achievedFrequency,
      frequencyAchievedAt: frequencyAchievedAt,
      achievedConsistency: achievedConsistency,
      consistencyAchievedAt: consistencyAchievedAt,
    );
  }

  /// Create an active session (no end time).
  static ContractionSession active({
    String? id,
    List<Contraction>? contractions,
    String? note,
  }) {
    return ContractionSession(
      id: id ?? 'session-active',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: null,
      isActive: true,
      contractions: contractions ?? FakeContraction.batch(5),
      note: note,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create an ended session (with end time).
  static ContractionSession ended({
    List<Contraction>? contractions,
    String? note,
  }) {
    return ContractionSession(
      id: 'session-ended',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: DateTime(2024, 1, 1, 11, 0),
      isActive: false,
      contractions: contractions ?? FakeContraction.batch(10),
      note: note,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session with an active contraction.
  static ContractionSession withActiveContraction({
    String? id,
    List<Contraction>? completedContractions,
  }) {
    final completed = completedContractions ?? FakeContraction.batch(3);
    final active = FakeContraction.active(
      id: 'contraction-active',
      sessionId: id ?? 'session-1',
    );

    return ContractionSession(
      id: id ?? 'session-1',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: null,
      isActive: true,
      contractions: [...completed, active],
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session meeting 5-1-1 rule criteria.
  static ContractionSession meeting511Rule({
    String? id,
    DateTime? startTime,
    int count = 8,
  }) {
    final start = startTime ?? DateTime.now().subtract(Duration(minutes: count * 5 + 10));
    final alertTime = start.add(const Duration(minutes: 60));
    
    return ContractionSession(
      id: id ?? 'session-511',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: FakeContraction.meeting511Rule(
        count: count,
        startTime: start,
        sessionId: id ?? 'session-511',
      ),
      note: null,
      achievedDuration: true,
      durationAchievedAt: alertTime,
      achievedFrequency: true,
      frequencyAchievedAt: alertTime,
      achievedConsistency: true,
      consistencyAchievedAt: alertTime,
    );
  }

  /// Create a session with a note attached.
  static ContractionSession withNote({
    String? id,
    required String note,
    List<Contraction>? contractions,
    bool isActive = false,
  }) {
    return ContractionSession(
      id: id ?? 'session-with-note',
      startTime: DateTime(2024, 1, 1, 10, 0),
      endTime: isActive ? null : DateTime(2024, 1, 1, 11, 0),
      isActive: isActive,
      contractions: contractions ?? FakeContraction.batch(8),
      note: note,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session with contractions below minimum (for testing thresholds).
  static ContractionSession belowMinimum({
    String? id,
    int count = 5,
  }) {
    // Use recent timestamps so contractions fall within the 60-minute rolling window
    final start = DateTime.now().subtract(Duration(minutes: count * 5 + 10));
    return ContractionSession(
      id: id ?? 'session-below-minimum',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: FakeContraction.batch(
        count,
        startTime: start,
        frequency: const Duration(minutes: 5),
        duration: const Duration(seconds: 50),
        sessionId: id ?? 'session-below-minimum',
      ),
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session at maximum contractions limit.
  static ContractionSession atMaxContractions({
    String? id,
  }) {
    final start = DateTime(2024, 1, 1, 10, 0);
    return ContractionSession(
      id: id ?? 'session-max',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: FakeContraction.batch(
        200, // maxContractionsPerSession
        startTime: start,
        frequency: const Duration(minutes: 2),
        duration: const Duration(seconds: 50),
        sessionId: id ?? 'session-max',
      ),
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session with duration reset condition (3 consecutive short contractions).
  static ContractionSession withDurationReset({
    String? id,
  }) {
    // Use recent timestamps so contractions fall within the 60-minute rolling window
    final start = DateTime.now().subtract(const Duration(minutes: 35));
    // Add some good contractions first, then 3 consecutive short ones
    final goodContractions = FakeContraction.batch(
      3,
      startTime: start,
      frequency: const Duration(minutes: 5),
      duration: const Duration(seconds: 50),
      sessionId: id ?? 'session-duration-reset',
    );
    final weakContractions = FakeContraction.weak(
      count: 3,
      startTime: start.add(const Duration(minutes: 20)),
      sessionId: id ?? 'session-duration-reset',
    );

    return ContractionSession(
      id: id ?? 'session-duration-reset',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: [...goodContractions, ...weakContractions],
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session with frequency reset condition (> 20 minute gap).
  ///
  /// The frequency reset is triggered when the time since the LAST contraction
  /// exceeds 20 minutes. So we need contractions that ended more than 20 minutes ago.
  static ContractionSession withFrequencyReset({
    String? id,
  }) {
    // Start 45 minutes ago, with contractions ending 25+ minutes ago
    // This ensures the gap from last contraction to now is > 20 minutes
    final start = DateTime.now().subtract(const Duration(minutes: 45));
    final contractions = FakeContraction.withGaps(
      gaps: [
        const Duration(minutes: 5),
        const Duration(minutes: 5),
      ],
      startTime: start,
      sessionId: id ?? 'session-frequency-reset',
    );
    // Last contraction starts at start + 10 min = 35 minutes ago
    // That's > 20 minutes, so frequency reset should trigger

    return ContractionSession(
      id: id ?? 'session-frequency-reset',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: contractions,
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }

  /// Create a session with consistency reset condition (3/5 invalid intervals).
  static ContractionSession withConsistencyReset({
    String? id,
  }) {
    // Use recent timestamps so contractions fall within the 60-minute rolling window
    final start = DateTime.now().subtract(const Duration(minutes: 50));
    final contractions = FakeContraction.withGaps(
      gaps: [
        const Duration(minutes: 8), // Invalid
        const Duration(minutes: 4), // Valid
        const Duration(minutes: 10), // Invalid
        const Duration(minutes: 9), // Invalid
      ],
      startTime: start,
      sessionId: id ?? 'session-consistency-reset',
    );

    return ContractionSession(
      id: id ?? 'session-consistency-reset',
      startTime: start,
      endTime: null,
      isActive: true,
      contractions: contractions,
      note: null,
      achievedDuration: false,
      durationAchievedAt: null,
      achievedFrequency: false,
      frequencyAchievedAt: null,
      achievedConsistency: false,
      consistencyAchievedAt: null,
    );
  }
}

/// Fake data builders for Rule511Status entities.
class FakeRule511Status {
  /// Create a simple status with default or custom values.
  static Rule511Status simple({
    bool alertActive = false,
    int contractionsInWindow = 0,
    int validDurationCount = 0,
    int validFrequencyCount = 0,
    double validityPercentage = 0.0,
    double durationProgress = 0.0,
    double frequencyProgress = 0.0,
    double consistencyProgress = 0.0,
    bool isDurationReset = false,
    bool isFrequencyReset = false,
    bool isConsistencyReset = false,
    String? durationResetReason,
    String? frequencyResetReason,
    String? consistencyResetReason,
    DateTime? windowStartTime,
  }) {
    return Rule511Status(
      alertActive: alertActive,
      contractionsInWindow: contractionsInWindow,
      validDurationCount: validDurationCount,
      validFrequencyCount: validFrequencyCount,
      validityPercentage: validityPercentage,
      durationProgress: durationProgress,
      frequencyProgress: frequencyProgress,
      consistencyProgress: consistencyProgress,
      isDurationReset: isDurationReset,
      isFrequencyReset: isFrequencyReset,
      isConsistencyReset: isConsistencyReset,
      durationResetReason: durationResetReason,
      frequencyResetReason: frequencyResetReason,
      consistencyResetReason: consistencyResetReason,
      windowStartTime: windowStartTime,
    );
  }

  /// Create a status indicating full 5-1-1 alert.
  static Rule511Status alertActive({
    int? validContractions,
    int? totalContractions,
  }) {
    final total = totalContractions ?? 8;
    final valid = validContractions ?? 8;
    return Rule511Status(
      alertActive: true,
      contractionsInWindow: total,
      validDurationCount: valid,
      validFrequencyCount: valid - 1, // frequency is between contractions
      validityPercentage: 1.0,
      durationProgress: 1.0,
      frequencyProgress: 1.0,
      consistencyProgress: 1.0,
      isDurationReset: false,
      isFrequencyReset: false,
      isConsistencyReset: false,
      durationResetReason: null,
      frequencyResetReason: null,
      consistencyResetReason: null,
      windowStartTime: DateTime(2024, 1, 1, 10, 0),
    );
  }

  /// Create a status with partial progress (not all criteria met).
  static Rule511Status partialProgress({
    int contractions = 4,
  }) {
    return Rule511Status(
      alertActive: false,
      contractionsInWindow: contractions,
      validDurationCount: contractions,
      validFrequencyCount: contractions - 1,
      validityPercentage: 0.7,
      durationProgress: 0.8,
      frequencyProgress: 0.8,
      consistencyProgress: 0.5,
      isDurationReset: false,
      isFrequencyReset: false,
      isConsistencyReset: false,
      durationResetReason: null,
      frequencyResetReason: null,
      consistencyResetReason: null,
      windowStartTime: DateTime(2024, 1, 1, 10, 0),
    );
  }

  /// Create a status with reset flags.
  static Rule511Status withReset({
    bool isDurationReset = false,
    bool isFrequencyReset = false,
    bool isConsistencyReset = false,
    String? durationResetReason,
    String? frequencyResetReason,
    String? consistencyResetReason,
  }) {
    return Rule511Status(
      alertActive: false,
      contractionsInWindow: 3,
      validDurationCount: 1,
      validFrequencyCount: 0,
      validityPercentage: 0.3,
      durationProgress: 0.3,
      frequencyProgress: 0.0,
      consistencyProgress: 0.0,
      isDurationReset: isDurationReset,
      isFrequencyReset: isFrequencyReset,
      isConsistencyReset: isConsistencyReset,
      durationResetReason: durationResetReason ?? (isDurationReset ? 'Weak contractions' : null),
      frequencyResetReason: frequencyResetReason ?? (isFrequencyReset ? 'Time gap too long' : null),
      consistencyResetReason: consistencyResetReason ?? (isConsistencyReset ? 'Pattern broken' : null),
      windowStartTime: DateTime(2024, 1, 1, 10, 0),
    );
  }
}

// ----------------------------------------------------------------------------
// Mocks (Mocktail)
// ----------------------------------------------------------------------------

/// Mock implementation of ContractionTimerRepository for testing.
class MockContractionTimerRepository extends Mock
    implements ContractionTimerRepository {}

/// Mock implementation of ContractionTimerDao for testing.
class MockContractionTimerDao extends Mock implements ContractionTimerDao {}

