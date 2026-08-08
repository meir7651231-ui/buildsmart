import 'package:buildsmart/features/fittings/engine/grid_adjacency.dart';
import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/grid_topology.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('grid topology — D12 §P4 free-end tracking', () {
    test('a lone coupler exposes both ends free', () {
      final ends = freeEndsOf(const [
        GridCell(0, 0, 0, RunElement(Family.coupler, 32)),
      ]);
      expect(ends.map((e) => e.step).toSet(),
          {GridStep.west, GridStep.east});
      expect(ends.every((e) => e.od == 32), isTrue);
    });

    test('two connected couplers leave only the two outer ends free', () {
      final ends = freeEndsOf(const [
        GridCell(0, 0, 0, RunElement(Family.coupler, 32)),
        GridCell(1, 0, 0, RunElement(Family.coupler, 32)),
      ]);
      // The touching ports (A-east, B-west) are consumed; outer west+east remain.
      expect(ends.length, 2);
      expect(ends.map((e) => (e.cell.x, e.step)).toSet(),
          {(0, GridStep.west), (1, GridStep.east)});
    });

    test('a lone tee exposes all three ends free', () {
      final ends = freeEndsOf(const [
        GridCell(0, 0, 0, RunElement(Family.tee, 50, dir: Dir.up)),
      ]);
      expect(ends.map((e) => e.step).toSet(),
          {GridStep.west, GridStep.east, GridStep.above});
    });

    test('a neighbour that does not mate (od mismatch) leaves the port free', () {
      // Adjacent but od 32 vs 50 → they do NOT connect → both facing ports free.
      final ends = freeEndsOf(const [
        GridCell(0, 0, 0, RunElement(Family.coupler, 32)),
        GridCell(1, 0, 0, RunElement(Family.coupler, 50)),
      ]);
      // 4 ports total, none consumed (no real connection).
      expect(ends.length, 4);
    });

    test('a plug caps one end — a coupler + plug leaves a single free end', () {
      // coupler at 0, plug at its east neighbour (plug port faces −X = west,
      // i.e. back toward the coupler) → they connect; the coupler west stays free.
      final ends = freeEndsOf(const [
        GridCell(0, 0, 0, RunElement(Family.coupler, 32)),
        GridCell(1, 0, 0, RunElement(Family.plug, 32)),
      ]);
      expect(ends.length, 1);
      expect(ends.single.step, GridStep.west);
      expect(ends.single.cell.x, 0);
    });
  });
}
