// Pins Pane C (#studio · Pillar 1 · step 24b — the theme editor): preset swatches
// stage the brand into the DRAFT (live via configThemeProvider; publish enabled);
// the WCAG contrast warning shows for a sub-AA brand and clears for a high-contrast
// one; both sliders render. Fake sink, no auth — the pane is a pure draft editor.
import 'package:buildsmart/screens/studio/panes/theme_pane.dart';
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/theme/config_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSink implements ConfigSink {
  @override
  Future<void> save(ConfigDoc doc) async {}
  @override
  Future<ConfigDoc?> load() async => null;
  @override
  Stream<ConfigDoc>? watch() => null;
}

const _charcoal = Color(0xFF334155); // high contrast vs white (no warning)

void main() {
  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<ProviderContainer> pump(WidgetTester tester) async {
    final c = make();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: ThemePane()),
          ),
        ),
      ),
    );
    return c;
  }

  testWidgets('renders two sliders + the preset swatches', (tester) async {
    await pump(tester);
    expect(find.byType(Slider), findsNWidgets(2)); // radius + fontScale
    expect(find.byKey(const ValueKey(BsTokens.brand)), findsOneWidget);
    expect(find.byKey(const ValueKey(_charcoal)), findsOneWidget);
  });

  testWidgets('tapping a swatch stages it into the draft (live, publishable)', (
    tester,
  ) async {
    final c = await pump(tester);
    await tester.tap(find.byKey(const ValueKey(_charcoal)));
    await tester.pump();
    expect(c.read(configThemeProvider).brand, _charcoal); // live
    expect(c.read(configStoreProvider).draftNodeCount, greaterThan(0)); // publish
  });

  testWidgets('contrast warning shows for sub-AA brand, clears for high-contrast', (
    tester,
  ) async {
    final c = await pump(tester);
    // The default brand (orange) is sub-AA vs white ⇒ the warning is shown.
    expect(find.byKey(const Key('studio-contrast-warning')), findsOneWidget);
    // Charcoal clears AA ⇒ warning gone.
    await tester.tap(find.byKey(const ValueKey(_charcoal)));
    await tester.pump();
    expect(find.byKey(const Key('studio-contrast-warning')), findsNothing);
    expect(c.read(configThemeProvider).brand, _charcoal);
  });

  testWidgets('reset stages the inert fallback', (tester) async {
    final c = await pump(tester);
    // Make it dirty first.
    c.read(configStoreProvider.notifier).setThemeDraft(
          const CfgTheme(brand: Color(0xFF112233)),
        );
    await tester.pump();
    expect(c.read(configThemeProvider).brand, const Color(0xFF112233));
    await tester.tap(find.text('אפס עיצוב לברירת-המחדל'));
    await tester.pump();
    expect(c.read(configThemeProvider).brand, BsTokens.brand);
  });
}
