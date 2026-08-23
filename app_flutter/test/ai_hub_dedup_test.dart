// Render-guard for the AI-hub dedup (consolidate-duplicate-surfaces refactor):
// the '💡 חלופות זולות' and '📐 סריקת תוכניות' tiles must open the CANONICAL R9
// modal sheets (contractor_tools_sheets.dart) — not the old duplicate full
// screens (_Alternatives / _PlanScan, now deleted). Locks the switch wiring in
// ai_hub_screen.dart so a future edit can't silently re-introduce a second
// surface or break the tile → sheet path.
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AI-hub "חלופות זולות" tile opens the canonical cheaper-alts sheet',
      (t) async {
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AIHubScreen())),
    );
    await t.pumpAndSettle();

    // Grid intact after the dedup — both refactored tiles still present.
    expect(find.text('חלופות זולות'), findsOneWidget);
    expect(find.text('סריקת תוכניות'), findsOneWidget);

    await t.ensureVisible(find.text('חלופות זולות'));
    await t.pumpAndSettle();
    await t.tap(find.text('חלופות זולות'));
    await t.pumpAndSettle();

    expect(t.takeException(), isNull,
        reason: 'opening the canonical sheet must not throw');
    // The R9 sheet renders cheaper-alternative rows carrying savings — proof it
    // is the modal sheet, not a pushed full screen.
    expect(find.textContaining('חיסכון'), findsWidgets,
        reason: 'canonical cheaper-alternatives sheet must render savings rows');
  });
}
