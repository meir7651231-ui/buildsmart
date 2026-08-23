// Regression guard: pool-level length dedup must not collapse mm tokens.
//
// `dedupLengthByMm` collapses equivalent LENGTH representations to one chip
// (cm vs meters — P11: `15 ס"מ` ≡ `0.15 מ׳`). It used to include the `mm`
// family too, which is wrong: an `mm` token is almost always a DIAMETER
// (`250 מ"מ` shower head) or a cross-dim OD (`16×20`). Collapsing by raw mm
// value merged `250 מ"מ` into `25 ס"מ` and `16×20` into `16×16` — and since
// the per-product filter matches by exact label, every product carrying the
// collapsed-away label became UNREACHABLE by the surviving chip (328 products
// catalog-wide). These guards lock mm out of the length dedup while keeping
// the cm/meters collapse.
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _labels(List<SizeToken> t) {
  final out = dedupLengthByMm(t);
  return out.map((x) => x.label).toList()..sort();
}

void main() {
  group('dedupLengthByMm keeps mm tokens (reachability)', () {
    test('250 מ"מ (diameter) is NOT merged into 25 ס"מ', () {
      final out = _labels([
        const SizeToken(label: '250 מ"מ', family: SizeFamily.mm, mm: 250),
        const SizeToken(label: '25 ס"מ', family: SizeFamily.cm, mm: 250),
      ]);
      expect(out, containsAll(['250 מ"מ', '25 ס"מ']));
    });

    test('16×20 and 16×16 (same OD, different wall) both survive', () {
      final out = _labels([
        const SizeToken(label: '16×20', family: SizeFamily.mm, mm: 16),
        const SizeToken(label: '16×16', family: SizeFamily.mm, mm: 16),
      ]);
      expect(out, containsAll(['16×16', '16×20']));
    });

    test('200 מ"מ and 20 ס"מ both survive (mm not a length)', () {
      final out = _labels([
        const SizeToken(label: '200 מ"מ', family: SizeFamily.mm, mm: 200),
        const SizeToken(label: '20 ס"מ', family: SizeFamily.cm, mm: 200),
      ]);
      expect(out, containsAll(['200 מ"מ', '20 ס"מ']));
    });

    test('P11 still holds: 15 ס"מ ≡ 0.15 מ׳ collapse to the cm form', () {
      final out = _labels([
        const SizeToken(label: '15 ס"מ', family: SizeFamily.cm, mm: 150),
        const SizeToken(label: '0.15 מ׳', family: SizeFamily.meters, mm: 150),
      ]);
      expect(out, ['15 ס"מ']);
    });
  });
}
