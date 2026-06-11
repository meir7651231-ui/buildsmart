import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/profession_screen.dart';
import 'package:buildsmart/screens/smart_home_screen.dart';
import 'package:buildsmart/state/home_content_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wave-1 placeholder HIDE guard. Non-live departments and the בקרוב trades are
/// kept in the data (reversible) but must NOT render. These pump the REAL
/// widgets and assert the hidden items are absent and the live ones present, so
/// dropping the `.where((d) => d.live)` / coming-soon filters fails CI.
Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        // The screens supply their own Directionality(rtl); a bare MaterialApp
        // host is enough (matches the existing widget-test harness).
        home: child,
      ),
    );

void main() {
  group('departments grid hides the non-live placeholders', () {
    testWidgets('renders, hides גבס ופרופילים + חשמל, keeps אינסטלציה',
        (t) async {
      await t.pumpWidget(_wrap(const DepartmentsScreen()));
      await t.pumpAndSettle();

      // The grid actually rendered (the header is always there).
      expect(find.text('מחלקות'), findsOneWidget);

      // Non-live placeholders are gone (data kept, render filtered).
      expect(find.text('גבס ופרופילים'), findsNothing);
      expect(find.text('חשמל'), findsNothing);
      // And there is no "בקרוב" badge anymore — every tile shown is live.
      expect(find.text('בקרוב'), findsNothing);

      // The first live department still shows.
      expect(find.text('אינסטלציה'), findsOneWidget);
      // A second live one too (sanity that we didn't hide everything).
      expect(find.text('ברזים וסניטריים'), findsOneWidget);
    });
  });

  group('profession picker hides the בקרוב trades', () {
    testWidgets('hides חשמלאי + קבלן שיפוצים, keeps אינסטלטור', (t) async {
      await t.pumpWidget(_wrap(const ProfessionScreen()));
      await t.pumpAndSettle();

      // The picker rendered.
      expect(find.text('מה התחום שלך?'), findsOneWidget);

      // Coming-soon trades are filtered out of the picker.
      expect(find.text('חשמלאי'), findsNothing);
      expect(find.text('קבלן שיפוצים'), findsNothing);

      // The one fully-built trade is still offered.
      expect(find.text('אינסטלטור'), findsOneWidget);
    });
  });

  group('smart-home departments strip hides the placeholders', () {
    testWidgets('the מחלקות strip does not show חשמל', (t) async {
      // _Departments is private; reach it through the public section builder.
      await t.pumpWidget(
        _wrap(
          // _MiniTile uses InkWell → needs a Material ancestor (Scaffold gives
          // one); the strip content is unchanged.
          Scaffold(
            body: ListView(
              children: [smartHomeSectionFor(HomeSection.categories)],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();

      // The strip rendered (its title) and the non-live dept is absent. The
      // strip is .take(3) of the live depts, so the live ones it shows are the
      // first three (אינסטלציה …); חשמל is non-live → never in it.
      expect(find.text('מחלקות'), findsOneWidget);
      expect(find.text('חשמל'), findsNothing);
      expect(find.text('אינסטלציה'), findsOneWidget);
    });
  });
}
