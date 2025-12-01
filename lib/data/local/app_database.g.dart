// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KickSessionsTable extends KickSessions
    with TableInfo<$KickSessionsTable, KickSessionDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KickSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMillisMeta = const VerificationMeta(
    'startTimeMillis',
  );
  @override
  late final GeneratedColumn<int> startTimeMillis = GeneratedColumn<int>(
    'start_time_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMillisMeta = const VerificationMeta(
    'endTimeMillis',
  );
  @override
  late final GeneratedColumn<int> endTimeMillis = GeneratedColumn<int>(
    'end_time_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pausedAtMillisMeta = const VerificationMeta(
    'pausedAtMillis',
  );
  @override
  late final GeneratedColumn<int> pausedAtMillis = GeneratedColumn<int>(
    'paused_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPausedMillisMeta = const VerificationMeta(
    'totalPausedMillis',
  );
  @override
  late final GeneratedColumn<int> totalPausedMillis = GeneratedColumn<int>(
    'total_paused_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pauseCountMeta = const VerificationMeta(
    'pauseCount',
  );
  @override
  late final GeneratedColumn<int> pauseCount = GeneratedColumn<int>(
    'pause_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTimeMillis,
    endTimeMillis,
    isActive,
    pausedAtMillis,
    totalPausedMillis,
    pauseCount,
    note,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kick_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<KickSessionDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time_millis')) {
      context.handle(
        _startTimeMillisMeta,
        startTimeMillis.isAcceptableOrUnknown(
          data['start_time_millis']!,
          _startTimeMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMillisMeta);
    }
    if (data.containsKey('end_time_millis')) {
      context.handle(
        _endTimeMillisMeta,
        endTimeMillis.isAcceptableOrUnknown(
          data['end_time_millis']!,
          _endTimeMillisMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('paused_at_millis')) {
      context.handle(
        _pausedAtMillisMeta,
        pausedAtMillis.isAcceptableOrUnknown(
          data['paused_at_millis']!,
          _pausedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('total_paused_millis')) {
      context.handle(
        _totalPausedMillisMeta,
        totalPausedMillis.isAcceptableOrUnknown(
          data['total_paused_millis']!,
          _totalPausedMillisMeta,
        ),
      );
    }
    if (data.containsKey('pause_count')) {
      context.handle(
        _pauseCountMeta,
        pauseCount.isAcceptableOrUnknown(data['pause_count']!, _pauseCountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KickSessionDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KickSessionDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTimeMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_millis'],
      )!,
      endTimeMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_millis'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      pausedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at_millis'],
      ),
      totalPausedMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paused_millis'],
      )!,
      pauseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_count'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $KickSessionsTable createAlias(String alias) {
    return $KickSessionsTable(attachedDatabase, alias);
  }
}

class KickSessionDto extends DataClass implements Insertable<KickSessionDto> {
  /// Unique identifier (UUID)
  final String id;

  /// When the session started (stored as millis since epoch for precision)
  final int startTimeMillis;

  /// When the session ended (null if still active)
  final int? endTimeMillis;

  /// Whether this session is currently active
  /// Active sessions appear in the UI and prevent new session creation
  final bool isActive;

  /// Timestamp when session was paused (null if not currently paused)
  /// When paused, kick recording is disabled but session remains active
  final int? pausedAtMillis;

  /// Total accumulated pause duration in milliseconds
  /// Updated each time the session is resumed
  final int totalPausedMillis;

  /// Number of times the user has paused this session
  /// Tracking metric for understanding user behavior patterns
  final int pauseCount;

  /// Optional encrypted note attached to this session
  /// Users can add personal observations about the session
  final String? note;

  /// Timestamp when record was created (stored as millis since epoch)
  final int createdAtMillis;

  /// Timestamp when record was last updated (stored as millis since epoch)
  final int updatedAtMillis;
  const KickSessionDto({
    required this.id,
    required this.startTimeMillis,
    this.endTimeMillis,
    required this.isActive,
    this.pausedAtMillis,
    required this.totalPausedMillis,
    required this.pauseCount,
    this.note,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time_millis'] = Variable<int>(startTimeMillis);
    if (!nullToAbsent || endTimeMillis != null) {
      map['end_time_millis'] = Variable<int>(endTimeMillis);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || pausedAtMillis != null) {
      map['paused_at_millis'] = Variable<int>(pausedAtMillis);
    }
    map['total_paused_millis'] = Variable<int>(totalPausedMillis);
    map['pause_count'] = Variable<int>(pauseCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  KickSessionsCompanion toCompanion(bool nullToAbsent) {
    return KickSessionsCompanion(
      id: Value(id),
      startTimeMillis: Value(startTimeMillis),
      endTimeMillis: endTimeMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeMillis),
      isActive: Value(isActive),
      pausedAtMillis: pausedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAtMillis),
      totalPausedMillis: Value(totalPausedMillis),
      pauseCount: Value(pauseCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory KickSessionDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KickSessionDto(
      id: serializer.fromJson<String>(json['id']),
      startTimeMillis: serializer.fromJson<int>(json['startTimeMillis']),
      endTimeMillis: serializer.fromJson<int?>(json['endTimeMillis']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      pausedAtMillis: serializer.fromJson<int?>(json['pausedAtMillis']),
      totalPausedMillis: serializer.fromJson<int>(json['totalPausedMillis']),
      pauseCount: serializer.fromJson<int>(json['pauseCount']),
      note: serializer.fromJson<String?>(json['note']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTimeMillis': serializer.toJson<int>(startTimeMillis),
      'endTimeMillis': serializer.toJson<int?>(endTimeMillis),
      'isActive': serializer.toJson<bool>(isActive),
      'pausedAtMillis': serializer.toJson<int?>(pausedAtMillis),
      'totalPausedMillis': serializer.toJson<int>(totalPausedMillis),
      'pauseCount': serializer.toJson<int>(pauseCount),
      'note': serializer.toJson<String?>(note),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  KickSessionDto copyWith({
    String? id,
    int? startTimeMillis,
    Value<int?> endTimeMillis = const Value.absent(),
    bool? isActive,
    Value<int?> pausedAtMillis = const Value.absent(),
    int? totalPausedMillis,
    int? pauseCount,
    Value<String?> note = const Value.absent(),
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => KickSessionDto(
    id: id ?? this.id,
    startTimeMillis: startTimeMillis ?? this.startTimeMillis,
    endTimeMillis: endTimeMillis.present
        ? endTimeMillis.value
        : this.endTimeMillis,
    isActive: isActive ?? this.isActive,
    pausedAtMillis: pausedAtMillis.present
        ? pausedAtMillis.value
        : this.pausedAtMillis,
    totalPausedMillis: totalPausedMillis ?? this.totalPausedMillis,
    pauseCount: pauseCount ?? this.pauseCount,
    note: note.present ? note.value : this.note,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  KickSessionDto copyWithCompanion(KickSessionsCompanion data) {
    return KickSessionDto(
      id: data.id.present ? data.id.value : this.id,
      startTimeMillis: data.startTimeMillis.present
          ? data.startTimeMillis.value
          : this.startTimeMillis,
      endTimeMillis: data.endTimeMillis.present
          ? data.endTimeMillis.value
          : this.endTimeMillis,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      pausedAtMillis: data.pausedAtMillis.present
          ? data.pausedAtMillis.value
          : this.pausedAtMillis,
      totalPausedMillis: data.totalPausedMillis.present
          ? data.totalPausedMillis.value
          : this.totalPausedMillis,
      pauseCount: data.pauseCount.present
          ? data.pauseCount.value
          : this.pauseCount,
      note: data.note.present ? data.note.value : this.note,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KickSessionDto(')
          ..write('id: $id, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('isActive: $isActive, ')
          ..write('pausedAtMillis: $pausedAtMillis, ')
          ..write('totalPausedMillis: $totalPausedMillis, ')
          ..write('pauseCount: $pauseCount, ')
          ..write('note: $note, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTimeMillis,
    endTimeMillis,
    isActive,
    pausedAtMillis,
    totalPausedMillis,
    pauseCount,
    note,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KickSessionDto &&
          other.id == this.id &&
          other.startTimeMillis == this.startTimeMillis &&
          other.endTimeMillis == this.endTimeMillis &&
          other.isActive == this.isActive &&
          other.pausedAtMillis == this.pausedAtMillis &&
          other.totalPausedMillis == this.totalPausedMillis &&
          other.pauseCount == this.pauseCount &&
          other.note == this.note &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class KickSessionsCompanion extends UpdateCompanion<KickSessionDto> {
  final Value<String> id;
  final Value<int> startTimeMillis;
  final Value<int?> endTimeMillis;
  final Value<bool> isActive;
  final Value<int?> pausedAtMillis;
  final Value<int> totalPausedMillis;
  final Value<int> pauseCount;
  final Value<String?> note;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const KickSessionsCompanion({
    this.id = const Value.absent(),
    this.startTimeMillis = const Value.absent(),
    this.endTimeMillis = const Value.absent(),
    this.isActive = const Value.absent(),
    this.pausedAtMillis = const Value.absent(),
    this.totalPausedMillis = const Value.absent(),
    this.pauseCount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KickSessionsCompanion.insert({
    required String id,
    required int startTimeMillis,
    this.endTimeMillis = const Value.absent(),
    this.isActive = const Value.absent(),
    this.pausedAtMillis = const Value.absent(),
    this.totalPausedMillis = const Value.absent(),
    this.pauseCount = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTimeMillis = Value(startTimeMillis),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<KickSessionDto> custom({
    Expression<String>? id,
    Expression<int>? startTimeMillis,
    Expression<int>? endTimeMillis,
    Expression<bool>? isActive,
    Expression<int>? pausedAtMillis,
    Expression<int>? totalPausedMillis,
    Expression<int>? pauseCount,
    Expression<String>? note,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTimeMillis != null) 'start_time_millis': startTimeMillis,
      if (endTimeMillis != null) 'end_time_millis': endTimeMillis,
      if (isActive != null) 'is_active': isActive,
      if (pausedAtMillis != null) 'paused_at_millis': pausedAtMillis,
      if (totalPausedMillis != null) 'total_paused_millis': totalPausedMillis,
      if (pauseCount != null) 'pause_count': pauseCount,
      if (note != null) 'note': note,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KickSessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startTimeMillis,
    Value<int?>? endTimeMillis,
    Value<bool>? isActive,
    Value<int?>? pausedAtMillis,
    Value<int>? totalPausedMillis,
    Value<int>? pauseCount,
    Value<String?>? note,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return KickSessionsCompanion(
      id: id ?? this.id,
      startTimeMillis: startTimeMillis ?? this.startTimeMillis,
      endTimeMillis: endTimeMillis ?? this.endTimeMillis,
      isActive: isActive ?? this.isActive,
      pausedAtMillis: pausedAtMillis ?? this.pausedAtMillis,
      totalPausedMillis: totalPausedMillis ?? this.totalPausedMillis,
      pauseCount: pauseCount ?? this.pauseCount,
      note: note ?? this.note,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTimeMillis.present) {
      map['start_time_millis'] = Variable<int>(startTimeMillis.value);
    }
    if (endTimeMillis.present) {
      map['end_time_millis'] = Variable<int>(endTimeMillis.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (pausedAtMillis.present) {
      map['paused_at_millis'] = Variable<int>(pausedAtMillis.value);
    }
    if (totalPausedMillis.present) {
      map['total_paused_millis'] = Variable<int>(totalPausedMillis.value);
    }
    if (pauseCount.present) {
      map['pause_count'] = Variable<int>(pauseCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KickSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('isActive: $isActive, ')
          ..write('pausedAtMillis: $pausedAtMillis, ')
          ..write('totalPausedMillis: $totalPausedMillis, ')
          ..write('pauseCount: $pauseCount, ')
          ..write('note: $note, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KicksTable extends Kicks with TableInfo<$KicksTable, KickDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KicksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES kick_sessions(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _timestampMillisMeta = const VerificationMeta(
    'timestampMillis',
  );
  @override
  late final GeneratedColumn<int> timestampMillis = GeneratedColumn<int>(
    'timestamp_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perceivedStrengthMeta = const VerificationMeta(
    'perceivedStrength',
  );
  @override
  late final GeneratedColumn<String> perceivedStrength =
      GeneratedColumn<String>(
        'perceived_strength',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestampMillis,
    sequenceNumber,
    perceivedStrength,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kicks';
  @override
  VerificationContext validateIntegrity(
    Insertable<KickDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_millis')) {
      context.handle(
        _timestampMillisMeta,
        timestampMillis.isAcceptableOrUnknown(
          data['timestamp_millis']!,
          _timestampMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMillisMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('perceived_strength')) {
      context.handle(
        _perceivedStrengthMeta,
        perceivedStrength.isAcceptableOrUnknown(
          data['perceived_strength']!,
          _perceivedStrengthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedStrengthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, sequenceNumber},
  ];
  @override
  KickDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KickDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      timestampMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_millis'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      perceivedStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perceived_strength'],
      )!,
    );
  }

  @override
  $KicksTable createAlias(String alias) {
    return $KicksTable(attachedDatabase, alias);
  }
}

class KickDto extends DataClass implements Insertable<KickDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to parent session
  /// Cascade delete ensures kicks are removed when session is deleted
  final String sessionId;

  /// Timestamp when the kick was recorded (stored as millis since epoch for precision)
  /// Used for calculating time between kicks and patterns
  final int timestampMillis;

  /// Sequential number of this kick within the session (1-indexed)
  /// Used for ordering and "undo last kick" functionality
  final int sequenceNumber;

  /// Encrypted perceived movement strength
  /// Stored as encrypted base64 string for medical data privacy
  /// Decrypts to enum: weak, moderate, strong
  final String perceivedStrength;
  const KickDto({
    required this.id,
    required this.sessionId,
    required this.timestampMillis,
    required this.sequenceNumber,
    required this.perceivedStrength,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['timestamp_millis'] = Variable<int>(timestampMillis);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['perceived_strength'] = Variable<String>(perceivedStrength);
    return map;
  }

  KicksCompanion toCompanion(bool nullToAbsent) {
    return KicksCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampMillis: Value(timestampMillis),
      sequenceNumber: Value(sequenceNumber),
      perceivedStrength: Value(perceivedStrength),
    );
  }

  factory KickDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KickDto(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      timestampMillis: serializer.fromJson<int>(json['timestampMillis']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      perceivedStrength: serializer.fromJson<String>(json['perceivedStrength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'timestampMillis': serializer.toJson<int>(timestampMillis),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'perceivedStrength': serializer.toJson<String>(perceivedStrength),
    };
  }

  KickDto copyWith({
    String? id,
    String? sessionId,
    int? timestampMillis,
    int? sequenceNumber,
    String? perceivedStrength,
  }) => KickDto(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestampMillis: timestampMillis ?? this.timestampMillis,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    perceivedStrength: perceivedStrength ?? this.perceivedStrength,
  );
  KickDto copyWithCompanion(KicksCompanion data) {
    return KickDto(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampMillis: data.timestampMillis.present
          ? data.timestampMillis.value
          : this.timestampMillis,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      perceivedStrength: data.perceivedStrength.present
          ? data.perceivedStrength.value
          : this.perceivedStrength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KickDto(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampMillis: $timestampMillis, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('perceivedStrength: $perceivedStrength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestampMillis,
    sequenceNumber,
    perceivedStrength,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KickDto &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampMillis == this.timestampMillis &&
          other.sequenceNumber == this.sequenceNumber &&
          other.perceivedStrength == this.perceivedStrength);
}

class KicksCompanion extends UpdateCompanion<KickDto> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> timestampMillis;
  final Value<int> sequenceNumber;
  final Value<String> perceivedStrength;
  final Value<int> rowid;
  const KicksCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampMillis = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.perceivedStrength = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KicksCompanion.insert({
    required String id,
    required String sessionId,
    required int timestampMillis,
    required int sequenceNumber,
    required String perceivedStrength,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       timestampMillis = Value(timestampMillis),
       sequenceNumber = Value(sequenceNumber),
       perceivedStrength = Value(perceivedStrength);
  static Insertable<KickDto> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? timestampMillis,
    Expression<int>? sequenceNumber,
    Expression<String>? perceivedStrength,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampMillis != null) 'timestamp_millis': timestampMillis,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (perceivedStrength != null) 'perceived_strength': perceivedStrength,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KicksCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? timestampMillis,
    Value<int>? sequenceNumber,
    Value<String>? perceivedStrength,
    Value<int>? rowid,
  }) {
    return KicksCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampMillis: timestampMillis ?? this.timestampMillis,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      perceivedStrength: perceivedStrength ?? this.perceivedStrength,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (timestampMillis.present) {
      map['timestamp_millis'] = Variable<int>(timestampMillis.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (perceivedStrength.present) {
      map['perceived_strength'] = Variable<String>(perceivedStrength.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KicksCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampMillis: $timestampMillis, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('perceivedStrength: $perceivedStrength, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KickSessionsTable kickSessions = $KickSessionsTable(this);
  late final $KicksTable kicks = $KicksTable(this);
  late final KickCounterDao kickCounterDao = KickCounterDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [kickSessions, kicks];
}

typedef $$KickSessionsTableCreateCompanionBuilder =
    KickSessionsCompanion Function({
      required String id,
      required int startTimeMillis,
      Value<int?> endTimeMillis,
      Value<bool> isActive,
      Value<int?> pausedAtMillis,
      Value<int> totalPausedMillis,
      Value<int> pauseCount,
      Value<String?> note,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$KickSessionsTableUpdateCompanionBuilder =
    KickSessionsCompanion Function({
      Value<String> id,
      Value<int> startTimeMillis,
      Value<int?> endTimeMillis,
      Value<bool> isActive,
      Value<int?> pausedAtMillis,
      Value<int> totalPausedMillis,
      Value<int> pauseCount,
      Value<String?> note,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$KickSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPausedMillis => $composableBuilder(
    column: $table.totalPausedMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseCount => $composableBuilder(
    column: $table.pauseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KickSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPausedMillis => $composableBuilder(
    column: $table.totalPausedMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseCount => $composableBuilder(
    column: $table.pauseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KickSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPausedMillis => $composableBuilder(
    column: $table.totalPausedMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseCount => $composableBuilder(
    column: $table.pauseCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$KickSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KickSessionsTable,
          KickSessionDto,
          $$KickSessionsTableFilterComposer,
          $$KickSessionsTableOrderingComposer,
          $$KickSessionsTableAnnotationComposer,
          $$KickSessionsTableCreateCompanionBuilder,
          $$KickSessionsTableUpdateCompanionBuilder,
          (
            KickSessionDto,
            BaseReferences<_$AppDatabase, $KickSessionsTable, KickSessionDto>,
          ),
          KickSessionDto,
          PrefetchHooks Function()
        > {
  $$KickSessionsTableTableManager(_$AppDatabase db, $KickSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KickSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KickSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KickSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startTimeMillis = const Value.absent(),
                Value<int?> endTimeMillis = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> pausedAtMillis = const Value.absent(),
                Value<int> totalPausedMillis = const Value.absent(),
                Value<int> pauseCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KickSessionsCompanion(
                id: id,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                isActive: isActive,
                pausedAtMillis: pausedAtMillis,
                totalPausedMillis: totalPausedMillis,
                pauseCount: pauseCount,
                note: note,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startTimeMillis,
                Value<int?> endTimeMillis = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> pausedAtMillis = const Value.absent(),
                Value<int> totalPausedMillis = const Value.absent(),
                Value<int> pauseCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => KickSessionsCompanion.insert(
                id: id,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                isActive: isActive,
                pausedAtMillis: pausedAtMillis,
                totalPausedMillis: totalPausedMillis,
                pauseCount: pauseCount,
                note: note,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KickSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KickSessionsTable,
      KickSessionDto,
      $$KickSessionsTableFilterComposer,
      $$KickSessionsTableOrderingComposer,
      $$KickSessionsTableAnnotationComposer,
      $$KickSessionsTableCreateCompanionBuilder,
      $$KickSessionsTableUpdateCompanionBuilder,
      (
        KickSessionDto,
        BaseReferences<_$AppDatabase, $KickSessionsTable, KickSessionDto>,
      ),
      KickSessionDto,
      PrefetchHooks Function()
    >;
typedef $$KicksTableCreateCompanionBuilder =
    KicksCompanion Function({
      required String id,
      required String sessionId,
      required int timestampMillis,
      required int sequenceNumber,
      required String perceivedStrength,
      Value<int> rowid,
    });
typedef $$KicksTableUpdateCompanionBuilder =
    KicksCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> timestampMillis,
      Value<int> sequenceNumber,
      Value<String> perceivedStrength,
      Value<int> rowid,
    });

class $$KicksTableFilterComposer extends Composer<_$AppDatabase, $KicksTable> {
  $$KicksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get perceivedStrength => $composableBuilder(
    column: $table.perceivedStrength,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KicksTableOrderingComposer
    extends Composer<_$AppDatabase, $KicksTable> {
  $$KicksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get perceivedStrength => $composableBuilder(
    column: $table.perceivedStrength,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KicksTableAnnotationComposer
    extends Composer<_$AppDatabase, $KicksTable> {
  $$KicksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get perceivedStrength => $composableBuilder(
    column: $table.perceivedStrength,
    builder: (column) => column,
  );
}

class $$KicksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KicksTable,
          KickDto,
          $$KicksTableFilterComposer,
          $$KicksTableOrderingComposer,
          $$KicksTableAnnotationComposer,
          $$KicksTableCreateCompanionBuilder,
          $$KicksTableUpdateCompanionBuilder,
          (KickDto, BaseReferences<_$AppDatabase, $KicksTable, KickDto>),
          KickDto,
          PrefetchHooks Function()
        > {
  $$KicksTableTableManager(_$AppDatabase db, $KicksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KicksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KicksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KicksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> timestampMillis = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> perceivedStrength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KicksCompanion(
                id: id,
                sessionId: sessionId,
                timestampMillis: timestampMillis,
                sequenceNumber: sequenceNumber,
                perceivedStrength: perceivedStrength,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int timestampMillis,
                required int sequenceNumber,
                required String perceivedStrength,
                Value<int> rowid = const Value.absent(),
              }) => KicksCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestampMillis: timestampMillis,
                sequenceNumber: sequenceNumber,
                perceivedStrength: perceivedStrength,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KicksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KicksTable,
      KickDto,
      $$KicksTableFilterComposer,
      $$KicksTableOrderingComposer,
      $$KicksTableAnnotationComposer,
      $$KicksTableCreateCompanionBuilder,
      $$KicksTableUpdateCompanionBuilder,
      (KickDto, BaseReferences<_$AppDatabase, $KicksTable, KickDto>),
      KickDto,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KickSessionsTableTableManager get kickSessions =>
      $$KickSessionsTableTableManager(_db, _db.kickSessions);
  $$KicksTableTableManager get kicks =>
      $$KicksTableTableManager(_db, _db.kicks);
}
