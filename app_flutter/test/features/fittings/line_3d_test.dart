import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/ui/line_3d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Line3DView paints an isometric cube line without error',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Line3DView(
            cells: [
              GridCell(0, 0, 0, RunElement(Family.coupler, 50)),
              GridCell(1, 0, 0, RunElement(Family.elbow90, 50)),
              GridCell(1, 0, 1, RunElement(Family.tee, 50, dir: Dir.up)),
              GridCell(1, 1, 1, RunElement(Family.plug, 50)),
            ],
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('line3d')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Line3DView handles an empty line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Line3DView(cells: []))),
    );
    expect(find.byKey(const Key('line3d')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
