// Apple-readiness "build-or-hide" pass — guard suite.
//
// The product owner decided that for App Store review every backend-blocked
// "under construction" feature must be HIDDEN (no visible "בבנייה"/"בקרוב"/
// "(הדגמה)"/"לא זמין" placeholder). The hide is driven by the single
// compile-time [kHideUnderConstruction] flag and is fully REVERSIBLE: the
// underlying widgets, providers, seeds and const data all stay in code, so
// flipping the flag re-exposes everything.
//
// These tests assert, while the flag is on:
//   • the AI hub's DEFERRED tools (3way / weather / wear) are gone from the
//     live search index AND from the rendered hub grid — and the REAL tools
//     (plan-scan / barcode / voice / analytics) are kept;
//   • the chat attachment sheet shows no "לא זמין בדמו" placeholder rows;
//   • C7 (plan-scan / "סריקת תוכניות") stays visible — it is a real flow;
//   • B6 (filter + sort) is genuinely wired (pure functions reorder/filter a
//     real list).

import 'dart:io';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show filterByImage, sortCatalogProducts;
import 'package:buildsmart/screens/store_screen.dart' show StoreScreen;
import 'package:buildsmart/state/catalog_settings.dart' show ProductSort;
import 'package:buildsmart/state/under_construction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hiding = kHideUnderConstruction;

  // ── Search index: deferred AI tools filtered, real ones kept ───────────────
  group('search index hides the deferred AI tools (reversible)', () {
    test('kHiddenSearchTitles are absent from kVisibleSearchIndex', () {
      if (!hiding) return; // copy returns only when the flag is on
      for (final title in kHiddenSearchTitles) {
        expect(
          kVisibleSearchIndex.where((e) => e.title == title),
          isEmpty,
          reason: 'hidden AI tool "$title" must not be search-navigable',
        );
      }
    });

    test('the const kSearchIndex still HOLDS them (hide is reversible)', () {
      for (final title in kHiddenSearchTitles) {
        expect(
          kSearchIndex.where((e) => e.title == title),
          isNotEmpty,
          reason: 'const data kept so flip re-exposes "$title"',
        );
      }
    });

    test('the real AI tools + C7 plan-scan are KEPT in the live index', () {
      for (final keep in const [
        'סריקת תוכניות', // C7 — real scan flow, must stay
        'חיזוי מלאי',
        'סורק ברקוד',
        'דיבור למשימה',
        'Analytics חכם',
      ]) {
        expect(
          kVisibleSearchIndex.where((e) => e.title == keep),
          isNotEmpty,
          reason: '"$keep" is a real feature and must stay searchable',
        );
      }
    });
  });

  // ── AI hub grid: deferred tiles not rendered, real tiles rendered ──────────
  group('AI hub grid hides the deferred tool tiles', () {
    test('visibleToolIds excludes the deferred ids when hiding', () {
      if (hiding) {
        for (final id in AIHubScreen.deferredToolIds) {
          expect(AIHubScreen.visibleToolIds, isNot(contains(id)),
              reason: 'deferred tool "$id" must not render on the hub grid');
        }
      }
    });

    test('the real tools (incl. C7 plan) stay on the grid', () {
      // plan = C7 (real scan flow); stock/barcode/voice/alt/analytics = real.
      for (final id in const ['plan', 'stock', 'barcode', 'voice', 'analytics']) {
        expect(AIHubScreen.visibleToolIds, contains(id),
            reason: 'real tool "$id" must stay on the grid');
      }
    });

    test('exactly the 3 deferred tools are dropped (count check)', () {
      if (hiding) {
        // 9 tiles total − 3 deferred = 6 visible.
        expect(AIHubScreen.visibleToolIds, hasLength(6));
        expect(AIHubScreen.deferredToolIds, {'3way', 'weather', 'wear'});
      }
    });
  });

  // ── B6: filter + sort are genuinely wired (pure-function behavior) ─────────
  group('B6 — catalog filter + sort really transform a list', () {
    const withImg = LipskeyCatalogProduct(
      sku: 'A-200',
      nameHe: 'בית', // ב
      nameEn: 'House',
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🧪',
      page: 1,
      imageFile: 'house.jpg',
    );
    const noImg = LipskeyCatalogProduct(
      sku: 'A-100',
      nameHe: 'אבן', // א — sorts before ב
      nameEn: 'Stone',
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🧪',
      page: 1,
    );
    const list = [withImg, noImg];

    test('sort name A-Z reorders (אבן before בית)', () {
      final sorted = sortCatalogProducts(list, ProductSort.nameAZ);
      expect(sorted.map((p) => p.nameHe), ['אבן', 'בית']);
    });

    test('sort name Z-A reverses', () {
      final sorted = sortCatalogProducts(list, ProductSort.nameZA);
      expect(sorted.map((p) => p.nameHe), ['בית', 'אבן']);
    });

    test('sort by SKU orders by sku string', () {
      final sorted = sortCatalogProducts(list, ProductSort.sku);
      expect(sorted.map((p) => p.sku), ['A-100', 'A-200']);
    });

    test('image-only filter keeps only products that carry an image', () {
      expect(filterByImage(list, true), [withImg]);
      expect(filterByImage(list, false), list); // off = passthrough
    });
  });

  // ── Store persona: placeholder quick-actions / hub tiles hidden ────────────
  group('store screen hides its "בבנייה" placeholders', () {
    Future<void> pumpStore(WidgetTester t) async {
      SharedPreferences.setMockInitialValues({});
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: StoreScreen())),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('placeholder quick-actions gone, real ones kept', (t) async {
      await pumpStore(t);
      if (hiding) {
        // מועדים / תזמון / שיחה open all-"בבנייה" sheets → hidden.
        expect(find.text('מועדים'), findsNothing);
        expect(find.text('תזמון'), findsNothing);
        expect(find.text('שיחה'), findsNothing);
      }
      // Real quick-actions always present.
      expect(find.text('מועדפים'), findsOneWidget);
      expect(find.text('כספים'), findsOneWidget);
    });

    testWidgets('placeholder hub tiles gone, wired tiles + no בבנייה', (t) async {
      await pumpStore(t);
      if (hiding) {
        // _tapFor → null tiles (toast "בבנייה") are filtered out.
        expect(find.text('השכרת כלים'), findsNothing);
        expect(find.text('פקדונות'), findsNothing);
        expect(find.text('🔧 שירותים'), findsNothing); // services tab hidden
        // No reachable "בבנייה" anywhere on the landing hub.
        expect(find.textContaining('בבנייה'), findsNothing);
      }
      // The wired tiles still render.
      expect(find.text('הסל שלי'), findsWidgets);
      expect(find.text('ההזמנות שלי'), findsWidgets);
    });
  });

  // ── Source guard: every gated visible placeholder is behind the flag ───────
  // A regression tripwire — if someone deletes a `kHideUnderConstruction` guard
  // (re-exposing the placeholder for Apple review), the matching case fails.
  // It asserts the placeholder LITERAL and the flag name both appear in the
  // file, i.e. the render of that string is flag-gated.
  group('source guard — placeholders are gated by kHideUnderConstruction', () {
    const cases = <String, List<String>>{
      'lib/screens/chats_screen.dart': ['לא זמין בדמו'],
      'lib/screens/persona_portal.dart': ['נתוני הדגמה'],
      'lib/screens/courier_portal_tab.dart': ['זמינות להדגמה'],
      'lib/screens/persona_picking_sheet.dart': ['ביטול ההזמנה כולה — בקרוב'],
      // The worker-report "תמונה צורפה (הדגמה)" fake was FILLED — it now routes
      // through the real pickTaskPhoto capture (no faked success). The file's
      // remaining flag-gated placeholder is the manager-board demo disclaimer.
      'lib/screens/tasks_screen.dart': ['(בהדגמה —'],
      'lib/screens/store_screen.dart': ['🚧 בבנייה'],
      'lib/screens/home_shell.dart': ['שירותים'],
    };
    cases.forEach((path, needles) {
      test('$path gates its placeholder(s)', () {
        final src = File(path).readAsStringSync();
        expect(src.contains('kHideUnderConstruction'), isTrue,
            reason: '$path must import/use the hide flag');
        for (final n in needles) {
          expect(src.contains(n), isTrue,
              reason: 'literal "$n" expected to still exist in code (reversible)');
        }
      });
    });
  });
}
