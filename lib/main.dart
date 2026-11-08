import 'package:flutter/material.dart';

import 'screens/tasks_screen.dart';
import 'state/tasks_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(TodoListApp(store: TasksStore()));
}

/// Radice dell'app: crea il tema e mostra la schermata con l'elenco.
class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key, required this.store});

  final TasksStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le mie attività',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: TasksScreen(store: store),
    );
  }
}
