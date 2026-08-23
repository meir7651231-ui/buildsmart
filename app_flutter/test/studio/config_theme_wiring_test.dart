// Pins the config→theme wiring (#studio · Pillar 1 · step 24a): empty doc ⇒ the
// inert fallback (zero-regression); setThemeDraft ⇒ configThemeProvider reflects it
// live; a theme-only draft is publishable + promotes; and AppTheme reflects cfg.brand
// in the colorScheme. Fake sink, no auth.
import 'package:buildsmart/state/studio/config_doc.dart';
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
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

void main() {
  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [configSinkProvider.overrideWithValue(_FakeSink())],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('empty doc ⇒ configTheme is the inert fallback', () {
    final t = make().read(configThemeProvider);
    expect(t.brand, BsTokens.brand);
    expect(t.radius, BsTokens.radiusCard);
  });

  test('setThemeDraft ⇒ configTheme reflects the override (live)', () {
    final c = make();
    c.read(configStoreProvider.notifier).setThemeDraft(
          const CfgTheme(brand: Color(0xFF112233), radius: 4),
        );
    final t = c.read(configThemeProvider);
    expect(t.brand, const Color(0xFF112233));
    expect(t.radius, 4);
  });

  test('a theme-only draft is publishable and promotes', () {
    final c = make();
    final n = c.read(configStoreProvider.notifier)
      ..setThemeDraft(const CfgTheme(brand: Color(0xFF112233)));
    expect(n.state.draftNodeCount, greaterThan(0)); // publish enabled
    n.publish(nowMs: 1);
    expect(n.state.draft.isEmpty, isTrue); // promoted + cleared
    expect(c.read(configThemeProvider).brand, const Color(0xFF112233)); // live
  });

  test('AppTheme reflects cfg.brand in the colorScheme (default = BsTokens)', () {
    expect(
      AppTheme.light(cfg: const CfgTheme(brand: Color(0xFF112233)))
          .colorScheme
          .primary,
      const Color(0xFF112233),
    );
    expect(AppTheme.light().colorScheme.primary, BsTokens.brand); // zero-reg
  });
}
