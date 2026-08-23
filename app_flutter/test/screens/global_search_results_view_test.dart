// GLOBAL SEARCH — the IN-PLACE results panel (option A). [GlobalSearchResultsView]
// is what HomeShell overlays over EVERY tab while a query is present, so the search
// results REPLACE the screen content wherever you are. This proves the panel shows
// the live ENTITY domains (not just products) — the whole point of the unification.
//
// Gated on [kGlobalSearch] (const, default OFF); run the real assertion with
//   flutter test test/screens/global_search_results_view_test.dart \
//     --dart-define=GLOBAL_SEARCH=true

import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/screens/catalog_screen.dart'
    show GlobalSearchResultsView, keyboardDiveQueryProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'the panel renders an ENTITY tile (task) in place for a query — proving it '
      'shows the live domains, not only products', (tester) async {
    if (!kGlobalSearch) {
      markTestSkipped('kGlobalSearch OFF — run with '
          '--dart-define=GLOBAL_SEARCH=true to exercise the panel');
      return;
    }
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // The keyboard seeds this on every keystroke, on every tab. Seed it directly
    // here to drive the panel. "איטום" is a SEEDED task name ("איטום רצפת מקלחת")
    // with no catalog product match — so the panel's ENTITY row must carry it.
    container.read(keyboardDiveQueryProvider.notifier).state = 'איטום';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: GlobalSearchResultsView()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('איטום רצפת מקלחת'), findsWidgets,
        reason: 'the seeded task surfaces as an entity tile in the panel');
    expect(find.text('משימה'), findsWidgets,
        reason: 'the entity tile carries its Hebrew type badge (task = משימה)');
  });
}
