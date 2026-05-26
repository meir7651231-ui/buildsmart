// Verified plumbing connection specs for catalog products.
// Each product's physical connector ends are described explicitly so the
// compatibility engine can make 100% accurate predictions without relying on
// name-parsing heuristics.
//
// Connection end semantics:
//   hdpeCompression  — compression ring that grabs an HDPE pipe (sized by DN mm)
//   pexPress         — press/crimp sleeve that grabs a PEX pipe (sized by OD mm)
//   copperPress      — press/compression joint on copper tube (sized by OD mm)
//   bspMale          — external BSP thread (sized by inch string, e.g. '1/2"')
//   bspFemale        — internal BSP thread (same size notation)
//
// Compatibility rules:
//   • bspMale(X) ⟺ bspFemale(X)  — direct thread-to-thread joint
//   • pexPress(X) ⟺ pexPress(X)  — fitting accepts the PEX pipe of that OD
//   • copperPress(X) ⟺ copperPress(X) — fitting accepts the copper tube
//   • hdpeCompression(X) ⟷ hdpeCompression(X) — pipe-bridged (same pipe DN)
//   Two products are compatible if ANY end of A mates with ANY end of B.
//
// Material / temperature: each spec carries maxTempC so the engine can reject
// a product whose material can't survive the line's operating temperature
// (e.g. HDPE caps at ~40°C continuous and must never serve 80°C hot water).

enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale }

class ConnectorEnd {
  final EndType type;
  final String size;

  const ConnectorEnd(this.type, this.size);

  bool directMatesWith(ConnectorEnd other) {
    // BSP thread: male ⟺ female of the same size.
    if (type == EndType.bspMale && other.type == EndType.bspFemale && size == other.size) return true;
    if (type == EndType.bspFemale && other.type == EndType.bspMale && size == other.size) return true;
    // PEX / copper press: a fitting end accepts a pipe/fitting of the same OD.
    if (type == EndType.pexPress && other.type == EndType.pexPress && size == other.size) return true;
    if (type == EndType.copperPress && other.type == EndType.copperPress && size == other.size) return true;
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

  /// PEX sub-type + connection method for PEX products (e.g. 'PEX-B · Crimp').
  /// Null for non-PEX products.
  final String? pexType;

  /// Maximum continuous service temperature (°C). Defaults to 40 — the safe
  /// cap for HDPE — so every legacy cold-water spec is correct without edits.
  final double maxTempC;

  const VerifiedSpec({
    required this.sku,
    required this.ends,
    required this.material,
    this.pressureRating,
    this.pexType,
    this.maxTempC = 40,
  });

  bool compatibleWith(VerifiedSpec other) {
    for (final eA in ends) {
      for (final eB in other.ends) {
        if (eA.directMatesWith(eB) || eA.pipeSharedWith(eB)) return true;
      }
    }
    return false;
  }

  /// True when this product's material can serve a line at [tempC].
  bool suitableForTemp(double tempC) => tempC <= maxTempC;
}

// ── helpers ──────────────────────────────────────────────────────────────────

const _hdpe   = 'HDPE';
const _pex    = 'PEX';
const _copper = 'נחושת';
const _brass  = 'פליז';
const _steel  = 'פלדה';
const _stainless = 'נירוסטה';
const _pn16   = 'PN16';

ConnectorEnd _c(String dn)    => ConnectorEnd(EndType.hdpeCompression, dn);
ConnectorEnd _px(String od)   => ConnectorEnd(EndType.pexPress,        od);
ConnectorEnd _cu(String od)   => ConnectorEnd(EndType.copperPress,     od);
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

  // ════════════════════════════════════════════════════════════════════════
  // HOT-WATER + RECIRCULATION FAMILY (PEX / copper / brass — rated ≥80°C)
  // ════════════════════════════════════════════════════════════════════════

  // ── brass interface / isolation (pump side) ────────────────────────────────
  // Pump modelled as through-device: BSP-female inlet + BSP-male outlet.
  'HW-PUMP-25': VerifiedSpec(sku: 'HW-PUMP-25', material: _brass,
      pressureRating: '10 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1"'), _bm('1"')]),
  // Inlet-side ball valve (boiler outlet / pump suction) — male × female 1".
  'HW-BALL-INLET-1': VerifiedSpec(sku: 'HW-BALL-INLET-1', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1"'), _bf('1"')]),
  'HW-UNION-1': VerifiedSpec(sku: 'HW-UNION-1', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1"'), _bm('1"')]),
  'HW-BALL-1': VerifiedSpec(sku: 'HW-BALL-1', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1"'), _bf('1"')]),

  // ── brass → PEX transition + PEX run ────────────────────────────────────────
  // PEX-B pipe: EN 15875 max 10 bar @ 80°C continuous service.
  'HW-ADP-1-PEX20': VerifiedSpec(sku: 'HW-ADP-1-PEX20', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 95,
      ends: [_bm('1"'), _px('20')]),
  'HW-PEX-20': VerifiedSpec(sku: 'HW-PEX-20', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('20'), _px('20')]),
  'HW-PEX-RED-20-16': VerifiedSpec(sku: 'HW-PEX-RED-20-16', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('20'), _px('16')]),
  'HW-PEX-16': VerifiedSpec(sku: 'HW-PEX-16', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('16'), _px('16')]),

  // ── PEX → copper transition + copper run ────────────────────────────────────
  // Copper press: EN 1254-2 max 16 bar @ 110°C.
  'HW-ADP-PEX16-CU15': VerifiedSpec(sku: 'HW-ADP-PEX16-CU15', material: _brass,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B', maxTempC: 110,
      ends: [_px('16'), _cu('15')]),
  'HW-CU-15': VerifiedSpec(sku: 'HW-CU-15', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),
  'HW-BALL-15': VerifiedSpec(sku: 'HW-BALL-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),

  // ── manifold + shower outlet ────────────────────────────────────────────────
  'HW-MANIFOLD-3': VerifiedSpec(sku: 'HW-MANIFOLD-3', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  'HW-SHOWER-ARM': VerifiedSpec(sku: 'HW-SHOWER-ARM', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  'HW-SHOWER-HEAD': VerifiedSpec(sku: 'HW-SHOWER-HEAD', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 80,
      ends: [_bm('1/2"')]),

  // ── recirculation loop ──────────────────────────────────────────────────────
  'HW-TEE-RECIRC': VerifiedSpec(sku: 'HW-TEE-RECIRC', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15'), _cu('15')]),
  'HW-CHECK-15': VerifiedSpec(sku: 'HW-CHECK-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),
  'HW-BALANCE-15': VerifiedSpec(sku: 'HW-BALANCE-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),

  // ── safety (closed hot loop) ────────────────────────────────────────────────
  'HW-PRV-34': VerifiedSpec(sku: 'HW-PRV-34', material: _brass,
      pressureRating: 'set 7 bar (body 10 bar)', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),
  'HW-EXPVESSEL': VerifiedSpec(sku: 'HW-EXPVESSEL', material: _steel,
      pressureRating: '10 bar @ 99°C', maxTempC: 99,
      ends: [_cu('15')]),
  // Automatic float vent — terminal device on the DN15 loop tee.
  'HW-AIRVENT': VerifiedSpec(sku: 'HW-AIRVENT', material: _brass,
      pressureRating: '10 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15')]),

  // ── galvanic isolation + thermal expansion ──────────────────────────────────
  'HW-DIELECTRIC-15': VerifiedSpec(sku: 'HW-DIELECTRIC-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('15'), _cu('15')]),
  'HW-EXP-COMP-20': VerifiedSpec(sku: 'HW-EXP-COMP-20', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('20'), _px('20')]),

  // ════════════════════════════════════════════════════════════════════════
  // ── commercial / larger DN (pump island + multi-floor distribution) ────

  // Y-strainers (pump protection)
  'HW-YSTR-40': VerifiedSpec(sku: 'HW-YSTR-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/2"'), _bm('1-1/2"')]),
  'HW-YSTR-32': VerifiedSpec(sku: 'HW-YSTR-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/4"'), _bm('1-1/4"')]),
  'HW-YSTR-15': VerifiedSpec(sku: 'HW-YSTR-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1/2"'), _bm('1/2"')]),

  // Flexible connectors (vibration isolation)
  'HW-FLEX-40': VerifiedSpec(sku: 'HW-FLEX-40', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/2"'), _bm('1-1/2"')]),
  'HW-FLEX-32': VerifiedSpec(sku: 'HW-FLEX-32', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/4"'), _bm('1-1/4"')]),

  // Commercial VSP pump DN40
  'HW-PUMP-40': VerifiedSpec(sku: 'HW-PUMP-40', material: _brass,
      pressureRating: '10 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/2"'), _bm('1-1/2"')]),

  // Ball valves — BSP threaded (pump island)
  'HW-BALL-INLET-40': VerifiedSpec(sku: 'HW-BALL-INLET-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1-1/2"'), _bf('1-1/2"')]),
  'HW-BALL-40': VerifiedSpec(sku: 'HW-BALL-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/2"'), _bf('1-1/2"')]),
  'HW-BALL-32': VerifiedSpec(sku: 'HW-BALL-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/4"'), _bf('1-1/4"')]),

  // Ball valves — copper press (inline distribution)
  'HW-BALL-CU-40': VerifiedSpec(sku: 'HW-BALL-CU-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _cu('40')]),
  'HW-BALL-CU-32': VerifiedSpec(sku: 'HW-BALL-CU-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('32'), _cu('32')]),
  'HW-BALL-CU-25': VerifiedSpec(sku: 'HW-BALL-CU-25', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),
  'HW-BALL-CU-20': VerifiedSpec(sku: 'HW-BALL-CU-20', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Check valves (backflow) — BSP
  'HW-CHECK-40': VerifiedSpec(sku: 'HW-CHECK-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/2"'), _bm('1-1/2"')]),
  'HW-CHECK-32': VerifiedSpec(sku: 'HW-CHECK-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bf('1-1/4"'), _bm('1-1/4"')]),
  // Check valve — copper press
  'HW-CHECK-CU-20': VerifiedSpec(sku: 'HW-CHECK-CU-20', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Bladder expansion tanks (diaphragm, EPDM membrane)
  'HW-BTANK-35': VerifiedSpec(sku: 'HW-BTANK-35', material: _steel,
      pressureRating: 'PN16 · N₂ 2.5 bar', maxTempC: 99,
      ends: [_bm('3/4"')]),
  'HW-BTANK-18': VerifiedSpec(sku: 'HW-BTANK-18', material: _steel,
      pressureRating: 'PN16 · N₂ 2.5 bar', maxTempC: 99,
      ends: [_bm('3/4"')]),

  // Instrumentation (terminal devices)
  'HW-GAUGE': VerifiedSpec(sku: 'HW-GAUGE', material: _brass,
      pressureRating: '0–10 bar gauge', maxTempC: 110,
      ends: [_bm('1/4"')]),
  'HW-DRAIN-12': VerifiedSpec(sku: 'HW-DRAIN-12', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1/2"')]),
  'HW-PT1000': VerifiedSpec(sku: 'HW-PT1000', material: _stainless,
      pressureRating: '0–120°C sensor', maxTempC: 120,
      ends: [_bm('1/2"')]),

  // Adapters: BSP ↔ copper DN40
  'HW-ADP-BSP112-CU40': VerifiedSpec(sku: 'HW-ADP-BSP112-CU40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1-1/2"'), _cu('40')]),
  'HW-ADP-CU40-BSP112': VerifiedSpec(sku: 'HW-ADP-CU40-BSP112', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _bf('1-1/2"')]),

  // Copper pipes (larger DN)
  'HW-CU-40': VerifiedSpec(sku: 'HW-CU-40', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _cu('40')]),
  'HW-CU-32': VerifiedSpec(sku: 'HW-CU-32', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('32'), _cu('32')]),
  'HW-CU-25': VerifiedSpec(sku: 'HW-CU-25', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),
  'HW-CU-20': VerifiedSpec(sku: 'HW-CU-20', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Copper reducing couplers
  'HW-RED-CU-40-32': VerifiedSpec(sku: 'HW-RED-CU-40-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _cu('32')]),
  'HW-RED-CU-32-25': VerifiedSpec(sku: 'HW-RED-CU-32-25', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('32'), _cu('25')]),
  'HW-RED-CU-25-20': VerifiedSpec(sku: 'HW-RED-CU-25-20', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('20')]),
  'HW-RED-CU-20-15': VerifiedSpec(sku: 'HW-RED-CU-20-15', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('15')]),

  // Dielectric unions — larger DN
  'HW-DIELECTRIC-40': VerifiedSpec(sku: 'HW-DIELECTRIC-40', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _cu('40')]),
  'HW-DIELECTRIC-32': VerifiedSpec(sku: 'HW-DIELECTRIC-32', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('32'), _cu('32')]),
  'HW-DIELECTRIC-25': VerifiedSpec(sku: 'HW-DIELECTRIC-25', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),
  'HW-DIELECTRIC-20': VerifiedSpec(sku: 'HW-DIELECTRIC-20', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Expansion bellows (stainless, thermal expansion compensation)
  'HW-BELLOWS-40': VerifiedSpec(sku: 'HW-BELLOWS-40', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('40'), _cu('40')]),
  'HW-BELLOWS-32': VerifiedSpec(sku: 'HW-BELLOWS-32', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('32'), _cu('32')]),
  'HW-BELLOWS-25': VerifiedSpec(sku: 'HW-BELLOWS-25', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),
  'HW-BELLOWS-20': VerifiedSpec(sku: 'HW-BELLOWS-20', material: _stainless,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Thermostatic Mixing Valves — TMTV anti-scald (modelled as pass-through)
  'HW-TMTV-32': VerifiedSpec(sku: 'HW-TMTV-32', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 80,
      ends: [_cu('32'), _cu('32')]),
  'HW-TMTV-25': VerifiedSpec(sku: 'HW-TMTV-25', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 80,
      ends: [_cu('25'), _cu('25')]),
  'HW-TMTV-20': VerifiedSpec(sku: 'HW-TMTV-20', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 80,
      ends: [_cu('20'), _cu('20')]),
  'HW-TMTV-15': VerifiedSpec(sku: 'HW-TMTV-15', material: _brass,
      pressureRating: '10 bar @ 80°C', maxTempC: 80,
      ends: [_cu('15'), _cu('15')]),

  // Pre-set balancing valves (hydraulic balance per floor riser)
  'HW-BALANCE-25': VerifiedSpec(sku: 'HW-BALANCE-25', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),
  'HW-BALANCE-20': VerifiedSpec(sku: 'HW-BALANCE-20', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20')]),

  // Copper tees (recirculation takeoffs per floor)
  'HW-TEE-CU-25': VerifiedSpec(sku: 'HW-TEE-CU-25', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25'), _cu('25')]),
  'HW-TEE-CU-20': VerifiedSpec(sku: 'HW-TEE-CU-20', material: _copper,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _cu('20'), _cu('20')]),

  // Manifolds — 4 and 6 outlets (DN20 copper press inlet, ½" BSP F outlets)
  'HW-MANIFOLD-4': VerifiedSpec(sku: 'HW-MANIFOLD-4', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  'HW-MANIFOLD-6': VerifiedSpec(sku: 'HW-MANIFOLD-6', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('20'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"'),
             _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),

  // PEX-B 25×3.5 (commercial kitchen / floor 1)
  'HW-PEX-25': VerifiedSpec(sku: 'HW-PEX-25', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('25'), _px('25')]),
  'HW-PEX-RED-25-20': VerifiedSpec(sku: 'HW-PEX-RED-25-20', material: _pex,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B · Crimp/Press', maxTempC: 95,
      ends: [_px('25'), _px('20')]),
  'HW-ADP-112-PEX25': VerifiedSpec(sku: 'HW-ADP-112-PEX25', material: _brass,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B', maxTempC: 95,
      ends: [_bm('1-1/2"'), _px('25')]),
  'HW-ADP-PEX25-CU25': VerifiedSpec(sku: 'HW-ADP-PEX25-CU25', material: _brass,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B', maxTempC: 95,
      ends: [_px('25'), _cu('25')]),
  'HW-ADP-PEX25-CU20': VerifiedSpec(sku: 'HW-ADP-PEX25-CU20', material: _brass,
      pressureRating: '10 bar @ 80°C', pexType: 'PEX-B', maxTempC: 95,
      ends: [_px('25'), _cu('20')]),

  // Thermal disinfection bypass (3-way actuated, anti-Legionella pasteurization)
  'HW-DISINFECT': VerifiedSpec(sku: 'HW-DISINFECT', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_cu('25'), _cu('25')]),

  // Legionella sampling port ¼" BSP (terminal)
  'HW-SAMPLE': VerifiedSpec(sku: 'HW-SAMPLE', material: _brass,
      pressureRating: '16 bar @ 110°C', maxTempC: 110,
      ends: [_bm('1/4"')]),
};
