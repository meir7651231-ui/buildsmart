// 🔑 ProductLine3D — the static gallery drop-in: builds a CustomPaint for a route,
// renders nothing (safe SizedBox) for an empty/unrenderable route, no exception.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/render/product_line_3d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a CustomPaint for a real route, no gestures, no exception',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ProductLine3D(route: [
          RunElement(Family.coupler, 50),
          RunElement(Family.elbow90, 50, dir: Dir.up),
          RunElement(Family.tee, 50),
          RunElement(Family.plug, 50),
        ],),
      ),
    ),);
    expect(find.byType(CustomPaint), findsWidgets);
    // static — no gesture detector to fight the gallery's PageView/zoom
    expect(find.byType(GestureDetector), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty/unrenderable route → safe empty box, no crash', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ProductLine3D(route: [])),
    ),);
    expect(tester.takeException(), isNull);
  });
}
