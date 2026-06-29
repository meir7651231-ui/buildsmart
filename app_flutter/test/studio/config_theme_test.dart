// Pins CfgTheme (#studio · Pillar 1 · step 23): the DEFAULTS equal the current
// BsTokens (so with no override the app is byte-identical — zero regression), the
// ThemeExtension contract (copyWith/lerp) holds, and the live AppTheme exposes it.
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults equal the current BsTokens (zero-regression)', () {
    const t = CfgTheme.fallback;
    expect(t.brand, BsTokens.brand);
    expect(t.surface, BsTokens.cardLight);
    expect(t.ink, BsTokens.inkLight);
    expect(t.radius, BsTokens.radiusCard);
    expect(t.fontScale, 1.0);
  });

  test('copyWith changes one field, keeps the rest', () {
    final t = CfgTheme.fallback.copyWith(brand: const Color(0xFF000000));
    expect(t.brand, const Color(0xFF000000));
    expect(t.surface, BsTokens.cardLight); // preserved
  });

  test('lerp interpolates (ThemeExtension contract)', () {
    const a = CfgTheme(radius: 0);
    const b = CfgTheme(radius: 10, fontScale: 2);
    final mid = a.lerp(b, 0.5);
    expect(mid.radius, 5);
    expect(mid.fontScale, 1.5);
  });

  testWidgets('the live AppTheme exposes CfgTheme with default values', (
    tester,
  ) async {
    CfgTheme? ext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            ext = Theme.of(context).extension<CfgTheme>();
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ext, isNotNull);
    expect(ext!.brand, BsTokens.brand); // defaults ⇒ identical look
  });

  test('toJson/fromJson round-trips; garbage ⇒ defaults (never throws)', () {
    const t = CfgTheme(brand: Color(0xFF010203), radius: 8, fontScale: 1.3);
    final back = CfgTheme.fromJson(t.toJson());
    expect(back.brand, const Color(0xFF010203));
    expect(back.radius, 8);
    expect(back.fontScale, 1.3);
    final bad = CfgTheme.fromJson(const {'brand': 'nope', 'radius': 'x'});
    expect(bad.brand, BsTokens.brand);
    expect(bad.radius, BsTokens.radiusCard);
  });

  testWidgets('cfgBrand falls back to BsTokens when the extension is absent', (
    tester,
  ) async {
    late Color c;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            c = cfgBrand(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(c, BsTokens.brand);
  });
}
