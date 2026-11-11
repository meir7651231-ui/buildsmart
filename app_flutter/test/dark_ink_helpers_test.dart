// Guards bsInk/bsMuted (lib/theme/app_theme.dart) — the theme-aware text inks
// that replaced hardcoded BsTokens.inkLight/mutedLight on screens whose
// SURFACES were already theme-aware (dark-mode waves 15–16). Before this,
// dark theme painted #1A1A1A text on #141009 (~1.1:1 — invisible).
//
// Invariants:
//   light → inkLight / mutedLight   (byte-identical to the old literals)
//   dark  → inkDark  / mutedDark    (WCAG AA on bgDark AND cardDark)
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Future<(Color, Color)> _resolve(WidgetTester t, ThemeData theme) async {
  late Color ink, muted;
  await t.pumpWidget(MaterialApp(
    theme: theme,
    home: Builder(builder: (c) {
      ink = bsInk(c);
      muted = bsMuted(c);
      return const SizedBox();
    }),
  ));
  return (ink, muted);
}

void main() {
  testWidgets('light theme keeps the exact legacy literals', (t) async {
    final (ink, muted) = await _resolve(t, AppTheme.light());
    expect(ink, BsTokens.inkLight);
    expect(muted, BsTokens.mutedLight);
  });

  testWidgets('dark theme switches to the dark inks', (t) async {
    final (ink, muted) = await _resolve(t, AppTheme.dark());
    expect(ink, BsTokens.inkDark);
    expect(muted, BsTokens.mutedDark);
  });

  testWidgets('dark inks pass WCAG AA on both dark surfaces', (t) async {
    final dark = AppTheme.dark();
    final (ink, muted) = await _resolve(t, dark);
    for (final bg in [dark.scaffoldBackgroundColor, dark.colorScheme.surface]) {
      expect(_contrast(ink, bg), greaterThanOrEqualTo(4.5));
      expect(_contrast(muted, bg), greaterThanOrEqualTo(4.5));
    }
    // and the bug this replaces really was unreadable:
    expect(_contrast(BsTokens.inkLight, dark.scaffoldBackgroundColor),
        lessThan(1.5));
  });
}
