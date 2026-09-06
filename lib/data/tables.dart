import 'package:drift/drift.dart';

class VaultItems extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get title => text()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VaultFields extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get key => text()();
  TextColumn get label => text()();
  TextColumn get value => text()();
  TextColumn get fieldType => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get concealed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VaultAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get label => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserCategories extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();
  TextColumn get fieldsJson => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class HiddenCategories extends Table {
  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
