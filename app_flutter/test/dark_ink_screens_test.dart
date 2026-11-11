// Dark-mode legibility guard for the screens whose SURFACES went theme-aware in
// dark-mode waves 15–16 but whose TEXT stayed hardcoded BsTokens.inkLight /
// mutedLight — #1A1A1A on bgDark #141009 (~1.1:1, invisible). Fixed in wave 17
// (bsInk/bsMuted). For every painted Text we find the nearest painted
// background up the tree and assert, in BOTH themes:
//   A) contrast ≥ 2.0 — catches "invisible" both ways (dark-on-dark AND the
//      light-on-light a careless fix would create on hardcoded white cards);
//   B) in dark theme, no light-theme ink literal sits on a dark background.
import 'package:buildsmart/screens/adapter_explain_screen.dart';
import 'package:buildsmart/screens/alt_explain_screen.dart';
import 'package:buildsmart/screens/coming_soon_screen.dart';
import 'package:buildsmart/screens/credit_explain_screen.dart';
import 'package:buildsmart/screens/daily_report_screen.dart';
import 'package:buildsmart/screens/paired_explain_screen.dart';
import 'package:buildsmart/screens/quote_polish_screen.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Nearest opaque painted fill above [e] — ColoredBox, DecoratedBox, Material
/// (via PhysicalShape/PhysicalModel), or the Scaffold background.
Color? _bgOf(Element e) {
  Color? found;
  e.visitAncestorElements((a) {
    final w = a.widget;
    Color? c;
    if (w is ColoredBox) c = w.color;
    if (w is DecoratedBox && w.decoration is BoxDecoration) {
      c = (w.decoration as BoxDecoration).color;
    }
    if (w is PhysicalShape) c = w.color;
    if (w is PhysicalModel) c = w.color;
    if (c != null && c.a > 0.9) {
      found = c;
      return false;
    }
    return true;
  });
  return found;
}

Iterable<Color> _colorsOf(InlineSpan s) sync* {
  final c = s.style?.color;
  if (c != null) yield c;
  if (s is TextSpan) {
    for (final child in s.children ?? const <InlineSpan>[]) {
      yield* _colorsOf(child);
    }
  }
}

final _screens = <String, Widget Function()>{
  'coming_soon': () => const ComingSoonScreen(profession: 'חשמלאי'),
  'alt_explain': () => const AltExplainScreen(
      product: 'דוד שמש', recName: 'כרומגן', recPrice: 1800,
      altName: 'אמקור', altPrice: 1500),
  'adapter_explain': () =>
      const AdapterExplainScreen(productName: 'מתאם', sku: 'A-1'),
  'paired_explain': () =>
      const PairedExplainScreen(product: 'ברז', types: ['צינור', 'מחבר']),
  'credit_explain': () => const CreditExplainScreen(
      name: 'לקוח', creditLimit: 10000, used: 4000, balance: 6000, pct: 40),
  'quote_polish': () =>
      const QuotePolishScreen(rawQuote: 'הצעה', productName: 'ברז'),
  'daily_report': () =>
      const DailyReportScreen(title: 'דוח', reportLines: ['שורה']),
};

void main() {
  for (final entry in _screens.entries) {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('${entry.key} · $mode · every text is legible', (t) async {
        t.view.physicalSize = const Size(1080, 2400);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(ProviderScope(
          child: MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            home: entry.value(),
          ),
        ));
        await t.pump(const Duration(milliseconds: 300));

        final problems = <String>[];
        var checked = 0;
        for (final el in find.byType(RichText).evaluate()) {
          final rt = el.widget as RichText;
          final bg = _bgOf(el);
          if (bg == null) continue;
          for (final fg in _colorsOf(rt.text)) {
            if (fg.a < 0.5) continue;
            checked++;
            final txt = rt.text.toPlainText();
            final cr = _contrast(fg, bg);
            if (cr < 2.0) {
              problems.add('"$txt" ${cr.toStringAsFixed(2)}:1 '
                  'fg=${fg.toARGB32().toRadixString(16)} '
                  'bg=${bg.toARGB32().toRadixString(16)}');
            }
            if (dark &&
                bg.computeLuminance() < 0.05 &&
                (fg == BsTokens.inkLight || fg == BsTokens.mutedLight)) {
              problems.add('"$txt" light-theme ink on dark bg');
            }
          }
        }
        expect(checked, greaterThan(0), reason: 'the walk found text');
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  }
}
