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
  static const VerificationMeta _postcodeMeta = const VerificationMeta(
    'postcode',
  );
  @override
  late final GeneratedColumn<String> postcode = GeneratedColumn<String>(
    'postcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    postcode,
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
    if (data.containsKey('postcode')) {
      context.handle(
        _postcodeMeta,
        postcode.isAcceptableOrUnknown(data['postcode']!, _postcodeMeta),
      );
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
      postcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postcode'],
      ),
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

  /// User's postcode for hospital search (optional)
  final String? postcode;
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
    this.postcode,
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
    if (!nullToAbsent || postcode != null) {
      map['postcode'] = Variable<String>(postcode);
    }
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
      postcode: postcode == null && nullToAbsent
          ? const Value.absent()
          : Value(postcode),
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
      postcode: serializer.fromJson<String?>(json['postcode']),
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
      'postcode': serializer.toJson<String?>(postcode),
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
    Value<String?> postcode = const Value.absent(),
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
    postcode: postcode.present ? postcode.value : this.postcode,
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
      postcode: data.postcode.present ? data.postcode.value : this.postcode,
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
          ..write('schemaVersion: $schemaVersion, ')
          ..write('postcode: $postcode')
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
    postcode,
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
          other.schemaVersion == this.schemaVersion &&
          other.postcode == this.postcode);
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
  final Value<String?> postcode;
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
    this.postcode = const Value.absent(),
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
    this.postcode = const Value.absent(),
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
    Expression<String>? postcode,
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
      if (postcode != null) 'postcode': postcode,
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
    Value<String?>? postcode,
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
      postcode: postcode ?? this.postcode,
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
    if (postcode.present) {
      map['postcode'] = Variable<String>(postcode.value);
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
          ..write('postcode: $postcode, ')
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

class $ContractionSessionsTable extends ContractionSessions
    with TableInfo<$ContractionSessionsTable, ContractionSessionDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractionSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _achievedDurationMeta = const VerificationMeta(
    'achievedDuration',
  );
  @override
  late final GeneratedColumn<bool> achievedDuration = GeneratedColumn<bool>(
    'achieved_duration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("achieved_duration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationAchievedAtMillisMeta =
      const VerificationMeta('durationAchievedAtMillis');
  @override
  late final GeneratedColumn<int> durationAchievedAtMillis =
      GeneratedColumn<int>(
        'duration_achieved_at_millis',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _achievedFrequencyMeta = const VerificationMeta(
    'achievedFrequency',
  );
  @override
  late final GeneratedColumn<bool> achievedFrequency = GeneratedColumn<bool>(
    'achieved_frequency',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("achieved_frequency" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _frequencyAchievedAtMillisMeta =
      const VerificationMeta('frequencyAchievedAtMillis');
  @override
  late final GeneratedColumn<int> frequencyAchievedAtMillis =
      GeneratedColumn<int>(
        'frequency_achieved_at_millis',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _achievedConsistencyMeta =
      const VerificationMeta('achievedConsistency');
  @override
  late final GeneratedColumn<bool> achievedConsistency = GeneratedColumn<bool>(
    'achieved_consistency',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("achieved_consistency" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _consistencyAchievedAtMillisMeta =
      const VerificationMeta('consistencyAchievedAtMillis');
  @override
  late final GeneratedColumn<int> consistencyAchievedAtMillis =
      GeneratedColumn<int>(
        'consistency_achieved_at_millis',
        aliasedName,
        true,
        type: DriftSqlType.int,
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
    achievedDuration,
    durationAchievedAtMillis,
    achievedFrequency,
    frequencyAchievedAtMillis,
    achievedConsistency,
    consistencyAchievedAtMillis,
    note,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contraction_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractionSessionDto> instance, {
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
    if (data.containsKey('achieved_duration')) {
      context.handle(
        _achievedDurationMeta,
        achievedDuration.isAcceptableOrUnknown(
          data['achieved_duration']!,
          _achievedDurationMeta,
        ),
      );
    }
    if (data.containsKey('duration_achieved_at_millis')) {
      context.handle(
        _durationAchievedAtMillisMeta,
        durationAchievedAtMillis.isAcceptableOrUnknown(
          data['duration_achieved_at_millis']!,
          _durationAchievedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('achieved_frequency')) {
      context.handle(
        _achievedFrequencyMeta,
        achievedFrequency.isAcceptableOrUnknown(
          data['achieved_frequency']!,
          _achievedFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('frequency_achieved_at_millis')) {
      context.handle(
        _frequencyAchievedAtMillisMeta,
        frequencyAchievedAtMillis.isAcceptableOrUnknown(
          data['frequency_achieved_at_millis']!,
          _frequencyAchievedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('achieved_consistency')) {
      context.handle(
        _achievedConsistencyMeta,
        achievedConsistency.isAcceptableOrUnknown(
          data['achieved_consistency']!,
          _achievedConsistencyMeta,
        ),
      );
    }
    if (data.containsKey('consistency_achieved_at_millis')) {
      context.handle(
        _consistencyAchievedAtMillisMeta,
        consistencyAchievedAtMillis.isAcceptableOrUnknown(
          data['consistency_achieved_at_millis']!,
          _consistencyAchievedAtMillisMeta,
        ),
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
  ContractionSessionDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractionSessionDto(
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
      achievedDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}achieved_duration'],
      )!,
      durationAchievedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_achieved_at_millis'],
      ),
      achievedFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}achieved_frequency'],
      )!,
      frequencyAchievedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_achieved_at_millis'],
      ),
      achievedConsistency: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}achieved_consistency'],
      )!,
      consistencyAchievedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consistency_achieved_at_millis'],
      ),
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
  $ContractionSessionsTable createAlias(String alias) {
    return $ContractionSessionsTable(attachedDatabase, alias);
  }
}

class ContractionSessionDto extends DataClass
    implements Insertable<ContractionSessionDto> {
  /// Unique identifier (UUID)
  final String id;

  /// When the session started (stored as millis since epoch for precision)
  final int startTimeMillis;

  /// When the session ended (null if still active)
  final int? endTimeMillis;

  /// Whether this session is currently active
  /// Active sessions appear in the UI and prevent new session creation
  final bool isActive;

  /// Whether duration criterion achieved (contractions >= 1 min)
  final bool achievedDuration;

  /// When duration criterion was first achieved
  final int? durationAchievedAtMillis;

  /// Whether frequency criterion achieved (contractions <= 5 min apart)
  final bool achievedFrequency;

  /// When frequency criterion was first achieved
  final int? frequencyAchievedAtMillis;

  /// Whether consistency criterion achieved (pattern for 1 hour)
  final bool achievedConsistency;

  /// When consistency criterion was first achieved
  final int? consistencyAchievedAtMillis;

  /// Optional encrypted note attached to this session
  /// Users can add personal observations about the session
  final String? note;

  /// Timestamp when record was created (stored as millis since epoch)
  final int createdAtMillis;

  /// Timestamp when record was last updated (stored as millis since epoch)
  final int updatedAtMillis;
  const ContractionSessionDto({
    required this.id,
    required this.startTimeMillis,
    this.endTimeMillis,
    required this.isActive,
    required this.achievedDuration,
    this.durationAchievedAtMillis,
    required this.achievedFrequency,
    this.frequencyAchievedAtMillis,
    required this.achievedConsistency,
    this.consistencyAchievedAtMillis,
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
    map['achieved_duration'] = Variable<bool>(achievedDuration);
    if (!nullToAbsent || durationAchievedAtMillis != null) {
      map['duration_achieved_at_millis'] = Variable<int>(
        durationAchievedAtMillis,
      );
    }
    map['achieved_frequency'] = Variable<bool>(achievedFrequency);
    if (!nullToAbsent || frequencyAchievedAtMillis != null) {
      map['frequency_achieved_at_millis'] = Variable<int>(
        frequencyAchievedAtMillis,
      );
    }
    map['achieved_consistency'] = Variable<bool>(achievedConsistency);
    if (!nullToAbsent || consistencyAchievedAtMillis != null) {
      map['consistency_achieved_at_millis'] = Variable<int>(
        consistencyAchievedAtMillis,
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ContractionSessionsCompanion toCompanion(bool nullToAbsent) {
    return ContractionSessionsCompanion(
      id: Value(id),
      startTimeMillis: Value(startTimeMillis),
      endTimeMillis: endTimeMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeMillis),
      isActive: Value(isActive),
      achievedDuration: Value(achievedDuration),
      durationAchievedAtMillis: durationAchievedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(durationAchievedAtMillis),
      achievedFrequency: Value(achievedFrequency),
      frequencyAchievedAtMillis:
          frequencyAchievedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyAchievedAtMillis),
      achievedConsistency: Value(achievedConsistency),
      consistencyAchievedAtMillis:
          consistencyAchievedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(consistencyAchievedAtMillis),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ContractionSessionDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractionSessionDto(
      id: serializer.fromJson<String>(json['id']),
      startTimeMillis: serializer.fromJson<int>(json['startTimeMillis']),
      endTimeMillis: serializer.fromJson<int?>(json['endTimeMillis']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      achievedDuration: serializer.fromJson<bool>(json['achievedDuration']),
      durationAchievedAtMillis: serializer.fromJson<int?>(
        json['durationAchievedAtMillis'],
      ),
      achievedFrequency: serializer.fromJson<bool>(json['achievedFrequency']),
      frequencyAchievedAtMillis: serializer.fromJson<int?>(
        json['frequencyAchievedAtMillis'],
      ),
      achievedConsistency: serializer.fromJson<bool>(
        json['achievedConsistency'],
      ),
      consistencyAchievedAtMillis: serializer.fromJson<int?>(
        json['consistencyAchievedAtMillis'],
      ),
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
      'achievedDuration': serializer.toJson<bool>(achievedDuration),
      'durationAchievedAtMillis': serializer.toJson<int?>(
        durationAchievedAtMillis,
      ),
      'achievedFrequency': serializer.toJson<bool>(achievedFrequency),
      'frequencyAchievedAtMillis': serializer.toJson<int?>(
        frequencyAchievedAtMillis,
      ),
      'achievedConsistency': serializer.toJson<bool>(achievedConsistency),
      'consistencyAchievedAtMillis': serializer.toJson<int?>(
        consistencyAchievedAtMillis,
      ),
      'note': serializer.toJson<String?>(note),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ContractionSessionDto copyWith({
    String? id,
    int? startTimeMillis,
    Value<int?> endTimeMillis = const Value.absent(),
    bool? isActive,
    bool? achievedDuration,
    Value<int?> durationAchievedAtMillis = const Value.absent(),
    bool? achievedFrequency,
    Value<int?> frequencyAchievedAtMillis = const Value.absent(),
    bool? achievedConsistency,
    Value<int?> consistencyAchievedAtMillis = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => ContractionSessionDto(
    id: id ?? this.id,
    startTimeMillis: startTimeMillis ?? this.startTimeMillis,
    endTimeMillis: endTimeMillis.present
        ? endTimeMillis.value
        : this.endTimeMillis,
    isActive: isActive ?? this.isActive,
    achievedDuration: achievedDuration ?? this.achievedDuration,
    durationAchievedAtMillis: durationAchievedAtMillis.present
        ? durationAchievedAtMillis.value
        : this.durationAchievedAtMillis,
    achievedFrequency: achievedFrequency ?? this.achievedFrequency,
    frequencyAchievedAtMillis: frequencyAchievedAtMillis.present
        ? frequencyAchievedAtMillis.value
        : this.frequencyAchievedAtMillis,
    achievedConsistency: achievedConsistency ?? this.achievedConsistency,
    consistencyAchievedAtMillis: consistencyAchievedAtMillis.present
        ? consistencyAchievedAtMillis.value
        : this.consistencyAchievedAtMillis,
    note: note.present ? note.value : this.note,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ContractionSessionDto copyWithCompanion(ContractionSessionsCompanion data) {
    return ContractionSessionDto(
      id: data.id.present ? data.id.value : this.id,
      startTimeMillis: data.startTimeMillis.present
          ? data.startTimeMillis.value
          : this.startTimeMillis,
      endTimeMillis: data.endTimeMillis.present
          ? data.endTimeMillis.value
          : this.endTimeMillis,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      achievedDuration: data.achievedDuration.present
          ? data.achievedDuration.value
          : this.achievedDuration,
      durationAchievedAtMillis: data.durationAchievedAtMillis.present
          ? data.durationAchievedAtMillis.value
          : this.durationAchievedAtMillis,
      achievedFrequency: data.achievedFrequency.present
          ? data.achievedFrequency.value
          : this.achievedFrequency,
      frequencyAchievedAtMillis: data.frequencyAchievedAtMillis.present
          ? data.frequencyAchievedAtMillis.value
          : this.frequencyAchievedAtMillis,
      achievedConsistency: data.achievedConsistency.present
          ? data.achievedConsistency.value
          : this.achievedConsistency,
      consistencyAchievedAtMillis: data.consistencyAchievedAtMillis.present
          ? data.consistencyAchievedAtMillis.value
          : this.consistencyAchievedAtMillis,
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
    return (StringBuffer('ContractionSessionDto(')
          ..write('id: $id, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('isActive: $isActive, ')
          ..write('achievedDuration: $achievedDuration, ')
          ..write('durationAchievedAtMillis: $durationAchievedAtMillis, ')
          ..write('achievedFrequency: $achievedFrequency, ')
          ..write('frequencyAchievedAtMillis: $frequencyAchievedAtMillis, ')
          ..write('achievedConsistency: $achievedConsistency, ')
          ..write('consistencyAchievedAtMillis: $consistencyAchievedAtMillis, ')
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
    achievedDuration,
    durationAchievedAtMillis,
    achievedFrequency,
    frequencyAchievedAtMillis,
    achievedConsistency,
    consistencyAchievedAtMillis,
    note,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractionSessionDto &&
          other.id == this.id &&
          other.startTimeMillis == this.startTimeMillis &&
          other.endTimeMillis == this.endTimeMillis &&
          other.isActive == this.isActive &&
          other.achievedDuration == this.achievedDuration &&
          other.durationAchievedAtMillis == this.durationAchievedAtMillis &&
          other.achievedFrequency == this.achievedFrequency &&
          other.frequencyAchievedAtMillis == this.frequencyAchievedAtMillis &&
          other.achievedConsistency == this.achievedConsistency &&
          other.consistencyAchievedAtMillis ==
              this.consistencyAchievedAtMillis &&
          other.note == this.note &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ContractionSessionsCompanion
    extends UpdateCompanion<ContractionSessionDto> {
  final Value<String> id;
  final Value<int> startTimeMillis;
  final Value<int?> endTimeMillis;
  final Value<bool> isActive;
  final Value<bool> achievedDuration;
  final Value<int?> durationAchievedAtMillis;
  final Value<bool> achievedFrequency;
  final Value<int?> frequencyAchievedAtMillis;
  final Value<bool> achievedConsistency;
  final Value<int?> consistencyAchievedAtMillis;
  final Value<String?> note;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ContractionSessionsCompanion({
    this.id = const Value.absent(),
    this.startTimeMillis = const Value.absent(),
    this.endTimeMillis = const Value.absent(),
    this.isActive = const Value.absent(),
    this.achievedDuration = const Value.absent(),
    this.durationAchievedAtMillis = const Value.absent(),
    this.achievedFrequency = const Value.absent(),
    this.frequencyAchievedAtMillis = const Value.absent(),
    this.achievedConsistency = const Value.absent(),
    this.consistencyAchievedAtMillis = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractionSessionsCompanion.insert({
    required String id,
    required int startTimeMillis,
    this.endTimeMillis = const Value.absent(),
    this.isActive = const Value.absent(),
    this.achievedDuration = const Value.absent(),
    this.durationAchievedAtMillis = const Value.absent(),
    this.achievedFrequency = const Value.absent(),
    this.frequencyAchievedAtMillis = const Value.absent(),
    this.achievedConsistency = const Value.absent(),
    this.consistencyAchievedAtMillis = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTimeMillis = Value(startTimeMillis),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ContractionSessionDto> custom({
    Expression<String>? id,
    Expression<int>? startTimeMillis,
    Expression<int>? endTimeMillis,
    Expression<bool>? isActive,
    Expression<bool>? achievedDuration,
    Expression<int>? durationAchievedAtMillis,
    Expression<bool>? achievedFrequency,
    Expression<int>? frequencyAchievedAtMillis,
    Expression<bool>? achievedConsistency,
    Expression<int>? consistencyAchievedAtMillis,
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
      if (achievedDuration != null) 'achieved_duration': achievedDuration,
      if (durationAchievedAtMillis != null)
        'duration_achieved_at_millis': durationAchievedAtMillis,
      if (achievedFrequency != null) 'achieved_frequency': achievedFrequency,
      if (frequencyAchievedAtMillis != null)
        'frequency_achieved_at_millis': frequencyAchievedAtMillis,
      if (achievedConsistency != null)
        'achieved_consistency': achievedConsistency,
      if (consistencyAchievedAtMillis != null)
        'consistency_achieved_at_millis': consistencyAchievedAtMillis,
      if (note != null) 'note': note,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractionSessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startTimeMillis,
    Value<int?>? endTimeMillis,
    Value<bool>? isActive,
    Value<bool>? achievedDuration,
    Value<int?>? durationAchievedAtMillis,
    Value<bool>? achievedFrequency,
    Value<int?>? frequencyAchievedAtMillis,
    Value<bool>? achievedConsistency,
    Value<int?>? consistencyAchievedAtMillis,
    Value<String?>? note,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ContractionSessionsCompanion(
      id: id ?? this.id,
      startTimeMillis: startTimeMillis ?? this.startTimeMillis,
      endTimeMillis: endTimeMillis ?? this.endTimeMillis,
      isActive: isActive ?? this.isActive,
      achievedDuration: achievedDuration ?? this.achievedDuration,
      durationAchievedAtMillis:
          durationAchievedAtMillis ?? this.durationAchievedAtMillis,
      achievedFrequency: achievedFrequency ?? this.achievedFrequency,
      frequencyAchievedAtMillis:
          frequencyAchievedAtMillis ?? this.frequencyAchievedAtMillis,
      achievedConsistency: achievedConsistency ?? this.achievedConsistency,
      consistencyAchievedAtMillis:
          consistencyAchievedAtMillis ?? this.consistencyAchievedAtMillis,
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
    if (achievedDuration.present) {
      map['achieved_duration'] = Variable<bool>(achievedDuration.value);
    }
    if (durationAchievedAtMillis.present) {
      map['duration_achieved_at_millis'] = Variable<int>(
        durationAchievedAtMillis.value,
      );
    }
    if (achievedFrequency.present) {
      map['achieved_frequency'] = Variable<bool>(achievedFrequency.value);
    }
    if (frequencyAchievedAtMillis.present) {
      map['frequency_achieved_at_millis'] = Variable<int>(
        frequencyAchievedAtMillis.value,
      );
    }
    if (achievedConsistency.present) {
      map['achieved_consistency'] = Variable<bool>(achievedConsistency.value);
    }
    if (consistencyAchievedAtMillis.present) {
      map['consistency_achieved_at_millis'] = Variable<int>(
        consistencyAchievedAtMillis.value,
      );
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
    return (StringBuffer('ContractionSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('isActive: $isActive, ')
          ..write('achievedDuration: $achievedDuration, ')
          ..write('durationAchievedAtMillis: $durationAchievedAtMillis, ')
          ..write('achievedFrequency: $achievedFrequency, ')
          ..write('frequencyAchievedAtMillis: $frequencyAchievedAtMillis, ')
          ..write('achievedConsistency: $achievedConsistency, ')
          ..write('consistencyAchievedAtMillis: $consistencyAchievedAtMillis, ')
          ..write('note: $note, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractionsTable extends Contractions
    with TableInfo<$ContractionsTable, ContractionDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    startTimeMillis,
    endTimeMillis,
    intensity,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contractions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractionDto> instance, {
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
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
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
  ContractionDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractionDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      startTimeMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_millis'],
      )!,
      endTimeMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_millis'],
      ),
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
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
  $ContractionsTable createAlias(String alias) {
    return $ContractionsTable(attachedDatabase, alias);
  }
}

class ContractionDto extends DataClass implements Insertable<ContractionDto> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to the session this contraction belongs to
  /// Links to ContractionSessions.id
  final String sessionId;

  /// When the contraction started (stored as millis since epoch for precision)
  final int startTimeMillis;

  /// When the contraction ended (null if currently active/being timed)
  final int? endTimeMillis;

  /// Perceived intensity as reported by user
  /// Stored as integer: 0 = mild, 1 = moderate, 2 = strong
  /// Maps to ContractionIntensity enum
  final int intensity;

  /// Timestamp when record was created (stored as millis since epoch)
  final int createdAtMillis;

  /// Timestamp when record was last updated (stored as millis since epoch)
  final int updatedAtMillis;
  const ContractionDto({
    required this.id,
    required this.sessionId,
    required this.startTimeMillis,
    this.endTimeMillis,
    required this.intensity,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['start_time_millis'] = Variable<int>(startTimeMillis);
    if (!nullToAbsent || endTimeMillis != null) {
      map['end_time_millis'] = Variable<int>(endTimeMillis);
    }
    map['intensity'] = Variable<int>(intensity);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  ContractionsCompanion toCompanion(bool nullToAbsent) {
    return ContractionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      startTimeMillis: Value(startTimeMillis),
      endTimeMillis: endTimeMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeMillis),
      intensity: Value(intensity),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory ContractionDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractionDto(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      startTimeMillis: serializer.fromJson<int>(json['startTimeMillis']),
      endTimeMillis: serializer.fromJson<int?>(json['endTimeMillis']),
      intensity: serializer.fromJson<int>(json['intensity']),
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
      'startTimeMillis': serializer.toJson<int>(startTimeMillis),
      'endTimeMillis': serializer.toJson<int?>(endTimeMillis),
      'intensity': serializer.toJson<int>(intensity),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  ContractionDto copyWith({
    String? id,
    String? sessionId,
    int? startTimeMillis,
    Value<int?> endTimeMillis = const Value.absent(),
    int? intensity,
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => ContractionDto(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    startTimeMillis: startTimeMillis ?? this.startTimeMillis,
    endTimeMillis: endTimeMillis.present
        ? endTimeMillis.value
        : this.endTimeMillis,
    intensity: intensity ?? this.intensity,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  ContractionDto copyWithCompanion(ContractionsCompanion data) {
    return ContractionDto(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startTimeMillis: data.startTimeMillis.present
          ? data.startTimeMillis.value
          : this.startTimeMillis,
      endTimeMillis: data.endTimeMillis.present
          ? data.endTimeMillis.value
          : this.endTimeMillis,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
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
    return (StringBuffer('ContractionDto(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('intensity: $intensity, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    startTimeMillis,
    endTimeMillis,
    intensity,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractionDto &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.startTimeMillis == this.startTimeMillis &&
          other.endTimeMillis == this.endTimeMillis &&
          other.intensity == this.intensity &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class ContractionsCompanion extends UpdateCompanion<ContractionDto> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> startTimeMillis;
  final Value<int?> endTimeMillis;
  final Value<int> intensity;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const ContractionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.startTimeMillis = const Value.absent(),
    this.endTimeMillis = const Value.absent(),
    this.intensity = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractionsCompanion.insert({
    required String id,
    required String sessionId,
    required int startTimeMillis,
    this.endTimeMillis = const Value.absent(),
    this.intensity = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       startTimeMillis = Value(startTimeMillis),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<ContractionDto> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? startTimeMillis,
    Expression<int>? endTimeMillis,
    Expression<int>? intensity,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (startTimeMillis != null) 'start_time_millis': startTimeMillis,
      if (endTimeMillis != null) 'end_time_millis': endTimeMillis,
      if (intensity != null) 'intensity': intensity,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractionsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? startTimeMillis,
    Value<int?>? endTimeMillis,
    Value<int>? intensity,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return ContractionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startTimeMillis: startTimeMillis ?? this.startTimeMillis,
      endTimeMillis: endTimeMillis ?? this.endTimeMillis,
      intensity: intensity ?? this.intensity,
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
    if (startTimeMillis.present) {
      map['start_time_millis'] = Variable<int>(startTimeMillis.value);
    }
    if (endTimeMillis.present) {
      map['end_time_millis'] = Variable<int>(endTimeMillis.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
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
    return (StringBuffer('ContractionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startTimeMillis: $startTimeMillis, ')
          ..write('endTimeMillis: $endTimeMillis, ')
          ..write('intensity: $intensity, ')
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

class $MaternityUnitsTable extends MaternityUnits
    with TableInfo<$MaternityUnitsTable, MaternityUnitDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaternityUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cqcLocationIdMeta = const VerificationMeta(
    'cqcLocationId',
  );
  @override
  late final GeneratedColumn<String> cqcLocationId = GeneratedColumn<String>(
    'cqc_location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cqcProviderIdMeta = const VerificationMeta(
    'cqcProviderId',
  );
  @override
  late final GeneratedColumn<String> cqcProviderId = GeneratedColumn<String>(
    'cqc_provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odsCodeMeta = const VerificationMeta(
    'odsCode',
  );
  @override
  late final GeneratedColumn<String> odsCode = GeneratedColumn<String>(
    'ods_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerNameMeta = const VerificationMeta(
    'providerName',
  );
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
    'provider_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isNhsMeta = const VerificationMeta('isNhs');
  @override
  late final GeneratedColumn<bool> isNhs = GeneratedColumn<bool>(
    'is_nhs',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_nhs" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _addressLine1Meta = const VerificationMeta(
    'addressLine1',
  );
  @override
  late final GeneratedColumn<String> addressLine1 = GeneratedColumn<String>(
    'address_line1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressLine2Meta = const VerificationMeta(
    'addressLine2',
  );
  @override
  late final GeneratedColumn<String> addressLine2 = GeneratedColumn<String>(
    'address_line2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _townCityMeta = const VerificationMeta(
    'townCity',
  );
  @override
  late final GeneratedColumn<String> townCity = GeneratedColumn<String>(
    'town_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countyMeta = const VerificationMeta('county');
  @override
  late final GeneratedColumn<String> county = GeneratedColumn<String>(
    'county',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postcodeMeta = const VerificationMeta(
    'postcode',
  );
  @override
  late final GeneratedColumn<String> postcode = GeneratedColumn<String>(
    'postcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localAuthorityMeta = const VerificationMeta(
    'localAuthority',
  );
  @override
  late final GeneratedColumn<String> localAuthority = GeneratedColumn<String>(
    'local_authority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overallRatingMeta = const VerificationMeta(
    'overallRating',
  );
  @override
  late final GeneratedColumn<String> overallRating = GeneratedColumn<String>(
    'overall_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingSafeMeta = const VerificationMeta(
    'ratingSafe',
  );
  @override
  late final GeneratedColumn<String> ratingSafe = GeneratedColumn<String>(
    'rating_safe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingEffectiveMeta = const VerificationMeta(
    'ratingEffective',
  );
  @override
  late final GeneratedColumn<String> ratingEffective = GeneratedColumn<String>(
    'rating_effective',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingCaringMeta = const VerificationMeta(
    'ratingCaring',
  );
  @override
  late final GeneratedColumn<String> ratingCaring = GeneratedColumn<String>(
    'rating_caring',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingResponsiveMeta = const VerificationMeta(
    'ratingResponsive',
  );
  @override
  late final GeneratedColumn<String> ratingResponsive = GeneratedColumn<String>(
    'rating_responsive',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingWellLedMeta = const VerificationMeta(
    'ratingWellLed',
  );
  @override
  late final GeneratedColumn<String> ratingWellLed = GeneratedColumn<String>(
    'rating_well_led',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maternityRatingMeta = const VerificationMeta(
    'maternityRating',
  );
  @override
  late final GeneratedColumn<String> maternityRating = GeneratedColumn<String>(
    'maternity_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maternityRatingDateMeta =
      const VerificationMeta('maternityRatingDate');
  @override
  late final GeneratedColumn<String> maternityRatingDate =
      GeneratedColumn<String>(
        'maternity_rating_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastInspectionDateMeta =
      const VerificationMeta('lastInspectionDate');
  @override
  late final GeneratedColumn<String> lastInspectionDate =
      GeneratedColumn<String>(
        'last_inspection_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cqcReportUrlMeta = const VerificationMeta(
    'cqcReportUrl',
  );
  @override
  late final GeneratedColumn<String> cqcReportUrl = GeneratedColumn<String>(
    'cqc_report_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationStatusMeta =
      const VerificationMeta('registrationStatus');
  @override
  late final GeneratedColumn<String> registrationStatus =
      GeneratedColumn<String>(
        'registration_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeCleanlinessMeta = const VerificationMeta(
    'placeCleanliness',
  );
  @override
  late final GeneratedColumn<double> placeCleanliness = GeneratedColumn<double>(
    'place_cleanliness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeFoodMeta = const VerificationMeta(
    'placeFood',
  );
  @override
  late final GeneratedColumn<double> placeFood = GeneratedColumn<double>(
    'place_food',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placePrivacyDignityWellbeingMeta =
      const VerificationMeta('placePrivacyDignityWellbeing');
  @override
  late final GeneratedColumn<double> placePrivacyDignityWellbeing =
      GeneratedColumn<double>(
        'place_privacy_dignity_wellbeing',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeConditionAppearanceMeta =
      const VerificationMeta('placeConditionAppearance');
  @override
  late final GeneratedColumn<double> placeConditionAppearance =
      GeneratedColumn<double>(
        'place_condition_appearance',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _placeSyncedAtMillisMeta =
      const VerificationMeta('placeSyncedAtMillis');
  @override
  late final GeneratedColumn<int> placeSyncedAtMillis = GeneratedColumn<int>(
    'place_synced_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthingOptionsMeta = const VerificationMeta(
    'birthingOptions',
  );
  @override
  late final GeneratedColumn<String> birthingOptions = GeneratedColumn<String>(
    'birthing_options',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facilitiesMeta = const VerificationMeta(
    'facilities',
  );
  @override
  late final GeneratedColumn<String> facilities = GeneratedColumn<String>(
    'facilities',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthStatisticsMeta = const VerificationMeta(
    'birthStatistics',
  );
  @override
  late final GeneratedColumn<String> birthStatistics = GeneratedColumn<String>(
    'birth_statistics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _cqcSyncedAtMillisMeta = const VerificationMeta(
    'cqcSyncedAtMillis',
  );
  @override
  late final GeneratedColumn<int> cqcSyncedAtMillis = GeneratedColumn<int>(
    'cqc_synced_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cqcLocationId,
    cqcProviderId,
    odsCode,
    name,
    providerName,
    unitType,
    isNhs,
    addressLine1,
    addressLine2,
    townCity,
    county,
    postcode,
    region,
    localAuthority,
    latitude,
    longitude,
    phone,
    website,
    overallRating,
    ratingSafe,
    ratingEffective,
    ratingCaring,
    ratingResponsive,
    ratingWellLed,
    maternityRating,
    maternityRatingDate,
    lastInspectionDate,
    cqcReportUrl,
    registrationStatus,
    placeCleanliness,
    placeFood,
    placePrivacyDignityWellbeing,
    placeConditionAppearance,
    placeSyncedAtMillis,
    birthingOptions,
    facilities,
    birthStatistics,
    notes,
    isActive,
    createdAtMillis,
    updatedAtMillis,
    cqcSyncedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maternity_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaternityUnitDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cqc_location_id')) {
      context.handle(
        _cqcLocationIdMeta,
        cqcLocationId.isAcceptableOrUnknown(
          data['cqc_location_id']!,
          _cqcLocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cqcLocationIdMeta);
    }
    if (data.containsKey('cqc_provider_id')) {
      context.handle(
        _cqcProviderIdMeta,
        cqcProviderId.isAcceptableOrUnknown(
          data['cqc_provider_id']!,
          _cqcProviderIdMeta,
        ),
      );
    }
    if (data.containsKey('ods_code')) {
      context.handle(
        _odsCodeMeta,
        odsCode.isAcceptableOrUnknown(data['ods_code']!, _odsCodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
        _providerNameMeta,
        providerName.isAcceptableOrUnknown(
          data['provider_name']!,
          _providerNameMeta,
        ),
      );
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('is_nhs')) {
      context.handle(
        _isNhsMeta,
        isNhs.isAcceptableOrUnknown(data['is_nhs']!, _isNhsMeta),
      );
    }
    if (data.containsKey('address_line1')) {
      context.handle(
        _addressLine1Meta,
        addressLine1.isAcceptableOrUnknown(
          data['address_line1']!,
          _addressLine1Meta,
        ),
      );
    }
    if (data.containsKey('address_line2')) {
      context.handle(
        _addressLine2Meta,
        addressLine2.isAcceptableOrUnknown(
          data['address_line2']!,
          _addressLine2Meta,
        ),
      );
    }
    if (data.containsKey('town_city')) {
      context.handle(
        _townCityMeta,
        townCity.isAcceptableOrUnknown(data['town_city']!, _townCityMeta),
      );
    }
    if (data.containsKey('county')) {
      context.handle(
        _countyMeta,
        county.isAcceptableOrUnknown(data['county']!, _countyMeta),
      );
    }
    if (data.containsKey('postcode')) {
      context.handle(
        _postcodeMeta,
        postcode.isAcceptableOrUnknown(data['postcode']!, _postcodeMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('local_authority')) {
      context.handle(
        _localAuthorityMeta,
        localAuthority.isAcceptableOrUnknown(
          data['local_authority']!,
          _localAuthorityMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('overall_rating')) {
      context.handle(
        _overallRatingMeta,
        overallRating.isAcceptableOrUnknown(
          data['overall_rating']!,
          _overallRatingMeta,
        ),
      );
    }
    if (data.containsKey('rating_safe')) {
      context.handle(
        _ratingSafeMeta,
        ratingSafe.isAcceptableOrUnknown(data['rating_safe']!, _ratingSafeMeta),
      );
    }
    if (data.containsKey('rating_effective')) {
      context.handle(
        _ratingEffectiveMeta,
        ratingEffective.isAcceptableOrUnknown(
          data['rating_effective']!,
          _ratingEffectiveMeta,
        ),
      );
    }
    if (data.containsKey('rating_caring')) {
      context.handle(
        _ratingCaringMeta,
        ratingCaring.isAcceptableOrUnknown(
          data['rating_caring']!,
          _ratingCaringMeta,
        ),
      );
    }
    if (data.containsKey('rating_responsive')) {
      context.handle(
        _ratingResponsiveMeta,
        ratingResponsive.isAcceptableOrUnknown(
          data['rating_responsive']!,
          _ratingResponsiveMeta,
        ),
      );
    }
    if (data.containsKey('rating_well_led')) {
      context.handle(
        _ratingWellLedMeta,
        ratingWellLed.isAcceptableOrUnknown(
          data['rating_well_led']!,
          _ratingWellLedMeta,
        ),
      );
    }
    if (data.containsKey('maternity_rating')) {
      context.handle(
        _maternityRatingMeta,
        maternityRating.isAcceptableOrUnknown(
          data['maternity_rating']!,
          _maternityRatingMeta,
        ),
      );
    }
    if (data.containsKey('maternity_rating_date')) {
      context.handle(
        _maternityRatingDateMeta,
        maternityRatingDate.isAcceptableOrUnknown(
          data['maternity_rating_date']!,
          _maternityRatingDateMeta,
        ),
      );
    }
    if (data.containsKey('last_inspection_date')) {
      context.handle(
        _lastInspectionDateMeta,
        lastInspectionDate.isAcceptableOrUnknown(
          data['last_inspection_date']!,
          _lastInspectionDateMeta,
        ),
      );
    }
    if (data.containsKey('cqc_report_url')) {
      context.handle(
        _cqcReportUrlMeta,
        cqcReportUrl.isAcceptableOrUnknown(
          data['cqc_report_url']!,
          _cqcReportUrlMeta,
        ),
      );
    }
    if (data.containsKey('registration_status')) {
      context.handle(
        _registrationStatusMeta,
        registrationStatus.isAcceptableOrUnknown(
          data['registration_status']!,
          _registrationStatusMeta,
        ),
      );
    }
    if (data.containsKey('place_cleanliness')) {
      context.handle(
        _placeCleanlinessMeta,
        placeCleanliness.isAcceptableOrUnknown(
          data['place_cleanliness']!,
          _placeCleanlinessMeta,
        ),
      );
    }
    if (data.containsKey('place_food')) {
      context.handle(
        _placeFoodMeta,
        placeFood.isAcceptableOrUnknown(data['place_food']!, _placeFoodMeta),
      );
    }
    if (data.containsKey('place_privacy_dignity_wellbeing')) {
      context.handle(
        _placePrivacyDignityWellbeingMeta,
        placePrivacyDignityWellbeing.isAcceptableOrUnknown(
          data['place_privacy_dignity_wellbeing']!,
          _placePrivacyDignityWellbeingMeta,
        ),
      );
    }
    if (data.containsKey('place_condition_appearance')) {
      context.handle(
        _placeConditionAppearanceMeta,
        placeConditionAppearance.isAcceptableOrUnknown(
          data['place_condition_appearance']!,
          _placeConditionAppearanceMeta,
        ),
      );
    }
    if (data.containsKey('place_synced_at_millis')) {
      context.handle(
        _placeSyncedAtMillisMeta,
        placeSyncedAtMillis.isAcceptableOrUnknown(
          data['place_synced_at_millis']!,
          _placeSyncedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('birthing_options')) {
      context.handle(
        _birthingOptionsMeta,
        birthingOptions.isAcceptableOrUnknown(
          data['birthing_options']!,
          _birthingOptionsMeta,
        ),
      );
    }
    if (data.containsKey('facilities')) {
      context.handle(
        _facilitiesMeta,
        facilities.isAcceptableOrUnknown(data['facilities']!, _facilitiesMeta),
      );
    }
    if (data.containsKey('birth_statistics')) {
      context.handle(
        _birthStatisticsMeta,
        birthStatistics.isAcceptableOrUnknown(
          data['birth_statistics']!,
          _birthStatisticsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('cqc_synced_at_millis')) {
      context.handle(
        _cqcSyncedAtMillisMeta,
        cqcSyncedAtMillis.isAcceptableOrUnknown(
          data['cqc_synced_at_millis']!,
          _cqcSyncedAtMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaternityUnitDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaternityUnitDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cqcLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cqc_location_id'],
      )!,
      cqcProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cqc_provider_id'],
      ),
      odsCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ods_code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      providerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_name'],
      ),
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      isNhs: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_nhs'],
      )!,
      addressLine1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line1'],
      ),
      addressLine2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line2'],
      ),
      townCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}town_city'],
      ),
      county: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}county'],
      ),
      postcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postcode'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      localAuthority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_authority'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      overallRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall_rating'],
      ),
      ratingSafe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating_safe'],
      ),
      ratingEffective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating_effective'],
      ),
      ratingCaring: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating_caring'],
      ),
      ratingResponsive: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating_responsive'],
      ),
      ratingWellLed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating_well_led'],
      ),
      maternityRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maternity_rating'],
      ),
      maternityRatingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maternity_rating_date'],
      ),
      lastInspectionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_inspection_date'],
      ),
      cqcReportUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cqc_report_url'],
      ),
      registrationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_status'],
      ),
      placeCleanliness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_cleanliness'],
      ),
      placeFood: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_food'],
      ),
      placePrivacyDignityWellbeing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_privacy_dignity_wellbeing'],
      ),
      placeConditionAppearance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}place_condition_appearance'],
      ),
      placeSyncedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place_synced_at_millis'],
      ),
      birthingOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthing_options'],
      ),
      facilities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facilities'],
      ),
      birthStatistics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_statistics'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
      cqcSyncedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cqc_synced_at_millis'],
      ),
    );
  }

  @override
  $MaternityUnitsTable createAlias(String alias) {
    return $MaternityUnitsTable(attachedDatabase, alias);
  }
}

class MaternityUnitDto extends DataClass
    implements Insertable<MaternityUnitDto> {
  /// UUID primary key (local).
  final String id;

  /// CQC unique location identifier.
  final String cqcLocationId;

  /// CQC provider ID.
  final String? cqcProviderId;

  /// NHS ODS code.
  final String? odsCode;

  /// Name of the maternity unit.
  final String name;

  /// Provider/Trust name.
  final String? providerName;

  /// Type: "nhs_hospital" or "independent_hospital".
  final String unitType;

  /// Whether this is an NHS facility.
  final bool isNhs;
  final String? addressLine1;
  final String? addressLine2;
  final String? townCity;
  final String? county;
  final String? postcode;
  final String? region;
  final String? localAuthority;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? website;
  final String? overallRating;
  final String? ratingSafe;
  final String? ratingEffective;
  final String? ratingCaring;
  final String? ratingResponsive;
  final String? ratingWellLed;
  final String? maternityRating;
  final String? maternityRatingDate;
  final String? lastInspectionDate;
  final String? cqcReportUrl;
  final String? registrationStatus;
  final double? placeCleanliness;
  final double? placeFood;
  final double? placePrivacyDignityWellbeing;
  final double? placeConditionAppearance;
  final int? placeSyncedAtMillis;
  final String? birthingOptions;
  final String? facilities;
  final String? birthStatistics;
  final String? notes;
  final bool isActive;
  final int createdAtMillis;
  final int updatedAtMillis;
  final int? cqcSyncedAtMillis;
  const MaternityUnitDto({
    required this.id,
    required this.cqcLocationId,
    this.cqcProviderId,
    this.odsCode,
    required this.name,
    this.providerName,
    required this.unitType,
    required this.isNhs,
    this.addressLine1,
    this.addressLine2,
    this.townCity,
    this.county,
    this.postcode,
    this.region,
    this.localAuthority,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    this.overallRating,
    this.ratingSafe,
    this.ratingEffective,
    this.ratingCaring,
    this.ratingResponsive,
    this.ratingWellLed,
    this.maternityRating,
    this.maternityRatingDate,
    this.lastInspectionDate,
    this.cqcReportUrl,
    this.registrationStatus,
    this.placeCleanliness,
    this.placeFood,
    this.placePrivacyDignityWellbeing,
    this.placeConditionAppearance,
    this.placeSyncedAtMillis,
    this.birthingOptions,
    this.facilities,
    this.birthStatistics,
    this.notes,
    required this.isActive,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    this.cqcSyncedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cqc_location_id'] = Variable<String>(cqcLocationId);
    if (!nullToAbsent || cqcProviderId != null) {
      map['cqc_provider_id'] = Variable<String>(cqcProviderId);
    }
    if (!nullToAbsent || odsCode != null) {
      map['ods_code'] = Variable<String>(odsCode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || providerName != null) {
      map['provider_name'] = Variable<String>(providerName);
    }
    map['unit_type'] = Variable<String>(unitType);
    map['is_nhs'] = Variable<bool>(isNhs);
    if (!nullToAbsent || addressLine1 != null) {
      map['address_line1'] = Variable<String>(addressLine1);
    }
    if (!nullToAbsent || addressLine2 != null) {
      map['address_line2'] = Variable<String>(addressLine2);
    }
    if (!nullToAbsent || townCity != null) {
      map['town_city'] = Variable<String>(townCity);
    }
    if (!nullToAbsent || county != null) {
      map['county'] = Variable<String>(county);
    }
    if (!nullToAbsent || postcode != null) {
      map['postcode'] = Variable<String>(postcode);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || localAuthority != null) {
      map['local_authority'] = Variable<String>(localAuthority);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || overallRating != null) {
      map['overall_rating'] = Variable<String>(overallRating);
    }
    if (!nullToAbsent || ratingSafe != null) {
      map['rating_safe'] = Variable<String>(ratingSafe);
    }
    if (!nullToAbsent || ratingEffective != null) {
      map['rating_effective'] = Variable<String>(ratingEffective);
    }
    if (!nullToAbsent || ratingCaring != null) {
      map['rating_caring'] = Variable<String>(ratingCaring);
    }
    if (!nullToAbsent || ratingResponsive != null) {
      map['rating_responsive'] = Variable<String>(ratingResponsive);
    }
    if (!nullToAbsent || ratingWellLed != null) {
      map['rating_well_led'] = Variable<String>(ratingWellLed);
    }
    if (!nullToAbsent || maternityRating != null) {
      map['maternity_rating'] = Variable<String>(maternityRating);
    }
    if (!nullToAbsent || maternityRatingDate != null) {
      map['maternity_rating_date'] = Variable<String>(maternityRatingDate);
    }
    if (!nullToAbsent || lastInspectionDate != null) {
      map['last_inspection_date'] = Variable<String>(lastInspectionDate);
    }
    if (!nullToAbsent || cqcReportUrl != null) {
      map['cqc_report_url'] = Variable<String>(cqcReportUrl);
    }
    if (!nullToAbsent || registrationStatus != null) {
      map['registration_status'] = Variable<String>(registrationStatus);
    }
    if (!nullToAbsent || placeCleanliness != null) {
      map['place_cleanliness'] = Variable<double>(placeCleanliness);
    }
    if (!nullToAbsent || placeFood != null) {
      map['place_food'] = Variable<double>(placeFood);
    }
    if (!nullToAbsent || placePrivacyDignityWellbeing != null) {
      map['place_privacy_dignity_wellbeing'] = Variable<double>(
        placePrivacyDignityWellbeing,
      );
    }
    if (!nullToAbsent || placeConditionAppearance != null) {
      map['place_condition_appearance'] = Variable<double>(
        placeConditionAppearance,
      );
    }
    if (!nullToAbsent || placeSyncedAtMillis != null) {
      map['place_synced_at_millis'] = Variable<int>(placeSyncedAtMillis);
    }
    if (!nullToAbsent || birthingOptions != null) {
      map['birthing_options'] = Variable<String>(birthingOptions);
    }
    if (!nullToAbsent || facilities != null) {
      map['facilities'] = Variable<String>(facilities);
    }
    if (!nullToAbsent || birthStatistics != null) {
      map['birth_statistics'] = Variable<String>(birthStatistics);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    if (!nullToAbsent || cqcSyncedAtMillis != null) {
      map['cqc_synced_at_millis'] = Variable<int>(cqcSyncedAtMillis);
    }
    return map;
  }

  MaternityUnitsCompanion toCompanion(bool nullToAbsent) {
    return MaternityUnitsCompanion(
      id: Value(id),
      cqcLocationId: Value(cqcLocationId),
      cqcProviderId: cqcProviderId == null && nullToAbsent
          ? const Value.absent()
          : Value(cqcProviderId),
      odsCode: odsCode == null && nullToAbsent
          ? const Value.absent()
          : Value(odsCode),
      name: Value(name),
      providerName: providerName == null && nullToAbsent
          ? const Value.absent()
          : Value(providerName),
      unitType: Value(unitType),
      isNhs: Value(isNhs),
      addressLine1: addressLine1 == null && nullToAbsent
          ? const Value.absent()
          : Value(addressLine1),
      addressLine2: addressLine2 == null && nullToAbsent
          ? const Value.absent()
          : Value(addressLine2),
      townCity: townCity == null && nullToAbsent
          ? const Value.absent()
          : Value(townCity),
      county: county == null && nullToAbsent
          ? const Value.absent()
          : Value(county),
      postcode: postcode == null && nullToAbsent
          ? const Value.absent()
          : Value(postcode),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      localAuthority: localAuthority == null && nullToAbsent
          ? const Value.absent()
          : Value(localAuthority),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      overallRating: overallRating == null && nullToAbsent
          ? const Value.absent()
          : Value(overallRating),
      ratingSafe: ratingSafe == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingSafe),
      ratingEffective: ratingEffective == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingEffective),
      ratingCaring: ratingCaring == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingCaring),
      ratingResponsive: ratingResponsive == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingResponsive),
      ratingWellLed: ratingWellLed == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingWellLed),
      maternityRating: maternityRating == null && nullToAbsent
          ? const Value.absent()
          : Value(maternityRating),
      maternityRatingDate: maternityRatingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maternityRatingDate),
      lastInspectionDate: lastInspectionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInspectionDate),
      cqcReportUrl: cqcReportUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(cqcReportUrl),
      registrationStatus: registrationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationStatus),
      placeCleanliness: placeCleanliness == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCleanliness),
      placeFood: placeFood == null && nullToAbsent
          ? const Value.absent()
          : Value(placeFood),
      placePrivacyDignityWellbeing:
          placePrivacyDignityWellbeing == null && nullToAbsent
          ? const Value.absent()
          : Value(placePrivacyDignityWellbeing),
      placeConditionAppearance: placeConditionAppearance == null && nullToAbsent
          ? const Value.absent()
          : Value(placeConditionAppearance),
      placeSyncedAtMillis: placeSyncedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(placeSyncedAtMillis),
      birthingOptions: birthingOptions == null && nullToAbsent
          ? const Value.absent()
          : Value(birthingOptions),
      facilities: facilities == null && nullToAbsent
          ? const Value.absent()
          : Value(facilities),
      birthStatistics: birthStatistics == null && nullToAbsent
          ? const Value.absent()
          : Value(birthStatistics),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
      cqcSyncedAtMillis: cqcSyncedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(cqcSyncedAtMillis),
    );
  }

  factory MaternityUnitDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaternityUnitDto(
      id: serializer.fromJson<String>(json['id']),
      cqcLocationId: serializer.fromJson<String>(json['cqcLocationId']),
      cqcProviderId: serializer.fromJson<String?>(json['cqcProviderId']),
      odsCode: serializer.fromJson<String?>(json['odsCode']),
      name: serializer.fromJson<String>(json['name']),
      providerName: serializer.fromJson<String?>(json['providerName']),
      unitType: serializer.fromJson<String>(json['unitType']),
      isNhs: serializer.fromJson<bool>(json['isNhs']),
      addressLine1: serializer.fromJson<String?>(json['addressLine1']),
      addressLine2: serializer.fromJson<String?>(json['addressLine2']),
      townCity: serializer.fromJson<String?>(json['townCity']),
      county: serializer.fromJson<String?>(json['county']),
      postcode: serializer.fromJson<String?>(json['postcode']),
      region: serializer.fromJson<String?>(json['region']),
      localAuthority: serializer.fromJson<String?>(json['localAuthority']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      phone: serializer.fromJson<String?>(json['phone']),
      website: serializer.fromJson<String?>(json['website']),
      overallRating: serializer.fromJson<String?>(json['overallRating']),
      ratingSafe: serializer.fromJson<String?>(json['ratingSafe']),
      ratingEffective: serializer.fromJson<String?>(json['ratingEffective']),
      ratingCaring: serializer.fromJson<String?>(json['ratingCaring']),
      ratingResponsive: serializer.fromJson<String?>(json['ratingResponsive']),
      ratingWellLed: serializer.fromJson<String?>(json['ratingWellLed']),
      maternityRating: serializer.fromJson<String?>(json['maternityRating']),
      maternityRatingDate: serializer.fromJson<String?>(
        json['maternityRatingDate'],
      ),
      lastInspectionDate: serializer.fromJson<String?>(
        json['lastInspectionDate'],
      ),
      cqcReportUrl: serializer.fromJson<String?>(json['cqcReportUrl']),
      registrationStatus: serializer.fromJson<String?>(
        json['registrationStatus'],
      ),
      placeCleanliness: serializer.fromJson<double?>(json['placeCleanliness']),
      placeFood: serializer.fromJson<double?>(json['placeFood']),
      placePrivacyDignityWellbeing: serializer.fromJson<double?>(
        json['placePrivacyDignityWellbeing'],
      ),
      placeConditionAppearance: serializer.fromJson<double?>(
        json['placeConditionAppearance'],
      ),
      placeSyncedAtMillis: serializer.fromJson<int?>(
        json['placeSyncedAtMillis'],
      ),
      birthingOptions: serializer.fromJson<String?>(json['birthingOptions']),
      facilities: serializer.fromJson<String?>(json['facilities']),
      birthStatistics: serializer.fromJson<String?>(json['birthStatistics']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
      cqcSyncedAtMillis: serializer.fromJson<int?>(json['cqcSyncedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cqcLocationId': serializer.toJson<String>(cqcLocationId),
      'cqcProviderId': serializer.toJson<String?>(cqcProviderId),
      'odsCode': serializer.toJson<String?>(odsCode),
      'name': serializer.toJson<String>(name),
      'providerName': serializer.toJson<String?>(providerName),
      'unitType': serializer.toJson<String>(unitType),
      'isNhs': serializer.toJson<bool>(isNhs),
      'addressLine1': serializer.toJson<String?>(addressLine1),
      'addressLine2': serializer.toJson<String?>(addressLine2),
      'townCity': serializer.toJson<String?>(townCity),
      'county': serializer.toJson<String?>(county),
      'postcode': serializer.toJson<String?>(postcode),
      'region': serializer.toJson<String?>(region),
      'localAuthority': serializer.toJson<String?>(localAuthority),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'phone': serializer.toJson<String?>(phone),
      'website': serializer.toJson<String?>(website),
      'overallRating': serializer.toJson<String?>(overallRating),
      'ratingSafe': serializer.toJson<String?>(ratingSafe),
      'ratingEffective': serializer.toJson<String?>(ratingEffective),
      'ratingCaring': serializer.toJson<String?>(ratingCaring),
      'ratingResponsive': serializer.toJson<String?>(ratingResponsive),
      'ratingWellLed': serializer.toJson<String?>(ratingWellLed),
      'maternityRating': serializer.toJson<String?>(maternityRating),
      'maternityRatingDate': serializer.toJson<String?>(maternityRatingDate),
      'lastInspectionDate': serializer.toJson<String?>(lastInspectionDate),
      'cqcReportUrl': serializer.toJson<String?>(cqcReportUrl),
      'registrationStatus': serializer.toJson<String?>(registrationStatus),
      'placeCleanliness': serializer.toJson<double?>(placeCleanliness),
      'placeFood': serializer.toJson<double?>(placeFood),
      'placePrivacyDignityWellbeing': serializer.toJson<double?>(
        placePrivacyDignityWellbeing,
      ),
      'placeConditionAppearance': serializer.toJson<double?>(
        placeConditionAppearance,
      ),
      'placeSyncedAtMillis': serializer.toJson<int?>(placeSyncedAtMillis),
      'birthingOptions': serializer.toJson<String?>(birthingOptions),
      'facilities': serializer.toJson<String?>(facilities),
      'birthStatistics': serializer.toJson<String?>(birthStatistics),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
      'cqcSyncedAtMillis': serializer.toJson<int?>(cqcSyncedAtMillis),
    };
  }

  MaternityUnitDto copyWith({
    String? id,
    String? cqcLocationId,
    Value<String?> cqcProviderId = const Value.absent(),
    Value<String?> odsCode = const Value.absent(),
    String? name,
    Value<String?> providerName = const Value.absent(),
    String? unitType,
    bool? isNhs,
    Value<String?> addressLine1 = const Value.absent(),
    Value<String?> addressLine2 = const Value.absent(),
    Value<String?> townCity = const Value.absent(),
    Value<String?> county = const Value.absent(),
    Value<String?> postcode = const Value.absent(),
    Value<String?> region = const Value.absent(),
    Value<String?> localAuthority = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> website = const Value.absent(),
    Value<String?> overallRating = const Value.absent(),
    Value<String?> ratingSafe = const Value.absent(),
    Value<String?> ratingEffective = const Value.absent(),
    Value<String?> ratingCaring = const Value.absent(),
    Value<String?> ratingResponsive = const Value.absent(),
    Value<String?> ratingWellLed = const Value.absent(),
    Value<String?> maternityRating = const Value.absent(),
    Value<String?> maternityRatingDate = const Value.absent(),
    Value<String?> lastInspectionDate = const Value.absent(),
    Value<String?> cqcReportUrl = const Value.absent(),
    Value<String?> registrationStatus = const Value.absent(),
    Value<double?> placeCleanliness = const Value.absent(),
    Value<double?> placeFood = const Value.absent(),
    Value<double?> placePrivacyDignityWellbeing = const Value.absent(),
    Value<double?> placeConditionAppearance = const Value.absent(),
    Value<int?> placeSyncedAtMillis = const Value.absent(),
    Value<String?> birthingOptions = const Value.absent(),
    Value<String?> facilities = const Value.absent(),
    Value<String?> birthStatistics = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    int? createdAtMillis,
    int? updatedAtMillis,
    Value<int?> cqcSyncedAtMillis = const Value.absent(),
  }) => MaternityUnitDto(
    id: id ?? this.id,
    cqcLocationId: cqcLocationId ?? this.cqcLocationId,
    cqcProviderId: cqcProviderId.present
        ? cqcProviderId.value
        : this.cqcProviderId,
    odsCode: odsCode.present ? odsCode.value : this.odsCode,
    name: name ?? this.name,
    providerName: providerName.present ? providerName.value : this.providerName,
    unitType: unitType ?? this.unitType,
    isNhs: isNhs ?? this.isNhs,
    addressLine1: addressLine1.present ? addressLine1.value : this.addressLine1,
    addressLine2: addressLine2.present ? addressLine2.value : this.addressLine2,
    townCity: townCity.present ? townCity.value : this.townCity,
    county: county.present ? county.value : this.county,
    postcode: postcode.present ? postcode.value : this.postcode,
    region: region.present ? region.value : this.region,
    localAuthority: localAuthority.present
        ? localAuthority.value
        : this.localAuthority,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    phone: phone.present ? phone.value : this.phone,
    website: website.present ? website.value : this.website,
    overallRating: overallRating.present
        ? overallRating.value
        : this.overallRating,
    ratingSafe: ratingSafe.present ? ratingSafe.value : this.ratingSafe,
    ratingEffective: ratingEffective.present
        ? ratingEffective.value
        : this.ratingEffective,
    ratingCaring: ratingCaring.present ? ratingCaring.value : this.ratingCaring,
    ratingResponsive: ratingResponsive.present
        ? ratingResponsive.value
        : this.ratingResponsive,
    ratingWellLed: ratingWellLed.present
        ? ratingWellLed.value
        : this.ratingWellLed,
    maternityRating: maternityRating.present
        ? maternityRating.value
        : this.maternityRating,
    maternityRatingDate: maternityRatingDate.present
        ? maternityRatingDate.value
        : this.maternityRatingDate,
    lastInspectionDate: lastInspectionDate.present
        ? lastInspectionDate.value
        : this.lastInspectionDate,
    cqcReportUrl: cqcReportUrl.present ? cqcReportUrl.value : this.cqcReportUrl,
    registrationStatus: registrationStatus.present
        ? registrationStatus.value
        : this.registrationStatus,
    placeCleanliness: placeCleanliness.present
        ? placeCleanliness.value
        : this.placeCleanliness,
    placeFood: placeFood.present ? placeFood.value : this.placeFood,
    placePrivacyDignityWellbeing: placePrivacyDignityWellbeing.present
        ? placePrivacyDignityWellbeing.value
        : this.placePrivacyDignityWellbeing,
    placeConditionAppearance: placeConditionAppearance.present
        ? placeConditionAppearance.value
        : this.placeConditionAppearance,
    placeSyncedAtMillis: placeSyncedAtMillis.present
        ? placeSyncedAtMillis.value
        : this.placeSyncedAtMillis,
    birthingOptions: birthingOptions.present
        ? birthingOptions.value
        : this.birthingOptions,
    facilities: facilities.present ? facilities.value : this.facilities,
    birthStatistics: birthStatistics.present
        ? birthStatistics.value
        : this.birthStatistics,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
    cqcSyncedAtMillis: cqcSyncedAtMillis.present
        ? cqcSyncedAtMillis.value
        : this.cqcSyncedAtMillis,
  );
  MaternityUnitDto copyWithCompanion(MaternityUnitsCompanion data) {
    return MaternityUnitDto(
      id: data.id.present ? data.id.value : this.id,
      cqcLocationId: data.cqcLocationId.present
          ? data.cqcLocationId.value
          : this.cqcLocationId,
      cqcProviderId: data.cqcProviderId.present
          ? data.cqcProviderId.value
          : this.cqcProviderId,
      odsCode: data.odsCode.present ? data.odsCode.value : this.odsCode,
      name: data.name.present ? data.name.value : this.name,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      isNhs: data.isNhs.present ? data.isNhs.value : this.isNhs,
      addressLine1: data.addressLine1.present
          ? data.addressLine1.value
          : this.addressLine1,
      addressLine2: data.addressLine2.present
          ? data.addressLine2.value
          : this.addressLine2,
      townCity: data.townCity.present ? data.townCity.value : this.townCity,
      county: data.county.present ? data.county.value : this.county,
      postcode: data.postcode.present ? data.postcode.value : this.postcode,
      region: data.region.present ? data.region.value : this.region,
      localAuthority: data.localAuthority.present
          ? data.localAuthority.value
          : this.localAuthority,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      phone: data.phone.present ? data.phone.value : this.phone,
      website: data.website.present ? data.website.value : this.website,
      overallRating: data.overallRating.present
          ? data.overallRating.value
          : this.overallRating,
      ratingSafe: data.ratingSafe.present
          ? data.ratingSafe.value
          : this.ratingSafe,
      ratingEffective: data.ratingEffective.present
          ? data.ratingEffective.value
          : this.ratingEffective,
      ratingCaring: data.ratingCaring.present
          ? data.ratingCaring.value
          : this.ratingCaring,
      ratingResponsive: data.ratingResponsive.present
          ? data.ratingResponsive.value
          : this.ratingResponsive,
      ratingWellLed: data.ratingWellLed.present
          ? data.ratingWellLed.value
          : this.ratingWellLed,
      maternityRating: data.maternityRating.present
          ? data.maternityRating.value
          : this.maternityRating,
      maternityRatingDate: data.maternityRatingDate.present
          ? data.maternityRatingDate.value
          : this.maternityRatingDate,
      lastInspectionDate: data.lastInspectionDate.present
          ? data.lastInspectionDate.value
          : this.lastInspectionDate,
      cqcReportUrl: data.cqcReportUrl.present
          ? data.cqcReportUrl.value
          : this.cqcReportUrl,
      registrationStatus: data.registrationStatus.present
          ? data.registrationStatus.value
          : this.registrationStatus,
      placeCleanliness: data.placeCleanliness.present
          ? data.placeCleanliness.value
          : this.placeCleanliness,
      placeFood: data.placeFood.present ? data.placeFood.value : this.placeFood,
      placePrivacyDignityWellbeing: data.placePrivacyDignityWellbeing.present
          ? data.placePrivacyDignityWellbeing.value
          : this.placePrivacyDignityWellbeing,
      placeConditionAppearance: data.placeConditionAppearance.present
          ? data.placeConditionAppearance.value
          : this.placeConditionAppearance,
      placeSyncedAtMillis: data.placeSyncedAtMillis.present
          ? data.placeSyncedAtMillis.value
          : this.placeSyncedAtMillis,
      birthingOptions: data.birthingOptions.present
          ? data.birthingOptions.value
          : this.birthingOptions,
      facilities: data.facilities.present
          ? data.facilities.value
          : this.facilities,
      birthStatistics: data.birthStatistics.present
          ? data.birthStatistics.value
          : this.birthStatistics,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
      cqcSyncedAtMillis: data.cqcSyncedAtMillis.present
          ? data.cqcSyncedAtMillis.value
          : this.cqcSyncedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaternityUnitDto(')
          ..write('id: $id, ')
          ..write('cqcLocationId: $cqcLocationId, ')
          ..write('cqcProviderId: $cqcProviderId, ')
          ..write('odsCode: $odsCode, ')
          ..write('name: $name, ')
          ..write('providerName: $providerName, ')
          ..write('unitType: $unitType, ')
          ..write('isNhs: $isNhs, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('townCity: $townCity, ')
          ..write('county: $county, ')
          ..write('postcode: $postcode, ')
          ..write('region: $region, ')
          ..write('localAuthority: $localAuthority, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('overallRating: $overallRating, ')
          ..write('ratingSafe: $ratingSafe, ')
          ..write('ratingEffective: $ratingEffective, ')
          ..write('ratingCaring: $ratingCaring, ')
          ..write('ratingResponsive: $ratingResponsive, ')
          ..write('ratingWellLed: $ratingWellLed, ')
          ..write('maternityRating: $maternityRating, ')
          ..write('maternityRatingDate: $maternityRatingDate, ')
          ..write('lastInspectionDate: $lastInspectionDate, ')
          ..write('cqcReportUrl: $cqcReportUrl, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('placeCleanliness: $placeCleanliness, ')
          ..write('placeFood: $placeFood, ')
          ..write(
            'placePrivacyDignityWellbeing: $placePrivacyDignityWellbeing, ',
          )
          ..write('placeConditionAppearance: $placeConditionAppearance, ')
          ..write('placeSyncedAtMillis: $placeSyncedAtMillis, ')
          ..write('birthingOptions: $birthingOptions, ')
          ..write('facilities: $facilities, ')
          ..write('birthStatistics: $birthStatistics, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('cqcSyncedAtMillis: $cqcSyncedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    cqcLocationId,
    cqcProviderId,
    odsCode,
    name,
    providerName,
    unitType,
    isNhs,
    addressLine1,
    addressLine2,
    townCity,
    county,
    postcode,
    region,
    localAuthority,
    latitude,
    longitude,
    phone,
    website,
    overallRating,
    ratingSafe,
    ratingEffective,
    ratingCaring,
    ratingResponsive,
    ratingWellLed,
    maternityRating,
    maternityRatingDate,
    lastInspectionDate,
    cqcReportUrl,
    registrationStatus,
    placeCleanliness,
    placeFood,
    placePrivacyDignityWellbeing,
    placeConditionAppearance,
    placeSyncedAtMillis,
    birthingOptions,
    facilities,
    birthStatistics,
    notes,
    isActive,
    createdAtMillis,
    updatedAtMillis,
    cqcSyncedAtMillis,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaternityUnitDto &&
          other.id == this.id &&
          other.cqcLocationId == this.cqcLocationId &&
          other.cqcProviderId == this.cqcProviderId &&
          other.odsCode == this.odsCode &&
          other.name == this.name &&
          other.providerName == this.providerName &&
          other.unitType == this.unitType &&
          other.isNhs == this.isNhs &&
          other.addressLine1 == this.addressLine1 &&
          other.addressLine2 == this.addressLine2 &&
          other.townCity == this.townCity &&
          other.county == this.county &&
          other.postcode == this.postcode &&
          other.region == this.region &&
          other.localAuthority == this.localAuthority &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.phone == this.phone &&
          other.website == this.website &&
          other.overallRating == this.overallRating &&
          other.ratingSafe == this.ratingSafe &&
          other.ratingEffective == this.ratingEffective &&
          other.ratingCaring == this.ratingCaring &&
          other.ratingResponsive == this.ratingResponsive &&
          other.ratingWellLed == this.ratingWellLed &&
          other.maternityRating == this.maternityRating &&
          other.maternityRatingDate == this.maternityRatingDate &&
          other.lastInspectionDate == this.lastInspectionDate &&
          other.cqcReportUrl == this.cqcReportUrl &&
          other.registrationStatus == this.registrationStatus &&
          other.placeCleanliness == this.placeCleanliness &&
          other.placeFood == this.placeFood &&
          other.placePrivacyDignityWellbeing ==
              this.placePrivacyDignityWellbeing &&
          other.placeConditionAppearance == this.placeConditionAppearance &&
          other.placeSyncedAtMillis == this.placeSyncedAtMillis &&
          other.birthingOptions == this.birthingOptions &&
          other.facilities == this.facilities &&
          other.birthStatistics == this.birthStatistics &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis &&
          other.cqcSyncedAtMillis == this.cqcSyncedAtMillis);
}

class MaternityUnitsCompanion extends UpdateCompanion<MaternityUnitDto> {
  final Value<String> id;
  final Value<String> cqcLocationId;
  final Value<String?> cqcProviderId;
  final Value<String?> odsCode;
  final Value<String> name;
  final Value<String?> providerName;
  final Value<String> unitType;
  final Value<bool> isNhs;
  final Value<String?> addressLine1;
  final Value<String?> addressLine2;
  final Value<String?> townCity;
  final Value<String?> county;
  final Value<String?> postcode;
  final Value<String?> region;
  final Value<String?> localAuthority;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> phone;
  final Value<String?> website;
  final Value<String?> overallRating;
  final Value<String?> ratingSafe;
  final Value<String?> ratingEffective;
  final Value<String?> ratingCaring;
  final Value<String?> ratingResponsive;
  final Value<String?> ratingWellLed;
  final Value<String?> maternityRating;
  final Value<String?> maternityRatingDate;
  final Value<String?> lastInspectionDate;
  final Value<String?> cqcReportUrl;
  final Value<String?> registrationStatus;
  final Value<double?> placeCleanliness;
  final Value<double?> placeFood;
  final Value<double?> placePrivacyDignityWellbeing;
  final Value<double?> placeConditionAppearance;
  final Value<int?> placeSyncedAtMillis;
  final Value<String?> birthingOptions;
  final Value<String?> facilities;
  final Value<String?> birthStatistics;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int?> cqcSyncedAtMillis;
  final Value<int> rowid;
  const MaternityUnitsCompanion({
    this.id = const Value.absent(),
    this.cqcLocationId = const Value.absent(),
    this.cqcProviderId = const Value.absent(),
    this.odsCode = const Value.absent(),
    this.name = const Value.absent(),
    this.providerName = const Value.absent(),
    this.unitType = const Value.absent(),
    this.isNhs = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.townCity = const Value.absent(),
    this.county = const Value.absent(),
    this.postcode = const Value.absent(),
    this.region = const Value.absent(),
    this.localAuthority = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.overallRating = const Value.absent(),
    this.ratingSafe = const Value.absent(),
    this.ratingEffective = const Value.absent(),
    this.ratingCaring = const Value.absent(),
    this.ratingResponsive = const Value.absent(),
    this.ratingWellLed = const Value.absent(),
    this.maternityRating = const Value.absent(),
    this.maternityRatingDate = const Value.absent(),
    this.lastInspectionDate = const Value.absent(),
    this.cqcReportUrl = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.placeCleanliness = const Value.absent(),
    this.placeFood = const Value.absent(),
    this.placePrivacyDignityWellbeing = const Value.absent(),
    this.placeConditionAppearance = const Value.absent(),
    this.placeSyncedAtMillis = const Value.absent(),
    this.birthingOptions = const Value.absent(),
    this.facilities = const Value.absent(),
    this.birthStatistics = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.cqcSyncedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaternityUnitsCompanion.insert({
    required String id,
    required String cqcLocationId,
    this.cqcProviderId = const Value.absent(),
    this.odsCode = const Value.absent(),
    required String name,
    this.providerName = const Value.absent(),
    required String unitType,
    this.isNhs = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.townCity = const Value.absent(),
    this.county = const Value.absent(),
    this.postcode = const Value.absent(),
    this.region = const Value.absent(),
    this.localAuthority = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.overallRating = const Value.absent(),
    this.ratingSafe = const Value.absent(),
    this.ratingEffective = const Value.absent(),
    this.ratingCaring = const Value.absent(),
    this.ratingResponsive = const Value.absent(),
    this.ratingWellLed = const Value.absent(),
    this.maternityRating = const Value.absent(),
    this.maternityRatingDate = const Value.absent(),
    this.lastInspectionDate = const Value.absent(),
    this.cqcReportUrl = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.placeCleanliness = const Value.absent(),
    this.placeFood = const Value.absent(),
    this.placePrivacyDignityWellbeing = const Value.absent(),
    this.placeConditionAppearance = const Value.absent(),
    this.placeSyncedAtMillis = const Value.absent(),
    this.birthingOptions = const Value.absent(),
    this.facilities = const Value.absent(),
    this.birthStatistics = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.cqcSyncedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cqcLocationId = Value(cqcLocationId),
       name = Value(name),
       unitType = Value(unitType),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<MaternityUnitDto> custom({
    Expression<String>? id,
    Expression<String>? cqcLocationId,
    Expression<String>? cqcProviderId,
    Expression<String>? odsCode,
    Expression<String>? name,
    Expression<String>? providerName,
    Expression<String>? unitType,
    Expression<bool>? isNhs,
    Expression<String>? addressLine1,
    Expression<String>? addressLine2,
    Expression<String>? townCity,
    Expression<String>? county,
    Expression<String>? postcode,
    Expression<String>? region,
    Expression<String>? localAuthority,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? phone,
    Expression<String>? website,
    Expression<String>? overallRating,
    Expression<String>? ratingSafe,
    Expression<String>? ratingEffective,
    Expression<String>? ratingCaring,
    Expression<String>? ratingResponsive,
    Expression<String>? ratingWellLed,
    Expression<String>? maternityRating,
    Expression<String>? maternityRatingDate,
    Expression<String>? lastInspectionDate,
    Expression<String>? cqcReportUrl,
    Expression<String>? registrationStatus,
    Expression<double>? placeCleanliness,
    Expression<double>? placeFood,
    Expression<double>? placePrivacyDignityWellbeing,
    Expression<double>? placeConditionAppearance,
    Expression<int>? placeSyncedAtMillis,
    Expression<String>? birthingOptions,
    Expression<String>? facilities,
    Expression<String>? birthStatistics,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? cqcSyncedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cqcLocationId != null) 'cqc_location_id': cqcLocationId,
      if (cqcProviderId != null) 'cqc_provider_id': cqcProviderId,
      if (odsCode != null) 'ods_code': odsCode,
      if (name != null) 'name': name,
      if (providerName != null) 'provider_name': providerName,
      if (unitType != null) 'unit_type': unitType,
      if (isNhs != null) 'is_nhs': isNhs,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (townCity != null) 'town_city': townCity,
      if (county != null) 'county': county,
      if (postcode != null) 'postcode': postcode,
      if (region != null) 'region': region,
      if (localAuthority != null) 'local_authority': localAuthority,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (overallRating != null) 'overall_rating': overallRating,
      if (ratingSafe != null) 'rating_safe': ratingSafe,
      if (ratingEffective != null) 'rating_effective': ratingEffective,
      if (ratingCaring != null) 'rating_caring': ratingCaring,
      if (ratingResponsive != null) 'rating_responsive': ratingResponsive,
      if (ratingWellLed != null) 'rating_well_led': ratingWellLed,
      if (maternityRating != null) 'maternity_rating': maternityRating,
      if (maternityRatingDate != null)
        'maternity_rating_date': maternityRatingDate,
      if (lastInspectionDate != null)
        'last_inspection_date': lastInspectionDate,
      if (cqcReportUrl != null) 'cqc_report_url': cqcReportUrl,
      if (registrationStatus != null) 'registration_status': registrationStatus,
      if (placeCleanliness != null) 'place_cleanliness': placeCleanliness,
      if (placeFood != null) 'place_food': placeFood,
      if (placePrivacyDignityWellbeing != null)
        'place_privacy_dignity_wellbeing': placePrivacyDignityWellbeing,
      if (placeConditionAppearance != null)
        'place_condition_appearance': placeConditionAppearance,
      if (placeSyncedAtMillis != null)
        'place_synced_at_millis': placeSyncedAtMillis,
      if (birthingOptions != null) 'birthing_options': birthingOptions,
      if (facilities != null) 'facilities': facilities,
      if (birthStatistics != null) 'birth_statistics': birthStatistics,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (cqcSyncedAtMillis != null) 'cqc_synced_at_millis': cqcSyncedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaternityUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? cqcLocationId,
    Value<String?>? cqcProviderId,
    Value<String?>? odsCode,
    Value<String>? name,
    Value<String?>? providerName,
    Value<String>? unitType,
    Value<bool>? isNhs,
    Value<String?>? addressLine1,
    Value<String?>? addressLine2,
    Value<String?>? townCity,
    Value<String?>? county,
    Value<String?>? postcode,
    Value<String?>? region,
    Value<String?>? localAuthority,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? phone,
    Value<String?>? website,
    Value<String?>? overallRating,
    Value<String?>? ratingSafe,
    Value<String?>? ratingEffective,
    Value<String?>? ratingCaring,
    Value<String?>? ratingResponsive,
    Value<String?>? ratingWellLed,
    Value<String?>? maternityRating,
    Value<String?>? maternityRatingDate,
    Value<String?>? lastInspectionDate,
    Value<String?>? cqcReportUrl,
    Value<String?>? registrationStatus,
    Value<double?>? placeCleanliness,
    Value<double?>? placeFood,
    Value<double?>? placePrivacyDignityWellbeing,
    Value<double?>? placeConditionAppearance,
    Value<int?>? placeSyncedAtMillis,
    Value<String?>? birthingOptions,
    Value<String?>? facilities,
    Value<String?>? birthStatistics,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int?>? cqcSyncedAtMillis,
    Value<int>? rowid,
  }) {
    return MaternityUnitsCompanion(
      id: id ?? this.id,
      cqcLocationId: cqcLocationId ?? this.cqcLocationId,
      cqcProviderId: cqcProviderId ?? this.cqcProviderId,
      odsCode: odsCode ?? this.odsCode,
      name: name ?? this.name,
      providerName: providerName ?? this.providerName,
      unitType: unitType ?? this.unitType,
      isNhs: isNhs ?? this.isNhs,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      townCity: townCity ?? this.townCity,
      county: county ?? this.county,
      postcode: postcode ?? this.postcode,
      region: region ?? this.region,
      localAuthority: localAuthority ?? this.localAuthority,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      overallRating: overallRating ?? this.overallRating,
      ratingSafe: ratingSafe ?? this.ratingSafe,
      ratingEffective: ratingEffective ?? this.ratingEffective,
      ratingCaring: ratingCaring ?? this.ratingCaring,
      ratingResponsive: ratingResponsive ?? this.ratingResponsive,
      ratingWellLed: ratingWellLed ?? this.ratingWellLed,
      maternityRating: maternityRating ?? this.maternityRating,
      maternityRatingDate: maternityRatingDate ?? this.maternityRatingDate,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      cqcReportUrl: cqcReportUrl ?? this.cqcReportUrl,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      placeCleanliness: placeCleanliness ?? this.placeCleanliness,
      placeFood: placeFood ?? this.placeFood,
      placePrivacyDignityWellbeing:
          placePrivacyDignityWellbeing ?? this.placePrivacyDignityWellbeing,
      placeConditionAppearance:
          placeConditionAppearance ?? this.placeConditionAppearance,
      placeSyncedAtMillis: placeSyncedAtMillis ?? this.placeSyncedAtMillis,
      birthingOptions: birthingOptions ?? this.birthingOptions,
      facilities: facilities ?? this.facilities,
      birthStatistics: birthStatistics ?? this.birthStatistics,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      cqcSyncedAtMillis: cqcSyncedAtMillis ?? this.cqcSyncedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cqcLocationId.present) {
      map['cqc_location_id'] = Variable<String>(cqcLocationId.value);
    }
    if (cqcProviderId.present) {
      map['cqc_provider_id'] = Variable<String>(cqcProviderId.value);
    }
    if (odsCode.present) {
      map['ods_code'] = Variable<String>(odsCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (isNhs.present) {
      map['is_nhs'] = Variable<bool>(isNhs.value);
    }
    if (addressLine1.present) {
      map['address_line1'] = Variable<String>(addressLine1.value);
    }
    if (addressLine2.present) {
      map['address_line2'] = Variable<String>(addressLine2.value);
    }
    if (townCity.present) {
      map['town_city'] = Variable<String>(townCity.value);
    }
    if (county.present) {
      map['county'] = Variable<String>(county.value);
    }
    if (postcode.present) {
      map['postcode'] = Variable<String>(postcode.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (localAuthority.present) {
      map['local_authority'] = Variable<String>(localAuthority.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (overallRating.present) {
      map['overall_rating'] = Variable<String>(overallRating.value);
    }
    if (ratingSafe.present) {
      map['rating_safe'] = Variable<String>(ratingSafe.value);
    }
    if (ratingEffective.present) {
      map['rating_effective'] = Variable<String>(ratingEffective.value);
    }
    if (ratingCaring.present) {
      map['rating_caring'] = Variable<String>(ratingCaring.value);
    }
    if (ratingResponsive.present) {
      map['rating_responsive'] = Variable<String>(ratingResponsive.value);
    }
    if (ratingWellLed.present) {
      map['rating_well_led'] = Variable<String>(ratingWellLed.value);
    }
    if (maternityRating.present) {
      map['maternity_rating'] = Variable<String>(maternityRating.value);
    }
    if (maternityRatingDate.present) {
      map['maternity_rating_date'] = Variable<String>(
        maternityRatingDate.value,
      );
    }
    if (lastInspectionDate.present) {
      map['last_inspection_date'] = Variable<String>(lastInspectionDate.value);
    }
    if (cqcReportUrl.present) {
      map['cqc_report_url'] = Variable<String>(cqcReportUrl.value);
    }
    if (registrationStatus.present) {
      map['registration_status'] = Variable<String>(registrationStatus.value);
    }
    if (placeCleanliness.present) {
      map['place_cleanliness'] = Variable<double>(placeCleanliness.value);
    }
    if (placeFood.present) {
      map['place_food'] = Variable<double>(placeFood.value);
    }
    if (placePrivacyDignityWellbeing.present) {
      map['place_privacy_dignity_wellbeing'] = Variable<double>(
        placePrivacyDignityWellbeing.value,
      );
    }
    if (placeConditionAppearance.present) {
      map['place_condition_appearance'] = Variable<double>(
        placeConditionAppearance.value,
      );
    }
    if (placeSyncedAtMillis.present) {
      map['place_synced_at_millis'] = Variable<int>(placeSyncedAtMillis.value);
    }
    if (birthingOptions.present) {
      map['birthing_options'] = Variable<String>(birthingOptions.value);
    }
    if (facilities.present) {
      map['facilities'] = Variable<String>(facilities.value);
    }
    if (birthStatistics.present) {
      map['birth_statistics'] = Variable<String>(birthStatistics.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (cqcSyncedAtMillis.present) {
      map['cqc_synced_at_millis'] = Variable<int>(cqcSyncedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaternityUnitsCompanion(')
          ..write('id: $id, ')
          ..write('cqcLocationId: $cqcLocationId, ')
          ..write('cqcProviderId: $cqcProviderId, ')
          ..write('odsCode: $odsCode, ')
          ..write('name: $name, ')
          ..write('providerName: $providerName, ')
          ..write('unitType: $unitType, ')
          ..write('isNhs: $isNhs, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('townCity: $townCity, ')
          ..write('county: $county, ')
          ..write('postcode: $postcode, ')
          ..write('region: $region, ')
          ..write('localAuthority: $localAuthority, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('overallRating: $overallRating, ')
          ..write('ratingSafe: $ratingSafe, ')
          ..write('ratingEffective: $ratingEffective, ')
          ..write('ratingCaring: $ratingCaring, ')
          ..write('ratingResponsive: $ratingResponsive, ')
          ..write('ratingWellLed: $ratingWellLed, ')
          ..write('maternityRating: $maternityRating, ')
          ..write('maternityRatingDate: $maternityRatingDate, ')
          ..write('lastInspectionDate: $lastInspectionDate, ')
          ..write('cqcReportUrl: $cqcReportUrl, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('placeCleanliness: $placeCleanliness, ')
          ..write('placeFood: $placeFood, ')
          ..write(
            'placePrivacyDignityWellbeing: $placePrivacyDignityWellbeing, ',
          )
          ..write('placeConditionAppearance: $placeConditionAppearance, ')
          ..write('placeSyncedAtMillis: $placeSyncedAtMillis, ')
          ..write('birthingOptions: $birthingOptions, ')
          ..write('facilities: $facilities, ')
          ..write('birthStatistics: $birthStatistics, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('cqcSyncedAtMillis: $cqcSyncedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HospitalShortlistsTable extends HospitalShortlists
    with TableInfo<$HospitalShortlistsTable, HospitalShortlistDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HospitalShortlistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maternityUnitIdMeta = const VerificationMeta(
    'maternityUnitId',
  );
  @override
  late final GeneratedColumn<String> maternityUnitId = GeneratedColumn<String>(
    'maternity_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES maternity_units (id)',
    ),
  );
  static const VerificationMeta _addedAtMillisMeta = const VerificationMeta(
    'addedAtMillis',
  );
  @override
  late final GeneratedColumn<int> addedAtMillis = GeneratedColumn<int>(
    'added_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSelectedMeta = const VerificationMeta(
    'isSelected',
  );
  @override
  late final GeneratedColumn<bool> isSelected = GeneratedColumn<bool>(
    'is_selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_selected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    maternityUnitId,
    addedAtMillis,
    isSelected,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hospital_shortlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<HospitalShortlistDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maternity_unit_id')) {
      context.handle(
        _maternityUnitIdMeta,
        maternityUnitId.isAcceptableOrUnknown(
          data['maternity_unit_id']!,
          _maternityUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maternityUnitIdMeta);
    }
    if (data.containsKey('added_at_millis')) {
      context.handle(
        _addedAtMillisMeta,
        addedAtMillis.isAcceptableOrUnknown(
          data['added_at_millis']!,
          _addedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedAtMillisMeta);
    }
    if (data.containsKey('is_selected')) {
      context.handle(
        _isSelectedMeta,
        isSelected.isAcceptableOrUnknown(data['is_selected']!, _isSelectedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HospitalShortlistDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HospitalShortlistDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      maternityUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maternity_unit_id'],
      )!,
      addedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at_millis'],
      )!,
      isSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_selected'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $HospitalShortlistsTable createAlias(String alias) {
    return $HospitalShortlistsTable(attachedDatabase, alias);
  }
}

class HospitalShortlistDto extends DataClass
    implements Insertable<HospitalShortlistDto> {
  /// UUID primary key.
  final String id;

  /// Reference to the maternity unit.
  final String maternityUnitId;

  /// When this hospital was added to the shortlist (millis since epoch).
  final int addedAtMillis;

  /// Whether this is the final selected hospital.
  final bool isSelected;

  /// Optional user notes about this hospital.
  final String? notes;
  const HospitalShortlistDto({
    required this.id,
    required this.maternityUnitId,
    required this.addedAtMillis,
    required this.isSelected,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maternity_unit_id'] = Variable<String>(maternityUnitId);
    map['added_at_millis'] = Variable<int>(addedAtMillis);
    map['is_selected'] = Variable<bool>(isSelected);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  HospitalShortlistsCompanion toCompanion(bool nullToAbsent) {
    return HospitalShortlistsCompanion(
      id: Value(id),
      maternityUnitId: Value(maternityUnitId),
      addedAtMillis: Value(addedAtMillis),
      isSelected: Value(isSelected),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory HospitalShortlistDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HospitalShortlistDto(
      id: serializer.fromJson<String>(json['id']),
      maternityUnitId: serializer.fromJson<String>(json['maternityUnitId']),
      addedAtMillis: serializer.fromJson<int>(json['addedAtMillis']),
      isSelected: serializer.fromJson<bool>(json['isSelected']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'maternityUnitId': serializer.toJson<String>(maternityUnitId),
      'addedAtMillis': serializer.toJson<int>(addedAtMillis),
      'isSelected': serializer.toJson<bool>(isSelected),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  HospitalShortlistDto copyWith({
    String? id,
    String? maternityUnitId,
    int? addedAtMillis,
    bool? isSelected,
    Value<String?> notes = const Value.absent(),
  }) => HospitalShortlistDto(
    id: id ?? this.id,
    maternityUnitId: maternityUnitId ?? this.maternityUnitId,
    addedAtMillis: addedAtMillis ?? this.addedAtMillis,
    isSelected: isSelected ?? this.isSelected,
    notes: notes.present ? notes.value : this.notes,
  );
  HospitalShortlistDto copyWithCompanion(HospitalShortlistsCompanion data) {
    return HospitalShortlistDto(
      id: data.id.present ? data.id.value : this.id,
      maternityUnitId: data.maternityUnitId.present
          ? data.maternityUnitId.value
          : this.maternityUnitId,
      addedAtMillis: data.addedAtMillis.present
          ? data.addedAtMillis.value
          : this.addedAtMillis,
      isSelected: data.isSelected.present
          ? data.isSelected.value
          : this.isSelected,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HospitalShortlistDto(')
          ..write('id: $id, ')
          ..write('maternityUnitId: $maternityUnitId, ')
          ..write('addedAtMillis: $addedAtMillis, ')
          ..write('isSelected: $isSelected, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, maternityUnitId, addedAtMillis, isSelected, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HospitalShortlistDto &&
          other.id == this.id &&
          other.maternityUnitId == this.maternityUnitId &&
          other.addedAtMillis == this.addedAtMillis &&
          other.isSelected == this.isSelected &&
          other.notes == this.notes);
}

class HospitalShortlistsCompanion
    extends UpdateCompanion<HospitalShortlistDto> {
  final Value<String> id;
  final Value<String> maternityUnitId;
  final Value<int> addedAtMillis;
  final Value<bool> isSelected;
  final Value<String?> notes;
  final Value<int> rowid;
  const HospitalShortlistsCompanion({
    this.id = const Value.absent(),
    this.maternityUnitId = const Value.absent(),
    this.addedAtMillis = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HospitalShortlistsCompanion.insert({
    required String id,
    required String maternityUnitId,
    required int addedAtMillis,
    this.isSelected = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       maternityUnitId = Value(maternityUnitId),
       addedAtMillis = Value(addedAtMillis);
  static Insertable<HospitalShortlistDto> custom({
    Expression<String>? id,
    Expression<String>? maternityUnitId,
    Expression<int>? addedAtMillis,
    Expression<bool>? isSelected,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maternityUnitId != null) 'maternity_unit_id': maternityUnitId,
      if (addedAtMillis != null) 'added_at_millis': addedAtMillis,
      if (isSelected != null) 'is_selected': isSelected,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HospitalShortlistsCompanion copyWith({
    Value<String>? id,
    Value<String>? maternityUnitId,
    Value<int>? addedAtMillis,
    Value<bool>? isSelected,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return HospitalShortlistsCompanion(
      id: id ?? this.id,
      maternityUnitId: maternityUnitId ?? this.maternityUnitId,
      addedAtMillis: addedAtMillis ?? this.addedAtMillis,
      isSelected: isSelected ?? this.isSelected,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (maternityUnitId.present) {
      map['maternity_unit_id'] = Variable<String>(maternityUnitId.value);
    }
    if (addedAtMillis.present) {
      map['added_at_millis'] = Variable<int>(addedAtMillis.value);
    }
    if (isSelected.present) {
      map['is_selected'] = Variable<bool>(isSelected.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HospitalShortlistsCompanion(')
          ..write('id: $id, ')
          ..write('maternityUnitId: $maternityUnitId, ')
          ..write('addedAtMillis: $addedAtMillis, ')
          ..write('isSelected: $isSelected, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadatasTable extends SyncMetadatas
    with TableInfo<$SyncMetadatasTable, SyncMetadataDto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadatasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMillisMeta = const VerificationMeta(
    'lastSyncAtMillis',
  );
  @override
  late final GeneratedColumn<int> lastSyncAtMillis = GeneratedColumn<int>(
    'last_sync_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncStatusMeta = const VerificationMeta(
    'lastSyncStatus',
  );
  @override
  late final GeneratedColumn<String> lastSyncStatus = GeneratedColumn<String>(
    'last_sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncCountMeta = const VerificationMeta(
    'lastSyncCount',
  );
  @override
  late final GeneratedColumn<int> lastSyncCount = GeneratedColumn<int>(
    'last_sync_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataVersionCodeMeta = const VerificationMeta(
    'dataVersionCode',
  );
  @override
  late final GeneratedColumn<int> dataVersionCode = GeneratedColumn<int>(
    'data_version_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    lastSyncAtMillis,
    lastSyncStatus,
    lastSyncCount,
    lastError,
    dataVersionCode,
    createdAtMillis,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadatas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataDto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_sync_at_millis')) {
      context.handle(
        _lastSyncAtMillisMeta,
        lastSyncAtMillis.isAcceptableOrUnknown(
          data['last_sync_at_millis']!,
          _lastSyncAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_status')) {
      context.handle(
        _lastSyncStatusMeta,
        lastSyncStatus.isAcceptableOrUnknown(
          data['last_sync_status']!,
          _lastSyncStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_count')) {
      context.handle(
        _lastSyncCountMeta,
        lastSyncCount.isAcceptableOrUnknown(
          data['last_sync_count']!,
          _lastSyncCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('data_version_code')) {
      context.handle(
        _dataVersionCodeMeta,
        dataVersionCode.isAcceptableOrUnknown(
          data['data_version_code']!,
          _dataVersionCodeMeta,
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
  SyncMetadataDto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataDto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lastSyncAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_at_millis'],
      ),
      lastSyncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_status'],
      ),
      lastSyncCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      dataVersionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}data_version_code'],
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
  $SyncMetadatasTable createAlias(String alias) {
    return $SyncMetadatasTable(attachedDatabase, alias);
  }
}

class SyncMetadataDto extends DataClass implements Insertable<SyncMetadataDto> {
  /// Unique identifier for the sync target (e.g., "maternity_units").
  final String id;

  /// When data was last successfully synced (millis since epoch).
  final int? lastSyncAtMillis;

  /// Status of the last sync attempt.
  final String? lastSyncStatus;

  /// Number of records processed in the last sync.
  final int lastSyncCount;

  /// Error message from the last failed sync attempt.
  final String? lastError;

  /// Version code of the pre-packaged JSON data.
  final int dataVersionCode;

  /// When this metadata record was created (millis since epoch).
  final int createdAtMillis;

  /// When this metadata record was last updated (millis since epoch).
  final int updatedAtMillis;
  const SyncMetadataDto({
    required this.id,
    this.lastSyncAtMillis,
    this.lastSyncStatus,
    required this.lastSyncCount,
    this.lastError,
    required this.dataVersionCode,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || lastSyncAtMillis != null) {
      map['last_sync_at_millis'] = Variable<int>(lastSyncAtMillis);
    }
    if (!nullToAbsent || lastSyncStatus != null) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus);
    }
    map['last_sync_count'] = Variable<int>(lastSyncCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['data_version_code'] = Variable<int>(dataVersionCode);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  SyncMetadatasCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadatasCompanion(
      id: Value(id),
      lastSyncAtMillis: lastSyncAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAtMillis),
      lastSyncStatus: lastSyncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncStatus),
      lastSyncCount: Value(lastSyncCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      dataVersionCode: Value(dataVersionCode),
      createdAtMillis: Value(createdAtMillis),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory SyncMetadataDto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataDto(
      id: serializer.fromJson<String>(json['id']),
      lastSyncAtMillis: serializer.fromJson<int?>(json['lastSyncAtMillis']),
      lastSyncStatus: serializer.fromJson<String?>(json['lastSyncStatus']),
      lastSyncCount: serializer.fromJson<int>(json['lastSyncCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      dataVersionCode: serializer.fromJson<int>(json['dataVersionCode']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastSyncAtMillis': serializer.toJson<int?>(lastSyncAtMillis),
      'lastSyncStatus': serializer.toJson<String?>(lastSyncStatus),
      'lastSyncCount': serializer.toJson<int>(lastSyncCount),
      'lastError': serializer.toJson<String?>(lastError),
      'dataVersionCode': serializer.toJson<int>(dataVersionCode),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  SyncMetadataDto copyWith({
    String? id,
    Value<int?> lastSyncAtMillis = const Value.absent(),
    Value<String?> lastSyncStatus = const Value.absent(),
    int? lastSyncCount,
    Value<String?> lastError = const Value.absent(),
    int? dataVersionCode,
    int? createdAtMillis,
    int? updatedAtMillis,
  }) => SyncMetadataDto(
    id: id ?? this.id,
    lastSyncAtMillis: lastSyncAtMillis.present
        ? lastSyncAtMillis.value
        : this.lastSyncAtMillis,
    lastSyncStatus: lastSyncStatus.present
        ? lastSyncStatus.value
        : this.lastSyncStatus,
    lastSyncCount: lastSyncCount ?? this.lastSyncCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    dataVersionCode: dataVersionCode ?? this.dataVersionCode,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  SyncMetadataDto copyWithCompanion(SyncMetadatasCompanion data) {
    return SyncMetadataDto(
      id: data.id.present ? data.id.value : this.id,
      lastSyncAtMillis: data.lastSyncAtMillis.present
          ? data.lastSyncAtMillis.value
          : this.lastSyncAtMillis,
      lastSyncStatus: data.lastSyncStatus.present
          ? data.lastSyncStatus.value
          : this.lastSyncStatus,
      lastSyncCount: data.lastSyncCount.present
          ? data.lastSyncCount.value
          : this.lastSyncCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      dataVersionCode: data.dataVersionCode.present
          ? data.dataVersionCode.value
          : this.dataVersionCode,
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
    return (StringBuffer('SyncMetadataDto(')
          ..write('id: $id, ')
          ..write('lastSyncAtMillis: $lastSyncAtMillis, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncCount: $lastSyncCount, ')
          ..write('lastError: $lastError, ')
          ..write('dataVersionCode: $dataVersionCode, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastSyncAtMillis,
    lastSyncStatus,
    lastSyncCount,
    lastError,
    dataVersionCode,
    createdAtMillis,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataDto &&
          other.id == this.id &&
          other.lastSyncAtMillis == this.lastSyncAtMillis &&
          other.lastSyncStatus == this.lastSyncStatus &&
          other.lastSyncCount == this.lastSyncCount &&
          other.lastError == this.lastError &&
          other.dataVersionCode == this.dataVersionCode &&
          other.createdAtMillis == this.createdAtMillis &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class SyncMetadatasCompanion extends UpdateCompanion<SyncMetadataDto> {
  final Value<String> id;
  final Value<int?> lastSyncAtMillis;
  final Value<String?> lastSyncStatus;
  final Value<int> lastSyncCount;
  final Value<String?> lastError;
  final Value<int> dataVersionCode;
  final Value<int> createdAtMillis;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const SyncMetadatasCompanion({
    this.id = const Value.absent(),
    this.lastSyncAtMillis = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.dataVersionCode = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadatasCompanion.insert({
    required String id,
    this.lastSyncAtMillis = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.dataVersionCode = const Value.absent(),
    required int createdAtMillis,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtMillis = Value(createdAtMillis),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<SyncMetadataDto> custom({
    Expression<String>? id,
    Expression<int>? lastSyncAtMillis,
    Expression<String>? lastSyncStatus,
    Expression<int>? lastSyncCount,
    Expression<String>? lastError,
    Expression<int>? dataVersionCode,
    Expression<int>? createdAtMillis,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncAtMillis != null) 'last_sync_at_millis': lastSyncAtMillis,
      if (lastSyncStatus != null) 'last_sync_status': lastSyncStatus,
      if (lastSyncCount != null) 'last_sync_count': lastSyncCount,
      if (lastError != null) 'last_error': lastError,
      if (dataVersionCode != null) 'data_version_code': dataVersionCode,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadatasCompanion copyWith({
    Value<String>? id,
    Value<int?>? lastSyncAtMillis,
    Value<String?>? lastSyncStatus,
    Value<int>? lastSyncCount,
    Value<String?>? lastError,
    Value<int>? dataVersionCode,
    Value<int>? createdAtMillis,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return SyncMetadatasCompanion(
      id: id ?? this.id,
      lastSyncAtMillis: lastSyncAtMillis ?? this.lastSyncAtMillis,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncCount: lastSyncCount ?? this.lastSyncCount,
      lastError: lastError ?? this.lastError,
      dataVersionCode: dataVersionCode ?? this.dataVersionCode,
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
    if (lastSyncAtMillis.present) {
      map['last_sync_at_millis'] = Variable<int>(lastSyncAtMillis.value);
    }
    if (lastSyncStatus.present) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus.value);
    }
    if (lastSyncCount.present) {
      map['last_sync_count'] = Variable<int>(lastSyncCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (dataVersionCode.present) {
      map['data_version_code'] = Variable<int>(dataVersionCode.value);
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
    return (StringBuffer('SyncMetadatasCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncAtMillis: $lastSyncAtMillis, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncCount: $lastSyncCount, ')
          ..write('lastError: $lastError, ')
          ..write('dataVersionCode: $dataVersionCode, ')
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
  late final $ContractionSessionsTable contractionSessions =
      $ContractionSessionsTable(this);
  late final $ContractionsTable contractions = $ContractionsTable(this);
  late final $BumpPhotosTable bumpPhotos = $BumpPhotosTable(this);
  late final $MaternityUnitsTable maternityUnits = $MaternityUnitsTable(this);
  late final $HospitalShortlistsTable hospitalShortlists =
      $HospitalShortlistsTable(this);
  late final $SyncMetadatasTable syncMetadatas = $SyncMetadatasTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final PregnancyDao pregnancyDao = PregnancyDao(this as AppDatabase);
  late final KickCounterDao kickCounterDao = KickCounterDao(
    this as AppDatabase,
  );
  late final ContractionTimerDao contractionTimerDao = ContractionTimerDao(
    this as AppDatabase,
  );
  late final BumpPhotoDao bumpPhotoDao = BumpPhotoDao(this as AppDatabase);
  late final MaternityUnitDao maternityUnitDao = MaternityUnitDao(
    this as AppDatabase,
  );
  late final HospitalShortlistDao hospitalShortlistDao = HospitalShortlistDao(
    this as AppDatabase,
  );
  late final SyncMetadataDao syncMetadataDao = SyncMetadataDao(
    this as AppDatabase,
  );
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
    contractionSessions,
    contractions,
    bumpPhotos,
    maternityUnits,
    hospitalShortlists,
    syncMetadatas,
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
      Value<String?> postcode,
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
      Value<String?> postcode,
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

  ColumnFilters<String> get postcode => $composableBuilder(
    column: $table.postcode,
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

  ColumnOrderings<String> get postcode => $composableBuilder(
    column: $table.postcode,
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

  GeneratedColumn<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => column);

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
                Value<String?> postcode = const Value.absent(),
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
                postcode: postcode,
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
                Value<String?> postcode = const Value.absent(),
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
                postcode: postcode,
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
typedef $$ContractionSessionsTableCreateCompanionBuilder =
    ContractionSessionsCompanion Function({
      required String id,
      required int startTimeMillis,
      Value<int?> endTimeMillis,
      Value<bool> isActive,
      Value<bool> achievedDuration,
      Value<int?> durationAchievedAtMillis,
      Value<bool> achievedFrequency,
      Value<int?> frequencyAchievedAtMillis,
      Value<bool> achievedConsistency,
      Value<int?> consistencyAchievedAtMillis,
      Value<String?> note,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ContractionSessionsTableUpdateCompanionBuilder =
    ContractionSessionsCompanion Function({
      Value<String> id,
      Value<int> startTimeMillis,
      Value<int?> endTimeMillis,
      Value<bool> isActive,
      Value<bool> achievedDuration,
      Value<int?> durationAchievedAtMillis,
      Value<bool> achievedFrequency,
      Value<int?> frequencyAchievedAtMillis,
      Value<bool> achievedConsistency,
      Value<int?> consistencyAchievedAtMillis,
      Value<String?> note,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ContractionSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractionSessionsTable> {
  $$ContractionSessionsTableFilterComposer({
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

  ColumnFilters<bool> get achievedDuration => $composableBuilder(
    column: $table.achievedDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationAchievedAtMillis => $composableBuilder(
    column: $table.durationAchievedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get achievedFrequency => $composableBuilder(
    column: $table.achievedFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyAchievedAtMillis => $composableBuilder(
    column: $table.frequencyAchievedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get achievedConsistency => $composableBuilder(
    column: $table.achievedConsistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consistencyAchievedAtMillis => $composableBuilder(
    column: $table.consistencyAchievedAtMillis,
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

class $$ContractionSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractionSessionsTable> {
  $$ContractionSessionsTableOrderingComposer({
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

  ColumnOrderings<bool> get achievedDuration => $composableBuilder(
    column: $table.achievedDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationAchievedAtMillis => $composableBuilder(
    column: $table.durationAchievedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get achievedFrequency => $composableBuilder(
    column: $table.achievedFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyAchievedAtMillis => $composableBuilder(
    column: $table.frequencyAchievedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get achievedConsistency => $composableBuilder(
    column: $table.achievedConsistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consistencyAchievedAtMillis => $composableBuilder(
    column: $table.consistencyAchievedAtMillis,
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

class $$ContractionSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractionSessionsTable> {
  $$ContractionSessionsTableAnnotationComposer({
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

  GeneratedColumn<bool> get achievedDuration => $composableBuilder(
    column: $table.achievedDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationAchievedAtMillis => $composableBuilder(
    column: $table.durationAchievedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get achievedFrequency => $composableBuilder(
    column: $table.achievedFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequencyAchievedAtMillis => $composableBuilder(
    column: $table.frequencyAchievedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get achievedConsistency => $composableBuilder(
    column: $table.achievedConsistency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consistencyAchievedAtMillis => $composableBuilder(
    column: $table.consistencyAchievedAtMillis,
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

class $$ContractionSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractionSessionsTable,
          ContractionSessionDto,
          $$ContractionSessionsTableFilterComposer,
          $$ContractionSessionsTableOrderingComposer,
          $$ContractionSessionsTableAnnotationComposer,
          $$ContractionSessionsTableCreateCompanionBuilder,
          $$ContractionSessionsTableUpdateCompanionBuilder,
          (
            ContractionSessionDto,
            BaseReferences<
              _$AppDatabase,
              $ContractionSessionsTable,
              ContractionSessionDto
            >,
          ),
          ContractionSessionDto,
          PrefetchHooks Function()
        > {
  $$ContractionSessionsTableTableManager(
    _$AppDatabase db,
    $ContractionSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractionSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractionSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContractionSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startTimeMillis = const Value.absent(),
                Value<int?> endTimeMillis = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> achievedDuration = const Value.absent(),
                Value<int?> durationAchievedAtMillis = const Value.absent(),
                Value<bool> achievedFrequency = const Value.absent(),
                Value<int?> frequencyAchievedAtMillis = const Value.absent(),
                Value<bool> achievedConsistency = const Value.absent(),
                Value<int?> consistencyAchievedAtMillis = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractionSessionsCompanion(
                id: id,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                isActive: isActive,
                achievedDuration: achievedDuration,
                durationAchievedAtMillis: durationAchievedAtMillis,
                achievedFrequency: achievedFrequency,
                frequencyAchievedAtMillis: frequencyAchievedAtMillis,
                achievedConsistency: achievedConsistency,
                consistencyAchievedAtMillis: consistencyAchievedAtMillis,
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
                Value<bool> achievedDuration = const Value.absent(),
                Value<int?> durationAchievedAtMillis = const Value.absent(),
                Value<bool> achievedFrequency = const Value.absent(),
                Value<int?> frequencyAchievedAtMillis = const Value.absent(),
                Value<bool> achievedConsistency = const Value.absent(),
                Value<int?> consistencyAchievedAtMillis = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ContractionSessionsCompanion.insert(
                id: id,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                isActive: isActive,
                achievedDuration: achievedDuration,
                durationAchievedAtMillis: durationAchievedAtMillis,
                achievedFrequency: achievedFrequency,
                frequencyAchievedAtMillis: frequencyAchievedAtMillis,
                achievedConsistency: achievedConsistency,
                consistencyAchievedAtMillis: consistencyAchievedAtMillis,
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

typedef $$ContractionSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractionSessionsTable,
      ContractionSessionDto,
      $$ContractionSessionsTableFilterComposer,
      $$ContractionSessionsTableOrderingComposer,
      $$ContractionSessionsTableAnnotationComposer,
      $$ContractionSessionsTableCreateCompanionBuilder,
      $$ContractionSessionsTableUpdateCompanionBuilder,
      (
        ContractionSessionDto,
        BaseReferences<
          _$AppDatabase,
          $ContractionSessionsTable,
          ContractionSessionDto
        >,
      ),
      ContractionSessionDto,
      PrefetchHooks Function()
    >;
typedef $$ContractionsTableCreateCompanionBuilder =
    ContractionsCompanion Function({
      required String id,
      required String sessionId,
      required int startTimeMillis,
      Value<int?> endTimeMillis,
      Value<int> intensity,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$ContractionsTableUpdateCompanionBuilder =
    ContractionsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> startTimeMillis,
      Value<int?> endTimeMillis,
      Value<int> intensity,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$ContractionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableFilterComposer({
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

  ColumnFilters<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensity => $composableBuilder(
    column: $table.intensity,
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

class $$ContractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableOrderingComposer({
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

  ColumnOrderings<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensity => $composableBuilder(
    column: $table.intensity,
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

class $$ContractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableAnnotationComposer({
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

  GeneratedColumn<int> get startTimeMillis => $composableBuilder(
    column: $table.startTimeMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMillis => $composableBuilder(
    column: $table.endTimeMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$ContractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractionsTable,
          ContractionDto,
          $$ContractionsTableFilterComposer,
          $$ContractionsTableOrderingComposer,
          $$ContractionsTableAnnotationComposer,
          $$ContractionsTableCreateCompanionBuilder,
          $$ContractionsTableUpdateCompanionBuilder,
          (
            ContractionDto,
            BaseReferences<_$AppDatabase, $ContractionsTable, ContractionDto>,
          ),
          ContractionDto,
          PrefetchHooks Function()
        > {
  $$ContractionsTableTableManager(_$AppDatabase db, $ContractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> startTimeMillis = const Value.absent(),
                Value<int?> endTimeMillis = const Value.absent(),
                Value<int> intensity = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractionsCompanion(
                id: id,
                sessionId: sessionId,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                intensity: intensity,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int startTimeMillis,
                Value<int?> endTimeMillis = const Value.absent(),
                Value<int> intensity = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ContractionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                startTimeMillis: startTimeMillis,
                endTimeMillis: endTimeMillis,
                intensity: intensity,
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

typedef $$ContractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractionsTable,
      ContractionDto,
      $$ContractionsTableFilterComposer,
      $$ContractionsTableOrderingComposer,
      $$ContractionsTableAnnotationComposer,
      $$ContractionsTableCreateCompanionBuilder,
      $$ContractionsTableUpdateCompanionBuilder,
      (
        ContractionDto,
        BaseReferences<_$AppDatabase, $ContractionsTable, ContractionDto>,
      ),
      ContractionDto,
      PrefetchHooks Function()
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
typedef $$MaternityUnitsTableCreateCompanionBuilder =
    MaternityUnitsCompanion Function({
      required String id,
      required String cqcLocationId,
      Value<String?> cqcProviderId,
      Value<String?> odsCode,
      required String name,
      Value<String?> providerName,
      required String unitType,
      Value<bool> isNhs,
      Value<String?> addressLine1,
      Value<String?> addressLine2,
      Value<String?> townCity,
      Value<String?> county,
      Value<String?> postcode,
      Value<String?> region,
      Value<String?> localAuthority,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> overallRating,
      Value<String?> ratingSafe,
      Value<String?> ratingEffective,
      Value<String?> ratingCaring,
      Value<String?> ratingResponsive,
      Value<String?> ratingWellLed,
      Value<String?> maternityRating,
      Value<String?> maternityRatingDate,
      Value<String?> lastInspectionDate,
      Value<String?> cqcReportUrl,
      Value<String?> registrationStatus,
      Value<double?> placeCleanliness,
      Value<double?> placeFood,
      Value<double?> placePrivacyDignityWellbeing,
      Value<double?> placeConditionAppearance,
      Value<int?> placeSyncedAtMillis,
      Value<String?> birthingOptions,
      Value<String?> facilities,
      Value<String?> birthStatistics,
      Value<String?> notes,
      Value<bool> isActive,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int?> cqcSyncedAtMillis,
      Value<int> rowid,
    });
typedef $$MaternityUnitsTableUpdateCompanionBuilder =
    MaternityUnitsCompanion Function({
      Value<String> id,
      Value<String> cqcLocationId,
      Value<String?> cqcProviderId,
      Value<String?> odsCode,
      Value<String> name,
      Value<String?> providerName,
      Value<String> unitType,
      Value<bool> isNhs,
      Value<String?> addressLine1,
      Value<String?> addressLine2,
      Value<String?> townCity,
      Value<String?> county,
      Value<String?> postcode,
      Value<String?> region,
      Value<String?> localAuthority,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> overallRating,
      Value<String?> ratingSafe,
      Value<String?> ratingEffective,
      Value<String?> ratingCaring,
      Value<String?> ratingResponsive,
      Value<String?> ratingWellLed,
      Value<String?> maternityRating,
      Value<String?> maternityRatingDate,
      Value<String?> lastInspectionDate,
      Value<String?> cqcReportUrl,
      Value<String?> registrationStatus,
      Value<double?> placeCleanliness,
      Value<double?> placeFood,
      Value<double?> placePrivacyDignityWellbeing,
      Value<double?> placeConditionAppearance,
      Value<int?> placeSyncedAtMillis,
      Value<String?> birthingOptions,
      Value<String?> facilities,
      Value<String?> birthStatistics,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int?> cqcSyncedAtMillis,
      Value<int> rowid,
    });

final class $$MaternityUnitsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MaternityUnitsTable, MaternityUnitDto> {
  $$MaternityUnitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $HospitalShortlistsTable,
    List<HospitalShortlistDto>
  >
  _hospitalShortlistsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.hospitalShortlists,
        aliasName: $_aliasNameGenerator(
          db.maternityUnits.id,
          db.hospitalShortlists.maternityUnitId,
        ),
      );

  $$HospitalShortlistsTableProcessedTableManager get hospitalShortlistsRefs {
    final manager =
        $$HospitalShortlistsTableTableManager(
          $_db,
          $_db.hospitalShortlists,
        ).filter(
          (f) => f.maternityUnitId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _hospitalShortlistsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaternityUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $MaternityUnitsTable> {
  $$MaternityUnitsTableFilterComposer({
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

  ColumnFilters<String> get cqcLocationId => $composableBuilder(
    column: $table.cqcLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cqcProviderId => $composableBuilder(
    column: $table.cqcProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get odsCode => $composableBuilder(
    column: $table.odsCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNhs => $composableBuilder(
    column: $table.isNhs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get townCity => $composableBuilder(
    column: $table.townCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get county => $composableBuilder(
    column: $table.county,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postcode => $composableBuilder(
    column: $table.postcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localAuthority => $composableBuilder(
    column: $table.localAuthority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratingSafe => $composableBuilder(
    column: $table.ratingSafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratingEffective => $composableBuilder(
    column: $table.ratingEffective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratingCaring => $composableBuilder(
    column: $table.ratingCaring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratingResponsive => $composableBuilder(
    column: $table.ratingResponsive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratingWellLed => $composableBuilder(
    column: $table.ratingWellLed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maternityRating => $composableBuilder(
    column: $table.maternityRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maternityRatingDate => $composableBuilder(
    column: $table.maternityRatingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastInspectionDate => $composableBuilder(
    column: $table.lastInspectionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cqcReportUrl => $composableBuilder(
    column: $table.cqcReportUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeCleanliness => $composableBuilder(
    column: $table.placeCleanliness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeFood => $composableBuilder(
    column: $table.placeFood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placePrivacyDignityWellbeing => $composableBuilder(
    column: $table.placePrivacyDignityWellbeing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get placeConditionAppearance => $composableBuilder(
    column: $table.placeConditionAppearance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placeSyncedAtMillis => $composableBuilder(
    column: $table.placeSyncedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthingOptions => $composableBuilder(
    column: $table.birthingOptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilities => $composableBuilder(
    column: $table.facilities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthStatistics => $composableBuilder(
    column: $table.birthStatistics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<int> get cqcSyncedAtMillis => $composableBuilder(
    column: $table.cqcSyncedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> hospitalShortlistsRefs(
    Expression<bool> Function($$HospitalShortlistsTableFilterComposer f) f,
  ) {
    final $$HospitalShortlistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hospitalShortlists,
      getReferencedColumn: (t) => t.maternityUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HospitalShortlistsTableFilterComposer(
            $db: $db,
            $table: $db.hospitalShortlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaternityUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaternityUnitsTable> {
  $$MaternityUnitsTableOrderingComposer({
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

  ColumnOrderings<String> get cqcLocationId => $composableBuilder(
    column: $table.cqcLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cqcProviderId => $composableBuilder(
    column: $table.cqcProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get odsCode => $composableBuilder(
    column: $table.odsCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNhs => $composableBuilder(
    column: $table.isNhs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get townCity => $composableBuilder(
    column: $table.townCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get county => $composableBuilder(
    column: $table.county,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postcode => $composableBuilder(
    column: $table.postcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localAuthority => $composableBuilder(
    column: $table.localAuthority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratingSafe => $composableBuilder(
    column: $table.ratingSafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratingEffective => $composableBuilder(
    column: $table.ratingEffective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratingCaring => $composableBuilder(
    column: $table.ratingCaring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratingResponsive => $composableBuilder(
    column: $table.ratingResponsive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratingWellLed => $composableBuilder(
    column: $table.ratingWellLed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maternityRating => $composableBuilder(
    column: $table.maternityRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maternityRatingDate => $composableBuilder(
    column: $table.maternityRatingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastInspectionDate => $composableBuilder(
    column: $table.lastInspectionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cqcReportUrl => $composableBuilder(
    column: $table.cqcReportUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeCleanliness => $composableBuilder(
    column: $table.placeCleanliness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placeFood => $composableBuilder(
    column: $table.placeFood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get placePrivacyDignityWellbeing =>
      $composableBuilder(
        column: $table.placePrivacyDignityWellbeing,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get placeConditionAppearance => $composableBuilder(
    column: $table.placeConditionAppearance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placeSyncedAtMillis => $composableBuilder(
    column: $table.placeSyncedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthingOptions => $composableBuilder(
    column: $table.birthingOptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilities => $composableBuilder(
    column: $table.facilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthStatistics => $composableBuilder(
    column: $table.birthStatistics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<int> get cqcSyncedAtMillis => $composableBuilder(
    column: $table.cqcSyncedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaternityUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaternityUnitsTable> {
  $$MaternityUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cqcLocationId => $composableBuilder(
    column: $table.cqcLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cqcProviderId => $composableBuilder(
    column: $table.cqcProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get odsCode =>
      $composableBuilder(column: $table.odsCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
    column: $table.providerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<bool> get isNhs =>
      $composableBuilder(column: $table.isNhs, builder: (column) => column);

  GeneratedColumn<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get townCity =>
      $composableBuilder(column: $table.townCity, builder: (column) => column);

  GeneratedColumn<String> get county =>
      $composableBuilder(column: $table.county, builder: (column) => column);

  GeneratedColumn<String> get postcode =>
      $composableBuilder(column: $table.postcode, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get localAuthority => $composableBuilder(
    column: $table.localAuthority,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get overallRating => $composableBuilder(
    column: $table.overallRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratingSafe => $composableBuilder(
    column: $table.ratingSafe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratingEffective => $composableBuilder(
    column: $table.ratingEffective,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratingCaring => $composableBuilder(
    column: $table.ratingCaring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratingResponsive => $composableBuilder(
    column: $table.ratingResponsive,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratingWellLed => $composableBuilder(
    column: $table.ratingWellLed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maternityRating => $composableBuilder(
    column: $table.maternityRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maternityRatingDate => $composableBuilder(
    column: $table.maternityRatingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastInspectionDate => $composableBuilder(
    column: $table.lastInspectionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cqcReportUrl => $composableBuilder(
    column: $table.cqcReportUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeCleanliness => $composableBuilder(
    column: $table.placeCleanliness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get placeFood =>
      $composableBuilder(column: $table.placeFood, builder: (column) => column);

  GeneratedColumn<double> get placePrivacyDignityWellbeing =>
      $composableBuilder(
        column: $table.placePrivacyDignityWellbeing,
        builder: (column) => column,
      );

  GeneratedColumn<double> get placeConditionAppearance => $composableBuilder(
    column: $table.placeConditionAppearance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get placeSyncedAtMillis => $composableBuilder(
    column: $table.placeSyncedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthingOptions => $composableBuilder(
    column: $table.birthingOptions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilities => $composableBuilder(
    column: $table.facilities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birthStatistics => $composableBuilder(
    column: $table.birthStatistics,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cqcSyncedAtMillis => $composableBuilder(
    column: $table.cqcSyncedAtMillis,
    builder: (column) => column,
  );

  Expression<T> hospitalShortlistsRefs<T extends Object>(
    Expression<T> Function($$HospitalShortlistsTableAnnotationComposer a) f,
  ) {
    final $$HospitalShortlistsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.hospitalShortlists,
          getReferencedColumn: (t) => t.maternityUnitId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HospitalShortlistsTableAnnotationComposer(
                $db: $db,
                $table: $db.hospitalShortlists,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaternityUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaternityUnitsTable,
          MaternityUnitDto,
          $$MaternityUnitsTableFilterComposer,
          $$MaternityUnitsTableOrderingComposer,
          $$MaternityUnitsTableAnnotationComposer,
          $$MaternityUnitsTableCreateCompanionBuilder,
          $$MaternityUnitsTableUpdateCompanionBuilder,
          (MaternityUnitDto, $$MaternityUnitsTableReferences),
          MaternityUnitDto,
          PrefetchHooks Function({bool hospitalShortlistsRefs})
        > {
  $$MaternityUnitsTableTableManager(
    _$AppDatabase db,
    $MaternityUnitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaternityUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaternityUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaternityUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cqcLocationId = const Value.absent(),
                Value<String?> cqcProviderId = const Value.absent(),
                Value<String?> odsCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> providerName = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<bool> isNhs = const Value.absent(),
                Value<String?> addressLine1 = const Value.absent(),
                Value<String?> addressLine2 = const Value.absent(),
                Value<String?> townCity = const Value.absent(),
                Value<String?> county = const Value.absent(),
                Value<String?> postcode = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> localAuthority = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> overallRating = const Value.absent(),
                Value<String?> ratingSafe = const Value.absent(),
                Value<String?> ratingEffective = const Value.absent(),
                Value<String?> ratingCaring = const Value.absent(),
                Value<String?> ratingResponsive = const Value.absent(),
                Value<String?> ratingWellLed = const Value.absent(),
                Value<String?> maternityRating = const Value.absent(),
                Value<String?> maternityRatingDate = const Value.absent(),
                Value<String?> lastInspectionDate = const Value.absent(),
                Value<String?> cqcReportUrl = const Value.absent(),
                Value<String?> registrationStatus = const Value.absent(),
                Value<double?> placeCleanliness = const Value.absent(),
                Value<double?> placeFood = const Value.absent(),
                Value<double?> placePrivacyDignityWellbeing =
                    const Value.absent(),
                Value<double?> placeConditionAppearance = const Value.absent(),
                Value<int?> placeSyncedAtMillis = const Value.absent(),
                Value<String?> birthingOptions = const Value.absent(),
                Value<String?> facilities = const Value.absent(),
                Value<String?> birthStatistics = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int?> cqcSyncedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaternityUnitsCompanion(
                id: id,
                cqcLocationId: cqcLocationId,
                cqcProviderId: cqcProviderId,
                odsCode: odsCode,
                name: name,
                providerName: providerName,
                unitType: unitType,
                isNhs: isNhs,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                townCity: townCity,
                county: county,
                postcode: postcode,
                region: region,
                localAuthority: localAuthority,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                website: website,
                overallRating: overallRating,
                ratingSafe: ratingSafe,
                ratingEffective: ratingEffective,
                ratingCaring: ratingCaring,
                ratingResponsive: ratingResponsive,
                ratingWellLed: ratingWellLed,
                maternityRating: maternityRating,
                maternityRatingDate: maternityRatingDate,
                lastInspectionDate: lastInspectionDate,
                cqcReportUrl: cqcReportUrl,
                registrationStatus: registrationStatus,
                placeCleanliness: placeCleanliness,
                placeFood: placeFood,
                placePrivacyDignityWellbeing: placePrivacyDignityWellbeing,
                placeConditionAppearance: placeConditionAppearance,
                placeSyncedAtMillis: placeSyncedAtMillis,
                birthingOptions: birthingOptions,
                facilities: facilities,
                birthStatistics: birthStatistics,
                notes: notes,
                isActive: isActive,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                cqcSyncedAtMillis: cqcSyncedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cqcLocationId,
                Value<String?> cqcProviderId = const Value.absent(),
                Value<String?> odsCode = const Value.absent(),
                required String name,
                Value<String?> providerName = const Value.absent(),
                required String unitType,
                Value<bool> isNhs = const Value.absent(),
                Value<String?> addressLine1 = const Value.absent(),
                Value<String?> addressLine2 = const Value.absent(),
                Value<String?> townCity = const Value.absent(),
                Value<String?> county = const Value.absent(),
                Value<String?> postcode = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> localAuthority = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> overallRating = const Value.absent(),
                Value<String?> ratingSafe = const Value.absent(),
                Value<String?> ratingEffective = const Value.absent(),
                Value<String?> ratingCaring = const Value.absent(),
                Value<String?> ratingResponsive = const Value.absent(),
                Value<String?> ratingWellLed = const Value.absent(),
                Value<String?> maternityRating = const Value.absent(),
                Value<String?> maternityRatingDate = const Value.absent(),
                Value<String?> lastInspectionDate = const Value.absent(),
                Value<String?> cqcReportUrl = const Value.absent(),
                Value<String?> registrationStatus = const Value.absent(),
                Value<double?> placeCleanliness = const Value.absent(),
                Value<double?> placeFood = const Value.absent(),
                Value<double?> placePrivacyDignityWellbeing =
                    const Value.absent(),
                Value<double?> placeConditionAppearance = const Value.absent(),
                Value<int?> placeSyncedAtMillis = const Value.absent(),
                Value<String?> birthingOptions = const Value.absent(),
                Value<String?> facilities = const Value.absent(),
                Value<String?> birthStatistics = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int?> cqcSyncedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaternityUnitsCompanion.insert(
                id: id,
                cqcLocationId: cqcLocationId,
                cqcProviderId: cqcProviderId,
                odsCode: odsCode,
                name: name,
                providerName: providerName,
                unitType: unitType,
                isNhs: isNhs,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                townCity: townCity,
                county: county,
                postcode: postcode,
                region: region,
                localAuthority: localAuthority,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                website: website,
                overallRating: overallRating,
                ratingSafe: ratingSafe,
                ratingEffective: ratingEffective,
                ratingCaring: ratingCaring,
                ratingResponsive: ratingResponsive,
                ratingWellLed: ratingWellLed,
                maternityRating: maternityRating,
                maternityRatingDate: maternityRatingDate,
                lastInspectionDate: lastInspectionDate,
                cqcReportUrl: cqcReportUrl,
                registrationStatus: registrationStatus,
                placeCleanliness: placeCleanliness,
                placeFood: placeFood,
                placePrivacyDignityWellbeing: placePrivacyDignityWellbeing,
                placeConditionAppearance: placeConditionAppearance,
                placeSyncedAtMillis: placeSyncedAtMillis,
                birthingOptions: birthingOptions,
                facilities: facilities,
                birthStatistics: birthStatistics,
                notes: notes,
                isActive: isActive,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                cqcSyncedAtMillis: cqcSyncedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaternityUnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({hospitalShortlistsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (hospitalShortlistsRefs) db.hospitalShortlists,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (hospitalShortlistsRefs)
                    await $_getPrefetchedData<
                      MaternityUnitDto,
                      $MaternityUnitsTable,
                      HospitalShortlistDto
                    >(
                      currentTable: table,
                      referencedTable: $$MaternityUnitsTableReferences
                          ._hospitalShortlistsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MaternityUnitsTableReferences(
                            db,
                            table,
                            p0,
                          ).hospitalShortlistsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.maternityUnitId == item.id,
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

typedef $$MaternityUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaternityUnitsTable,
      MaternityUnitDto,
      $$MaternityUnitsTableFilterComposer,
      $$MaternityUnitsTableOrderingComposer,
      $$MaternityUnitsTableAnnotationComposer,
      $$MaternityUnitsTableCreateCompanionBuilder,
      $$MaternityUnitsTableUpdateCompanionBuilder,
      (MaternityUnitDto, $$MaternityUnitsTableReferences),
      MaternityUnitDto,
      PrefetchHooks Function({bool hospitalShortlistsRefs})
    >;
typedef $$HospitalShortlistsTableCreateCompanionBuilder =
    HospitalShortlistsCompanion Function({
      required String id,
      required String maternityUnitId,
      required int addedAtMillis,
      Value<bool> isSelected,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$HospitalShortlistsTableUpdateCompanionBuilder =
    HospitalShortlistsCompanion Function({
      Value<String> id,
      Value<String> maternityUnitId,
      Value<int> addedAtMillis,
      Value<bool> isSelected,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$HospitalShortlistsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HospitalShortlistsTable,
          HospitalShortlistDto
        > {
  $$HospitalShortlistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MaternityUnitsTable _maternityUnitIdTable(_$AppDatabase db) =>
      db.maternityUnits.createAlias(
        $_aliasNameGenerator(
          db.hospitalShortlists.maternityUnitId,
          db.maternityUnits.id,
        ),
      );

  $$MaternityUnitsTableProcessedTableManager get maternityUnitId {
    final $_column = $_itemColumn<String>('maternity_unit_id')!;

    final manager = $$MaternityUnitsTableTableManager(
      $_db,
      $_db.maternityUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_maternityUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HospitalShortlistsTableFilterComposer
    extends Composer<_$AppDatabase, $HospitalShortlistsTable> {
  $$HospitalShortlistsTableFilterComposer({
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

  ColumnFilters<int> get addedAtMillis => $composableBuilder(
    column: $table.addedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$MaternityUnitsTableFilterComposer get maternityUnitId {
    final $$MaternityUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maternityUnitId,
      referencedTable: $db.maternityUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaternityUnitsTableFilterComposer(
            $db: $db,
            $table: $db.maternityUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HospitalShortlistsTableOrderingComposer
    extends Composer<_$AppDatabase, $HospitalShortlistsTable> {
  $$HospitalShortlistsTableOrderingComposer({
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

  ColumnOrderings<int> get addedAtMillis => $composableBuilder(
    column: $table.addedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MaternityUnitsTableOrderingComposer get maternityUnitId {
    final $$MaternityUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maternityUnitId,
      referencedTable: $db.maternityUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaternityUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.maternityUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HospitalShortlistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HospitalShortlistsTable> {
  $$HospitalShortlistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get addedAtMillis => $composableBuilder(
    column: $table.addedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$MaternityUnitsTableAnnotationComposer get maternityUnitId {
    final $$MaternityUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maternityUnitId,
      referencedTable: $db.maternityUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaternityUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.maternityUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HospitalShortlistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HospitalShortlistsTable,
          HospitalShortlistDto,
          $$HospitalShortlistsTableFilterComposer,
          $$HospitalShortlistsTableOrderingComposer,
          $$HospitalShortlistsTableAnnotationComposer,
          $$HospitalShortlistsTableCreateCompanionBuilder,
          $$HospitalShortlistsTableUpdateCompanionBuilder,
          (HospitalShortlistDto, $$HospitalShortlistsTableReferences),
          HospitalShortlistDto,
          PrefetchHooks Function({bool maternityUnitId})
        > {
  $$HospitalShortlistsTableTableManager(
    _$AppDatabase db,
    $HospitalShortlistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HospitalShortlistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HospitalShortlistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HospitalShortlistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> maternityUnitId = const Value.absent(),
                Value<int> addedAtMillis = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HospitalShortlistsCompanion(
                id: id,
                maternityUnitId: maternityUnitId,
                addedAtMillis: addedAtMillis,
                isSelected: isSelected,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String maternityUnitId,
                required int addedAtMillis,
                Value<bool> isSelected = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HospitalShortlistsCompanion.insert(
                id: id,
                maternityUnitId: maternityUnitId,
                addedAtMillis: addedAtMillis,
                isSelected: isSelected,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HospitalShortlistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({maternityUnitId = false}) {
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
                    if (maternityUnitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.maternityUnitId,
                                referencedTable:
                                    $$HospitalShortlistsTableReferences
                                        ._maternityUnitIdTable(db),
                                referencedColumn:
                                    $$HospitalShortlistsTableReferences
                                        ._maternityUnitIdTable(db)
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

typedef $$HospitalShortlistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HospitalShortlistsTable,
      HospitalShortlistDto,
      $$HospitalShortlistsTableFilterComposer,
      $$HospitalShortlistsTableOrderingComposer,
      $$HospitalShortlistsTableAnnotationComposer,
      $$HospitalShortlistsTableCreateCompanionBuilder,
      $$HospitalShortlistsTableUpdateCompanionBuilder,
      (HospitalShortlistDto, $$HospitalShortlistsTableReferences),
      HospitalShortlistDto,
      PrefetchHooks Function({bool maternityUnitId})
    >;
typedef $$SyncMetadatasTableCreateCompanionBuilder =
    SyncMetadatasCompanion Function({
      required String id,
      Value<int?> lastSyncAtMillis,
      Value<String?> lastSyncStatus,
      Value<int> lastSyncCount,
      Value<String?> lastError,
      Value<int> dataVersionCode,
      required int createdAtMillis,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$SyncMetadatasTableUpdateCompanionBuilder =
    SyncMetadatasCompanion Function({
      Value<String> id,
      Value<int?> lastSyncAtMillis,
      Value<String?> lastSyncStatus,
      Value<int> lastSyncCount,
      Value<String?> lastError,
      Value<int> dataVersionCode,
      Value<int> createdAtMillis,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$SyncMetadatasTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadatasTable> {
  $$SyncMetadatasTableFilterComposer({
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

  ColumnFilters<int> get lastSyncAtMillis => $composableBuilder(
    column: $table.lastSyncAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncCount => $composableBuilder(
    column: $table.lastSyncCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dataVersionCode => $composableBuilder(
    column: $table.dataVersionCode,
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

class $$SyncMetadatasTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadatasTable> {
  $$SyncMetadatasTableOrderingComposer({
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

  ColumnOrderings<int> get lastSyncAtMillis => $composableBuilder(
    column: $table.lastSyncAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncCount => $composableBuilder(
    column: $table.lastSyncCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataVersionCode => $composableBuilder(
    column: $table.dataVersionCode,
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

class $$SyncMetadatasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadatasTable> {
  $$SyncMetadatasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastSyncAtMillis => $composableBuilder(
    column: $table.lastSyncAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncCount => $composableBuilder(
    column: $table.lastSyncCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get dataVersionCode => $composableBuilder(
    column: $table.dataVersionCode,
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

class $$SyncMetadatasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadatasTable,
          SyncMetadataDto,
          $$SyncMetadatasTableFilterComposer,
          $$SyncMetadatasTableOrderingComposer,
          $$SyncMetadatasTableAnnotationComposer,
          $$SyncMetadatasTableCreateCompanionBuilder,
          $$SyncMetadatasTableUpdateCompanionBuilder,
          (
            SyncMetadataDto,
            BaseReferences<_$AppDatabase, $SyncMetadatasTable, SyncMetadataDto>,
          ),
          SyncMetadataDto,
          PrefetchHooks Function()
        > {
  $$SyncMetadatasTableTableManager(_$AppDatabase db, $SyncMetadatasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadatasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadatasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadatasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> lastSyncAtMillis = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<int> lastSyncCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> dataVersionCode = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadatasCompanion(
                id: id,
                lastSyncAtMillis: lastSyncAtMillis,
                lastSyncStatus: lastSyncStatus,
                lastSyncCount: lastSyncCount,
                lastError: lastError,
                dataVersionCode: dataVersionCode,
                createdAtMillis: createdAtMillis,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> lastSyncAtMillis = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<int> lastSyncCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> dataVersionCode = const Value.absent(),
                required int createdAtMillis,
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadatasCompanion.insert(
                id: id,
                lastSyncAtMillis: lastSyncAtMillis,
                lastSyncStatus: lastSyncStatus,
                lastSyncCount: lastSyncCount,
                lastError: lastError,
                dataVersionCode: dataVersionCode,
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

typedef $$SyncMetadatasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadatasTable,
      SyncMetadataDto,
      $$SyncMetadatasTableFilterComposer,
      $$SyncMetadatasTableOrderingComposer,
      $$SyncMetadatasTableAnnotationComposer,
      $$SyncMetadatasTableCreateCompanionBuilder,
      $$SyncMetadatasTableUpdateCompanionBuilder,
      (
        SyncMetadataDto,
        BaseReferences<_$AppDatabase, $SyncMetadatasTable, SyncMetadataDto>,
      ),
      SyncMetadataDto,
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
  $$ContractionSessionsTableTableManager get contractionSessions =>
      $$ContractionSessionsTableTableManager(_db, _db.contractionSessions);
  $$ContractionsTableTableManager get contractions =>
      $$ContractionsTableTableManager(_db, _db.contractions);
  $$BumpPhotosTableTableManager get bumpPhotos =>
      $$BumpPhotosTableTableManager(_db, _db.bumpPhotos);
  $$MaternityUnitsTableTableManager get maternityUnits =>
      $$MaternityUnitsTableTableManager(_db, _db.maternityUnits);
  $$HospitalShortlistsTableTableManager get hospitalShortlists =>
      $$HospitalShortlistsTableTableManager(_db, _db.hospitalShortlists);
  $$SyncMetadatasTableTableManager get syncMetadatas =>
      $$SyncMetadatasTableTableManager(_db, _db.syncMetadatas);
}
