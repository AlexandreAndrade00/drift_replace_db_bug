import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'database_connector.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

const _encryptionPassword = 'drift.example.unsafe_password';

class DatabaseConnector implements p.DatabaseConnector {
  @override
  QueryExecutor createDatabaseConnection({
    required String databaseName,
    QueryInterceptor? interceptor,
    String? path,
    FutureOr<void> Function()? isolateSetup,
    Uint8List? databaseBytes,
  }) {
    return LazyDatabase(() async {
      // put the database file into the documents folder for the app.
      final dbFolder = path ?? (await getApplicationSupportDirectory()).path;

      final databaseFile = File(join(dbFolder, '$databaseName.sqlite'));

      if (databaseBytes != null) {
        await databaseFile.create(recursive: true);

        await databaseFile.writeAsBytes(databaseBytes);
      }

      DatabaseConnection databaseConnection;

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
        // We can't access /tmp on Android, which sqlite3 would try by default.
        // Explicitly tell it about the correct temporary directory.
        sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
      }

      databaseConnection = NativeDatabase.createBackgroundConnection(
        databaseFile,
        isolateSetup: isolateSetup ??
            () {
              open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
            },
        setup: (db) {
          // Check that we're actually running with SQLCipher by quering the
          // cipher_version pragma.
          final result = db.select('pragma cipher_version');
          if (result.isEmpty) {
            throw UnsupportedError(
              'This database needs to run with SQLCipher, but that library is '
              'not available!',
            );
          }

          // Then, apply the key to encrypt the database. Unfortunately, this
          // pragma doesn't seem to support prepared statements so we inline the
          // key.
          final escapedKey = _encryptionPassword.replaceAll("'", "''");
          db.execute("pragma key = '$escapedKey'");

          // Test that the key is correct by selecting from a table
          db.execute('select count(*) from sqlite_master');
        },
      );

      if (interceptor != null) {
        databaseConnection = databaseConnection.interceptWith(interceptor);
      }

      return databaseConnection;
    });
  }

  @override
  Future<void> deleteDatabase(
      {required String databaseName, String? path}) async {
    final dbDirectoryPath =
        path ?? (await getApplicationSupportDirectory()).path;

    final dbPath = join(dbDirectoryPath, '$databaseName.sqlite');

    final dbFile = File(dbPath);

    if (dbFile.existsSync()) dbFile.deleteSync();
  }
}
