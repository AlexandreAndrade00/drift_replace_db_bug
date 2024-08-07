import 'dart:async';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;

import 'database_connector.dart'
    if (dart.library.io) 'native_database_connector.dart'
    if (dart.library.js_interop) 'web_database_connector.dart';

class DatabaseConnection {
  final DatabaseConnector _connector = DatabaseConnector();

  drift.QueryExecutor createDatabaseConnection({
    required String databaseName,
    drift.QueryInterceptor? interceptor,
    String? path,
    FutureOr<void> Function()? isolateSetup,
    Uint8List? databaseBytes,
  }) =>
      _connector.createDatabaseConnection(
        databaseName: databaseName,
        interceptor: interceptor,
        path: path,
        isolateSetup: isolateSetup,
        databaseBytes: databaseBytes,
      );

  Future<void> deleteDatabase(
          {required String databaseName, String? dbDirectory}) =>
      _connector.deleteDatabase(databaseName: databaseName, path: dbDirectory);
}
