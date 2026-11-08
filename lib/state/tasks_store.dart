import 'package:flutter/foundation.dart';

import '../models/task.dart';

/// Sorgente unica di verità per l'elenco delle attività.
///
/// Estende [ChangeNotifier]: chi ascolta (la lista) viene ridisegnato
/// automaticamente ad ogni mutazione. Non ci sono dipendenze esterne,
/// quindi la gestione dello stato resta esplicita e facile da seguire.
class TasksStore extends ChangeNotifier {
  final List<Task> _tasks = <Task>[];
  int _nextId = 1;

  /// Vista non modificabile dall'esterno: le mutazioni passano solo dai metodi.
  List<Task> get tasks => List<Task>.unmodifiable(_tasks);

  int get total => _tasks.length;
  int get completedCount => _tasks.where((task) => task.isDone).length;
  bool get isEmpty => _tasks.isEmpty;

  /// Aggiunge un'attività. Una nuova attività è sempre "da fare".
  Task add(String title, {bool isImportant = false}) {
    final task = Task(
      id: _nextId++,
      title: title.trim(),
      isImportant: isImportant,
    );
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  /// Porta l'attività da "da fare" a "completata" e viceversa.
  void toggleStatus(int id) {
    final index = _indexOf(id);
    if (index == -1) return;
    final task = _tasks[index];
    _tasks[index] = task.copyWith(
      status: task.isDone ? TaskStatus.todo : TaskStatus.done,
    );
    notifyListeners();
  }

  void remove(int id) {
    final index = _indexOf(id);
    if (index == -1) return;
    _tasks.removeAt(index);
    notifyListeners();
  }

  int _indexOf(int id) => _tasks.indexWhere((task) => task.id == id);
}
