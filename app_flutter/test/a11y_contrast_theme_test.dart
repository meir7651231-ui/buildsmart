// Guards the high-contrast semantic-color mapping (lib/theme/app_theme.dart).
// The app's existing "ניגודיות גבוהה" (highContrast) toggle could not reach
// widget-level color literals (white-on-orange FABs/chips, #22C55E price/online
// text). BsSemanticColors carries those two foregrounds so HC darkens them to
// WCAG AA, while NORMAL mode stays byte-identical to the brand palette.
//
// Invariant under test:
//   normal  → onAccent = white   , success = #22C55E  (default look unchanged)
//   HC      → onAccent = #1A1A1A , success = #15803D  (passes WCAG AA)
import 'package:buildsmart/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BsSemanticColors — high-contrast mapping', () {
    test('normal mode keeps the brand palette (default look unchanged)', () {
      final ext =
          AppTheme.light(highContrast: false).extension<BsSemanticColors>()!;
      expect(ext.onAccent, const Color(0xFFFFFFFF), reason: 'white on accent');
      expect(ext.success, const Color(0xFF22C55E), reason: 'brand green');
    });

    test('high-contrast darkens the unreachable foregrounds to AA', () {
      final ext =
          AppTheme.light(highContrast: true).extension<BsSemanticColors>()!;
      // #1A1A1A on #FF7A18 ≈ 6.7:1 ; #15803D on white ≈ 5.0:1 — both pass AA.
      expect(ext.onAccent, const Color(0xFF1A1A1A));
      expect(ext.success, const Color(0xFF15803D));
    });

    test('dark theme also carries the extension', () {
      expect(AppTheme.dark(highContrast: true).extension<BsSemanticColors>(),
          isNotNull);
    });

    testWidgets('bsOnAccent/bsSuccess resolve dark/AA-green under high-contrast',
        (tester) async {
      late Color a, s;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(highContrast: true),
        home: Builder(builder: (c) {
          a = bsOnAccent(c);
          s = bsSuccess(c);
          return const SizedBox();
        }),
      ));
      expect(a, const Color(0xFF1A1A1A));
      expect(s, const Color(0xFF15803D));
    });

    testWidgets('bsOnAccent/bsSuccess resolve white/brand-green in normal mode',
        (tester) async {
      late Color a, s;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(highContrast: false),
        home: Builder(builder: (c) {
          a = bsOnAccent(c);
          s = bsSuccess(c);
          return const SizedBox();
        }),
      ));
      expect(a, const Color(0xFFFFFFFF));
      expect(s, const Color(0xFF22C55E));
    });
  });
}
