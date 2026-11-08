/// Stato di un'attività: una nuova attività è sempre "da fare".
enum TaskStatus { todo, done }

/// Estensione di comodo per etichette e descrizioni leggibili.
extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'Da fare',
        TaskStatus.done => 'Completata',
      };
}

/// L'unica entità del dominio: l'attività.
///
/// È immutabile: ogni modifica produce una nuova istanza tramite [copyWith].
/// Questo rende prevedibile l'aggiornamento della UI.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.status = TaskStatus.todo,
    this.isImportant = false,
  });

  final int id;
  final String title;
  final TaskStatus status;
  final bool isImportant;

  bool get isDone => status == TaskStatus.done;

  Task copyWith({
    String? title,
    TaskStatus? status,
    bool? isImportant,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, status: ${status.name}, important: $isImportant)';
}

/// Dati raccolti dal form di creazione: il titolo (già validato) e
/// l'indicazione di importanza. L'id lo assegna lo store.
class TaskDraft {
  const TaskDraft({required this.title, this.isImportant = false});

  final String title;
  final bool isImportant;
}
