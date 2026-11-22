// Top bar at the narrowest phone widths (320–360px): the logo + the
// registered user's name chip + up to four action icons (search · camera ·
// ⋮ · 💡) must fit WITHOUT a RenderFlex overflow. Found by the 21.11
// screen-reviewer pass: at 320px the title Row overflowed by ~68px.
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NOTE: flutter_test renders with a box-glyph test font (every glyph is
// fontSize wide), so 'BuildSmart' measures ~220px here vs ~125px in Heebo —
// the widths below are therefore stricter than a real phone, not looser.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<List<String>> pumpBar(
    WidgetTester t,
    double width, {
    required String name,
    required bool searchIcon,
    double scale = 1.0,
  }) async {
    await t.binding.setSurfaceSize(Size(width, 700));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: Builder(
          builder:
              (ctx) => MediaQuery(
                data: const MediaQueryData().copyWith(
                  size: Size(width, 700),
                  textScaler: TextScaler.linear(scale),
                ),
                child: const BuildSmartApp(),
              ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    c
        .read(userProfileProvider.notifier)
        .register(name: name, contact: '0501234567');
    if (searchIcon) c.read(tabHeaderHiddenProvider.notifier).state = true;
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    final errors = <String>[];
    for (Object? e = t.takeException(); e != null; e = t.takeException()) {
      errors.add(e.toString());
    }
    return errors;
  }

  for (final w in [320.0, 340.0, 360.0]) {
    testWidgets('top bar fits at ${w.toInt()}px — name chip + 4 icons', (
      t,
    ) async {
      final over = await pumpBar(t, w, name: 'אלכסנדרה כהן', searchIcon: true);
      expect(over, isEmpty, reason: over.join('\n'));
      expect(find.text('BuildSmart'), findsOneWidget);
    });
  }

  testWidgets('with room (600px) the name chip shows and the logo keeps 22px', (
    t,
  ) async {
    final over = await pumpBar(t, 600, name: 'אלכסנדרה כהן', searchIcon: true);
    expect(over, isEmpty, reason: over.join('\n'));
    expect(
      find.text('אלכסנדרה'),
      findsOneWidget,
      reason: 'the chip only steps aside when there is no room for it',
    );
    expect(
      t.getSize(find.text('BuildSmart')).height,
      greaterThanOrEqualTo(22),
      reason: 'logo keeps its natural 22px size',
    );
  });

  testWidgets('320px hides the chip rather than squeezing it to a sliver', (
    t,
  ) async {
    await pumpBar(t, 320, name: 'אלכסנדרה כהן', searchIcon: true);
    expect(find.text('אלכסנדרה'), findsNothing);
    expect(find.text('BuildSmart'), findsOneWidget);
  });

  testWidgets('large text (1.3×) at 360px does not overflow', (t) async {
    final over = await pumpBar(
      t,
      360,
      name: 'אלכסנדרה כהן',
      searchIcon: true,
      scale: 1.3,
    );
    expect(over, isEmpty, reason: over.join('\n'));
  });
}
