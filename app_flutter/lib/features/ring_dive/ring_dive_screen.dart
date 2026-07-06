/// RingDive (צלילת-טבעות / Pro-X-Light) — the rotary product-finder surface
/// (owner design handoff, 6/7). ONE wheel, phase-driven: `root` (the 9 search
/// styles) → `find` (one clean axis per turn over the REAL catalog) → product
/// leaves → quantity → cart. The wheel renders the CLEAN taxonomy/attribute
/// axes derived by `ring_dive_catalog` (dept·cat·type·size·angle·color·material·
/// brand) — NOT the old word-cloud. Zero engine change.
///
/// GATED on `kRingDiveFlag` (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true`. OFF by default → `SizedBox.shrink()` →
/// byte-identical.
///
/// RD-V2 (this): the Pro-X-Light SCREEN CHROME — a 392px phone card (warm bg,
/// gradient border, corner brackets, static scan-line), the RINGDIVE·OS status
/// bar, the 56px count block (count · readout · status line), the "סנן לפי"
/// axis-switcher chip strip, numbered breadcrumb chips, and the results rail
/// (NO price — the catalog has none). The wheel + hub + sheets are reused. The
/// qty dual-ring (RD-D), compat/job modes (RD-E) and motion polish + JetBrains
/// Mono font (RD-G/V4) come later. See BUILD-PLAN.md.
library;

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/smart_tree.dart'
    show SmartBrand, SmartProduct, kSmartProducts, smartProductForSku;
import 'package:buildsmart/features/ring_dive/ring_dive_catalog.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_qty.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart';
import 'package:buildsmart/logic/install_engine.dart' show compatibleWith;
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── design tokens (Pro-X-Light) ──────────────────────────────────────────────
const Color _kInk = Color(0xFF1C2230);
const Color _kOrange = Color(0xFFFF7A18);
const Color _kOrangeDeep = Color(0xFFE8690B);
const Color _kMuted = Color(0xFF9AA0AC);
const Color _kSub = Color(0xFF6B7280);
const Color _kMonoTag = Color(0xFF9A8F82);

/// The monospace face (JetBrains Mono is bundled in RD-V4; fall back for now).
const String _kMono = 'monospace';

/// Colour-name → swatch (the design's `dots` map), for the result cards.
const Map<String, Color> _dotColors = <String, Color>{
  'לבן': Color(0xFFF4F4F0),
  'שחור מט': Color(0xFF2A2A2A),
  'שחור': Color(0xFF1A1A1A),
  'פרגמון': Color(0xFFEAD9B0),
  'אפור': Color(0xFF9AA0A6),
  'ניקל מוברש': Color(0xFFC7CBCE),
  'ניקל': Color(0xFFB9C0C6),
  'כרום': Color(0xFFC6CDD3),
  'נחושת': Color(0xFFC67B3D),
  'ירוק': Color(0xFF3E8E5A),
  'כחול': Color(0xFF2C6FB0),
  'קרמיקה': Color(0xFFF4F4F0),
};

/// The 9 root search styles (emoji + label + axis key). The first 8 enter `find`
/// with that axis active; `job` is the kit flow (RD-E — a placeholder for now).
const List<({String key, String emoji, String label})> _styles =
    <({String key, String emoji, String label})>[
  (key: 'dept', emoji: '🗂️', label: 'מחלקה'),
  (key: 'cat', emoji: '📁', label: 'קטגוריה'),
  (key: 'type', emoji: '🔧', label: 'סוג'),
  (key: 'size', emoji: '📏', label: 'גודל'),
  (key: 'angle', emoji: '📐', label: 'זווית'),
  (key: 'color', emoji: '🎨', label: 'צבע'),
  (key: 'material', emoji: '⚙️', label: 'חומר'),
  (key: 'brand', emoji: '🏷️', label: 'מותג'),
  (key: 'job', emoji: '🧩', label: 'לפי עבודה'),
];

/// The RingDive surface. Renders nothing until `kRingDiveFlag` is enabled.
class RingDiveScreen extends ConsumerStatefulWidget {
  const RingDiveScreen({super.key});

  @override
  ConsumerState<RingDiveScreen> createState() => _RingDiveScreenState();
}

class _RingDiveScreenState extends ConsumerState<RingDiveScreen> {
  /// 'root' — pick a search style · 'find' — drill the axes · 'job' — placeholder.
  String _mode = 'root';

  /// The chosen constraints so far, in order (the breadcrumb).
  final List<({String field, String value})> _path =
      <({String field, String value})>[];

  /// The active axis in `find` mode (the wheel shows its options).
  String? _axisField;

  /// The product leaves under the current constraints — refreshed by [build]
  /// each frame and indexed by the wheel's focus on tap. Selecting reads this
  /// live field (not a closure-captured local), so a tap always resolves
  /// against the current constraint set, never a stale snapshot from a prior
  /// dive/back.
  List<RdProduct> _leaves = const <RdProduct>[];

  /// The landed product (→ the quantity phase) and its chosen quantity.
  LipskeyCatalogProduct? _product;
  int? _qty;
  bool _added = false;

  /// The anchor for `compat` mode (its real connectable partners fill the
  /// wheel), and the live partner list indexed by the wheel's focus on tap.
  LipskeyCatalogProduct? _origin;
  List<LipskeyCatalogProduct> _compatLeaves = const <LipskeyCatalogProduct>[];

  /// `job` mode: the chosen recipe key (null = the recipe list is on the wheel),
  /// the chosen model within it (defaults to the recommended brand), and whether
  /// its kit has been added.
  String? _jobKey;
  SmartBrand? _kitBrand;
  bool _kitAdded = false;

  /// The live 0–99 quantity from the dual-ring, shown on the confirm bar. Kept
  /// off `setState` so a qty drag rebuilds only the ring + the confirm label,
  /// not the whole card.
  final ValueNotifier<int> _qtyLive = ValueNotifier<int>(1);

  @override
  void dispose() {
    _qtyLive.dispose();
    super.dispose();
  }

  /// The path as a constraint map for the derivation layer.
  RdCons get _cons =>
      <String, String>{for (final s in _path) s.field: s.value};

  bool get _hasSelection => _mode != 'root';

  void _enterStyle(String axis) {
    // 'job' is not a real axis in `kRdAxes`; it enters the real recipe/kit mode
    // (kSmartProducts) instead of drilling — routing it to `find` would silently
    // fall back to the first axis (dept) and mislead the user.
    final validAxis = kRdAxes.contains(axis);
    setState(() {
      _mode = validAxis ? 'find' : 'job';
      _axisField = validAxis ? axis : null;
      _path.clear();
      _origin = null;
      _product = null;
      _qty = null;
      _added = false;
      _jobKey = null;
      _kitBrand = null;
      _kitAdded = false;
    });
  }

  void _dive(String field, String value) {
    setState(() {
      _path.add((field: field, value: value));
      final axes = rdFindAxes(_cons);
      _axisField = axes.isNotEmpty ? axes.first : null;
    });
  }

  /// Jump the active axis to [field] (the "סנן לפי" switcher) without diving.
  void _switchAxis(String field) {
    HapticFeedback.selectionClick();
    setState(() => _axisField = field);
  }

  void _pickProduct(LipskeyCatalogProduct p) {
    _qtyLive.value = 1;
    setState(() => _product = p);
  }

  void _backTo(int level) {
    setState(() {
      _path.removeRange(level, _path.length);
      _product = null;
      _qty = null;
      _added = false;
      final axes = rdFindAxes(_cons);
      _axisField = axes.isNotEmpty ? axes.first : null;
    });
  }

  void _reset() {
    setState(() {
      _mode = 'root';
      _path.clear();
      _axisField = null;
      _origin = null;
      _product = null;
      _qty = null;
      _added = false;
      _jobKey = null;
      _kitBrand = null;
      _kitAdded = false;
    });
  }

  // ── job / kit mode (the REAL smart_tree recipes) ───────────────────────────

  SmartProduct _jobByKey(String key) =>
      kSmartProducts.firstWhere((j) => j.key == key);

  void _pickJob(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      _jobKey = key;
      _kitBrand = _jobByKey(key).recBrand;
      _kitAdded = false;
    });
  }

  void _pickBrand(SmartBrand b) {
    HapticFeedback.selectionClick();
    setState(() => _kitBrand = b);
  }

  void _addKit() {
    HapticFeedback.mediumImpact();
    setState(() => _kitAdded = true);
  }

  void _backToJobList() {
    setState(() {
      _jobKey = null;
      _kitBrand = null;
      _kitAdded = false;
    });
  }

  /// From the done phase — jump to the recipe that lists this product as a
  /// model (the real reverse index); if none, land on the recipe list.
  void _enterJobFrom(LipskeyCatalogProduct p) {
    final job = smartProductForSku(p.sku);
    HapticFeedback.selectionClick();
    setState(() {
      _mode = 'job';
      _jobKey = job?.key;
      _kitBrand = job?.recBrand;
      _kitAdded = false;
      _path.clear();
      _axisField = null;
      _origin = null;
      _product = null;
      _qty = null;
      _added = false;
    });
  }

  /// Enter `compat` mode — the real "what connects to this product" list, from
  /// the verified-connections engine, fills the wheel.
  void _enterCompat(LipskeyCatalogProduct p) {
    HapticFeedback.selectionClick();
    setState(() {
      _mode = 'compat';
      _origin = p;
      _path.clear();
      _axisField = null;
      _product = null;
      _qty = null;
      _added = false;
    });
  }

  /// A short rim label for a product (type + size), falling back to its name.
  String _short(LipskeyCatalogProduct p) {
    final axes = RdProduct(p).axes;
    final parts = <String>[
      if (axes['type']?.isNotEmpty ?? false) axes['type']!.first,
      if (axes['size']?.isNotEmpty ?? false) axes['size']!.first,
    ];
    return parts.isEmpty ? p.nameHe : parts.join(' ');
  }

  void _confirmQty(int v) {
    if (v < 1) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _qty = v;
      _added = true;
    });
  }

  void _cancelQty() {
    setState(() => _product = null);
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(featureFlagsProvider).contains(kRingDiveFlag);
    if (!on) return const SizedBox.shrink();

    // ── the wheel content + the chrome read-outs for the current phase ──
    final labels = <String>[];
    final sublabels = <String>[];
    var hubHint = 'סובב · הקש לבחור';
    void Function(int)? onSelect;
    var footer = const <LipskeyCatalogProduct>[];
    var qtyChoosing = false;

    var count = 0;
    var readout = 'מוצרים';
    var statusLine = '';
    var axisFields = const <String>[];
    String? activeField;

    if (_product != null) {
      final p = _product!;
      if (_qty == null) {
        // ── quantity: the dual number-ring (RingDiveQty) drives this phase ──
        qtyChoosing = true;
      } else {
        // ── done: the chosen product rests in the hub ──
        labels.add(p.nameHe);
        sublabels.add('כמות $_qty');
        hubHint = _added ? 'נוסף לסל ✓' : 'הוסף לסל למטה';
      }
    } else if (_mode == 'root') {
      // ── root: the 9 search styles ──
      for (final s in _styles) {
        labels.add('${s.emoji} ${s.label}');
        sublabels.add('התחל מ');
      }
      hubHint = 'בחר איך לחפש';
      count = rdPool.length;
      statusLine = 'בחר איך למצוא את המוצר הראשון';
      onSelect = (i) {
        if (i >= 0 && i < _styles.length) _enterStyle(_styles[i].key);
      };
    } else if (_mode == 'job') {
      // ── job (RD-E2): the REAL smart_tree recipes (kSmartProducts) ──
      if (_jobKey == null) {
        // the recipe list fills the wheel.
        count = kSmartProducts.length;
        readout = 'עבודות';
        statusLine = 'בחר עבודה — נרכיב ערכה שלמה';
        hubHint = 'בחר עבודה';
        for (final j in kSmartProducts) {
          labels.add('${j.emoji} ${j.name}');
          sublabels.add('עבודה');
        }
        onSelect = (i) {
          if (i >= 0 && i < kSmartProducts.length) {
            _pickJob(kSmartProducts[i].key);
          }
        };
      } else {
        final job = _jobByKey(_jobKey!);
        count = job.acc.length;
        readout = 'רכיבים';
        if (_kitAdded) {
          labels.add(job.name);
          sublabels.add('ערכה');
          hubHint = 'הערכה נוספה ✓';
          statusLine = 'הערכה נוספה — חיפוש חדש?';
        } else {
          // the models (brands) fill the wheel; the acc components sit below.
          statusLine = 'ערכה ל${job.name} — בחר דגם והוסף';
          hubHint = 'בחר דגם';
          for (final b in job.brands) {
            labels.add(b.name);
            sublabels.add('דגם');
          }
          onSelect = (i) {
            if (i >= 0 && i < job.brands.length) _pickBrand(job.brands[i]);
          };
        }
      }
    } else if (_mode == 'compat') {
      // ── compat: the REAL "what connects" list (verified-connections) ──
      final partners = _origin == null
          ? const <LipskeyCatalogProduct>[]
          : compatibleWith(_origin!);
      _compatLeaves = partners;
      count = partners.length;
      readout = 'תואמים';
      statusLine = partners.isEmpty
          ? 'אין מוצרים תואמים'
          : 'מה מתחבר ל${_origin!.nameHe}';
      hubHint = 'הקש להוספה';
      for (final p in partners.take(12)) {
        labels.add(_short(p));
        sublabels.add('תואם');
      }
      onSelect = (i) {
        if (i >= 0 && i < _compatLeaves.length && i < 12) {
          _pickProduct(_compatLeaves[i]);
        }
      };
      footer = partners.take(10).toList(growable: false);
    } else {
      // ── find: one clean axis at a time, then product leaves ──
      final cons = _cons;
      // Filter the ~1948-product pool ONCE per frame and reuse the narrowed set
      // as the pool for the axis + option queries (idempotent — every product
      // in `matched` already satisfies `cons`) so we don't re-scan three times.
      final matched = rdMatching(cons);
      final axes = rdFindAxes(cons, matched);
      count = matched.length;
      readout = 'מועמדים';
      if (axes.isEmpty) {
        // Store the live leaves in a field; the tap handler indexes THIS field,
        // so a select always resolves against the current constraint set.
        _leaves = matched;
        labels.addAll(matched.map((rp) => rp.name));
        sublabels.addAll(matched.map((_) => 'בחר מוצר'));
        hubHint = 'הקש לבחור מוצר';
        statusLine = 'בחר מוצר · הקש על השם';
        onSelect = (i) {
          if (i >= 0 && i < _leaves.length) _pickProduct(_leaves[i].product);
        };
      } else {
        _leaves = const <RdProduct>[];
        final field = (_axisField != null && axes.contains(_axisField))
            ? _axisField!
            : axes.first;
        final opts = rdOptsFor(field, cons, matched);
        final label = kRdAxisLabel[field] ?? '';
        labels.addAll(opts);
        sublabels.addAll(opts.map((_) => label));
        axisFields = axes;
        activeField = field;
        statusLine = axes.length > 1
            ? 'בחר $label · או החלף סינון למעלה'
            : 'בחר $label · סובב את הגלגל';
        onSelect = (i) {
          if (i >= 0 && i < opts.length) _dive(field, opts[i]);
        };
        footer =
            matched.take(10).map((rp) => rp.product).toList(growable: false);
      }
    }

    final kitPhase = _mode == 'job' && _jobKey != null && !_kitAdded;
    final kitDone = _mode == 'job' && _jobKey != null && _kitAdded;
    final kitJob = kitPhase ? _jobByKey(_jobKey!) : null;

    final inFind = _product == null;
    final Widget wheelChild = qtyChoosing
        ? RingDiveQty(
            initial: _qtyLive.value,
            lockedCount: _path.length,
            onChanged: (v) => _qtyLive.value = v,
          )
        : RingDiveWheel(
            labels: labels,
            sublabels: sublabels,
            hubHint: hubHint,
            lockedCount: _path.length,
            onSelect: onSelect,
          );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.1),
            radius: 1.25,
            colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8F2EA), Color(0xFFEFE6DB)],
            stops: <double>[0, 0.45, 1],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
            child: _phoneCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statusBar(),
                  if (inFind) _countBlock(count, readout, statusLine),
                  if (inFind && axisFields.length > 1)
                    _axisStrip(axisFields, activeField),
                  if (inFind && _path.isNotEmpty) _breadcrumbStrip(),
                  if (_mode == 'job' && _jobKey != null) _jobCrumb(),
                  _wheelArea(wheelChild),
                  if (qtyChoosing) _qtyConfirmBar(),
                  if (_product != null && _qty != null) _cartBar(),
                  if (kitJob != null) _kitStrip(kitJob),
                  if (kitJob != null) _kitAddBar(kitJob),
                  if (kitDone) _kitDoneBar(),
                  if (inFind && footer.isNotEmpty)
                    _resultsRail(footer, count),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── the phone card shell (gradient border · brackets · scan-line) ──────────

  Widget _phoneCard({required Widget child}) {
    return Container(
      width: 392,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            Color(0xB3FF7A18),
            Color(0x80D2C8BC),
            Color(0xB3FFFFFF),
            Color(0x66FF7A18),
          ],
          stops: <double>[0, 0.32, 0.6, 1],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x73785A2D),
            blurRadius: 80,
            spreadRadius: -30,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFFFFFFFF),
                Color(0xFFFDFBF8),
                Color(0xFFFAF5EF),
              ],
              stops: <double>[0, 0.6, 1],
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 744),
            child: Stack(
              children: [
                // the scan-line accent (static for RD-V2; animated in RD-G)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 36,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x1FFF7A18), Color(0x00FF7A18)],
                      ),
                    ),
                  ),
                ),
                child,
                ..._cornerBrackets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _cornerBrackets() {
    const orange = Color(0xB3FF7A18);
    const grey = Color(0x59786E64);
    Widget bracket({required bool top, required bool right, required Color c}) {
      return Positioned(
        top: top ? 14 : null,
        bottom: top ? null : 14,
        right: right ? 14 : null,
        left: right ? null : 14,
        child: IgnorePointer(
          child: Container(
            width: 22,
            height: 22,
            foregroundDecoration: BoxDecoration(
              border: Border(
                top: top ? BorderSide(color: c, width: 2) : BorderSide.none,
                bottom: top ? BorderSide.none : BorderSide(color: c, width: 2),
                right: right ? BorderSide(color: c, width: 2) : BorderSide.none,
                left: right ? BorderSide.none : BorderSide(color: c, width: 2),
              ),
            ),
          ),
        ),
      );
    }

    return <Widget>[
      bracket(top: true, right: true, c: orange),
      bracket(top: true, right: false, c: grey),
      bracket(top: false, right: true, c: grey),
      bracket(top: false, right: false, c: orange),
    ];
  }

  // ── status bar (RINGDIVE·OS + reset) ───────────────────────────────────────

  Widget _statusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kOrange,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x99FF7A18),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'RINGDIVE·OS',
                style: TextStyle(
                  fontFamily: _kMono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFF3A4150),
                ),
              ),
            ],
          ),
          Opacity(
            opacity: _hasSelection ? 1 : 0,
            child: GestureDetector(
              onTap: _hasSelection ? _reset : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x0A000000),
                  border: Border.all(color: const Color(0x17000000)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '↺ מחדש',
                  style: TextStyle(
                    fontFamily: _kMono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: _kSub,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── the 56px count block ───────────────────────────────────────────────────

  Widget _countBlock(int count, String readout, String statusLine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontFamily: _kMono,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 0.9,
                  letterSpacing: -2,
                  color: _kInk,
                  shadows: <Shadow>[
                    Shadow(color: Color(0x38FF7A18), blurRadius: 14, offset: Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  readout,
                  style: const TextStyle(
                    fontFamily: _kMono,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: _kMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            statusLine,
            style: const TextStyle(
              fontFamily: 'Heebo',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _kSub,
            ),
          ),
        ],
      ),
    );
  }

  // ── "סנן לפי" axis switcher ─────────────────────────────────────────────────

  Widget _axisStrip(List<String> fields, String? active) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            const Text(
              'סנן לפי',
              style: TextStyle(
                fontFamily: _kMono,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _kMonoTag,
              ),
            ),
            const SizedBox(width: 7),
            for (final f in fields) _axisChip(f, f == active),
          ],
        ),
      ),
    );
  }

  Widget _axisChip(String field, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: GestureDetector(
        onTap: active ? null : () => _switchAxis(field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFF9A3F), Color(0xFFF0710C)],
                  )
                : null,
            color: active ? null : const Color(0x14FF7A18),
            border: Border.all(
              color: active ? _kOrangeDeep : const Color(0x4DFF7A18),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            kRdAxisLabel[field] ?? field,
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? const Color(0xFF3A1600) : const Color(0xFFB54708),
            ),
          ),
        ),
      ),
    );
  }

  // ── numbered breadcrumb chips ──────────────────────────────────────────────

  Widget _breadcrumbStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (var i = 0; i < _path.length; i++)
            _crumb(i + 1, kRdAxisLabel[_path[i].field] ?? '', _path[i].value,
                () => _backTo(i)),
        ],
      ),
    );
  }

  Widget _crumb(int n, String axis, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x1AFF7A18),
          border: Border.all(color: const Color(0x52FF7A18)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$n· $axis ✎',
              style: const TextStyle(
                fontFamily: _kMono,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: _kMonoTag,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Heebo',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── the wheel area (dial + commit marker) ──────────────────────────────────

  Widget _wheelArea(Widget child) {
    return SizedBox(
      height: 360,
      child: Center(
        child: SizedBox(
          width: 340,
          height: 340,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              child,
              const Positioned(
                top: 0,
                child: IgnorePointer(
                  child: Text(
                    '▲',
                    style: TextStyle(fontSize: 13, color: _kOrange),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── qty confirm bar (dual-ring live) + done cart bar ───────────────────────

  Widget _qtyConfirmBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancelQty,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0x0D000000),
                border: Border.all(color: const Color(0x1F000000)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'ביטול',
                style: TextStyle(
                  fontFamily: 'Heebo',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A6270),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _qtyLive,
              builder: (context, v, _) => GestureDetector(
                onTap: () => _confirmQty(v),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFFF9A3F), Color(0xFFF0710C)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'הוסף לסל · × $v',
                    style: const TextStyle(
                      fontFamily: 'Heebo',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A0D02),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartBar() {
    final p = _product;
    final canCompat = p != null && compatibleWith(p).isNotEmpty;
    final canJob = p != null && smartProductForSku(p.sku) != null;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '✓ נוסף לסל · מה עכשיו?',
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3E8E5A),
            ),
          ),
          Text(
            '$_qty יחידות',
            style: const TextStyle(
              fontFamily: 'Heebo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kMonoTag,
            ),
          ),
          const SizedBox(height: 12),
          if (canJob) ...[
            SizedBox(
              width: 240,
              child: _pillButton(
                '🧩 השלם ערכה',
                const Color(0xFF3A4D80),
                () => _enterJobFrom(p),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (canCompat) ...[
            SizedBox(
              width: 240,
              child: _pillButton(
                '🔗 מה מתחבר לזה',
                const Color(0xFFB54708),
                () => _enterCompat(p),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: 240,
            child: _pillButton('חיפוש חדש', _kInk, _reset),
          ),
        ],
      ),
    );
  }

  // ── job / kit widgets (breadcrumb · components strip · add · done) ──────────

  Widget _jobCrumb() {
    final job = _jobByKey(_jobKey!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _backToJobList,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x1AFF7A18),
              border: Border.all(color: const Color(0x52FF7A18)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'עבודה ✎',
                  style: TextStyle(
                    fontFamily: _kMono,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: _kMonoTag,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${job.emoji} ${job.name}',
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kitStrip(SmartProduct job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0F000000))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            child: Text(
              'רכיבי הערכה · ${job.acc.length}',
              style: const TextStyle(
                fontFamily: _kMono,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: _kMonoTag,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  for (final a in job.acc) _accChip(a.emoji, a.name, must: a.must),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accChip(String emoji, String name, {required bool must}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: must ? const Color(0x14FF7A18) : const Color(0x08000000),
          border: Border.all(
            color: must ? const Color(0x40FF7A18) : const Color(0x14000000),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Heebo',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: must ? const Color(0xFFB54708) : _kSub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kitAddBar(SmartProduct job) {
    final brand = _kitBrand ?? job.recBrand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'דגם נבחר · ${brand.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Heebo',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _kSub,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _pillButton('🧩 הוסף ערכה לסל', _kOrange, _addKit),
          ),
        ],
      ),
    );
  }

  Widget _kitDoneBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '✓ הערכה נוספה לסל',
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3E8E5A),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: _pillButton('חיפוש חדש', _kInk, _reset),
          ),
        ],
      ),
    );
  }

  // ── results rail + product sheet (NO price — owner-locked) ──────────────────

  Widget _resultsRail(List<LipskeyCatalogProduct> products, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0F000000))),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x08FF7A18), Color(0x00FF7A18)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'מועמדים',
                  style: TextStyle(
                    fontFamily: _kMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: _kMonoTag,
                  ),
                ),
                Text(
                  '$total ▸',
                  style: const TextStyle(
                    fontFamily: _kMono,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kOrangeDeep,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 96,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final p in products) _railCard(p)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _railCard(LipskeyCatalogProduct p) {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: GestureDetector(
        onTap: () => _openSheet(p),
        child: Container(
          width: 158,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFBF8F4)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x12000000)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -13,
                right: -13,
                bottom: -13,
                child: Container(
                  width: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[_kOrange, Color(0x00FF7A18)],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _dotColors[p.color] ?? const Color(0xFFB7B0A5),
                          border: Border.all(color: const Color(0x26000000)),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          p.brand,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _kMono,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: _kMonoTag,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      p.nameHe,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Heebo',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Color(0xFF2A303C),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet(LipskeyCatalogProduct p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetCtx) => _sheetContent(sheetCtx, p),
    );
  }

  Widget _sheetContent(BuildContext sheetCtx, LipskeyCatalogProduct p) {
    final specs = <MapEntry<String, String>>[
      if (p.categoryHe.isNotEmpty) MapEntry('קטגוריה', p.categoryHe),
      if (p.color != null) MapEntry('צבע', p.color!),
      for (final e in (p.dims ?? const <String, dynamic>{}).entries)
        MapEntry(e.key, '${e.value}'),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E1D8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[p.color] ?? const Color(0xFFB7B0A5),
                    border: Border.all(color: const Color(0x24000000)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  p.brand,
                  style: const TextStyle(
                    fontFamily: _kMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _kMonoTag,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              p.nameHe,
              style: const TextStyle(
                fontFamily: 'Heebo',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: _kInk,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [for (final s in specs) _specChip(s.key, s.value)],
            ),
            const SizedBox(height: 20),
            _pillButton('הוסף להזמנה', _kOrange, () {
              Navigator.of(sheetCtx).pop();
              _pickProduct(p);
            }),
          ],
        ),
      ),
    );
  }

  Widget _specChip(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1EA),
        border: Border.all(color: const Color(0xFFEBE5DB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$k · $v',
        style: const TextStyle(
          fontFamily: _kMono,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A505C),
        ),
      ),
    );
  }

  Widget _pillButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Heebo',
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
