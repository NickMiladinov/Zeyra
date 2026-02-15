// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maternity_unit_dao.dart';

// ignore_for_file: type=lint
mixin _$MaternityUnitDaoMixin on DatabaseAccessor<AppDatabase> {
  $MaternityUnitsTable get maternityUnits => attachedDatabase.maternityUnits;
  MaternityUnitDaoManager get managers => MaternityUnitDaoManager(this);
}

class MaternityUnitDaoManager {
  final _$MaternityUnitDaoMixin _db;
  MaternityUnitDaoManager(this._db);
  $$MaternityUnitsTableTableManager get maternityUnits =>
      $$MaternityUnitsTableTableManager(
        _db.attachedDatabase,
        _db.maternityUnits,
      );
}
