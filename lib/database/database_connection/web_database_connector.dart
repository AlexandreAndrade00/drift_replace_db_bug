import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'database_connector.dart' as p;

class DatabaseConnector implements p.DatabaseConnector {
  @override
  QueryExecutor createDatabaseConnection({
    required String databaseName,
    QueryInterceptor? interceptor,
    String? path,
    FutureOr<void> Function()? isolateSetup,
    Uint8List? databaseBytes,
  }) {
    return DatabaseConnection.delayed(Future(() async {
      final result = await WasmDatabase.open(
        databaseName: databaseName,
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse(
          kReleaseMode ? 'drift_worker.dart.min.js' : 'drift_worker.dart.js',
        ),
        initializeDatabase: () => databaseBytes,
      );

      if (result.missingFeatures.isNotEmpty) {
        // Depending how central local persistence is to your app, you may want
        // to show a warning to the user if only unreliable implementations
        // are available.
        debugPrint(
            'Using ${result.chosenImplementation} due to missing browser '
            'features: ${result.missingFeatures}');
      }

      DatabaseConnection databaseConnection = result.resolvedExecutor;

      if (interceptor != null) {
        databaseConnection = databaseConnection.interceptWith(interceptor);
      }

      return databaseConnection;
    }));
  }

  @override
  Future<void> deleteDatabase(
      {required String databaseName, String? path}) async {
    final probe = await WasmDatabase.probe(
      databaseName: databaseName,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse(
        kReleaseMode ? 'drift_worker.dart.min.js' : 'drift_worker.dart.js',
      ),
    );

    await probe.deleteDatabase(probe.existingDatabases.single);
  }
}
