// 🎛️ קטלוג מגדיר — the catalog-config dive screen as a HOME section, mirroring
// `superFinder`. The section is registered in BOTH the [HomeSection] enum AND the
// [kDefaultHomeOrder] (with its [kHomeSectionMeta]), so the home reorder/preview UI
// carries it like any other section. The LIVE OPEN box is gated on the const
// `kCatalogConfig` (OFF in a normal test run ⇒ the section tree-shakes ⇒ the home is
// byte-identical); these guards pin the registration + the reorder-preview hero.
import 'package:buildsmart/screens/smart_home_screen.dart'
    show smartHomeSectionFor;
import 'package:buildsmart/state/home_content_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bare MaterialApp host — the section widgets supply their own colours/InkWell and
/// need a Material ancestor; a Scaffold gives one (matches the placeholder-hide
/// harness).
Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: ListView(children: [child])),
      ),
    );

void main() {
  group('home catalog-config section registration', () {
    test('catalogConfig is a default home section with 🎛️ meta', () {
      // Registered in the default order (so it reorders/previews like any section)…
      expect(kDefaultHomeOrder, contains(HomeSection.catalogConfig));
      // …and it sits right after superFinder (the pattern it mirrors).
      expect(
        kDefaultHomeOrder.indexOf(HomeSection.catalogConfig),
        kDefaultHomeOrder.indexOf(HomeSection.superFinder) + 1,
      );
      // …with display metadata (emoji + title) so the reorder rows can label it.
      final meta = kHomeSectionMeta[HomeSection.catalogConfig];
      expect(meta, isNotNull);
      expect(meta!.emoji, '🎛️');
      expect(meta.title, 'קטלוג מגדיר');
    });
  });

  group('home catalog-config section renders', () {
    testWidgets('smartHomeSectionFor(catalogConfig) renders the hero token',
        (t) async {
      // The section builder must return a real, renderable widget (the compact
      // reorder-preview hero) without throwing — kCatalogConfig OFF or ON.
      expect(() => smartHomeSectionFor(HomeSection.catalogConfig),
          returnsNormally);
      await t.pumpWidget(
        _wrap(smartHomeSectionFor(HomeSection.catalogConfig)),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      // The hero labels the section (🎛️ קטלוג מגדיר) — proof it actually rendered.
      expect(find.text('🎛️ קטלוג מגדיר'), findsOneWidget);
    });
  });
}
