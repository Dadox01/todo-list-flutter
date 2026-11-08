import 'package:flutter/material.dart';

import '../models/task.dart';

/// Schermata di creazione (S1).
///
/// Non modifica l'elenco: alla conferma restituisce una [TaskDraft] alla
/// schermata precedente, che si occupa di aggiungerla allo store. In caso di
/// rinuncia (tasto indietro) restituisce `null`.
class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  /// Disabilitata finché l'utente non prova a confermare: solo da quel momento
  /// l'errore appare e poi sparisce appena il titolo diventa valido.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isImportant = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Inserisci un titolo per l\'attività';
    }
    return null;
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) {
      return; // variante: titolo mancante, nessuna attività creata
    }

    Navigator.of(context).pop(
      TaskDraft(
        title: _titleController.text.trim(),
        isImportant: _isImportant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova attività'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Annulla',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Descrivi l\'attività e indica se è importante.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLength: 120,
                  onFieldSubmitted: (_) => _submit(),
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    labelText: 'Titolo',
                    hintText: 'Es. Comprare il pane',
                    prefixIcon: Icon(Icons.edit_outlined),
                    helperText: 'Campo obbligatorio',
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: SwitchListTile.adaptive(
                    value: _isImportant,
                    onChanged: (value) => setState(() => _isImportant = value),
                    secondary: Icon(
                      _isImportant ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _isImportant
                          ? const Color(0xFF8D4E00)
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: const Text('Importante'),
                    subtitle: const Text('Le attività importanti sono evidenziate'),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Aggiungi attività'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
