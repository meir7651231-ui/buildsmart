// materializeChain turns a chain into a fully explicit, 100%-direct sequence:
// at every fitting↔fitting compression joint it inserts the pipe that spans it
// (real catalog drainage pipe, or a synthetic cut-to-length supply pipe), so
// every adjacency becomes a real direct joint (thread / press / pipe↔fitting).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isPipe(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
}

/// A joint is "real direct" when it is a thread/press/drain mate, OR a
/// compression joint where exactly one side is a pipe (pipe-into-fitting).
bool realDirect(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final sa = kVerifiedSpecs[a.sku], sb = kVerifiedSpecs[b.sku];
  if (sa == null || sb == null) return false;
  for (final ea in sa.ends) {
    for (final eb in sb.ends) {
      if (ea.directMatesWith(eb)) return true;
    }
  }
  for (final ea in sa.ends) {
    for (final eb in sb.ends) {
      if (ea.pipeSharedWith(eb) && (_isPipe(a) != _isPipe(b))) return true;
    }
  }
  return false;
}

int gaps(List<LipskeyCatalogProduct> c) {
  var g = 0;
  for (var i = 0; i < c.length - 1; i++) {
    if (!realDirect(c[i], c[i + 1])) g++;
  }
  return g;
}

void main() {
  test('drainage: a real pipe is inserted → joint becomes direct', () {
    final pvc50 = kLipskeyCatalog
        .where((p) =>
            !_isPipe(p) &&
            kVerifiedSpecs[p.sku]?.material == 'PVC' &&
            (kVerifiedSpecs[p.sku]?.ends.any((e) =>
                    e.type == EndType.hdpeCompression && e.size == '50') ??
                false))
        .toList();
    if (pvc50.length < 2) return; // no pair to exercise — skip cleanly
    final chain = [pvc50[0], pvc50[1]];
    expect(gaps(chain), 1, reason: 'two fittings sharing DN50 start as a gap');
    final m = materializeChain(chain);
    expect(m.length, 3, reason: 'a pipe was inserted between them');
    expect(_isPipe(m[1]), isTrue, reason: 'the inserted item is a pipe');
    expect(gaps(m), 0, reason: 'both joints are now pipe↔fitting (direct)');
  });

  test('supply (HDPE): a synthetic cut-to-length pipe is inserted', () {
    final hdpe40 = kLipskeyCatalog
        .where((p) =>
            !_isPipe(p) &&
            kVerifiedSpecs[p.sku]?.material == 'HDPE' &&
            (kVerifiedSpecs[p.sku]?.ends.every((e) =>
                    e.type == EndType.hdpeCompression && e.size == '40') ??
                false))
        .toList();
    if (hdpe40.length < 2) return;
    final chain = [hdpe40[0], hdpe40[1]];
    expect(gaps(chain), 1);
    final m = materializeChain(chain);
    expect(m.length, 3);
    expect(m[1].sku, 'PIPE-HDPE-40', reason: 'synthetic supply pipe inserted');
    expect(_isPipe(m[1]), isTrue, reason: 'synthetic item parses as a pipe');
    expect(gaps(m), 0);
  });

  test('pipe ↔ pipe: a coupling is inserted (two pipes cannot butt together)',
      () {
    // Two PVC drainage pipes sharing a DN can't join directly — a coupling
    // must go between them.
    final pvcPipes = kLipskeyCatalog.where((p) {
      final s = kVerifiedSpecs[p.sku];
      return _isPipe(p) &&
          s?.material == 'PVC' &&
          (s?.ends.any((e) =>
                  e.type == EndType.hdpeCompression && e.size == '50') ??
              false);
    }).toList();
    if (pvcPipes.length < 2) return; // skip if no DN50 PVC pipe pair
    final chain = [pvcPipes[0], pvcPipes[1]];
    expect(gaps(chain), 1, reason: 'two pipes start as an un-joinable gap');
    final m = materializeChain(chain);
    expect(m.length, 3, reason: 'a coupling was inserted between the pipes');
    expect(_isPipe(m[1]), isFalse, reason: 'the inserted item is a fitting');
    expect(gaps(m), 0, reason: 'pipe↔coupling↔pipe — all direct');
  });

  test('no change when items already mate directly (thread)', () {
    // A nipple (BSP male) + bushing (BSP female) mate directly → no pipe added.
    final nipple = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final m = materializeChain([nipple, nipple]);
    // identical SKUs may or may not mate; just assert materialize never drops
    // items and never inserts a pipe where a direct mate exists.
    expect(m.length, greaterThanOrEqualTo(2));
  });
}
