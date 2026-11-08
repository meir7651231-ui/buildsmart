import 'package:buildsmart/features/maintenance/mx_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every house glyph parses into a non-empty path inside the grid', () {
    const all = [
      MxGlyphs.board,
      MxGlyphs.sites,
      MxGlyphs.wrench,
      MxGlyphs.calendarCheck,
      MxGlyphs.cart,
      MxGlyphs.megaphone,
      MxGlyphs.list,
      MxGlyphs.store,
      MxGlyphs.kitchen,
      MxGlyphs.bath,
      MxGlyphs.bed,
      MxGlyphs.sofa,
      MxGlyphs.laundry,
      MxGlyphs.door,
      MxGlyphs.shelter,
      MxGlyphs.outlet,
      MxGlyphs.lightSwitch,
      MxGlyphs.bulb,
      MxGlyphs.faucet,
      MxGlyphs.drain,
      MxGlyphs.toilet,
      MxGlyphs.shower,
      MxGlyphs.thermo,
      MxGlyphs.grabBar,
      MxGlyphs.fan,
      MxGlyphs.ac,
      MxGlyphs.window,
      MxGlyphs.shutter,
      MxGlyphs.mezuzah,
      MxGlyphs.boiler,
      MxGlyphs.clock,
      MxGlyphs.breaker,
      MxGlyphs.exitSensor,
      MxGlyphs.smoke,
      MxGlyphs.extinguisher,
      MxGlyphs.lock,
      MxGlyphs.warning,
      MxGlyphs.phone,
      MxGlyphs.truck,
      MxGlyphs.check,
      MxGlyphs.legal,
      MxGlyphs.box,
      MxGlyphs.receipt,
    ];
    for (final g in all) {
      final b = mxParsePath(g.d).getBounds();
      expect(b.isEmpty && b.width == 0 && b.height == 0, isFalse, reason: g.d);
      expect(
        const Rect.fromLTRB(-0.5, -0.5, 24.5, 24.5).contains(b.topLeft) &&
            const Rect.fromLTRB(-0.5, -0.5, 24.5, 24.5).contains(b.bottomRight),
        isTrue,
        reason: '${g.d} → $b',
      );
    }
  });

  test('relative commands, implicit lineto and arcs', () {
    final b = mxParsePath('M2 2h4v4h-4z M10 10a2 2 0 1 0 4 0').getBounds();
    expect(b.left, 2);
    expect(b.top, 2);
    expect(b.right, closeTo(14, 0.01));
  });

  testWidgets('MxIcon renders at 20 and 24', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            MxIcon(MxGlyphs.outlet, size: 20),
            MxIcon(MxGlyphs.warning),
          ],
        ),
      ),
    );
    expect(find.byType(MxIcon), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
