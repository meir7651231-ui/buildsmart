// Guards the dark-mode TEXT regression (#darkmode-ink): dark-mode waves 1–16 made
// the SURFACES theme-aware (bgLight→scaffoldBackgroundColor, cardLight→surface)
// but left the text on const `BsTokens.inkLight` (#1A1A1A) / `mutedLight`. In dark
// mode that is near-black ink on `cardDark` (#1F1A13) — ~1:1 contrast, the title
// literally disappears. Fixed screens read ink via `bsInk(context)` /
// `bsMuted(context)` (lib/theme/app_theme.dart) — light mode byte-identical.
//
// This pumps each fixed screen under the DARK theme and asserts no rendered text
// still carries the light-only ink, and that light mode still does (no drift).
import 'dart:math' as math;

import 'package:buildsmart/data/repositories/claude_functions.dart';
import 'package:buildsmart/features/catalog_config/catalog_config_screen.dart';
import 'package:buildsmart/screens/adapter_explain_screen.dart';
import 'package:buildsmart/screens/ai_assistant_screen.dart';
import 'package:buildsmart/screens/ai_finder_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/lipskey_brand_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/screens/suppliers_screen.dart';
import 'package:buildsmart/screens/alt_explain_screen.dart';
import 'package:buildsmart/screens/audit_screen.dart';
import 'package:buildsmart/screens/business_summary_screen.dart';
import 'package:buildsmart/screens/coming_soon_screen.dart';
import 'package:buildsmart/screens/consent_modal.dart';
import 'package:buildsmart/screens/credit_explain_screen.dart';
import 'package:buildsmart/screens/daily_report_screen.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart';
import 'package:buildsmart/screens/paired_explain_screen.dart';
import 'package:buildsmart/screens/quote_polish_screen.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/screens/reject_reason_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/studio/studio_screen.dart';
import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show studioCanEditProvider;
import 'package:buildsmart/state/studio/studio_nav.dart'
    show studioSelectedIdProvider;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show FontLoader, TextInputAction, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every text color actually painted (RenderParagraph spans, recursively).
Set<Color> _paintedTextColors(WidgetTester t) {
  final out = <Color>{};
  void visit(InlineSpan s) {
    final c = s.style?.color;
    if (c != null) out.add(c);
    if (s is TextSpan) s.children?.forEach(visit);
  }
  for (final e in find.byType(RichText).evaluate()) {
    final r = e.renderObject;
    if (r is RenderParagraph) visit(r.text);
  }
  return out;
}

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The nearest OPAQUE fill painted behind [e] (Container/DecoratedBox/ColoredBox/
/// Material — Scaffold & AppBar are Materials), else the theme scaffold color.
Color _backdrop(Element e) {
  Color? found;
  e.visitAncestorElements((a) {
    final w = a.widget;
    Color? c;
    if (w is ColoredBox) c = w.color;
    if (w is DecoratedBox && w.decoration is BoxDecoration) {
      c = (w.decoration as BoxDecoration).color;
    }
    if (w is Material && w.type != MaterialType.transparency) {
      c = w.color ?? Theme.of(a).colorScheme.surface;
    }
    if (c != null && c.a == 1) {
      found = c;
      return false;
    }
    return true;
  });
  return found ?? Theme.of(e).scaffoldBackgroundColor;
}

final _hasLetters = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Every ink-family text (the class this regression is about) must clear WCAG AA.
List<String> _lowContrastInk(WidgetTester t) {
  final ink = <Color>{
    BsTokens.inkLight, BsTokens.mutedLight, BsTokens.inkDark, BsTokens.mutedDark,
    BsTokens.dangerDark, BsTokens.dangerOnDark,
  };
  final bad = <String>[];
  for (final e in find.byType(RichText).evaluate()) {
    final r = e.renderObject;
    if (r is! RenderParagraph) continue;
    // Pictograph-only text (an emoji avatar) paints in the glyph's own
    // colours — its TextStyle colour is not what the eye sees. Judge text only.
    if (!_hasLetters.hasMatch(r.text.toPlainText())) continue;
    final bg = _backdrop(e);
    void v(InlineSpan s) {
      final c = s.style?.color;
      if (c != null && ink.contains(c)) {
        final k = _contrast(c, bg);
        if (k < 4.5) {
          bad.add('"${r.text.toPlainText()}" ${k.toStringAsFixed(2)}:1 on $bg');
        }
      }
      if (s is TextSpan) s.children?.forEach(v);
    }
    v(r.text);
  }
  return bad;
}

Future<void> _pump(WidgetTester t, Widget home,
    {required bool dark,
    List<Override> overrides = const [],
    Size size = const Size(780, 1600)}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: home,
    ),
  ));
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

class _SheetHost extends StatelessWidget {
  const _SheetHost();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showManagerScreensSheet(context),
            child: const Text('open'),
          ),
        ),
      );
}

Future<void> _openSheetIfNeeded(WidgetTester t, String name) async {
  if (name != 'manager_screens_sheet') return;
  await t.tap(find.text('open'));
  for (var i = 0; i < 10; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
  expect(find.text('מעבר בין מסכים'), findsOneWidget,
      reason: 'the sheet must actually be open before asserting on it');
}

final _screens = <String, Widget>{
  'coming_soon': const ComingSoonScreen(profession: 'חשמלאי'),
  'alt_explain': const AltExplainScreen(
      product: 'ברז', recName: 'א', recPrice: 100, altName: 'ב', altPrice: 80),
  'quote_polish':
      const QuotePolishScreen(rawQuote: 'הצעה', productName: 'צינור'),
  'adapter_explain':
      const AdapterExplainScreen(productName: 'מתאם', sku: '9101601610'),
  'paired_explain':
      const PairedExplainScreen(product: 'ברז', types: ['אטם']),
  'daily_report':
      const DailyReportScreen(title: 'דוח', reportLines: ['שורה']),
  'credit_explain': const CreditExplainScreen(
      name: 'יוסי', creditLimit: 1000, used: 500, balance: 500, pct: 50),
  'manager_screens_sheet': const _SheetHost(),
  'reject_reason': const RejectReasonScreen(role: 'קבלן', name: 'יוסי'),
  'business_summary':
      const BusinessSummaryScreen(insightLines: ['הכנסות']),
};

/// Fake gateway: [fail] throws (→ AiFailedState); else returns a reply (→ the
/// per-screen result text). Without an override the gateway is null in tests and
/// only the "AI off" rung renders — so these modes reach the other rungs.
class _FakeGateway implements ClaudeGateway {
  _FakeGateway({required this.fail});
  final bool fail;
  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    if (fail) throw const ClaudeException('internal', 'boom');
    return const ClaudeResult(text: 'תשובת-בדיקה של המודל', model: 'fake');
  }
}

const _aiScreens = {
  'alt_explain', 'quote_polish', 'adapter_explain', 'paired_explain',
  'daily_report', 'credit_explain', 'reject_reason', 'business_summary',
};

/// Opens a sheet/dialog entry point from a button (needs a [WidgetRef] for some).
class _Opener extends ConsumerWidget {
  const _Opener(this.open);
  final void Function(BuildContext, WidgetRef) open;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => open(context, ref),
            child: const Text('open'),
          ),
        ),
      );
}

/// Wave 2 (#darkmode-ink-w2). Judged by the WCAG check only: these screens also
/// host widgets from files not in this wave, so a blanket "no inkLight" ban
/// would flag legit dark-on-light-chip text. `tap` reaches the converted text.
final _wave2 = <String, (Widget, String?)>{
  'manager_copilot': (const ManagerCopilotScreen(), 'מה בוער עכשיו?'),
  // Studio is the owner's desktop editor — pumped at a desktop width below.
  'studio': (const StudioScreen(), null),
  'audit': (const AuditScreen(), null),
  'regression_panel': (const RegressionPanelScreen(), null),
  'catalog_config': (const CatalogConfigScreen(), null),
  'lipskey_products_empty':
      (const LipskeyProductsScreen(category: 'ריק', products: []), null),
  'role_picker': (_Opener((c, _) => showRolePicker(c)), 'open'),
  'consent_modal': (_Opener(showConsentModal), 'open'),
  // Copilot WITHOUT a tap: the welcome rung (headline · sub · chips) — tapping a
  // chip swaps it out for the bubbles, so it needs its own case.
  'manager_copilot_welcome': (const ManagerCopilotScreen(), null),
  // Studio panes beyond the default tree — reached by their pane tab.
  'studio_inspector': (const StudioScreen(), 'מפקח'),
  'studio_find': (const StudioScreen(), 'מצא והחלף'),
  'studio_history': (const StudioScreen(), 'גרסאות'),
  // Draft-dependent studio surfaces (a seeded draft text, see _seedDraft).
  'studio_publish_sheet': (const StudioScreen(), 'פרסם לכולם'),
  'studio_discard_sheet': (const StudioScreen(), 'בטל טיוטה'),
};

/// Cases that need a live studio DRAFT (find hits · publish/discard sheets).
const _needsDraft = {'studio_find', 'studio_publish_sheet', 'studio_discard_sheet'};

/// Seeds a draft text override on cart.cta through the real store API.
void _seedDraft(WidgetTester t) {
  ProviderScope.containerOf(t.element(find.byType(StudioScreen)))
      .read(configStoreProvider.notifier)
      .editDraft('cart.cta', (n) => n.copyWith(text: 'הזמנה מהירה'));
}

/// Proof each case really reached its target (not a vacuous pass).
const _mustSee = <String, String>{
  'role_picker': 'מי אתה?',
  'consent_modal': 'שיפור השירות — נתוני שימוש',
  'manager_copilot': 'תשובת-בדיקה של המודל',
  'studio_inspector': 'cart.cta',
  'studio_history': 'עדיין לא פורסמו גרסאות',
  'studio_publish_sheet': 'ישפיע על כל המשתמשים',
  'studio_discard_sheet': 'הטיוטה תימחק',
};

/// Extra provider seeding per case (the inspector needs a selected element).
final _extra = <String, List<Override>>{
  'studio_inspector': [studioSelectedIdProvider.overrideWith((_) => 'cart.cta')],
  // Draft surfaces are owner-gated (#84) — the owner is the one who sees them.
  for (final n in _needsDraft) n: [studioCanEditProvider.overrideWith((_) => true)],
};

Future<void> _settle(WidgetTester t, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// Wave 3 (#darkmode-ink-w3): high-traffic screens. Each case = (screen,
/// optional interaction reaching the converted UI, text proving it got there).
final _wave3 = <String, (Widget, Future<void> Function(WidgetTester)?, String?)>{
  'notifications': (const Scaffold(body: NotificationsScreen()), null, 'התראות'),
  // long-press → the row action menu (was #1E1E1E + const dark ink: ~1:1 in
  // BOTH themes — a live light-mode bug).
  'notifications_menu': (
    const Scaffold(body: NotificationsScreen()),
    (t) async {
      await t.longPress(find
          .byWidgetPredicate((w) => w.runtimeType.toString() == '_NotifRow')
          .first);
      await _settle(t);
    },
    'סמן כנקרא',
  ),
  // tab bodies — the app always mounts them under the shell's Scaffold.
  'chats': (const Scaffold(body: ChatsScreen()), null, null),
  'chats_archive': (const ChatsArchiveScreen(), null, 'אין שיחות בארכיון'),
  'profile': (const ProfileScreen(), null, null),
  'ai_assistant': (
    const AiAssistantScreen(),
    (t) async {
      await t.enterText(find.byType(TextField).first, 'מה המצב?');
      await t.testTextInput.receiveAction(TextInputAction.send);
      await _settle(t);
    },
    'תשובת-בדיקה של המודל',
  ),
  'ai_finder': (const AiFinderScreen(), null, null),
  'suppliers': (const SuppliersScreen(), null, null),
  'lipskey_brand': (const LipskeyBrandScreen(), null, null),
  'legal': (const LegalScreen(), null, null),
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // Real Heebo metrics — the default Ahem squares are ~2× wider and raise
  // phantom RenderFlex overflows that production never hits.
  setUpAll(() async {
    final loader = FontLoader('Heebo');
    for (final p in const [
      'assets/fonts/Heebo-Regular.ttf',
      'assets/fonts/Heebo-SemiBold.ttf',
      'assets/fonts/Heebo-Bold.ttf',
      'assets/fonts/Heebo-ExtraBold.ttf',
    ]) {
      loader.addFont(rootBundle.load(p));
    }
    await loader.load();
  });

  final lightOnly = <Color>{BsTokens.inkLight, BsTokens.mutedLight};

  for (final MapEntry(key: name, value: home) in _screens.entries) {
    testWidgets('$name — dark mode paints no light-only ink', (t) async {
      await _pump(t, home, dark: true);
      await _openSheetIfNeeded(t, name);
      final painted = _paintedTextColors(t);
      final offenders = <String>[];
      for (final e in find.byType(RichText).evaluate()) {
        final r = e.renderObject;
        if (r is! RenderParagraph) continue;
        void v(InlineSpan s) {
          if (lightOnly.contains(s.style?.color)) {
            offenders.add('"${r.text.toPlainText()}" <- ${e.debugGetCreatorChain(6)}');
          }
          if (s is TextSpan) s.children?.forEach(v);
        }
        v(r.text);
      }
      expect(painted.intersection(lightOnly), isEmpty,
          reason: '$name offenders:\n${offenders.join('\n')}\n'
              '$name still paints #1A1A1A/#6E655B text in dark mode');
      expect(painted, contains(BsTokens.inkDark),
          reason: '$name should paint the dark-theme ink');
      expect(_lowContrastInk(t), isEmpty,
          reason: '$name: ink text below WCAG AA 4.5:1 in dark mode');
    });

    testWidgets('$name — light mode keeps the ink + clears AA', (t) async {
      await _pump(t, home, dark: false);
      await _openSheetIfNeeded(t, name);
      expect(_paintedTextColors(t), contains(BsTokens.inkLight));
      expect(_lowContrastInk(t), isEmpty,
          reason: '$name: ink text below WCAG AA 4.5:1 in light mode');
    });
  }

  // The non-"off" rungs: a real reply (result text) and a failure (AiFailedState).
  for (final name in _aiScreens) {
    for (final fail in [false, true]) {
      for (final dark in [true, false]) {
        final mode = fail ? 'failed' : 'result';
        testWidgets('$name [$mode] ${dark ? 'dark' : 'light'} — ink clears AA',
            (t) async {
          await _pump(t, _screens[name]!,
              dark: dark,
              overrides: [
                claudeGatewayProvider.overrideWith((ref) => _FakeGateway(fail: fail)),
              ]);
          expect(
              find.text(fail ? 'משהו השתבש — נסה שוב.' : 'תשובת-בדיקה של המודל',
                  findRichText: true),
              findsWidgets,
              reason: '$name must actually reach the $mode rung');
          if (dark) {
            final painted = _paintedTextColors(t);
            expect(
                // dangerDark is NOT banned outright: the adapter "ends" chips pair
                // it with their own #FEE2E2 fill (legit). The WCAG check below
                // judges every danger text against its real backdrop instead.
                painted.intersection({BsTokens.inkLight, BsTokens.mutedLight}),
                isEmpty,
                reason: '$name [$mode] paints light-only ink in dark mode');
          }
          expect(_lowContrastInk(t), isEmpty,
              reason: '$name [$mode]: ink text below WCAG AA 4.5:1');
        });
      }
    }
  }

  for (final MapEntry(key: name, value: (home, tap)) in _wave2.entries) {
    for (final dark in [true, false]) {
      testWidgets('w2 $name ${dark ? 'dark' : 'light'} — ink clears AA',
          (t) async {
        await _pump(t, home,
            dark: dark,
            size: name.startsWith('studio')
                ? const Size(2800, 1800)
                : const Size(780, 1600),
            overrides: [
              claudeGatewayProvider
                  .overrideWith((ref) => _FakeGateway(fail: false)),
              ...?_extra[name],
            ]);
        if (_needsDraft.contains(name)) {
          _seedDraft(t);
          await t.pump();
        }
        if (tap != null) {
          await t.tap(find.textContaining(tap).first);
          for (var i = 0; i < 10; i++) {
            await t.pump(const Duration(milliseconds: 100));
          }
        }
        if (name == 'studio_find') {
          await t.enterText(find.widgetWithText(TextField, 'מצא טקסט'), 'הזמנה');
          for (var i = 0; i < 5; i++) {
            await t.pump(const Duration(milliseconds: 100));
          }
          // hit rows are the only Checkbox-bearing rows in the find pane.
          expect(find.byType(Checkbox), findsWidgets,
              reason: 'studio_find must render hit rows for the query');
        }
        final must = _mustSee[name];
        if (must != null) {
          expect(find.textContaining(must, findRichText: true), findsWidgets,
              reason: '$name must actually reach its target ("$must")');
        }
        final painted = _paintedTextColors(t);
        expect(
            painted.intersection({
              BsTokens.inkLight, BsTokens.mutedLight,
              BsTokens.inkDark, BsTokens.mutedDark,
            }),
            isNotEmpty,
            reason: '$name rendered no ink text at all — the check would be vacuous');
        expect(_lowContrastInk(t), isEmpty,
            reason: '$name: ink text below WCAG AA 4.5:1');
      });
    }
  }

  for (final MapEntry(key: name, value: (home, act, must)) in _wave3.entries) {
    for (final dark in [true, false]) {
      testWidgets('w3 $name ${dark ? 'dark' : 'light'} — ink clears AA',
          (t) async {
        await _pump(t, home, dark: dark, overrides: [
          claudeGatewayProvider
              .overrideWith((ref) => _FakeGateway(fail: false)),
        ]);
        await _settle(t, 3);
        if (act != null) await act(t);
        if (must != null) {
          expect(find.textContaining(must, findRichText: true), findsWidgets,
              reason: '$name must actually reach its target ("$must")');
        }
        expect(
            _paintedTextColors(t).intersection({
              BsTokens.inkLight, BsTokens.mutedLight,
              BsTokens.inkDark, BsTokens.mutedDark,
            }),
            isNotEmpty,
            reason: '$name rendered no ink text — the check would be vacuous');
        expect(_lowContrastInk(t), isEmpty,
            reason: '$name: ink text below WCAG AA 4.5:1');
      });
    }
  }
}
