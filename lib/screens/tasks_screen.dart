import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/tasks_store.dart';
import '../widgets/completion_summary.dart';
import '../widgets/task_tile.dart';
import 'new_task_screen.dart';

/// Schermata principale: elenco delle attività (R2) con le azioni di
/// aggiunta (R1), aggiornamento stato (R3) ed eliminazione (R4).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.store});

  final TasksStore store;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  /// Apre il form. Se l'utente conferma riceviamo la bozza, altrimenti
  /// (rinuncia con il tasto indietro) `draft` è null: l'elenco resta invariato
  /// e non mostriamo alcun messaggio.
  Future<void> _openNewTaskForm() async {
    final TaskDraft? draft = await Navigator.of(context).push<TaskDraft>(
      MaterialPageRoute<TaskDraft>(
        builder: (_) => const NewTaskScreen(),
      ),
    );
    if (!mounted || draft == null) return;

    final Task task = widget.store.add(
      draft.title,
      isImportant: draft.isImportant,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('«${task.title}» aggiunta all\'elenco'),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
  }

  /// R4: prima di eliminare chiediamo conferma.
  Future<void> _confirmDelete(Task task) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminare l\'attività?'),
        content: Text('«${task.title}» verrà rimossa dall\'elenco.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.store.remove(task.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('«${task.title}» eliminata'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività'),
        actions: [
          ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${widget.store.total}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTaskForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuova attività'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) {
            if (widget.store.isEmpty) {
              return EmptyTasksView(onAdd: _openNewTaskForm);
            }
            return Column(
              children: [
                CompletionSummary(
                  completed: widget.store.completedCount,
                  total: widget.store.total,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: widget.store.total,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final Task task = widget.store.tasks[index];
                      return TaskTile(
                        key: ValueKey<int>(task.id),
                        task: task,
                        onToggle: () => widget.store.toggleStatus(task.id),
                        onDelete: () => _confirmDelete(task),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
