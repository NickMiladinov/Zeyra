// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_dao.dart';

// ignore_for_file: type=lint
mixin _$PregnancyDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTable get userProfiles => attachedDatabase.userProfiles;
  $PregnanciesTable get pregnancies => attachedDatabase.pregnancies;
  PregnancyDaoManager get managers => PregnancyDaoManager(this);
}

class PregnancyDaoManager {
  final _$PregnancyDaoMixin _db;
  PregnancyDaoManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db.attachedDatabase, _db.userProfiles);
  $$PregnanciesTableTableManager get pregnancies =>
      $$PregnanciesTableTableManager(_db.attachedDatabase, _db.pregnancies);
}
