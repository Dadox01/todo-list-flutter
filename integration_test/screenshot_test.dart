// Test end-to-end che percorre gli scenari S1–S4 sull'emulatore e, tramite
// `simctl`, produce gli screenshot in docs/screenshots.
//
// Esecuzione:
//   flutter test integration_test/screenshot_test.dart -d <device-id>
//
// Ogni stato interessante viene "congelato" per 20 secondi: durante la pausa
// uno script esterno lancia `xcrun simctl io booted screenshot`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/state/tasks_store.dart';

Future<void> _holdForScreenshot(String name) async {
  debugPrint('SHOT:$name');
  await Future<void>.delayed(const Duration(seconds: 20));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('percorso completo e screenshot degli scenari', (tester) async {
    final store = TasksStore();
    await tester.pumpWidget(TodoListApp(store: store));
    await tester.pumpAndSettle();

    // Toccando fuori dal campo il focus si perde e la tastiera si chiude.
    Future<void> dismissKeyboard() async {
      await tester.tap(find.text('Descrivi l\'attività e indica se è importante.'));
      await tester.pumpAndSettle();
    }

    // S2 variante: nessuna attività.
    expect(find.text('Nessuna attività'), findsOneWidget);
    await _holdForScreenshot('03-vuoto');

    // S1: apro il form e provo a confermare senza titolo.
    await tester.tap(find.text('Nuova attività'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un titolo per l\'attività'), findsOneWidget);
    await dismissKeyboard();
    await _holdForScreenshot('04-errore-titolo');

    // Compilo il form (l'errore sparisce) e attivo "Importante".
    await tester.enterText(
      find.byType(TextFormField),
      'Pagare la bolletta della luce',
    );
    await tester.tap(find.text('Importante'));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un titolo per l\'attività'), findsNothing);
    await dismissKeyboard();
    await _holdForScreenshot('02-nuova-attivita');

    // Confermo: torno all'elenco con l'attività aggiunta e il messaggio.
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();
    expect(store.total, 1);
    await _holdForScreenshot('06-messaggio-conferma');

    // Aggiungo altre attività per rendere l'elenco rappresentativo.
    for (final title in const <String>['Comprare il pane', 'Chiamare il dentista']) {
      await tester.tap(find.text('Nuova attività'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), title);
      if (title == 'Chiamare il dentista') {
        await tester.tap(find.text('Importante'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Aggiungi attività'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Nuova attività'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Leggere 20 pagine');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();
    expect(store.total, 4);

    // S3: segno due attività come completate.
    await tester.tap(find.text('Comprare il pane'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leggere 20 pagine'));
    await tester.pumpAndSettle();
    expect(store.completedCount, 2);
    expect(find.text('2 di 4 completate'), findsOneWidget);

    // Chiudo la coda degli SnackBar di conferma prima dello screenshot.
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
        .clearSnackBars();
    await tester.pumpAndSettle();
    await _holdForScreenshot('01-elenco');

    // S4: richiesta di eliminazione con conferma.
    await tester.tap(find.byTooltip('Elimina «Chiamare il dentista»'));
    await tester.pumpAndSettle();
    expect(find.text('Eliminare l\'attività?'), findsOneWidget);
    await _holdForScreenshot('05-conferma-eliminazione');

    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();
    expect(store.total, 3);
  });
}
