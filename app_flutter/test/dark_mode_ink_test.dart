// Guards the dark-mode TEXT regression (#darkmode-ink): dark-mode waves 1–16 made
// the SURFACES theme-aware (bgLight→scaffoldBackgroundColor, cardLight→surface)
// but left the text on const `BsTokens.inkLight` (#1A1A1A) / `mutedLight`. In dark
// mode that is near-black ink on `cardDark` (#1F1A13) — ~1:1 contrast, the title
// literally disappears. Fixed screens read ink via `bsInk(context)` /
// `bsMuted(context)` (lib/theme/app_theme.dart) — light mode byte-identical.
//
// This pumps each fixed screen under the DARK theme and asserts no rendered text
// still carries the light-only ink, and that light mode still does (no drift).
import 'package:buildsmart/screens/adapter_explain_screen.dart';
import 'package:buildsmart/screens/alt_explain_screen.dart';
import 'package:buildsmart/screens/business_summary_screen.dart';
import 'package:buildsmart/screens/coming_soon_screen.dart';
import 'package:buildsmart/screens/credit_explain_screen.dart';
import 'package:buildsmart/screens/daily_report_screen.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart';
import 'package:buildsmart/screens/paired_explain_screen.dart';
import 'package:buildsmart/screens/quote_polish_screen.dart';
import 'package:buildsmart/screens/reject_reason_screen.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Every ink-family text (the class this regression is about) must clear WCAG AA.
List<String> _lowContrastInk(WidgetTester t) {
  final ink = <Color>{
    BsTokens.inkLight, BsTokens.mutedLight, BsTokens.inkDark, BsTokens.mutedDark,
  };
  final bad = <String>[];
  for (final e in find.byType(RichText).evaluate()) {
    final r = e.renderObject;
    if (r is! RenderParagraph) continue;
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

Future<void> _pump(WidgetTester t, Widget home, {required bool dark}) async {
  t.view.physicalSize = const Size(780, 1600);
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
  await t.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: home,
    ),
  ));
  await t.pump(const Duration(milliseconds: 100));
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
      const AdapterExplainScreen(productName: 'מתאם', sku: '123'),
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

void main() {
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
}
