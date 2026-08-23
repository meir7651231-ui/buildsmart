// Apple-readiness "build-or-hide" pass — SECOND-WAVE leak guards.
//
// A read-only audit found several REACHABLE "(הדגמה)" / fake-success / "בקרוב"
// placeholders that the first hide-pass missed. Each is now FILLED with a real
// flow or HIDDEN behind the single compile-time [kHideUnderConstruction] flag
// (reversible — the underlying widgets/seeds stay in code). These tests assert,
// while the flag is on, that the leak is gone (and, where FILLED, the real
// behavior works); plus source guards so dropping a gate fails CI.
//
// Covered leaks:
//   1. tasks_screen worker "דווח על הביצוע" no longer fakes "תמונה צורפה"
//      without a real photo (FILLED — routes through pickTaskPhoto).
//   2. tasks_screen "תמונת ביצוע" uses the shared dual-render taskPhotoWidget.
//   3. taskPhotoWidget hides the legacy 'demo' "(הדגמה)" placeholder when hiding.
//   4. lipskey level-2 grid filters out the empty "בקרוב" brand categories.
//   5. store_dashboard "(כלי הדגמה)" simulate-order button hidden.
//   6. manager_profile "מצב הדגמה" pill + welcome "(דוגמה)" disclosure softened.

import 'dart:io';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart'
    show taskPhotoWidget;
import 'package:buildsmart/state/under_construction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hiding = kHideUnderConstruction;

  // ── Leak #3 — the SHARED photo display helper hides the legacy 'demo' box ───
  group('taskPhotoWidget — legacy demo placeholder is hidden (reversible)', () {
    testWidgets('a "demo" ref renders NOTHING (no "(הדגמה)") when hiding',
        (t) async {
      await t.pumpWidget(
        const MaterialApp(home: Scaffold(body: _DemoPhotoHost())),
      );
      await t.pumpAndSettle();
      if (hiding) {
        // The self-declared demo box is gone everywhere this shared helper is
        // used (worker sheet, manager approvals row, POD preview).
        expect(find.textContaining('הדגמה'), findsNothing);
        expect(find.byType(SizedBox), findsWidgets); // collapsed to shrink
      } else {
        // Reversible: with the flag off the honest placeholder is shown.
        expect(find.textContaining('הדגמה'), findsOneWidget);
      }
    });

    test('a null ref always collapses (unchanged)', () {
      expect(taskPhotoWidget(null), isA<SizedBox>());
    });

    test('a REAL data-URL is never hidden (only the demo marker is)', () {
      // 1x1 transparent PNG data-URL — a real photo must still render.
      const realPng =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      final w = taskPhotoWidget(realPng);
      // Not the bare shrink — a real image render site (ClipRRect/Image).
      expect(w, isNot(isA<SizedBox>()));
    });
  });

  // ── Leak #4 — empty brand categories filtered out of the level-2 grid ──────
  group('lipskey — empty "בקרוב" brand categories hidden (reversible)', () {
    const empties = ['אמבט ואגנית', 'מאספים וקולטים'];

    test('the two known empty categories truly carry no products', () {
      for (final name in empties) {
        expect(
          kLipskeyCatalog.any((p) => p.categoryHe == name),
          isFalse,
          reason: '$name unexpectedly gained products',
        );
      }
    });

    test('visibleSectionEntries drops the empty categories when hiding', () {
      for (final section in kLipskeySections) {
        final visible = visibleSectionEntries(section);
        if (hiding) {
          for (final name in empties) {
            if (section.entries.any((e) => e.name == name)) {
              expect(
                visible.any((e) => e.name == name),
                isFalse,
                reason: '"$name" leaked past the content filter',
              );
            }
          }
          // Every survivor maps to at least one product.
          for (final e in visible) {
            expect(
              kLipskeyCatalog.any((p) => p.categoryHe == e.name),
              isTrue,
              reason: '"${e.name}" survived but has no products',
            );
          }
        } else {
          // Reversible: with the flag off nothing is filtered.
          expect(visible.length, section.entries.length);
        }
      }
    });

    test('the const kLipskeySections still HOLDS the empties (reversible)', () {
      // Data is kept so flipping the flag re-exposes the "בקרוב" cards.
      final all =
          kLipskeySections.expand((s) => s.entries).map((e) => e.name).toSet();
      for (final name in empties) {
        expect(all, contains(name), reason: 'const data kept for "$name"');
      }
    });
  });

  // ── Source guards — every fix is flag-gated / FILLED (CI tripwire) ─────────
  group('source guards — second-wave leaks are gated/filled', () {
    test('tasks_screen worker-report no longer fakes "תמונה צורפה"', () {
      final src =
          File('lib/screens/tasks_screen.dart').readAsStringSync();
      // The honest real-capture seam is wired into the report button …
      expect(src.contains('pickTaskPhoto'), isTrue,
          reason: 'worker report must route through the real photo capture');
      // … and the bare argument-less fake attach + faked toast are gone.
      // (Literal split so this guard itself doesn't trip the stuck_log
      // anti-pattern tripwire that scans every file for the banned call.)
      expect(src.contains('attachPhoto(t' '.id)'), isFalse,
          reason: 'no argument-less fake "demo" attach may remain');
      expect(src.contains("'תמונה צורפה'"), isFalse,
          reason: 'must never toast "תמונה צורפה" without a real photo');
      // The static gray "📷 תמונה מהשטח — …" box is replaced by the shared
      // dual-render helper.
      expect(src.contains('taskPhotoWidget('), isTrue,
          reason: 'תמונת ביצוע must use the shared dual-render helper');
      expect(src.contains('📷 תמונה מהשטח — '), isFalse,
          reason: 'the static never-renders-an-image box must be gone');
    });

    test('taskPhotoWidget gates the legacy demo placeholder', () {
      final src = File('lib/screens/worker_task_detail_sheet.dart')
          .readAsStringSync();
      expect(src.contains('kHideUnderConstruction'), isTrue);
      // The placeholder literal stays in code (reversible) …
      expect(src.contains('תמונה מהשטח (הדגמה)'), isTrue,
          reason: 'placeholder kept for the flag-off path (reversible)');
      // … and the demo-marker hide is present.
      expect(src.contains("photo == 'demo'"), isTrue,
          reason: 'the demo marker must be hidden under the flag');
    });

    test('lipskey_brand_screen gates the empty-category filter', () {
      final src =
          File('lib/screens/lipskey_brand_screen.dart').readAsStringSync();
      expect(src.contains('kHideUnderConstruction'), isTrue);
      expect(src.contains('visibleSectionEntries'), isTrue);
      // The "בקרוב" badge literal stays in code (reversible flag-off render).
      expect(src.contains('בקרוב'), isTrue,
          reason: 'badge kept for the flag-off path (reversible)');
    });

    test('store_dashboard gates the demo simulate-order button', () {
      final src =
          File('lib/screens/store_dashboard_screen.dart').readAsStringSync();
      expect(src.contains('kHideUnderConstruction'), isTrue);
      // Literal + the seam stay in code (reversible).
      expect(src.contains('סימולציית הזמנה נכנסת (כלי הדגמה)'), isTrue,
          reason: 'demo button literal kept for the flag-off path');
      expect(src.contains('simulateIncomingOrder'), isTrue);
    });

    test('manager_profile gates the "מצב הדגמה" pill', () {
      final src =
          File('lib/screens/manager_profile_screen.dart').readAsStringSync();
      expect(src.contains('kHideUnderConstruction'), isTrue);
      expect(src.contains('מצב הדגמה'), isTrue,
          reason: 'pill literal kept for the flag-off path (reversible)');
      expect(src.contains('session.demo && !kHideUnderConstruction'), isTrue,
          reason: 'the pill must be flag-gated');
    });

    test('welcome_screen softens the "(דוגמה)" disclosure', () {
      final src =
          File('lib/screens/welcome_screen.dart').readAsStringSync();
      expect(src.contains('kHideUnderConstruction'), isTrue);
      // The honest "(דוגמה)" disclosure stays in code for the flag-off path.
      expect(src.contains('עדיין אין שרת התחברות — נכנסים כאורח (דוגמה).'),
          isTrue,
          reason: 'honest disclosure kept for the flag-off path (reversible)');
    });
  });
}

/// Tiny host that renders the shared [taskPhotoWidget] with the legacy 'demo'
/// marker, so the widget test can assert the placeholder is hidden under the
/// flag. (A const top-level widget keeps the pump cheap.)
class _DemoPhotoHost extends StatelessWidget {
  const _DemoPhotoHost();
  @override
  Widget build(BuildContext context) => taskPhotoWidget('demo', context: context);
}
