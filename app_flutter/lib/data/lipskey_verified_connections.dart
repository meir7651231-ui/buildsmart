// Verified plumbing connection specs for catalog products.
// Each product's physical connector ends are described explicitly so the
// compatibility engine can make 100% accurate predictions without relying on
// name-parsing heuristics.
//
// Connection end semantics:
//   hdpeCompression  — compression ring that grabs an HDPE pipe (sized by DN mm)
//   bspMale          — external BSP thread (sized by inch string, e.g. '1/2"')
//   bspFemale        — internal BSP thread (same size notation)
//
// Compatibility rules:
//   • bspMale(X) ⟺ bspFemale(X)  — direct thread-to-thread joint
//   • hdpeCompression(X) ⟷ hdpeCompression(X) — pipe-bridged (same pipe DN)
//   Two products are compatible if ANY end of A mates with ANY end of B.

enum EndType { hdpeCompression, bspMale, bspFemale }

class ConnectorEnd {
  final EndType type;
  final String size;

  const ConnectorEnd(this.type, this.size);

  bool directMatesWith(ConnectorEnd other) {
    if (type == EndType.bspMale && other.type == EndType.bspFemale && size == other.size) return true;
    if (type == EndType.bspFemale && other.type == EndType.bspMale && size == other.size) return true;
    return false;
  }

  bool pipeSharedWith(ConnectorEnd other) =>
      type == EndType.hdpeCompression &&
      other.type == EndType.hdpeCompression &&
      size == other.size;
}

class VerifiedSpec {
  final String sku;
  final List<ConnectorEnd> ends;
  final String material;
  final String? pressureRating;

  const VerifiedSpec({
    required this.sku,
    required this.ends,
    required this.material,
    this.pressureRating,
  });

  bool compatibleWith(VerifiedSpec other) {
    for (final eA in ends) {
      for (final eB in other.ends) {
        if (eA.directMatesWith(eB) || eA.pipeSharedWith(eB)) return true;
      }
    }
    return false;
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

const _hdpe = 'HDPE';
const _pn16 = 'PN16';

ConnectorEnd _c(String dn)    => ConnectorEnd(EndType.hdpeCompression, dn);
ConnectorEnd _bm(String inch) => ConnectorEnd(EndType.bspMale,         inch);
ConnectorEnd _bf(String inch) => ConnectorEnd(EndType.bspFemale,       inch);

// ── verified specs map ────────────────────────────────────────────────────────

final Map<String, VerifiedSpec> kVerifiedSpecs = {

  // ── מצמדים ישרים (couplers) ────────────────────────────────────────────────

  '9101601610': VerifiedSpec(sku: '9101601610', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _c('16')]),
  '9102002004': VerifiedSpec(sku: '9102002004', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _c('20')]),
  '9102002010': VerifiedSpec(sku: '9102002010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _c('20')]),
  '910250080':  VerifiedSpec(sku: '910250080',  material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _c('25')]),
  '9102502510': VerifiedSpec(sku: '9102502510', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _c('25')]),
  '9103202580': VerifiedSpec(sku: '9103202580', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _c('25')]),
  '9104002580': VerifiedSpec(sku: '9104002580', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _c('25')]),
  '9103203210': VerifiedSpec(sku: '9103203210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _c('32')]),
  '9104003280': VerifiedSpec(sku: '9104003280', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _c('40')]),
  '9104004010': VerifiedSpec(sku: '9104004010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _c('40')]),
  '9105005010': VerifiedSpec(sku: '9105005010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _c('50')]),
  '9106306310': VerifiedSpec(sku: '9106306310', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _c('63')]),

  // ── מצמדים עם הברגה חיצונית — BSP male (compression + male thread) ─────────

  '9101601211': VerifiedSpec(sku: '9101601211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bm('1/2"')]),
  '9101603411': VerifiedSpec(sku: '9101603411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bm('3/4"')]),
  '9102001211': VerifiedSpec(sku: '9102001211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bm('1/2"')]),
  '9102003411': VerifiedSpec(sku: '9102003411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bm('3/4"')]),
  '9102010011': VerifiedSpec(sku: '9102010011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bm('1"')]),
  '9102501211': VerifiedSpec(sku: '9102501211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('1/2"')]),
  '9102503411': VerifiedSpec(sku: '9102503411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('3/4"')]),
  '9102510011': VerifiedSpec(sku: '9102510011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('1"')]),
  '9103201211': VerifiedSpec(sku: '9103201211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('1/2"')]),
  '9103203411': VerifiedSpec(sku: '9103203411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('3/4"')]),
  '9103210011': VerifiedSpec(sku: '9103210011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('1"')]),
  '9103211211': VerifiedSpec(sku: '9103211211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('1-1/2"')]),
  '9103211411': VerifiedSpec(sku: '9103211411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('1-1/4"')]),
  '9104010011': VerifiedSpec(sku: '9104010011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('1"')]),
  '9104011211': VerifiedSpec(sku: '9104011211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('1-1/2"')]),
  '9104011411': VerifiedSpec(sku: '9104011411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('1-1/4"')]),
  '9104020011': VerifiedSpec(sku: '9104020011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('2"')]),
  '9105010011': VerifiedSpec(sku: '9105010011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('1"')]),
  '9105011211': VerifiedSpec(sku: '9105011211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('1-1/2"')]),
  '9105011411': VerifiedSpec(sku: '9105011411', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('1-1/4"')]),
  '9105020011': VerifiedSpec(sku: '9105020011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('2"')]),
  '9106311211': VerifiedSpec(sku: '9106311211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bm('1-1/2"')]),
  '9106320011': VerifiedSpec(sku: '9106320011', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bm('2"')]),
  '9106321211': VerifiedSpec(sku: '9106321211', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bm('2-1/2"')]),

  // ── מצמדים עם הברגה פנימית — BSP female (compression + female thread) ──────

  '9101601210': VerifiedSpec(sku: '9101601210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bf('1/2"')]),
  '9101603410': VerifiedSpec(sku: '9101603410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bf('3/4"')]),
  '9102001210': VerifiedSpec(sku: '9102001210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bf('1/2"')]),
  '9102003410': VerifiedSpec(sku: '9102003410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bf('3/4"')]),
  '9102501210': VerifiedSpec(sku: '9102501210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('1/2"')]),
  '9102503410': VerifiedSpec(sku: '9102503410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('3/4"')]),
  '9102510010': VerifiedSpec(sku: '9102510010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('1"')]),
  '9103203410': VerifiedSpec(sku: '9103203410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bf('3/4"')]),
  '9103210010': VerifiedSpec(sku: '9103210010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bf('1"')]),
  '9103211210': VerifiedSpec(sku: '9103211210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bf('1-1/2"')]),
  '9104010010': VerifiedSpec(sku: '9104010010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bf('1"')]),
  '9104011210': VerifiedSpec(sku: '9104011210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bf('1-1/2"')]),
  '9104011410': VerifiedSpec(sku: '9104011410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bf('1-1/4"')]),
  '9105011210': VerifiedSpec(sku: '9105011210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bf('1-1/2"')]),
  '9105011410': VerifiedSpec(sku: '9105011410', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bf('1-1/4"')]),
  '9105020010': VerifiedSpec(sku: '9105020010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bf('2"')]),
  '9106311210': VerifiedSpec(sku: '9106311210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bf('1-1/2"')]),
  '9106320010': VerifiedSpec(sku: '9106320010', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bf('2"')]),
  '9106321210': VerifiedSpec(sku: '9106321210', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bf('2-1/2"')]),

  // ── זוויות עם הברגה חיצונית — BSP male elbows ────────────────────────────

  '9101601231': VerifiedSpec(sku: '9101601231', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bm('1/2"')]),
  '9101603431': VerifiedSpec(sku: '9101603431', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bm('3/4"')]),
  '9102001231': VerifiedSpec(sku: '9102001231', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bm('1/2"')]),
  '9102003431': VerifiedSpec(sku: '9102003431', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bm('3/4"')]),
  '9102501231': VerifiedSpec(sku: '9102501231', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('1/2"')]),
  '9102503431': VerifiedSpec(sku: '9102503431', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('3/4"')]),
  '9102510031': VerifiedSpec(sku: '9102510031', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bm('1"')]),
  '9103203431': VerifiedSpec(sku: '9103203431', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('3/4"')]),
  '9103210031': VerifiedSpec(sku: '9103210031', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bm('1"')]),
  '9104011231': VerifiedSpec(sku: '9104011231', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('1-1/2"')]),
  '9104011431': VerifiedSpec(sku: '9104011431', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bm('1-1/4"')]),
  '9105011231': VerifiedSpec(sku: '9105011231', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('1-1/2"')]),
  '9105020031': VerifiedSpec(sku: '9105020031', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bm('2"')]),
  '9106320031': VerifiedSpec(sku: '9106320031', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bm('2"')]),

  // ── זוויות עם הברגה פנימית — BSP female elbows ────────────────────────────

  '9101601232': VerifiedSpec(sku: '9101601232', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _bf('1/2"')]),
  '9102001230': VerifiedSpec(sku: '9102001230', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bf('1/2"')]),
  '9102003430': VerifiedSpec(sku: '9102003430', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _bf('3/4"')]),
  '9102501230': VerifiedSpec(sku: '9102501230', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('1/2"')]),
  '9102503430': VerifiedSpec(sku: '9102503430', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('3/4"')]),
  '9102510030': VerifiedSpec(sku: '9102510030', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _bf('1"')]),
  '9103203430': VerifiedSpec(sku: '9103203430', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bf('3/4"')]),
  '9103210030': VerifiedSpec(sku: '9103210030', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _bf('1"')]),
  '9104011230': VerifiedSpec(sku: '9104011230', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bf('1-1/2"')]),
  '9104011430': VerifiedSpec(sku: '9104011430', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _bf('1-1/4"')]),
  '9105011230': VerifiedSpec(sku: '9105011230', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bf('1-1/2"')]),
  '9105020030': VerifiedSpec(sku: '9105020030', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _bf('2"')]),
  '9106320030': VerifiedSpec(sku: '9106320030', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _bf('2"')]),

  // ── הסתעפויות (tees — 3 compression ends) ────────────────────────────────

  '9101601640': VerifiedSpec(sku: '9101601640', material: _hdpe, pressureRating: _pn16,
      ends: [_c('16'), _c('16'), _c('16')]),
  '9102002040': VerifiedSpec(sku: '9102002040', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _c('20'), _c('20')]),
  '9102502540': VerifiedSpec(sku: '9102502540', material: _hdpe, pressureRating: _pn16,
      ends: [_c('25'), _c('25'), _c('25')]),
  '9103203240': VerifiedSpec(sku: '9103203240', material: _hdpe, pressureRating: _pn16,
      ends: [_c('32'), _c('32'), _c('32')]),
  '9104003240': VerifiedSpec(sku: '9104003240', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _c('32'), _c('40')]),
  '9104004040': VerifiedSpec(sku: '9104004040', material: _hdpe, pressureRating: _pn16,
      ends: [_c('40'), _c('40'), _c('40')]),
  '9105005040': VerifiedSpec(sku: '9105005040', material: _hdpe, pressureRating: _pn16,
      ends: [_c('50'), _c('50'), _c('50')]),
  '9106306340': VerifiedSpec(sku: '9106306340', material: _hdpe, pressureRating: _pn16,
      ends: [_c('63'), _c('63'), _c('63')]),
  '9102001242': VerifiedSpec(sku: '9102001242', material: _hdpe, pressureRating: _pn16,
      ends: [_c('20'), _c('16'), _c('20')]),
};
