// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital_shortlist_dao.dart';

// ignore_for_file: type=lint
mixin _$HospitalShortlistDaoMixin on DatabaseAccessor<AppDatabase> {
  $MaternityUnitsTable get maternityUnits => attachedDatabase.maternityUnits;
  $HospitalShortlistsTable get hospitalShortlists =>
      attachedDatabase.hospitalShortlists;
  HospitalShortlistDaoManager get managers => HospitalShortlistDaoManager(this);
}

class HospitalShortlistDaoManager {
  final _$HospitalShortlistDaoMixin _db;
  HospitalShortlistDaoManager(this._db);
  $$MaternityUnitsTableTableManager get maternityUnits =>
      $$MaternityUnitsTableTableManager(
        _db.attachedDatabase,
        _db.maternityUnits,
      );
  $$HospitalShortlistsTableTableManager get hospitalShortlists =>
      $$HospitalShortlistsTableTableManager(
        _db.attachedDatabase,
        _db.hospitalShortlists,
      );
}
