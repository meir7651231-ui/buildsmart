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

  // ── ברזי כיור (Sink Faucets) ───────────────────────────────────────────────
  '7777113A': VerifiedSpec(sku: '7777113A', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '7777557K': VerifiedSpec(sku: '7777557K', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777114': VerifiedSpec(sku: '77777114', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '77777335': VerifiedSpec(sku: '77777335', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777557': VerifiedSpec(sku: '77777557', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M1114': VerifiedSpec(sku: '777M1114', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M1122': VerifiedSpec(sku: '777M1122', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M1803': VerifiedSpec(sku: '777M1803', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M1804': VerifiedSpec(sku: '777M1804', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2162': VerifiedSpec(sku: '777M2162', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2168': VerifiedSpec(sku: '777M2168', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2203': VerifiedSpec(sku: '777M2203', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2204': VerifiedSpec(sku: '777M2204', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── ברזי מטבח (Kitchen Faucets) ────────────────────────────────────────────
  '7777343K': VerifiedSpec(sku: '7777343K', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777343': VerifiedSpec(sku: '77777343', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '779096B': VerifiedSpec(sku: '779096B', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '779096C': VerifiedSpec(sku: '779096C', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '779096F': VerifiedSpec(sku: '779096F', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '779096G': VerifiedSpec(sku: '779096G', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '779096S': VerifiedSpec(sku: '779096S', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── ברזי קיר (Wall Faucets) ────────────────────────────────────────────────
  '7772364D': VerifiedSpec(sku: '7772364D', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '7777106A': VerifiedSpec(sku: '7777106A', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '7777107A': VerifiedSpec(sku: '7777107A', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '7777111A': VerifiedSpec(sku: '7777111A', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '7777112Y': VerifiedSpec(sku: '7777112Y', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '77777112': VerifiedSpec(sku: '77777112', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '777M1716': VerifiedSpec(sku: '777M1716', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M1717': VerifiedSpec(sku: '777M1717', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2206': VerifiedSpec(sku: '777M2206', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2207': VerifiedSpec(sku: '777M2207', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2216': VerifiedSpec(sku: '777M2216', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2217': VerifiedSpec(sku: '777M2217', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2414': VerifiedSpec(sku: '777M2414', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── ברזי מקלחת (Shower Faucets) ────────────────────────────────────────────
  '777M1808': VerifiedSpec(sku: '777M1808', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2208': VerifiedSpec(sku: '777M2208', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── ברזי אמבטיה (Bath Faucets) ─────────────────────────────────────────────
  '777M1801': VerifiedSpec(sku: '777M1801', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '777M2201': VerifiedSpec(sku: '777M2201', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── ברזי גן (Garden Taps) ──────────────────────────────────────────────────
  '77777341': VerifiedSpec(sku: '77777341', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '77777345': VerifiedSpec(sku: '77777345', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"')]),

  // ── ברזי מעבר (Ball / Gate / Globe Valves) ─────────────────────────────────
  '77003128': VerifiedSpec(sku: '77003128', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777201': VerifiedSpec(sku: '77777201', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777202': VerifiedSpec(sku: '77777202', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777203': VerifiedSpec(sku: '77777203', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777204': VerifiedSpec(sku: '77777204', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/4"'), _bf('1-1/4"')]),
  '77777205': VerifiedSpec(sku: '77777205', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/2"'), _bf('1-1/2"')]),
  '77777206': VerifiedSpec(sku: '77777206', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),
  '77777212': VerifiedSpec(sku: '77777212', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777293': VerifiedSpec(sku: '77777293', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777296': VerifiedSpec(sku: '77777296', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),
  '77777302': VerifiedSpec(sku: '77777302', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777303': VerifiedSpec(sku: '77777303', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777311': VerifiedSpec(sku: '77777311', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777312': VerifiedSpec(sku: '77777312', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('3/4"')]),
  '77777313': VerifiedSpec(sku: '77777313', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('1"')]),
  '77777314': VerifiedSpec(sku: '77777314', material: _brass, maxTempC: 90,
      ends: [_bm('1-1/4"'), _bf('1-1/4"')]),
  '77777315': VerifiedSpec(sku: '77777315', material: _brass, maxTempC: 90,
      ends: [_bm('1-1/2"'), _bf('1-1/2"')]),
  '77777316': VerifiedSpec(sku: '77777316', material: _brass, maxTempC: 90,
      ends: [_bm('2"'), _bf('2"')]),
  '77777392': VerifiedSpec(sku: '77777392', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777396': VerifiedSpec(sku: '77777396', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),

  // ── ברזים (Taps — general) ─────────────────────────────────────────────────
  '34-5017': VerifiedSpec(sku: '34-5017', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),

  // ── אביזרי נחושת (Brass Fittings) ─────────────────────────────────────────
  // ניפל כפול (double nipple M×M)
  '77777641': VerifiedSpec(sku: '77777641', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bm('1/2"')]),
  '77777642': VerifiedSpec(sku: '77777642', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bm('3/4"')]),
  '77777643': VerifiedSpec(sku: '77777643', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bm('1"')]),
  // כפה (cap — F end: screws onto a male thread, closes it)
  '77777101': VerifiedSpec(sku: '77777101', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '77777102': VerifiedSpec(sku: '77777102', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"')]),
  '77777103': VerifiedSpec(sku: '77777103', material: _brass, maxTempC: 90,
      ends: [_bf('1"')]),
  // מופה (socket F×F coupler)
  '77777104': VerifiedSpec(sku: '77777104', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777105': VerifiedSpec(sku: '77777105', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777106': VerifiedSpec(sku: '77777106', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  // פקק (plug M — closes a female thread)
  '7778071':  VerifiedSpec(sku: '7778071',  material: _brass, maxTempC: 90,
      ends: [_bm('1/2"')]),
  '77778071': VerifiedSpec(sku: '77778071', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"')]),
  '77778072': VerifiedSpec(sku: '77778072', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"')]),
  '77778073': VerifiedSpec(sku: '77778073', material: _brass, maxTempC: 90,
      ends: [_bm('1"')]),
  // רקורד לשעון מים + ניפל (water-meter union)
  '77777632': VerifiedSpec(sku: '77777632', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('3/4"')]),
  '77777630': VerifiedSpec(sku: '77777630', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777631': VerifiedSpec(sku: '77777631', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777635': VerifiedSpec(sku: '77777635', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777633': VerifiedSpec(sku: '77777633', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/2"'), _bf('1-1/2"')]),
  '77777634': VerifiedSpec(sku: '77777634', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),
  // בושינג מפחית (reducer bushing M×F: male=small, female=large)
  '77777661': VerifiedSpec(sku: '77777661', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('1/2"')]),
  '77777663': VerifiedSpec(sku: '77777663', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('1/2"')]),
  '77777662': VerifiedSpec(sku: '77777662', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('3/4"')]),
  // מאריך נחושת / ניקל (extension nipple M×F — length varies, thread is ½" BSP)
  '77777701': VerifiedSpec(sku: '77777701', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777702': VerifiedSpec(sku: '77777702', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777703': VerifiedSpec(sku: '77777703', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777704': VerifiedSpec(sku: '77777704', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777705': VerifiedSpec(sku: '77777705', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777706': VerifiedSpec(sku: '77777706', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777707': VerifiedSpec(sku: '77777707', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777755': VerifiedSpec(sku: '77777755', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777756': VerifiedSpec(sku: '77777756', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777708': VerifiedSpec(sku: '77777708', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777709': VerifiedSpec(sku: '77777709', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777710': VerifiedSpec(sku: '77777710', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777100': VerifiedSpec(sku: '77777100', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  // אל-חוזר / שסתום אל-חזור כלפה (flap check valve F×F)
  '77004401': VerifiedSpec(sku: '77004401', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77004402': VerifiedSpec(sku: '77004402', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77004403': VerifiedSpec(sku: '77004403', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77004404': VerifiedSpec(sku: '77004404', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/4"'), _bf('1-1/4"')]),
  '77004405': VerifiedSpec(sku: '77004405', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/2"'), _bf('1-1/2"')]),
  '77004406': VerifiedSpec(sku: '77004406', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),
  '77004407': VerifiedSpec(sku: '77004407', material: _brass, maxTempC: 90,
      ends: [_bf('2-1/2"'), _bf('2-1/2"')]),
  '77004408': VerifiedSpec(sku: '77004408', material: _brass, maxTempC: 90,
      ends: [_bf('3"'), _bf('3"')]),
  '77004416': VerifiedSpec(sku: '77004416', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  // מצמד/חיבור (straight coupler F×F)
  '77777471': VerifiedSpec(sku: '77777471', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777472': VerifiedSpec(sku: '77777472', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777473': VerifiedSpec(sku: '77777473', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  '77777474': VerifiedSpec(sku: '77777474', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/4"'), _bf('1-1/4"')]),
  '77777475': VerifiedSpec(sku: '77777475', material: _brass, maxTempC: 90,
      ends: [_bf('1-1/2"'), _bf('1-1/2"')]),
  '77777476': VerifiedSpec(sku: '77777476', material: _brass, maxTempC: 90,
      ends: [_bf('2"'), _bf('2"')]),
  // מחבר M×F / M×M (connectors)
  '77001190': VerifiedSpec(sku: '77001190', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77001192': VerifiedSpec(sku: '77001192', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('3/4"')]),
  '77001194': VerifiedSpec(sku: '77001194', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('1"')]),
  '77001191': VerifiedSpec(sku: '77001191', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bm('1/2"')]),
  '77001193': VerifiedSpec(sku: '77001193', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bm('3/4"')]),
  // טי (tee F×F×F)
  '77777671': VerifiedSpec(sku: '77777671', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  '77777672': VerifiedSpec(sku: '77777672', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"'), _bf('3/4"')]),
  '77777673': VerifiedSpec(sku: '77777673', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"'), _bf('1"')]),
  // זווית (elbow F×F)
  '77777677': VerifiedSpec(sku: '77777677', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"'), _bf('1/2"')]),
  '77777678': VerifiedSpec(sku: '77777678', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('3/4"')]),
  '77777679': VerifiedSpec(sku: '77777679', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1"')]),
  // זווית M×F (elbow)
  '77777683': VerifiedSpec(sku: '77777683', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('1/2"')]),
  '77777684': VerifiedSpec(sku: '77777684', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('3/4"')]),
  '77777685': VerifiedSpec(sku: '77777685', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('1"')]),
  // ברך M×F (elbow style 2)
  '77777612': VerifiedSpec(sku: '77777612', material: _brass, maxTempC: 90,
      ends: [_bm('3/4"'), _bf('3/4"')]),
  '77777613': VerifiedSpec(sku: '77777613', material: _brass, maxTempC: 90,
      ends: [_bm('1"'), _bf('1"')]),
  // בושינג מפחית (reducer bushing)
  '8315':  VerifiedSpec(sku: '8315',  material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('3/4"')]),
  '8315B': VerifiedSpec(sku: '8315B', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('3/8"')]),
  '77780751': VerifiedSpec(sku: '77780751', material: _brass, maxTempC: 90,
      ends: [_bm('1/2"'), _bf('3/8"')]),
  // רוזטה (pipe escutcheon — cosmetic, single female port)
  '77770003': VerifiedSpec(sku: '77770003', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),
  '77770004': VerifiedSpec(sku: '77770004', material: _brass, maxTempC: 90,
      ends: [_bf('1/2"')]),

  // ── ברכיים (Elbows — drain/sewer PVC) ─────────────────────────────────────
  '116624': VerifiedSpec(sku: '116624', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116601': VerifiedSpec(sku: '116601', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116033': VerifiedSpec(sku: '116033', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '142289': VerifiedSpec(sku: '142289', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116028': VerifiedSpec(sku: '116028', material: 'PVC', maxTempC: 50, ends: [_c('160'), _c('160')]),
  '116031': VerifiedSpec(sku: '116031', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '124843': VerifiedSpec(sku: '124843', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110'), _c('110')]),
  '116026': VerifiedSpec(sku: '116026', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110'), _c('110'), _c('110')]),
  '194899': VerifiedSpec(sku: '194899', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '194900': VerifiedSpec(sku: '194900', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116591': VerifiedSpec(sku: '116591', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116553': VerifiedSpec(sku: '116553', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '161884': VerifiedSpec(sku: '161884', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '190297': VerifiedSpec(sku: '190297', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116037': VerifiedSpec(sku: '116037', material: 'PVC', maxTempC: 50, ends: [_c('160'), _c('160')]),

  // ── צינורות אפורות (Gray Drain Pipes) ──────────────────────────────────────
  '273227': VerifiedSpec(sku: '273227', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '221022': VerifiedSpec(sku: '221022', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '221085': VerifiedSpec(sku: '221085', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '116113': VerifiedSpec(sku: '116113', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '219791': VerifiedSpec(sku: '219791', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116180': VerifiedSpec(sku: '116180', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116593': VerifiedSpec(sku: '116593', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '164588': VerifiedSpec(sku: '164588', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116071': VerifiedSpec(sku: '116071', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116078': VerifiedSpec(sku: '116078', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116091': VerifiedSpec(sku: '116091', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '116093': VerifiedSpec(sku: '116093', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '116617': VerifiedSpec(sku: '116617', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116620': VerifiedSpec(sku: '116620', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116099': VerifiedSpec(sku: '116099', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116101': VerifiedSpec(sku: '116101', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116622': VerifiedSpec(sku: '116622', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116103': VerifiedSpec(sku: '116103', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '116105': VerifiedSpec(sku: '116105', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),

  // ── צינורות PP ────────────────────────────────────────────────────────────
  '224169': VerifiedSpec(sku: '224169', material: 'PP', maxTempC: 70, ends: [_c('110'), _c('110')]),
  '224168': VerifiedSpec(sku: '224168', material: 'PP', maxTempC: 70, ends: [_c('110'), _c('110')]),
  '224170': VerifiedSpec(sku: '224170', material: 'PP', maxTempC: 70, ends: [_c('110'), _c('110')]),
  '224185': VerifiedSpec(sku: '224185', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),
  '224186': VerifiedSpec(sku: '224186', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),
  '224187': VerifiedSpec(sku: '224187', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),
  '224345': VerifiedSpec(sku: '224345', material: 'PP', maxTempC: 70, ends: [_c('110'), _c('110')]),
  '224344': VerifiedSpec(sku: '224344', material: 'PP', maxTempC: 70, ends: [_c('110'), _c('110')]),
  '224348': VerifiedSpec(sku: '224348', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),
  '224347': VerifiedSpec(sku: '224347', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),
  '224346': VerifiedSpec(sku: '224346', material: 'PP', maxTempC: 70, ends: [_c('160'), _c('160')]),

  // ── צינורות רב שכבתי (Multi-layer Drain Pipes) ────────────────────────────
  '273216': VerifiedSpec(sku: '273216', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('75'), _c('75')]),
  '273201': VerifiedSpec(sku: '273201', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('110'), _c('110')]),
  '273219': VerifiedSpec(sku: '273219', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('160'), _c('160')]),
  '273217': VerifiedSpec(sku: '273217', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('75'), _c('75')]),
  '273202': VerifiedSpec(sku: '273202', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('110'), _c('110')]),
  '273203': VerifiedSpec(sku: '273203', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('110'), _c('110')]),
  '273215': VerifiedSpec(sku: '273215', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('110'), _c('110')]),
  '273220': VerifiedSpec(sku: '273220', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('160'), _c('160')]),
  '273221': VerifiedSpec(sku: '273221', material: 'רב-שכבתי', maxTempC: 90, ends: [_c('160'), _c('160')]),

  // ── אביזרי ביוב ───────────────────────────────────────────────────────────
  '273089': VerifiedSpec(sku: '273089', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── מאספי רצפה ───────────────────────────────────────────────────────────
  '116148': VerifiedSpec(sku: '116148', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '171191': VerifiedSpec(sku: '171191', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116151': VerifiedSpec(sku: '116151', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116638': VerifiedSpec(sku: '116638', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '217648': VerifiedSpec(sku: '217648', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116640': VerifiedSpec(sku: '116640', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116175': VerifiedSpec(sku: '116175', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '196687': VerifiedSpec(sku: '196687', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── מאספים וקולטים ────────────────────────────────────────────────────────
  '196587': VerifiedSpec(sku: '196587', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── מחסומי רצפה ──────────────────────────────────────────────────────────
  '220542': VerifiedSpec(sku: '220542', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '220543': VerifiedSpec(sku: '220543', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '218681': VerifiedSpec(sku: '218681', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '218722': VerifiedSpec(sku: '218722', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116167': VerifiedSpec(sku: '116167', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116163': VerifiedSpec(sku: '116163', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '116146': VerifiedSpec(sku: '116146', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116169': VerifiedSpec(sku: '116169', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── מחסומים גלויים (Bottle Traps) ─────────────────────────────────────────
  '217861': VerifiedSpec(sku: '217861', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '213055': VerifiedSpec(sku: '213055', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '218553': VerifiedSpec(sku: '218553', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116632': VerifiedSpec(sku: '116632', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '213054': VerifiedSpec(sku: '213054', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116652': VerifiedSpec(sku: '116652', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116124': VerifiedSpec(sku: '116124', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116649': VerifiedSpec(sku: '116649', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '171190': VerifiedSpec(sku: '171190', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '209448': VerifiedSpec(sku: '209448', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '171189': VerifiedSpec(sku: '171189', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '218495': VerifiedSpec(sku: '218495', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116127': VerifiedSpec(sku: '116127', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '213056': VerifiedSpec(sku: '213056', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '217005': VerifiedSpec(sku: '217005', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '216984': VerifiedSpec(sku: '216984', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '172349': VerifiedSpec(sku: '172349', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '209447': VerifiedSpec(sku: '209447', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116144': VerifiedSpec(sku: '116144', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '217004': VerifiedSpec(sku: '217004', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '213057': VerifiedSpec(sku: '213057', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '610949': VerifiedSpec(sku: '610949', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '611045': VerifiedSpec(sku: '611045', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '193420': VerifiedSpec(sku: '193420', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '645971': VerifiedSpec(sku: '645971', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '217675': VerifiedSpec(sku: '217675', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '172033': VerifiedSpec(sku: '172033', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '178700': VerifiedSpec(sku: '178700', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '645975': VerifiedSpec(sku: '645975', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '615301': VerifiedSpec(sku: '615301', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '612812': VerifiedSpec(sku: '612812', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116233': VerifiedSpec(sku: '116233', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116635': VerifiedSpec(sku: '116635', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '116178': VerifiedSpec(sku: '116178', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '187700': VerifiedSpec(sku: '187700', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),

  // ── סיפונים (Siphons) ──────────────────────────────────────────────────────
  '77771610': VerifiedSpec(sku: '77771610', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '77771012': VerifiedSpec(sku: '77771012', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '77003220': VerifiedSpec(sku: '77003220', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '77003221': VerifiedSpec(sku: '77003221', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '77771271': VerifiedSpec(sku: '77771271', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '77771040': VerifiedSpec(sku: '77771040', material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),

  // ── תעלות ניקוז (Drain Channels) ───────────────────────────────────────────
  '77575305': VerifiedSpec(sku: '77575305', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '77575310': VerifiedSpec(sku: '77575310', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '77575315': VerifiedSpec(sku: '77575315', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '77575320': VerifiedSpec(sku: '77575320', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '77575325': VerifiedSpec(sku: '77575325', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '77575335': VerifiedSpec(sku: '77575335', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '77575328': VerifiedSpec(sku: '77575328', material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '77575327': VerifiedSpec(sku: '77575327', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '77575329': VerifiedSpec(sku: '77575329', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '77575330': VerifiedSpec(sku: '77575330', material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── אביזרי תבריג (Threaded Drain Fittings) ─────────────────────────────────
  '997091':  VerifiedSpec(sku: '997091',  material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116565':  VerifiedSpec(sku: '116565',  material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50'), _c('50')]),

  // ── אביזרי שקע-תקע (Push-fit Drain Couplings) ─────────────────────────────
  '218051':  VerifiedSpec(sku: '218051',  material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),
  '115581':  VerifiedSpec(sku: '115581',  material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '116258':  VerifiedSpec(sku: '116258',  material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── פקקים וצינורות (Drain Plugs) ──────────────────────────────────────────
  '120311':  VerifiedSpec(sku: '120311',  material: 'PVC', maxTempC: 50, ends: [_c('40')]),

  // ── מחלקים (Manifolds — brass supply) ─────────────────────────────────────
  '76032202': VerifiedSpec(sku: '76032202', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"')]),
  '76032203': VerifiedSpec(sku: '76032203', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  '76032204': VerifiedSpec(sku: '76032204', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  '7608202B': VerifiedSpec(sku: '7608202B', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('1/2"'), _bf('1/2"')]),
  '7609202B': VerifiedSpec(sku: '7609202B', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"')]),
  '7609202R': VerifiedSpec(sku: '7609202R', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"')]),
  '7609203B': VerifiedSpec(sku: '7609203B', material: _brass, maxTempC: 90,
      ends: [_bf('1"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  '7609203R': VerifiedSpec(sku: '7609203R', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('1/2"'), _bf('1/2"')]),
  '77603202': VerifiedSpec(sku: '77603202', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('1/2"'), _bf('1/2"')]),
  '77603203': VerifiedSpec(sku: '77603203', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),
  '77603204': VerifiedSpec(sku: '77603204', material: _brass, maxTempC: 90,
      ends: [_bf('3/4"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"'), _bf('1/2"')]),

  // ── ראשי מקלחת (Shower Heads — BSP F inlet) ───────────────────────────────
  '7777708G': VerifiedSpec(sku: '7777708G', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777707B': VerifiedSpec(sku: '7777707B', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777708B': VerifiedSpec(sku: '7777708B', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777710C': VerifiedSpec(sku: '7777710C', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777711C': VerifiedSpec(sku: '7777711C', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777707C': VerifiedSpec(sku: '7777707C', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '7777708C': VerifiedSpec(sku: '7777708C', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701199': VerifiedSpec(sku: '77701199', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701170': VerifiedSpec(sku: '77701170', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701165': VerifiedSpec(sku: '77701165', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701166': VerifiedSpec(sku: '77701166', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),

  // ── זרועות דוש (Shower Arms — BSP M×M) ───────────────────────────────────
  '77701189': VerifiedSpec(sku: '77701189', material: _brass, maxTempC: 90, ends: [_bm('1/2"'), _bm('1/2"')]),
  '77701190': VerifiedSpec(sku: '77701190', material: _brass, maxTempC: 90, ends: [_bm('1/2"'), _bm('1/2"')]),
  '77701191': VerifiedSpec(sku: '77701191', material: _brass, maxTempC: 90, ends: [_bm('1/2"'), _bm('1/2"')]),
  '77701192': VerifiedSpec(sku: '77701192', material: _brass, maxTempC: 90, ends: [_bm('1/2"'), _bm('1/2"')]),
  '77701193': VerifiedSpec(sku: '77701193', material: _brass, maxTempC: 90, ends: [_bm('1/2"'), _bm('1/2"')]),

  // ── מזלפי יד (Hand Sprayers — BSP F inlet) ────────────────────────────────
  '77701204': VerifiedSpec(sku: '77701204', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701205': VerifiedSpec(sku: '77701205', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701135': VerifiedSpec(sku: '77701135', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701125': VerifiedSpec(sku: '77701125', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701140': VerifiedSpec(sku: '77701140', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701203': VerifiedSpec(sku: '77701203', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701195': VerifiedSpec(sku: '77701195', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701130': VerifiedSpec(sku: '77701130', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701150': VerifiedSpec(sku: '77701150', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701179': VerifiedSpec(sku: '77701179', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701112': VerifiedSpec(sku: '77701112', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701197': VerifiedSpec(sku: '77701197', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701198': VerifiedSpec(sku: '77701198', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),
  '77701177': VerifiedSpec(sku: '77701177', material: _brass, maxTempC: 90, ends: [_bf('1/2"')]),

  // ── צינורות מקלחת (Shower Hoses — F×F) ────────────────────────────────────
  '77701155': VerifiedSpec(sku: '77701155', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77701160': VerifiedSpec(sku: '77701160', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77701196': VerifiedSpec(sku: '77701196', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77701113': VerifiedSpec(sku: '77701113', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77701114': VerifiedSpec(sku: '77701114', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),

  // ── צינורות גמישים (Flexible Supply Hoses) ────────────────────────────────
  '77381040': VerifiedSpec(sku: '77381040', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77381050': VerifiedSpec(sku: '77381050', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77381060': VerifiedSpec(sku: '77381060', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77121240': VerifiedSpec(sku: '77121240', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77121250': VerifiedSpec(sku: '77121250', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77121260': VerifiedSpec(sku: '77121260', material: _brass, maxTempC: 90, ends: [_bf('1/2"'), _bf('1/2"')]),
  '77383815': VerifiedSpec(sku: '77383815', material: _brass, maxTempC: 90, ends: [_bf('3/8"'), _bf('3/8"')]),
  '77383820': VerifiedSpec(sku: '77383820', material: _brass, maxTempC: 90, ends: [_bf('3/8"'), _bf('3/8"')]),
  '77383825': VerifiedSpec(sku: '77383825', material: _brass, maxTempC: 90, ends: [_bf('3/8"'), _bf('3/8"')]),
  '77383830': VerifiedSpec(sku: '77383830', material: _brass, maxTempC: 90, ends: [_bf('3/8"'), _bf('3/8"')]),
  '77383840': VerifiedSpec(sku: '77383840', material: _brass, maxTempC: 90, ends: [_bf('3/8"'), _bf('3/8"')]),
  // Flexible drain/jacuzzi pipes
  '1053232':  VerifiedSpec(sku: '1053232',  material: 'PVC', maxTempC: 50, ends: [_c('32'), _c('32')]),
  '1054040':  VerifiedSpec(sku: '1054040',  material: 'PVC', maxTempC: 50, ends: [_c('40'), _c('40')]),
  '1054050':  VerifiedSpec(sku: '1054050',  material: 'PVC', maxTempC: 50, ends: [_c('50'), _c('50')]),

  // ── אל חזור ביוב (Drain Backflow Preventers) ──────────────────────────────
  '777D0481': VerifiedSpec(sku: '777D0481', material: 'PVC', maxTempC: 50, ends: [_c('75'), _c('75')]),
  '777D0482': VerifiedSpec(sku: '777D0482', material: 'PVC', maxTempC: 50, ends: [_c('110'), _c('110')]),
  '777D0484': VerifiedSpec(sku: '777D0484', material: 'PVC', maxTempC: 50, ends: [_c('160'), _c('160')]),
};
