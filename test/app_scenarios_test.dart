import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/state/tasks_store.dart';

/// Avvia l'app con uno store già popolato (eventualmente vuoto).
Future<TasksStore> pumpApp(
  WidgetTester tester, {
  List<String> titles = const <String>[],
  Set<String> importantTitles = const <String>{},
}) async {
  final store = TasksStore();
  for (final title in titles) {
    store.add(title, isImportant: importantTitles.contains(title));
  }
  await tester.pumpWidget(TodoListApp(store: store));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  group('S1 – Aggiungere un\'attività', () {
    testWidgets('conferma: torna all\'elenco, aggiunge e mostra il messaggio',
        (tester) async {
      final store = await pumpApp(tester);

      await tester.tap(find.text('Nuova attività'));
      await tester.pumpAndSettle();

      // Siamo sulla schermata di creazione.
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Comprare il pane');
      await tester.tap(find.text('Importante'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aggiungi attività'));
      await tester.pumpAndSettle();

      // Torna all'elenco con la nuova attività.
      expect(find.byType(TextFormField), findsNothing);
      expect(store.total, 1);
      expect(store.tasks.single.title, 'Comprare il pane');
      expect(store.tasks.single.isImportant, isTrue);
      expect(store.tasks.single.status, TaskStatus.todo);
      expect(find.text('Comprare il pane'), findsOneWidget);

      // Messaggio temporaneo di conferma.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('«Comprare il pane» aggiunta all\'elenco'), findsOneWidget);
    });

    testWidgets('variante titolo mancante: segnala l\'errore e non crea nulla',
        (tester) async {
      final store = await pumpApp(tester);

      await tester.tap(find.text('Nuova attività'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aggiungi attività'));
      await tester.pumpAndSettle();

      expect(find.text('Inserisci un titolo per l\'attività'), findsOneWidget);
      expect(store.isEmpty, isTrue);
      // Restiamo sul form.
      expect(find.byType(TextFormField), findsOneWidget);

      // L'errore scompare appena il titolo viene corretto.
      await tester.enterText(find.byType(TextFormField), 'Studiare Flutter');
      await tester.pumpAndSettle();
      expect(find.text('Inserisci un titolo per l\'attività'), findsNothing);

      await tester.tap(find.text('Aggiungi attività'));
      await tester.pumpAndSettle();
      expect(store.total, 1);
    });

    testWidgets('variante rinuncia: l\'elenco resta invariato, nessun messaggio',
        (tester) async {
      final store = await pumpApp(tester);

      await tester.tap(find.text('Nuova attività'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Attività abbandonata');

      // Comando di ritorno del dispositivo.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(store.isEmpty, isTrue);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Nessuna attività'), findsOneWidget);
    });

    testWidgets('di default l\'attività non è importante', (tester) async {
      final store = await pumpApp(tester);

      await tester.tap(find.text('Nuova attività'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Normale');
      await tester.tap(find.text('Aggiungi attività'));
      await tester.pumpAndSettle();

      expect(store.tasks.single.isImportant, isFalse);
      expect(find.text('Normale'), findsWidgets); // titolo + pill "Normale"
    });
  });

  group('S2 – Consultare le attività', () {
    testWidgets('mostra elenco, stato, importanza e conteggio', (tester) async {
      final store = await pumpApp(
        tester,
        titles: <String>['Pane', 'Latte', 'Bolletta'],
        importantTitles: <String>{'Bolletta'},
      );
      store.toggleStatus(store.tasks[1].id); // Latte completata
      await tester.pumpAndSettle();

      expect(find.text('Pane'), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Bolletta'), findsOneWidget);

      expect(find.text('1 di 3 completate'), findsOneWidget);
      expect(find.text('Importante'), findsOneWidget);
      expect(find.text('Normale'), findsNWidgets(2));
      expect(find.text('Completata'), findsOneWidget);
      expect(find.text('Da fare'), findsNWidgets(2));
    });

    testWidgets('variante nessuna attività: indica come aggiungerne una',
        (tester) async {
      await pumpApp(tester);

      expect(find.text('Nessuna attività'), findsOneWidget);
      expect(find.text('Aggiungi la prima attività'), findsOneWidget);
      expect(find.textContaining('per aggiungere la prima'), findsOneWidget);
    });
  });

  group('S3 – Aggiornare lo stato', () {
    testWidgets('selezionando l\'attività si aggiornano stato e conteggio',
        (tester) async {
      final store = await pumpApp(tester, titles: <String>['Pane', 'Latte']);
      expect(find.text('0 di 2 completate'), findsOneWidget);

      await tester.tap(find.text('Pane'));
      await tester.pumpAndSettle();

      expect(store.tasks.first.isDone, isTrue);
      expect(find.text('1 di 2 completate'), findsOneWidget);
      expect(find.text('Completata'), findsOneWidget);

      // Si può tornare a "da fare" con la casella.
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(store.tasks.first.isDone, isFalse);
      expect(find.text('0 di 2 completate'), findsOneWidget);
    });
  });

  group('S4 – Eliminare un\'attività', () {
    testWidgets('chiede conferma e poi rimuove', (tester) async {
      final store = await pumpApp(tester, titles: <String>['Pane', 'Latte']);

      await tester.tap(find.byTooltip('Elimina «Pane»'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminare l\'attività?'), findsOneWidget);

      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();

      expect(store.total, 1);
      expect(find.text('Pane'), findsNothing);
      expect(find.text('Latte'), findsOneWidget);
    });

    testWidgets('variante rinuncia: l\'attività resta invariata', (tester) async {
      final store = await pumpApp(tester, titles: <String>['Pane', 'Latte']);

      await tester.tap(find.byTooltip('Elimina «Pane»'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(store.total, 2);
      expect(find.text('Pane'), findsOneWidget);
    });
  });
}
