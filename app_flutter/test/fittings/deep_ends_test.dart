// 🔑🛡️ Phase B (27+29) — precise ends + cross-material adapter mating, with the
// M2 non-leak proven to zero tolerance (one over-match = a leak).
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/features/fittings/plan/deep_ends.dart';
import 'package:flutter_test/flutter_test.dart';

// A metal (brass) fitting with a BSP-female 1/2" thread — the counterpart a
// PP-R threaded adapter is meant to join.
VerifiedSpec _brassBspFemale(String inch) => VerifiedSpec(
      sku: 'BRASS-$inch',
      material: 'פליז',
      ends: [ConnectorEnd(EndType.bspFemale, inch)],
    );

// A PP-R welded coupler (socket) of a given DN.
VerifiedSpec _pprCoupler(int dn) => VerifiedSpec(
      sku: 'PPR-C-$dn',
      material: kPprMaterial,
      ends: [ConnectorEnd(EndType.hdpeCompression, '$dn'), ConnectorEnd(EndType.hdpeCompression, '$dn')],
    );

// An HDPE-supply fitting of a given DN (same push-fit socket type, other material).
VerifiedSpec _hdpeSupply(int dn) => VerifiedSpec(
      sku: 'HDPE-$dn',
      material: 'HDPE',
      ends: [ConnectorEnd(EndType.hdpeCompression, '$dn')],
    );

void main() {
  group('step 27 — precise end types', () {
    test('welded families → the right socket count', () {
      expect(weldEndsFor('מצמד', 32)!.length, 2);
      expect(weldEndsFor('מסעף (טי)', 50)!.length, 3);
      expect(weldEndsFor('פקק', 40)!.length, 1);
      expect(weldEndsFor('רוכב', 63)!.length, 3);
      expect(weldEndsFor('לא-משפחה', 32), isNull);
      for (final e in weldEndsFor('מצמד', 32)!) {
        expect(e.type, EndType.hdpeCompression); // socket-weld overload
      }
    });

    test('adapter → socket + BSP thread; no thread data → socket-only (honest-absent)', () {
      final m = ppRThreadAdapterEnds(20, threadInch: '1/2"', male: true);
      expect(m.map((e) => e.type), [EndType.hdpeCompression, EndType.bspMale]);
      final f = ppRThreadAdapterEnds(25, threadInch: '3/4"', male: false);
      expect(f[1].type, EndType.bspFemale);
      expect(f[1].size, '3/4"');
      expect(ppRThreadAdapterEnds(20).length, 1); // no thread info → socket only
    });
  });

  group('🔑 step 29 — a PP-R adapter connects across materials', () {
    final adapter =
        ppRThreadAdapterSpec(sku: 'PPR-ADP-20', socketDn: 20, threadInch: '1/2"', male: true);

    test('thread side joins BRASS (material-independent BSP joint)', () {
      expect(adapter.compatibleWith(_brassBspFemale('1/2"')), isTrue,
          reason: 'PP-R male 1/2" must screw into brass female 1/2"',);
    });

    test('socket side joins another PP-R fitting (same-material weld)', () {
      expect(adapter.compatibleWith(_pprCoupler(20)), isTrue,
          reason: 'the PP-R socket welds to a PP-R coupler of the same DN',);
    });
  });

  group('🛡️ M2 — the adapter never OVER-matches (zero tolerance)', () {
    final adapter =
        ppRThreadAdapterSpec(sku: 'PPR-ADP-20', socketDn: 20, threadInch: '1/2"', male: true);

    test('the PP-R socket does NOT join an HDPE-supply socket of the same DN', () {
      expect(adapter.compatibleWith(_hdpeSupply(20)), isFalse,
          reason: 'PPR≠HDPE — a push-fit socket is material-driven (M2)',);
    });

    test('the thread does NOT join a wrong-size BSP', () {
      expect(adapter.compatibleWith(_brassBspFemale('3/4"')), isFalse,
          reason: '1/2" male must not mate 3/4" female',);
    });

    test('the thread does NOT join a same-GENDER BSP', () {
      const maleBrass = VerifiedSpec(
        sku: 'BRASS-M', material: 'פליז',
        ends: [ConnectorEnd(EndType.bspMale, '1/2"')],
      );
      expect(adapter.compatibleWith(maleBrass), isFalse,
          reason: 'male↔male never mates',);
    });

    test('the PP-R socket does NOT join ANY non-PPR same-DN party (adversarial sweep)', () {
      // The reliability+safety review verified these all return FALSE; pinned here
      // as regression guards — one over-match would be a leak.
      for (final mat in ['PVC', 'PP', 'רב-שכבתי', 'ceramic', 'rubber', 'HDPE·ניקוז']) {
        final party = VerifiedSpec(
          sku: 'X-$mat', material: mat,
          ends: [const ConnectorEnd(EndType.hdpeCompression, '20')],
        );
        expect(adapter.compatibleWith(party), isFalse, reason: 'PPR socket ↮ $mat @DN20');
      }
    });

    test('a press/drain end of the same numeric size never mates the socket', () {
      for (final t in [EndType.pexPress, EndType.copperPress, EndType.drainOpening]) {
        final party = VerifiedSpec(
          sku: 'X-$t', material: 'נחושת',
          ends: [ConnectorEnd(t, '20')],
        );
        expect(adapter.compatibleWith(party), isFalse, reason: 'socket ↮ $t "20"');
      }
    });

    test('a mark-less adapter inch is canonicalized so it still mates (no false-negative)', () {
      final noMark =
          ppRThreadAdapterSpec(sku: 'ADP-NM', socketDn: 20, threadInch: '1/2', male: true);
      expect(noMark.ends.last.size, '1/2"'); // normalized
      expect(noMark.compatibleWith(_brassBspFemale('1/2"')), isTrue);
    });

    test('a female adapter mirrors: joins a MALE brass, not a female one', () {
      final fAdapter =
          ppRThreadAdapterSpec(sku: 'PPR-ADP-F', socketDn: 20, threadInch: '1/2"', male: false);
      const maleBrass = VerifiedSpec(
        sku: 'BRASS-M', material: 'פליז',
        ends: [ConnectorEnd(EndType.bspMale, '1/2"')],
      );
      expect(fAdapter.compatibleWith(maleBrass), isTrue);
      expect(fAdapter.compatibleWith(_brassBspFemale('1/2"')), isFalse);
    });
  });
}
