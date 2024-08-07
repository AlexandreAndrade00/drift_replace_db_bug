import 'package:drift_replace_db_runtime/database/database.dart';
import 'package:drift_replace_db_runtime/widgets/body_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'database/database_connection/database_connection.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppDatabase database = AppDatabase();

  Future<void> resetDatabase() async {
    await database.close();

    await DatabaseConnection().deleteDatabase(databaseName: "db");

    final fileBytes =
        Uint8List.sublistView(await rootBundle.load("lib/assets/db.sqlite"));

    database = AppDatabase(fileBytes: fileBytes);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Column(children: [
        TextButton(
            onPressed: resetDatabase, child: const Text('Replace Database')),
        Expanded(
            child: Provider.value(value: database, child: const BodyWidget()))
      ])),
    );
  }
}
