import 'package:drift/drift.dart';
import 'database_connection/database_connection.dart' as db;

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();

  DateTimeColumn get createdAt => dateTime().nullable()();
}

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase({Uint8List? fileBytes})
      : super(db.DatabaseConnection().createDatabaseConnection(
            databaseName: "db", databaseBytes: fileBytes));

  @override
  int get schemaVersion => 1;
}
