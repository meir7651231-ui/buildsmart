import 'package:buildsmart/features/fittings/ui/sudoku_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host() =>
      const MaterialApp(home: Scaffold(body: Center(child: SudokuGrid())));

  testWidgets('tapping an empty neighbour shows engine-filtered suggestions',
      (tester) async {
    await tester.pumpWidget(host());
    // Centre (1,1) is seeded with a coupler; tap its east neighbour (1,2).
    await tester.tap(find.byKey(const Key('cell_1_2')));
    await tester.pump();

    expect(find.byKey(const Key('suggestHeader')), findsOneWidget);
    // At least one round mate-chip is offered (OD label shown beneath it).
    expect(find.byKey(const Key('suggest_0')), findsOneWidget);
    expect(find.textContaining('50'), findsWidgets);
  });

  testWidgets('a far cell with no placed neighbour offers nothing',
      (tester) async {
    await tester.pumpWidget(host());
    // (0,0) is diagonal to the centre — not a lattice neighbour.
    await tester.tap(find.byKey(const Key('cell_0_0')));
    await tester.pump();
    expect(find.textContaining('אין אביזר שמתחבר'), findsOneWidget);
  });

  testWidgets('placing a suggestion fills the cell', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.byKey(const Key('cell_1_2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('suggest_0')));
    await tester.pump();

    // The empty-cell tap target is gone (now placed) and suggestions cleared.
    expect(find.byKey(const Key('cell_1_2')), findsNothing);
    expect(find.byKey(const Key('suggestHeader')), findsNothing);
  });

  testWidgets('check button reports free ends via the engine', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.byKey(const Key('gridBtnCheck')));
    await tester.pump();
    // A lone coupler has 2 free ends.
    expect(find.textContaining('2 קצוות פנויים'), findsOneWidget);
  });
}
