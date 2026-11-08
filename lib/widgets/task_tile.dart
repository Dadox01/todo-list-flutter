import 'package:flutter/material.dart';

import '../models/task.dart';

/// Singola riga dell'elenco: titolo, stato e importanza.
///
/// Il widget è "stupido": non conosce lo store, riceve solo i dati e le
/// azioni da eseguire. Tutta la logica resta in [TasksScreen].
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = task.isDone;

    return Material(
      color: done
          ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Toccando la riga si aggiorna subito lo stato (R3).
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: done,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration:
                            done ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: scheme.onSurfaceVariant,
                        color: done ? scheme.onSurfaceVariant : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Pill(
                          icon: done
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          label: task.status.label,
                          background: done
                              ? const Color(0xFF1B5E20).withValues(alpha: 0.14)
                              : scheme.surfaceContainerHighest,
                          foreground: done
                              ? const Color(0xFF1B5E20)
                              : scheme.onSurfaceVariant,
                        ),
                        _Pill(
                          icon: task.isImportant
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          label: task.isImportant ? 'Importante' : 'Normale',
                          background: task.isImportant
                              ? const Color(0xFFF57F17).withValues(alpha: 0.16)
                              : scheme.surfaceContainerHighest,
                          foreground: task.isImportant
                              ? const Color(0xFF8D4E00)
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Elimina «${task.title}»',
                icon: Icon(Icons.delete_outline_rounded, color: scheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Piccola etichetta arrotondata con icona, usata per stato e importanza.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
