import 'package:buildsmart/features/fittings/engine/grid_adjacency.dart';
import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('grid cell connection — D12 §P3', () {
    test('stepTo is the lattice step for neighbours, null otherwise', () {
      const a = GridCell(0, 0, 0, RunElement(Family.coupler, 32));
      expect(a.stepTo(const GridCell(1, 0, 0, RunElement(Family.coupler, 32))),
          GridStep.east);
      expect(a.stepTo(const GridCell(0, 0, 1, RunElement(Family.coupler, 32))),
          GridStep.above);
      // gap (distance 2) and diagonal are not unit neighbours.
      expect(a.stepTo(const GridCell(2, 0, 0, RunElement(Family.coupler, 32))),
          isNull);
      expect(a.stepTo(const GridCell(1, 1, 0, RunElement(Family.coupler, 32))),
          isNull);
    });

    test('two couplers in a row connect when od matches', () {
      const a = GridCell(0, 0, 0, RunElement(Family.coupler, 32));
      const b = GridCell(1, 0, 0, RunElement(Family.coupler, 32));
      expect(cellsConnect(a, b), isTrue);
      expect(cellsConnect(b, a), isTrue); // symmetric
    });

    test('od mismatch does not connect', () {
      const a = GridCell(0, 0, 0, RunElement(Family.coupler, 32));
      const b = GridCell(1, 0, 0, RunElement(Family.coupler, 50));
      expect(cellsConnect(a, b), isFalse);
    });

    test('non-neighbours (gap / diagonal) do not connect', () {
      const a = GridCell(0, 0, 0, RunElement(Family.coupler, 32));
      expect(
        cellsConnect(a, const GridCell(2, 0, 0, RunElement(Family.coupler, 32))),
        isFalse,
      );
      expect(
        cellsConnect(a, const GridCell(1, 1, 0, RunElement(Family.coupler, 32))),
        isFalse,
      );
    });

    test('tee east port connects a coupler on its east neighbour', () {
      const tee = GridCell(0, 0, 0, RunElement(Family.tee, 50, dir: Dir.up));
      const coupler = GridCell(1, 0, 0, RunElement(Family.coupler, 50));
      expect(cellsConnect(tee, coupler), isTrue);
    });

    test('a horizontal coupler cannot meet the tee vertical branch', () {
      // tee(up) has an ABOVE port; a default coupler (±X only) placed above has
      // no downward port → no connection (orientation matters).
      const tee = GridCell(0, 0, 0, RunElement(Family.tee, 50, dir: Dir.up));
      const coupler = GridCell(0, 0, 1, RunElement(Family.coupler, 50));
      expect(cellsConnect(tee, coupler), isFalse);
    });
  });
}
