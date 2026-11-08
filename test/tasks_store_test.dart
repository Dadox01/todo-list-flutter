import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/state/tasks_store.dart';

void main() {
  group('TasksStore', () {
    test('una nuova attività è da fare e non importante', () {
      final store = TasksStore();
      final task = store.add('Pane');

      expect(task.status, TaskStatus.todo);
      expect(task.isImportant, isFalse);
      expect(store.total, 1);
      expect(store.completedCount, 0);
    });

    test('il titolo viene ripulito dagli spazi e gli id sono unici', () {
      final store = TasksStore();
      final first = store.add('  Pane  ');
      final second = store.add('Latte');

      expect(first.title, 'Pane');
      expect(first.id, isNot(second.id));
    });

    test('toggleStatus aggiorna stato e conteggio in entrambe le direzioni', () {
      final store = TasksStore();
      final task = store.add('Pane');

      store.toggleStatus(task.id);
      expect(store.tasks.single.isDone, isTrue);
      expect(store.completedCount, 1);

      store.toggleStatus(task.id);
      expect(store.tasks.single.isDone, isFalse);
      expect(store.completedCount, 0);
    });

    test('remove elimina solo l\'attività indicata', () {
      final store = TasksStore();
      final pane = store.add('Pane');
      store.add('Latte');

      store.remove(pane.id);

      expect(store.total, 1);
      expect(store.tasks.single.title, 'Latte');
    });

    test('notifica gli ascoltatori ad ogni mutazione', () {
      final store = TasksStore();
      var notifications = 0;
      store.addListener(() => notifications++);

      final task = store.add('Pane');
      store.toggleStatus(task.id);
      store.remove(task.id);

      expect(notifications, 3);
    });

    test('la lista esposta non è modificabile dall\'esterno', () {
      final store = TasksStore();
      store.add('Pane');

      expect(
        () => store.tasks.add(const Task(id: 99, title: 'Intruso')),
        throwsUnsupportedError,
      );
    });
  });
}
