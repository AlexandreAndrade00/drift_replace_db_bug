import 'dart:async';

import 'package:drift/drift.dart';

interface class DatabaseConnector {
  QueryExecutor createDatabaseConnection({
    required String databaseName,
    QueryInterceptor? interceptor,
    String? path,
    FutureOr<void> Function()? isolateSetup,
    Uint8List? databaseBytes,
  }) =>
      throw UnimplementedError();

  Future<void> deleteDatabase({required String databaseName, String? path}) =>
      throw UnimplementedError();
}
