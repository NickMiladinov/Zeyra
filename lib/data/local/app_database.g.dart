// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authIdMeta = const VerificationMeta('authId');
  @override
  late final GeneratedColumn<String> authId = GeneratedColumn<String>(
    'auth_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMillisMeta = const VerificationMeta(
    'dateOfBirthMillis',
  );
  @override
  late final GeneratedColumn<int> dateOfBirthMillis = GeneratedColumn<int>(
    'date_of_birth_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _databasePathMeta = const VerificationMeta(
    'databasePath',
  );
  @override
  late final GeneratedColumn<String> databasePath = GeneratedColumn<String>(
    'database_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptionKeyIdMeta = const VerificationMeta(
    'encryptionKeyId',
  );
  @override
  late final GeneratedColumn<String> encryptionKeyId = GeneratedColumn<String>(
    'encryption_key_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMillisMeta =
      const VerificationMeta('lastAccessedAtMillis');
  @override
  late final GeneratedColumn<int> lastAccessedAtMillis = GeneratedColumn<int>(
    'last_accessed_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authId,
    email,
    firstName,
    lastName,
    dateOfBirthMillis,
    gender,
    createdAtMillis,
    updatedAtMillis,
    isSynced,
    databasePath,
    encryptionKeyId,
    lastAccessedAtMillis,
    schemaVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('auth_id')) {
      context.handle(
        _authIdMeta,
        authId.isAcceptableOrUnknown(data['auth_id']!, _authIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('date_of_birth_millis')) {
      context.handle(
        _dateOfBirthMillisMeta,
        dateOfBirthMillis.isAcceptableOrUnknown(
          data['date_of_birth_millis']!,
          _dateOfBirthMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMillisMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
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
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('database_path')) {
      context.handle(
        _databasePathMeta,
        databasePath.isAcceptableOrUnknown(
          data['database_path']!,
          _databasePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_databasePathMeta);
    }
    if (data.containsKey('encryption_key_id')) {
      context.handle(
        _encryptionKeyIdMeta,
        encryptionKeyId.isAcceptableOrUnknown(
          data['encryption_key_id']!,
          _encryptionKeyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptionKeyIdMeta);
    }
    if (data.containsKey('last_accessed_at_millis')) {
      context.handle(
        _lastAccessedAtMillisMeta,
        lastAccessedAtMillis.isAcceptableOrUnknown(
          data['last_accessed_at_millis']!,
          _lastAccessedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMillisMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      dateOfBirthMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_of_birth_millis'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      databasePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}database_path'],
      )!,
      encryptionKeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encryption_key_id'],
      )!,
      lastAccessedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at_millis'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileDto extends DataClass implements Insertable<UserProfileDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Supabase Auth user ID
  final String authId;

  /// User's email
  final String email;

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// Date of birth (stored as millis since epoch)
  final int dateOfBirthMillis;

  /// Gender (stored as lowercase string)
  final String gender;

  /// When record was created (millis since epoch)
  final int createdAtMillis;

  /// When record was last updated (millis since epoch)
  final int updatedAtMillis;

  /// Whether synced to cloud
  final bool isSynced;

  /// Path to database file
  final String databasePath;

  /// Encryption key ID in secure storage
  final String encryptionKeyId;

  /// Last access timestamp (millis since epoch)
  final int lastAccessedAtMillis;

  /// Database schema version
  final int schemaVersion;
  const UserProfileDto({
    required this.id,
    required this.authId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirthMillis,
    required this.gender,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    required this.isSynced,
    required this.databasePath,
    required this.encryptionKeyId,
    required this.lastAccessedAtMillis,
    required this.schemaVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['auth_id'] = Variable<String>(authId);
    map['email'] = Variable<String>(email);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['date_of_birth_millis'] = Variable<int>(dateOfBirthMillis);
    map['gender'] = Variable<String>(gender);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    map['is_synced'] = Variable<bool>(isSynced);
    map['database_path'] = Variable<String>(databasePath);
    map['encryption_key_id'] = Variable<String>(encryptionKeyId);
    map['last_accessed_at_millis'] = Variable<int>(lastAccessedAtMillis);
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      authId: Value(authId),
      email: Value(email),
      firstName: Value(firstName),
      lastName: Value(lastName),
      dateOfBirthMillis: Value(dateOfBirthMillis),
      gender: Value(gender),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
      isSynced: Value(isSynced),
      databasePath: Value(databasePath),
      encryptionKeyId: Value(encryptionKeyId),
      lastAccessedAtMillis: Value(lastAccessedAtMillis),
      schemaVersion: Value(schemaVersion),
    );
  }

  factory UserProfileDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileDto(
      id: serializer.fromJson<String>(json['id']),
      authId: serializer.fromJson<String>(json['authId']),
      email: serializer.fromJson<String>(json['email']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      dateOfBirthMillis: serializer.fromJson<int>(json['dateOfBirthMillis']),
      gender: serializer.fromJson<String>(json['gender']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      databasePath: serializer.fromJson<String>(json['databasePath']),
      encryptionKeyId: serializer.fromJson<String>(json['encryptionKeyId']),
      lastAccessedAtMillis: serializer.fromJson<int>(
        json['lastAccessedAtMillis'],
      ),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'authId': serializer.toJson<String>(authId),
      'email': serializer.toJson<String>(email),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'dateOfBirthMillis': serializer.toJson<int>(dateOfBirthMillis),
      'gender': serializer.toJson<String>(gender),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'isSynced': serializer.toJson<bool>(isSynced),
      'databasePath': serializer.toJson<String>(databasePath),
      'encryptionKeyId': serializer.toJson<String>(encryptionKeyId),
      'lastAccessedAtMillis': serializer.toJson<int>(lastAccessedAtMillis),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  UserProfileDto copyWith({
    String? id,
    String? authId,
    String? email,
    String? firstName,
    String? lastName,
    int? dateOfBirthMillis,
    String? gender,
    int? createdAtMillis,
    int? updatedAtMillis,
    bool? isSynced,
    String? databasePath,
    String? encryptionKeyId,
    int? lastAccessedAtMillis,
    int? schemaVersion,
  }) => UserProfileDto(
    id: id ?? this.id,
    authId: authId ?? this.authId,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    dateOfBirthMillis: dateOfBirthMillis ?? this.dateOfBirthMillis,
    gender: gender ?? this.gender,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    isSynced: isSynced ?? this.isSynced,
    databasePath: databasePath ?? this.databasePath,
    encryptionKeyId: encryptionKeyId ?? this.encryptionKeyId,
    lastAccessedAtMillis: lastAccessedAtMillis ?? this.lastAccessedAtMillis,
    schemaVersion: schemaVersion ?? this.schemaVersion,
  );
  UserProfileDto copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileDto(
      id: data.id.present ? data.id.value : this.id,
      authId: data.authId.present ? data.authId.value : this.authId,
      email: data.email.present ? data.email.value : this.email,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      dateOfBirthMillis: data.dateOfBirthMillis.present
          ? data.dateOfBirthMillis.value
          : this.dateOfBirthMillis,
      gender: data.gender.present ? data.gender.value : this.gender,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      databasePath: data.databasePath.present
          ? data.databasePath.value
          : this.databasePath,
      encryptionKeyId: data.encryptionKeyId.present
          ? data.encryptionKeyId.value
          : this.encryptionKeyId,
      lastAccessedAtMillis: data.lastAccessedAtMillis.present
          ? data.lastAccessedAtMillis.value
          : this.lastAccessedAtMillis,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileDto(')
          ..write('id: $id, ')
          ..write('authId: $authId, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('dateOfBirthMillis: $dateOfBirthMillis, ')
          ..write('gender: $gender, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('isSynced: $isSynced, ')
          ..write('databasePath: $databasePath, ')
          ..write('encryptionKeyId: $encryptionKeyId, ')
          ..write('lastAccessedAtMillis: $lastAccessedAtMillis, ')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authId,
    email,
    firstName,
    lastName,
    dateOfBirthMillis,
    gender,
    createdAtMillis,
    updatedAtMillis,
    isSynced,
    databasePath,
    encryptionKeyId,
    lastAccessedAtMillis,
    schemaVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileDto &&
          other.id == this.id &&
          other.authId == this.authId &&
          other.email == this.email &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.dateOfBirthMillis == this.dateOfBirthMillis &&
          other.gender == this.gender &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.isSynced == this.isSynced &&
          other.databasePath == this.databasePath &&
          other.encryptionKeyId == this.encryptionKeyId &&
          other.lastAccessedAtMillis == this.lastAccessedAtMillis &&
          other.schemaVersion == this.schemaVersion);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileDto> {
  final Value<String> id;
  final Value<String> authId;
  final Value<String> email;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<int> dateOfBirthMillis;
  final Value<String> gender;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<bool> isSynced;
  final Value<String> databasePath;
  final Value<String> encryptionKeyId;
  final Value<int> lastAccessedAtMillis;
  final Value<int> schemaVersion;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.authId = const Value.absent(),
    this.email = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.dateOfBirthMillis = const Value.absent(),
    this.gender = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.databasePath = const Value.absent(),
    this.encryptionKeyId = const Value.absent(),
    this.lastAccessedAtMillis = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String authId,
    required String email,
    required String firstName,
    required String lastName,
    required int dateOfBirthMillis,
    required String gender,
    required int createdAtMillis,
    required int updatedAtMillis,
    this.isSynced = const Value.absent(),
    required String databasePath,
    required String encryptionKeyId,
    required int lastAccessedAtMillis,
    required int schemaVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authId = Value(authId),
       email = Value(email),
       firstName = Value(firstName),
       lastName = Value(lastName),
       dateOfBirthMillis = Value(dateOfBirthMillis),
       gender = Value(gender),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis),
       databasePath = Value(databasePath),
       encryptionKeyId = Value(encryptionKeyId),
       lastAccessedAtMillis = Value(lastAccessedAtMillis),
       schemaVersion = Value(schemaVersion);
  static Insertable<UserProfileDto> custom({
    Expression<String>? id,
    Expression<String>? authId,
    Expression<String>? email,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<int>? dateOfBirthMillis,
    Expression<String>? gender,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<bool>? isSynced,
    Expression<String>? databasePath,
    Expression<String>? encryptionKeyId,
    Expression<int>? lastAccessedAtMillis,
    Expression<int>? schemaVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authId != null) 'auth_id': authId,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirthMillis != null) 'date_of_birth_millis': dateOfBirthMillis,
      if (gender != null) 'gender': gender,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (isSynced != null) 'is_synced': isSynced,
      if (databasePath != null) 'database_path': databasePath,
      if (encryptionKeyId != null) 'encryption_key_id': encryptionKeyId,
      if (lastAccessedAtMillis != null)
        'last_accessed_at_millis': lastAccessedAtMillis,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? authId,
    Value<String>? email,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<int>? dateOfBirthMillis,
    Value<String>? gender,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<bool>? isSynced,
    Value<String>? databasePath,
    Value<String>? encryptionKeyId,
    Value<int>? lastAccessedAtMillis,
    Value<int>? schemaVersion,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirthMillis: dateOfBirthMillis ?? this.dateOfBirthMillis,
      gender: gender ?? this.gender,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      isSynced: isSynced ?? this.isSynced,
      databasePath: databasePath ?? this.databasePath,
      encryptionKeyId: encryptionKeyId ?? this.encryptionKeyId,
      lastAccessedAtMillis: lastAccessedAtMillis ?? this.lastAccessedAtMillis,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authId.present) {
      map['auth_id'] = Variable<String>(authId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (dateOfBirthMillis.present) {
      map['date_of_birth_millis'] = Variable<int>(dateOfBirthMillis.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (databasePath.present) {
      map['database_path'] = Variable<String>(databasePath.value);
    }
    if (encryptionKeyId.present) {
      map['encryption_key_id'] = Variable<String>(encryptionKeyId.value);
    }
    if (lastAccessedAtMillis.present) {
      map['last_accessed_at_millis'] = Variable<int>(
        lastAccessedAtMillis.value,
      );
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('authId: $authId, ')
          ..write('email: $email, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('dateOfBirthMillis: $dateOfBirthMillis, ')
          ..write('gender: $gender, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('isSynced: $isSynced, ')
          ..write('databasePath: $databasePath, ')
          ..write('encryptionKeyId: $encryptionKeyId, ')
          ..write('lastAccessedAtMillis: $lastAccessedAtMillis, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PregnanciesTable extends Pregnancies
    with TableInfo<$PregnanciesTable, PregnancyDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateMillisMeta = const VerificationMeta(
    'startDateMillis',
  );
  @override
  late final GeneratedColumn<int> startDateMillis = GeneratedColumn<int>(
    'start_date_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMillisMeta = const VerificationMeta(
    'dueDateMillis',
  );
  @override
  late final GeneratedColumn<int> dueDateMillis = GeneratedColumn<int>(
    'due_date_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedHospitalIdMeta =
      const VerificationMeta('selectedHospitalId');
  @override
  late final GeneratedColumn<String> selectedHospitalId =
      GeneratedColumn<String>(
        'selected_hospital_id',
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
    userId,
    startDateMillis,
    dueDateMillis,
    selectedHospitalId,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancies';
  @override
  VerificationContext validateIntegrity(
    Insertable<PregnancyDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('start_date_millis')) {
      context.handle(
        _startDateMillisMeta,
        startDateMillis.isAcceptableOrUnknown(
          data['start_date_millis']!,
          _startDateMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDateMillisMeta);
    }
    if (data.containsKey('due_date_millis')) {
      context.handle(
        _dueDateMillisMeta,
        dueDateMillis.isAcceptableOrUnknown(
          data['due_date_millis']!,
          _dueDateMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dueDateMillisMeta);
    }
    if (data.containsKey('selected_hospital_id')) {
      context.handle(
        _selectedHospitalIdMeta,
        selectedHospitalId.isAcceptableOrUnknown(
          data['selected_hospital_id']!,
          _selectedHospitalIdMeta,
        ),
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
  PregnancyDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PregnancyDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startDateMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date_millis'],
      )!,
      dueDateMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date_millis'],
      )!,
      selectedHospitalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_hospital_id'],
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
  $PregnanciesTable createAlias(String alias) {
    return $PregnanciesTable(attachedDatabase, alias);
  }
}

class PregnancyDto extends DataClass implements Insertable<PregnancyDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to UserProfiles
  final String userId;

  /// Last Menstrual Period date (millis since epoch)
  final int startDateMillis;

  /// Expected due date (millis since epoch)
  final int dueDateMillis;

  /// Selected hospital ID (nullable)
  final String? selectedHospitalId;

  /// When record was created (millis since epoch)
  final int createdAtMillis;

  /// When record was last updated (millis since epoch)
  final int updatedAtMillis;
  const PregnancyDto({
    required this.id,
    required this.userId,
    required this.startDateMillis,
    required this.dueDateMillis,
    this.selectedHospitalId,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['start_date_millis'] = Variable<int>(startDateMillis);
    map['due_date_millis'] = Variable<int>(dueDateMillis);
    if (!nullToAbsent || selectedHospitalId != null) {
      map['selected_hospital_id'] = Variable<String>(selectedHospitalId);
    }
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  PregnanciesCompanion toCompanion(bool nullToAbsent) {
    return PregnanciesCompanion(
      id: Value(id),
      userId: Value(userId),
      startDateMillis: Value(startDateMillis),
      dueDateMillis: Value(dueDateMillis),
      selectedHospitalId: selectedHospitalId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedHospitalId),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory PregnancyDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PregnancyDto(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      startDateMillis: serializer.fromJson<int>(json['startDateMillis']),
      dueDateMillis: serializer.fromJson<int>(json['dueDateMillis']),
      selectedHospitalId: serializer.fromJson<String?>(
        json['selectedHospitalId'],
      ),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'startDateMillis': serializer.toJson<int>(startDateMillis),
      'dueDateMillis': serializer.toJson<int>(dueDateMillis),
      'selectedHospitalId': serializer.toJson<String?>(selectedHospitalId),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  PregnancyDto copyWith({
    String? id,
    String? userId,
    int? startDateMillis,
    int? dueDateMillis,
    Value<String?> selectedHospitalId = const Value.absent(),
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => PregnancyDto(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    startDateMillis: startDateMillis ?? this.startDateMillis,
    dueDateMillis: dueDateMillis ?? this.dueDateMillis,
    selectedHospitalId: selectedHospitalId.present
        ? selectedHospitalId.value
        : this.selectedHospitalId,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  PregnancyDto copyWithCompanion(PregnanciesCompanion data) {
    return PregnancyDto(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      startDateMillis: data.startDateMillis.present
          ? data.startDateMillis.value
          : this.startDateMillis,
      dueDateMillis: data.dueDateMillis.present
          ? data.dueDateMillis.value
          : this.dueDateMillis,
      selectedHospitalId: data.selectedHospitalId.present
          ? data.selectedHospitalId.value
          : this.selectedHospitalId,
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
    return (StringBuffer('PregnancyDto(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startDateMillis: $startDateMillis, ')
          ..write('dueDateMillis: $dueDateMillis, ')
          ..write('selectedHospitalId: $selectedHospitalId, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    startDateMillis,
    dueDateMillis,
    selectedHospitalId,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PregnancyDto &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.startDateMillis == this.startDateMillis &&
          other.dueDateMillis == this.dueDateMillis &&
          other.selectedHospitalId == this.selectedHospitalId &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class PregnanciesCompanion extends UpdateCompanion<PregnancyDto> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> startDateMillis;
  final Value<int> dueDateMillis;
  final Value<String?> selectedHospitalId;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const PregnanciesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.startDateMillis = const Value.absent(),
    this.dueDateMillis = const Value.absent(),
    this.selectedHospitalId = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PregnanciesCompanion.insert({
    required String id,
    required String userId,
    required int startDateMillis,
    required int dueDateMillis,
    this.selectedHospitalId = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startDateMillis = Value(startDateMillis),
       dueDateMillis = Value(dueDateMillis),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<PregnancyDto> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? startDateMillis,
    Expression<int>? dueDateMillis,
    Expression<String>? selectedHospitalId,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (startDateMillis != null) 'start_date_millis': startDateMillis,
      if (dueDateMillis != null) 'due_date_millis': dueDateMillis,
      if (selectedHospitalId != null)
        'selected_hospital_id': selectedHospitalId,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PregnanciesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? startDateMillis,
    Value<int>? dueDateMillis,
    Value<String?>? selectedHospitalId,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return PregnanciesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDateMillis: startDateMillis ?? this.startDateMillis,
      dueDateMillis: dueDateMillis ?? this.dueDateMillis,
      selectedHospitalId: selectedHospitalId ?? this.selectedHospitalId,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startDateMillis.present) {
      map['start_date_millis'] = Variable<int>(startDateMillis.value);
    }
    if (dueDateMillis.present) {
      map['due_date_millis'] = Variable<int>(dueDateMillis.value);
    }
    if (selectedHospitalId.present) {
      map['selected_hospital_id'] = Variable<String>(selectedHospitalId.value);
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
    return (StringBuffer('PregnanciesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('startDateMillis: $startDateMillis, ')
          ..write('dueDateMillis: $dueDateMillis, ')
          ..write('selectedHospitalId: $selectedHospitalId, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kick_sessions (id) ON DELETE CASCADE',
    ),
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

class $PauseEventsTable extends PauseEvents
    with TableInfo<$PauseEventsTable, PauseEventDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PauseEventsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kick_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pausedAtMillisMeta = const VerificationMeta(
    'pausedAtMillis',
  );
  @override
  late final GeneratedColumn<int> pausedAtMillis = GeneratedColumn<int>(
    'paused_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resumedAtMillisMeta = const VerificationMeta(
    'resumedAtMillis',
  );
  @override
  late final GeneratedColumn<int> resumedAtMillis = GeneratedColumn<int>(
    'resumed_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kickCountAtPauseMeta = const VerificationMeta(
    'kickCountAtPause',
  );
  @override
  late final GeneratedColumn<int> kickCountAtPause = GeneratedColumn<int>(
    'kick_count_at_pause',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    sessionId,
    pausedAtMillis,
    resumedAtMillis,
    kickCountAtPause,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pause_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PauseEventDto> instance, {
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
    if (data.containsKey('paused_at_millis')) {
      context.handle(
        _pausedAtMillisMeta,
        pausedAtMillis.isAcceptableOrUnknown(
          data['paused_at_millis']!,
          _pausedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pausedAtMillisMeta);
    }
    if (data.containsKey('resumed_at_millis')) {
      context.handle(
        _resumedAtMillisMeta,
        resumedAtMillis.isAcceptableOrUnknown(
          data['resumed_at_millis']!,
          _resumedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('kick_count_at_pause')) {
      context.handle(
        _kickCountAtPauseMeta,
        kickCountAtPause.isAcceptableOrUnknown(
          data['kick_count_at_pause']!,
          _kickCountAtPauseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kickCountAtPauseMeta);
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
  PauseEventDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PauseEventDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      pausedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_at_millis'],
      )!,
      resumedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resumed_at_millis'],
      ),
      kickCountAtPause: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kick_count_at_pause'],
      )!,
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
  $PauseEventsTable createAlias(String alias) {
    return $PauseEventsTable(attachedDatabase, alias);
  }
}

class PauseEventDto extends DataClass implements Insertable<PauseEventDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to parent session
  /// Cascade delete ensures pause events are removed when session is deleted
  final String sessionId;

  /// Timestamp when the session was paused (stored as millis since epoch)
  final int pausedAtMillis;

  /// Timestamp when the session was resumed (null if still paused or session ended while paused)
  /// Stored as millis since epoch for precision
  final int? resumedAtMillis;

  /// Number of kicks recorded BEFORE this pause started
  /// Used to determine which pauses should be excluded from time-to-10 calculation
  final int kickCountAtPause;

  /// Timestamp when record was created (stored as millis since epoch)
  final int createdAtMillis;

  /// Timestamp when record was last updated (stored as millis since epoch)
  final int updatedAtMillis;
  const PauseEventDto({
    required this.id,
    required this.sessionId,
    required this.pausedAtMillis,
    this.resumedAtMillis,
    required this.kickCountAtPause,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['paused_at_millis'] = Variable<int>(pausedAtMillis);
    if (!nullToAbsent || resumedAtMillis != null) {
      map['resumed_at_millis'] = Variable<int>(resumedAtMillis);
    }
    map['kick_count_at_pause'] = Variable<int>(kickCountAtPause);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  PauseEventsCompanion toCompanion(bool nullToAbsent) {
    return PauseEventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      pausedAtMillis: Value(pausedAtMillis),
      resumedAtMillis: resumedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(resumedAtMillis),
      kickCountAtPause: Value(kickCountAtPause),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory PauseEventDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PauseEventDto(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      pausedAtMillis: serializer.fromJson<int>(json['pausedAtMillis']),
      resumedAtMillis: serializer.fromJson<int?>(json['resumedAtMillis']),
      kickCountAtPause: serializer.fromJson<int>(json['kickCountAtPause']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'pausedAtMillis': serializer.toJson<int>(pausedAtMillis),
      'resumedAtMillis': serializer.toJson<int?>(resumedAtMillis),
      'kickCountAtPause': serializer.toJson<int>(kickCountAtPause),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  PauseEventDto copyWith({
    String? id,
    String? sessionId,
    int? pausedAtMillis,
    Value<int?> resumedAtMillis = const Value.absent(),
    int? kickCountAtPause,
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => PauseEventDto(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    pausedAtMillis: pausedAtMillis ?? this.pausedAtMillis,
    resumedAtMillis: resumedAtMillis.present
        ? resumedAtMillis.value
        : this.resumedAtMillis,
    kickCountAtPause: kickCountAtPause ?? this.kickCountAtPause,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  PauseEventDto copyWithCompanion(PauseEventsCompanion data) {
    return PauseEventDto(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      pausedAtMillis: data.pausedAtMillis.present
          ? data.pausedAtMillis.value
          : this.pausedAtMillis,
      resumedAtMillis: data.resumedAtMillis.present
          ? data.resumedAtMillis.value
          : this.resumedAtMillis,
      kickCountAtPause: data.kickCountAtPause.present
          ? data.kickCountAtPause.value
          : this.kickCountAtPause,
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
    return (StringBuffer('PauseEventDto(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('pausedAtMillis: $pausedAtMillis, ')
          ..write('resumedAtMillis: $resumedAtMillis, ')
          ..write('kickCountAtPause: $kickCountAtPause, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    pausedAtMillis,
    resumedAtMillis,
    kickCountAtPause,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PauseEventDto &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.pausedAtMillis == this.pausedAtMillis &&
          other.resumedAtMillis == this.resumedAtMillis &&
          other.kickCountAtPause == this.kickCountAtPause &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class PauseEventsCompanion extends UpdateCompanion<PauseEventDto> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> pausedAtMillis;
  final Value<int?> resumedAtMillis;
  final Value<int> kickCountAtPause;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const PauseEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.pausedAtMillis = const Value.absent(),
    this.resumedAtMillis = const Value.absent(),
    this.kickCountAtPause = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PauseEventsCompanion.insert({
    required String id,
    required String sessionId,
    required int pausedAtMillis,
    this.resumedAtMillis = const Value.absent(),
    required int kickCountAtPause,
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       pausedAtMillis = Value(pausedAtMillis),
       kickCountAtPause = Value(kickCountAtPause),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<PauseEventDto> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? pausedAtMillis,
    Expression<int>? resumedAtMillis,
    Expression<int>? kickCountAtPause,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (pausedAtMillis != null) 'paused_at_millis': pausedAtMillis,
      if (resumedAtMillis != null) 'resumed_at_millis': resumedAtMillis,
      if (kickCountAtPause != null) 'kick_count_at_pause': kickCountAtPause,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PauseEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? pausedAtMillis,
    Value<int?>? resumedAtMillis,
    Value<int>? kickCountAtPause,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return PauseEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      pausedAtMillis: pausedAtMillis ?? this.pausedAtMillis,
      resumedAtMillis: resumedAtMillis ?? this.resumedAtMillis,
      kickCountAtPause: kickCountAtPause ?? this.kickCountAtPause,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (pausedAtMillis.present) {
      map['paused_at_millis'] = Variable<int>(pausedAtMillis.value);
    }
    if (resumedAtMillis.present) {
      map['resumed_at_millis'] = Variable<int>(resumedAtMillis.value);
    }
    if (kickCountAtPause.present) {
      map['kick_count_at_pause'] = Variable<int>(kickCountAtPause.value);
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
    return (StringBuffer('PauseEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('pausedAtMillis: $pausedAtMillis, ')
          ..write('resumedAtMillis: $resumedAtMillis, ')
          ..write('kickCountAtPause: $kickCountAtPause, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BumpPhotosTable extends BumpPhotos
    with TableInfo<$BumpPhotosTable, BumpPhotoDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BumpPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pregnancyIdMeta = const VerificationMeta(
    'pregnancyId',
  );
  @override
  late final GeneratedColumn<String> pregnancyId = GeneratedColumn<String>(
    'pregnancy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekNumberMeta = const VerificationMeta(
    'weekNumber',
  );
  @override
  late final GeneratedColumn<int> weekNumber = GeneratedColumn<int>(
    'week_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _photoDateMillisMeta = const VerificationMeta(
    'photoDateMillis',
  );
  @override
  late final GeneratedColumn<int> photoDateMillis = GeneratedColumn<int>(
    'photo_date_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    pregnancyId,
    weekNumber,
    filePath,
    note,
    photoDateMillis,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bump_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<BumpPhotoDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pregnancy_id')) {
      context.handle(
        _pregnancyIdMeta,
        pregnancyId.isAcceptableOrUnknown(
          data['pregnancy_id']!,
          _pregnancyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pregnancyIdMeta);
    }
    if (data.containsKey('week_number')) {
      context.handle(
        _weekNumberMeta,
        weekNumber.isAcceptableOrUnknown(data['week_number']!, _weekNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_weekNumberMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('photo_date_millis')) {
      context.handle(
        _photoDateMillisMeta,
        photoDateMillis.isAcceptableOrUnknown(
          data['photo_date_millis']!,
          _photoDateMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_photoDateMillisMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pregnancyId, weekNumber},
  ];
  @override
  BumpPhotoDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BumpPhotoDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pregnancyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pregnancy_id'],
      )!,
      weekNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_number'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      photoDateMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_date_millis'],
      )!,
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
  $BumpPhotosTable createAlias(String alias) {
    return $BumpPhotosTable(attachedDatabase, alias);
  }
}

class BumpPhotoDto extends DataClass implements Insertable<BumpPhotoDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to Pregnancies table
  final String pregnancyId;

  /// Pregnancy week number (1-44)
  final int weekNumber;

  /// Local file path to the photo (nullable to support notes without photos)
  final String? filePath;

  /// Optional user note about this week
  final String? note;

  /// When the photo was taken/added (stored as millis since epoch)
  final int photoDateMillis;

  /// Timestamp when record was created (stored as millis since epoch)
  final int createdAtMillis;

  /// Timestamp when record was last updated (stored as millis since epoch)
  final int updatedAtMillis;
  const BumpPhotoDto({
    required this.id,
    required this.pregnancyId,
    required this.weekNumber,
    this.filePath,
    this.note,
    required this.photoDateMillis,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pregnancy_id'] = Variable<String>(pregnancyId);
    map['week_number'] = Variable<int>(weekNumber);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['photo_date_millis'] = Variable<int>(photoDateMillis);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  BumpPhotosCompanion toCompanion(bool nullToAbsent) {
    return BumpPhotosCompanion(
      id: Value(id),
      pregnancyId: Value(pregnancyId),
      weekNumber: Value(weekNumber),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoDateMillis: Value(photoDateMillis),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory BumpPhotoDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BumpPhotoDto(
      id: serializer.fromJson<String>(json['id']),
      pregnancyId: serializer.fromJson<String>(json['pregnancyId']),
      weekNumber: serializer.fromJson<int>(json['weekNumber']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      note: serializer.fromJson<String?>(json['note']),
      photoDateMillis: serializer.fromJson<int>(json['photoDateMillis']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pregnancyId': serializer.toJson<String>(pregnancyId),
      'weekNumber': serializer.toJson<int>(weekNumber),
      'filePath': serializer.toJson<String?>(filePath),
      'note': serializer.toJson<String?>(note),
      'photoDateMillis': serializer.toJson<int>(photoDateMillis),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  BumpPhotoDto copyWith({
    String? id,
    String? pregnancyId,
    int? weekNumber,
    Value<String?> filePath = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? photoDateMillis,
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => BumpPhotoDto(
    id: id ?? this.id,
    pregnancyId: pregnancyId ?? this.pregnancyId,
    weekNumber: weekNumber ?? this.weekNumber,
    filePath: filePath.present ? filePath.value : this.filePath,
    note: note.present ? note.value : this.note,
    photoDateMillis: photoDateMillis ?? this.photoDateMillis,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  BumpPhotoDto copyWithCompanion(BumpPhotosCompanion data) {
    return BumpPhotoDto(
      id: data.id.present ? data.id.value : this.id,
      pregnancyId: data.pregnancyId.present
          ? data.pregnancyId.value
          : this.pregnancyId,
      weekNumber: data.weekNumber.present
          ? data.weekNumber.value
          : this.weekNumber,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      note: data.note.present ? data.note.value : this.note,
      photoDateMillis: data.photoDateMillis.present
          ? data.photoDateMillis.value
          : this.photoDateMillis,
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
    return (StringBuffer('BumpPhotoDto(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('filePath: $filePath, ')
          ..write('note: $note, ')
          ..write('photoDateMillis: $photoDateMillis, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pregnancyId,
    weekNumber,
    filePath,
    note,
    photoDateMillis,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BumpPhotoDto &&
          other.id == this.id &&
          other.pregnancyId == this.pregnancyId &&
          other.weekNumber == this.weekNumber &&
          other.filePath == this.filePath &&
          other.note == this.note &&
          other.photoDateMillis == this.photoDateMillis &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class BumpPhotosCompanion extends UpdateCompanion<BumpPhotoDto> {
  final Value<String> id;
  final Value<String> pregnancyId;
  final Value<int> weekNumber;
  final Value<String?> filePath;
  final Value<String?> note;
  final Value<int> photoDateMillis;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const BumpPhotosCompanion({
    this.id = const Value.absent(),
    this.pregnancyId = const Value.absent(),
    this.weekNumber = const Value.absent(),
    this.filePath = const Value.absent(),
    this.note = const Value.absent(),
    this.photoDateMillis = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BumpPhotosCompanion.insert({
    required String id,
    required String pregnancyId,
    required int weekNumber,
    this.filePath = const Value.absent(),
    this.note = const Value.absent(),
    required int photoDateMillis,
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pregnancyId = Value(pregnancyId),
       weekNumber = Value(weekNumber),
       photoDateMillis = Value(photoDateMillis),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<BumpPhotoDto> custom({
    Expression<String>? id,
    Expression<String>? pregnancyId,
    Expression<int>? weekNumber,
    Expression<String>? filePath,
    Expression<String>? note,
    Expression<int>? photoDateMillis,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pregnancyId != null) 'pregnancy_id': pregnancyId,
      if (weekNumber != null) 'week_number': weekNumber,
      if (filePath != null) 'file_path': filePath,
      if (note != null) 'note': note,
      if (photoDateMillis != null) 'photo_date_millis': photoDateMillis,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BumpPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? pregnancyId,
    Value<int>? weekNumber,
    Value<String?>? filePath,
    Value<String?>? note,
    Value<int>? photoDateMillis,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return BumpPhotosCompanion(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      weekNumber: weekNumber ?? this.weekNumber,
      filePath: filePath ?? this.filePath,
      note: note ?? this.note,
      photoDateMillis: photoDateMillis ?? this.photoDateMillis,
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
    if (pregnancyId.present) {
      map['pregnancy_id'] = Variable<String>(pregnancyId.value);
    }
    if (weekNumber.present) {
      map['week_number'] = Variable<int>(weekNumber.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photoDateMillis.present) {
      map['photo_date_millis'] = Variable<int>(photoDateMillis.value);
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
    return (StringBuffer('BumpPhotosCompanion(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('filePath: $filePath, ')
          ..write('note: $note, ')
          ..write('photoDateMillis: $photoDateMillis, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $PregnanciesTable pregnancies = $PregnanciesTable(this);
  late final $KickSessionsTable kickSessions = $KickSessionsTable(this);
  late final $KicksTable kicks = $KicksTable(this);
  late final $PauseEventsTable pauseEvents = $PauseEventsTable(this);
  late final $BumpPhotosTable bumpPhotos = $BumpPhotosTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final PregnancyDao pregnancyDao = PregnancyDao(this as AppDatabase);
  late final KickCounterDao kickCounterDao = KickCounterDao(
    this as AppDatabase,
  );
  late final BumpPhotoDao bumpPhotoDao = BumpPhotoDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    pregnancies,
    kickSessions,
    kicks,
    pauseEvents,
    bumpPhotos,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pregnancies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'kick_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('kicks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'kick_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pause_events', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String authId,
      required String email,
      required String firstName,
      required String lastName,
      required int dateOfBirthMillis,
      required String gender,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<bool> isSynced,
      required String databasePath,
      required String encryptionKeyId,
      required int lastAccessedAtMillis,
      required int schemaVersion,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> authId,
      Value<String> email,
      Value<String> firstName,
      Value<String> lastName,
      Value<int> dateOfBirthMillis,
      Value<String> gender,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<bool> isSynced,
      Value<String> databasePath,
      Value<String> encryptionKeyId,
      Value<int> lastAccessedAtMillis,
      Value<int> schemaVersion,
      Value<int> rowid,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileDto> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PregnanciesTable, List<PregnancyDto>>
  _pregnanciesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pregnancies,
    aliasName: $_aliasNameGenerator(db.userProfiles.id, db.pregnancies.userId),
  );

  $$PregnanciesTableProcessedTableManager get pregnanciesRefs {
    final manager = $$PregnanciesTableTableManager(
      $_db,
      $_db.pregnancies,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pregnanciesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get authId => $composableBuilder(
    column: $table.authId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateOfBirthMillis => $composableBuilder(
    column: $table.dateOfBirthMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
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

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get databasePath => $composableBuilder(
    column: $table.databasePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptionKeyId => $composableBuilder(
    column: $table.encryptionKeyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAtMillis => $composableBuilder(
    column: $table.lastAccessedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pregnanciesRefs(
    Expression<bool> Function($$PregnanciesTableFilterComposer f) f,
  ) {
    final $$PregnanciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pregnancies,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PregnanciesTableFilterComposer(
            $db: $db,
            $table: $db.pregnancies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get authId => $composableBuilder(
    column: $table.authId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateOfBirthMillis => $composableBuilder(
    column: $table.dateOfBirthMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
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

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get databasePath => $composableBuilder(
    column: $table.databasePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptionKeyId => $composableBuilder(
    column: $table.encryptionKeyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAtMillis => $composableBuilder(
    column: $table.lastAccessedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authId =>
      $composableBuilder(column: $table.authId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<int> get dateOfBirthMillis => $composableBuilder(
    column: $table.dateOfBirthMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get databasePath => $composableBuilder(
    column: $table.databasePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptionKeyId => $composableBuilder(
    column: $table.encryptionKeyId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAtMillis => $composableBuilder(
    column: $table.lastAccessedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  Expression<T> pregnanciesRefs<T extends Object>(
    Expression<T> Function($$PregnanciesTableAnnotationComposer a) f,
  ) {
    final $$PregnanciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pregnancies,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PregnanciesTableAnnotationComposer(
            $db: $db,
            $table: $db.pregnancies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileDto,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfileDto, $$UserProfilesTableReferences),
          UserProfileDto,
          PrefetchHooks Function({bool pregnanciesRefs})
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> authId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<int> dateOfBirthMillis = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> databasePath = const Value.absent(),
                Value<String> encryptionKeyId = const Value.absent(),
                Value<int> lastAccessedAtMillis = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                authId: authId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                dateOfBirthMillis: dateOfBirthMillis,
                gender: gender,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                isSynced: isSynced,
                databasePath: databasePath,
                encryptionKeyId: encryptionKeyId,
                lastAccessedAtMillis: lastAccessedAtMillis,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String authId,
                required String email,
                required String firstName,
                required String lastName,
                required int dateOfBirthMillis,
                required String gender,
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<bool> isSynced = const Value.absent(),
                required String databasePath,
                required String encryptionKeyId,
                required int lastAccessedAtMillis,
                required int schemaVersion,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                authId: authId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                dateOfBirthMillis: dateOfBirthMillis,
                gender: gender,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                isSynced: isSynced,
                databasePath: databasePath,
                encryptionKeyId: encryptionKeyId,
                lastAccessedAtMillis: lastAccessedAtMillis,
                schemaVersion: schemaVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pregnanciesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (pregnanciesRefs) db.pregnancies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pregnanciesRefs)
                    await $_getPrefetchedData<
                      UserProfileDto,
                      $UserProfilesTable,
                      PregnancyDto
                    >(
                      currentTable: table,
                      referencedTable: $$UserProfilesTableReferences
                          ._pregnanciesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).pregnanciesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileDto,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfileDto, $$UserProfilesTableReferences),
      UserProfileDto,
      PrefetchHooks Function({bool pregnanciesRefs})
    >;
typedef $$PregnanciesTableCreateCompanionBuilder =
    PregnanciesCompanion Function({
      required String id,
      required String userId,
      required int startDateMillis,
      required int dueDateMillis,
      Value<String?> selectedHospitalId,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$PregnanciesTableUpdateCompanionBuilder =
    PregnanciesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> startDateMillis,
      Value<int> dueDateMillis,
      Value<String?> selectedHospitalId,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

final class $$PregnanciesTableReferences
    extends BaseReferences<_$AppDatabase, $PregnanciesTable, PregnancyDto> {
  $$PregnanciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.pregnancies.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PregnanciesTableFilterComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableFilterComposer({
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

  ColumnFilters<int> get startDateMillis => $composableBuilder(
    column: $table.startDateMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDateMillis => $composableBuilder(
    column: $table.dueDateMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedHospitalId => $composableBuilder(
    column: $table.selectedHospitalId,
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

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PregnanciesTableOrderingComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableOrderingComposer({
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

  ColumnOrderings<int> get startDateMillis => $composableBuilder(
    column: $table.startDateMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDateMillis => $composableBuilder(
    column: $table.dueDateMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedHospitalId => $composableBuilder(
    column: $table.selectedHospitalId,
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

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PregnanciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startDateMillis => $composableBuilder(
    column: $table.startDateMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDateMillis => $composableBuilder(
    column: $table.dueDateMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedHospitalId => $composableBuilder(
    column: $table.selectedHospitalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PregnanciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PregnanciesTable,
          PregnancyDto,
          $$PregnanciesTableFilterComposer,
          $$PregnanciesTableOrderingComposer,
          $$PregnanciesTableAnnotationComposer,
          $$PregnanciesTableCreateCompanionBuilder,
          $$PregnanciesTableUpdateCompanionBuilder,
          (PregnancyDto, $$PregnanciesTableReferences),
          PregnancyDto,
          PrefetchHooks Function({bool userId})
        > {
  $$PregnanciesTableTableManager(_$AppDatabase db, $PregnanciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PregnanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PregnanciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PregnanciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> startDateMillis = const Value.absent(),
                Value<int> dueDateMillis = const Value.absent(),
                Value<String?> selectedHospitalId = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PregnanciesCompanion(
                id: id,
                userId: userId,
                startDateMillis: startDateMillis,
                dueDateMillis: dueDateMillis,
                selectedHospitalId: selectedHospitalId,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int startDateMillis,
                required int dueDateMillis,
                Value<String?> selectedHospitalId = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => PregnanciesCompanion.insert(
                id: id,
                userId: userId,
                startDateMillis: startDateMillis,
                dueDateMillis: dueDateMillis,
                selectedHospitalId: selectedHospitalId,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PregnanciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$PregnanciesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$PregnanciesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PregnanciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PregnanciesTable,
      PregnancyDto,
      $$PregnanciesTableFilterComposer,
      $$PregnanciesTableOrderingComposer,
      $$PregnanciesTableAnnotationComposer,
      $$PregnanciesTableCreateCompanionBuilder,
      $$PregnanciesTableUpdateCompanionBuilder,
      (PregnancyDto, $$PregnanciesTableReferences),
      PregnancyDto,
      PrefetchHooks Function({bool userId})
    >;
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

final class $$KickSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $KickSessionsTable, KickSessionDto> {
  $$KickSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$KicksTable, List<KickDto>> _kicksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.kicks,
    aliasName: $_aliasNameGenerator(db.kickSessions.id, db.kicks.sessionId),
  );

  $$KicksTableProcessedTableManager get kicksRefs {
    final manager = $$KicksTableTableManager(
      $_db,
      $_db.kicks,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_kicksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PauseEventsTable, List<PauseEventDto>>
  _pauseEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pauseEvents,
    aliasName: $_aliasNameGenerator(
      db.kickSessions.id,
      db.pauseEvents.sessionId,
    ),
  );

  $$PauseEventsTableProcessedTableManager get pauseEventsRefs {
    final manager = $$PauseEventsTableTableManager(
      $_db,
      $_db.pauseEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pauseEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  Expression<bool> kicksRefs(
    Expression<bool> Function($$KicksTableFilterComposer f) f,
  ) {
    final $$KicksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.kicks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KicksTableFilterComposer(
            $db: $db,
            $table: $db.kicks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pauseEventsRefs(
    Expression<bool> Function($$PauseEventsTableFilterComposer f) f,
  ) {
    final $$PauseEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauseEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PauseEventsTableFilterComposer(
            $db: $db,
            $table: $db.pauseEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  Expression<T> kicksRefs<T extends Object>(
    Expression<T> Function($$KicksTableAnnotationComposer a) f,
  ) {
    final $$KicksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.kicks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KicksTableAnnotationComposer(
            $db: $db,
            $table: $db.kicks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pauseEventsRefs<T extends Object>(
    Expression<T> Function($$PauseEventsTableAnnotationComposer a) f,
  ) {
    final $$PauseEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pauseEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PauseEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.pauseEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (KickSessionDto, $$KickSessionsTableReferences),
          KickSessionDto,
          PrefetchHooks Function({bool kicksRefs, bool pauseEventsRefs})
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
              .map(
                (e) => (
                  e.readTable(table),
                  $$KickSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({kicksRefs = false, pauseEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (kicksRefs) db.kicks,
                    if (pauseEventsRefs) db.pauseEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (kicksRefs)
                        await $_getPrefetchedData<
                          KickSessionDto,
                          $KickSessionsTable,
                          KickDto
                        >(
                          currentTable: table,
                          referencedTable: $$KickSessionsTableReferences
                              ._kicksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KickSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).kicksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pauseEventsRefs)
                        await $_getPrefetchedData<
                          KickSessionDto,
                          $KickSessionsTable,
                          PauseEventDto
                        >(
                          currentTable: table,
                          referencedTable: $$KickSessionsTableReferences
                              ._pauseEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KickSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).pauseEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (KickSessionDto, $$KickSessionsTableReferences),
      KickSessionDto,
      PrefetchHooks Function({bool kicksRefs, bool pauseEventsRefs})
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

final class $$KicksTableReferences
    extends BaseReferences<_$AppDatabase, $KicksTable, KickDto> {
  $$KicksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KickSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.kickSessions.createAlias(
        $_aliasNameGenerator(db.kicks.sessionId, db.kickSessions.id),
      );

  $$KickSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$KickSessionsTableTableManager(
      $_db,
      $_db.kickSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  $$KickSessionsTableFilterComposer get sessionId {
    final $$KickSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableFilterComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$KickSessionsTableOrderingComposer get sessionId {
    final $$KickSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$KickSessionsTableAnnotationComposer get sessionId {
    final $$KickSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (KickDto, $$KicksTableReferences),
          KickDto,
          PrefetchHooks Function({bool sessionId})
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
              .map(
                (e) =>
                    (e.readTable(table), $$KicksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$KicksTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$KicksTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (KickDto, $$KicksTableReferences),
      KickDto,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$PauseEventsTableCreateCompanionBuilder =
    PauseEventsCompanion Function({
      required String id,
      required String sessionId,
      required int pausedAtMillis,
      Value<int?> resumedAtMillis,
      required int kickCountAtPause,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$PauseEventsTableUpdateCompanionBuilder =
    PauseEventsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> pausedAtMillis,
      Value<int?> resumedAtMillis,
      Value<int> kickCountAtPause,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

final class $$PauseEventsTableReferences
    extends BaseReferences<_$AppDatabase, $PauseEventsTable, PauseEventDto> {
  $$PauseEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KickSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.kickSessions.createAlias(
        $_aliasNameGenerator(db.pauseEvents.sessionId, db.kickSessions.id),
      );

  $$KickSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$KickSessionsTableTableManager(
      $_db,
      $_db.kickSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PauseEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PauseEventsTable> {
  $$PauseEventsTableFilterComposer({
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

  ColumnFilters<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resumedAtMillis => $composableBuilder(
    column: $table.resumedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kickCountAtPause => $composableBuilder(
    column: $table.kickCountAtPause,
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

  $$KickSessionsTableFilterComposer get sessionId {
    final $$KickSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableFilterComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PauseEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PauseEventsTable> {
  $$PauseEventsTableOrderingComposer({
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

  ColumnOrderings<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resumedAtMillis => $composableBuilder(
    column: $table.resumedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kickCountAtPause => $composableBuilder(
    column: $table.kickCountAtPause,
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

  $$KickSessionsTableOrderingComposer get sessionId {
    final $$KickSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PauseEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PauseEventsTable> {
  $$PauseEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pausedAtMillis => $composableBuilder(
    column: $table.pausedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resumedAtMillis => $composableBuilder(
    column: $table.resumedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kickCountAtPause => $composableBuilder(
    column: $table.kickCountAtPause,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  $$KickSessionsTableAnnotationComposer get sessionId {
    final $$KickSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.kickSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KickSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.kickSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PauseEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PauseEventsTable,
          PauseEventDto,
          $$PauseEventsTableFilterComposer,
          $$PauseEventsTableOrderingComposer,
          $$PauseEventsTableAnnotationComposer,
          $$PauseEventsTableCreateCompanionBuilder,
          $$PauseEventsTableUpdateCompanionBuilder,
          (PauseEventDto, $$PauseEventsTableReferences),
          PauseEventDto,
          PrefetchHooks Function({bool sessionId})
        > {
  $$PauseEventsTableTableManager(_$AppDatabase db, $PauseEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PauseEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PauseEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PauseEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> pausedAtMillis = const Value.absent(),
                Value<int?> resumedAtMillis = const Value.absent(),
                Value<int> kickCountAtPause = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PauseEventsCompanion(
                id: id,
                sessionId: sessionId,
                pausedAtMillis: pausedAtMillis,
                resumedAtMillis: resumedAtMillis,
                kickCountAtPause: kickCountAtPause,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int pausedAtMillis,
                Value<int?> resumedAtMillis = const Value.absent(),
                required int kickCountAtPause,
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => PauseEventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                pausedAtMillis: pausedAtMillis,
                resumedAtMillis: resumedAtMillis,
                kickCountAtPause: kickCountAtPause,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PauseEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$PauseEventsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$PauseEventsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PauseEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PauseEventsTable,
      PauseEventDto,
      $$PauseEventsTableFilterComposer,
      $$PauseEventsTableOrderingComposer,
      $$PauseEventsTableAnnotationComposer,
      $$PauseEventsTableCreateCompanionBuilder,
      $$PauseEventsTableUpdateCompanionBuilder,
      (PauseEventDto, $$PauseEventsTableReferences),
      PauseEventDto,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$BumpPhotosTableCreateCompanionBuilder =
    BumpPhotosCompanion Function({
      required String id,
      required String pregnancyId,
      required int weekNumber,
      Value<String?> filePath,
      Value<String?> note,
      required int photoDateMillis,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$BumpPhotosTableUpdateCompanionBuilder =
    BumpPhotosCompanion Function({
      Value<String> id,
      Value<String> pregnancyId,
      Value<int> weekNumber,
      Value<String?> filePath,
      Value<String?> note,
      Value<int> photoDateMillis,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$BumpPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $BumpPhotosTable> {
  $$BumpPhotosTableFilterComposer({
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

  ColumnFilters<String> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoDateMillis => $composableBuilder(
    column: $table.photoDateMillis,
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

class $$BumpPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $BumpPhotosTable> {
  $$BumpPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoDateMillis => $composableBuilder(
    column: $table.photoDateMillis,
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

class $$BumpPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BumpPhotosTable> {
  $$BumpPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get photoDateMillis => $composableBuilder(
    column: $table.photoDateMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$BumpPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BumpPhotosTable,
          BumpPhotoDto,
          $$BumpPhotosTableFilterComposer,
          $$BumpPhotosTableOrderingComposer,
          $$BumpPhotosTableAnnotationComposer,
          $$BumpPhotosTableCreateCompanionBuilder,
          $$BumpPhotosTableUpdateCompanionBuilder,
          (
            BumpPhotoDto,
            BaseReferences<_$AppDatabase, $BumpPhotosTable, BumpPhotoDto>,
          ),
          BumpPhotoDto,
          PrefetchHooks Function()
        > {
  $$BumpPhotosTableTableManager(_$AppDatabase db, $BumpPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BumpPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BumpPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BumpPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pregnancyId = const Value.absent(),
                Value<int> weekNumber = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> photoDateMillis = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BumpPhotosCompanion(
                id: id,
                pregnancyId: pregnancyId,
                weekNumber: weekNumber,
                filePath: filePath,
                note: note,
                photoDateMillis: photoDateMillis,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pregnancyId,
                required int weekNumber,
                Value<String?> filePath = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int photoDateMillis,
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => BumpPhotosCompanion.insert(
                id: id,
                pregnancyId: pregnancyId,
                weekNumber: weekNumber,
                filePath: filePath,
                note: note,
                photoDateMillis: photoDateMillis,
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

typedef $$BumpPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BumpPhotosTable,
      BumpPhotoDto,
      $$BumpPhotosTableFilterComposer,
      $$BumpPhotosTableOrderingComposer,
      $$BumpPhotosTableAnnotationComposer,
      $$BumpPhotosTableCreateCompanionBuilder,
      $$BumpPhotosTableUpdateCompanionBuilder,
      (
        BumpPhotoDto,
        BaseReferences<_$AppDatabase, $BumpPhotosTable, BumpPhotoDto>,
      ),
      BumpPhotoDto,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$PregnanciesTableTableManager get pregnancies =>
      $$PregnanciesTableTableManager(_db, _db.pregnancies);
  $$KickSessionsTableTableManager get kickSessions =>
      $$KickSessionsTableTableManager(_db, _db.kickSessions);
  $$KicksTableTableManager get kicks =>
      $$KicksTableTableManager(_db, _db.kicks);
  $$PauseEventsTableTableManager get pauseEvents =>
      $$PauseEventsTableTableManager(_db, _db.pauseEvents);
  $$BumpPhotosTableTableManager get bumpPhotos =>
      $$BumpPhotosTableTableManager(_db, _db.bumpPhotos);
}
