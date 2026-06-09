// Cluster-1 guard (9×9 fleet, autonomous run 2026-06-09 · tasks #38/#40/#48):
// the 3 AI-tool modal bottom-sheets each gained an explicit X (tooltip 'סגור')
// in addition to drag/scrim dismissal. These widget tests are the BEHAVIORAL
// proof that tapping the X pops the sheet (grep proves the bytes; this proves
// the behavior). The X lives in the shared `_SheetHandle` used by all 3 sheets.
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Host with a button that opens [open] on a real BuildContext, under RTL +
/// ProviderScope (the scan sheet is a ConsumerStatefulWidget).
Widget _host(void Function(BuildContext) open) => ProviderScope(
      child: MaterialApp(
        builder: (ctx, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => open(ctx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _openThenCloseWithX(
  WidgetTester t,
  void Function(BuildContext) open,
  String title,
) async {
  await t.pumpWidget(_host(open));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  expect(find.text(title), findsOneWidget, reason: 'sheet should be open');

  // The explicit close affordance — verbatim Hebrew tooltip 'סגור'.
  final x = find.byTooltip('סגור');
  expect(x, findsOneWidget, reason: 'sheet must expose an explicit סגור (X)');

  await t.tap(x);
  await t.pumpAndSettle();
  expect(find.text(title), findsNothing,
      reason: 'tapping the X (סגור) must dismiss the sheet');
}

void main() {
  testWidgets('חלופות זולות sheet — X (סגור) dismisses it', (t) async {
    await _openThenCloseWithX(
        t, openCheaperAlternativesSheet, '💡 חלופות זולות');
  });

  testWidgets('השוואת מחירים sheet — X (סגור) dismisses it', (t) async {
    await _openThenCloseWithX(t, openPriceCompareSheet, '📊 השוואת מחירים');
  });

  testWidgets('סרוק תוכנית sheet — X (סגור) dismisses the picker', (t) async {
    // Picker phase only (no plan picked → no scan Timer started): the shared
    // _SheetHandle X is present in every phase and means full-dismiss.
    await _openThenCloseWithX(
        t, (ctx) => openScanPlanSheet(ctx), '📐 סרוק תוכנית עבודה');
  });
}
