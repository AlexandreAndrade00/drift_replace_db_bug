import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import 'todos_widget.dart';

class BodyWidget extends StatelessWidget {
  const BodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IconButton(
              onPressed: () => context.read<AppDatabase>().todoItems.insertOne(
                  TodoItemsCompanion.insert(
                      title: "aaaaaa", content: "bbbbbbbbbbbbb")),
              icon: const Icon(Icons.add)),
          const Expanded(child: TodosWidget())
        ],
      ),
    );
  }
}
