import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── colors — exact match to _CatalogRow in catalog_screen.dart ───────────────
const _bg       = Color(0xFFFFFFFF);
const _surface  = Color(0xFFF5F5F5);   // avatar circle bg, search bar, chips
const _divider  = Color(0xFFF5F5F5);   // same as catalog divider
const _title    = Color(0xFF1A1A1A);   // exact match: TextStyle(color: Color(0xFF1A1A1A))
const _sub      = Color(0xFF888888);   // exact match: TextStyle(color: Color(0xFF888888))
const _brand    = BsTokens.brand;      // orange

// ── puzzle clipper ────────────────────────────────────────────────────────────

const double _d = 14.0;  // depth of tab / notch
const double _s = 28.0;  // span width of tab / notch
const double _r = 5.0;   // corner radius

class _PuzzleClipper extends CustomClipper<Path> {
  const _PuzzleClipper({this.notchBottom = false, this.tabTop = false});
  final bool notchBottom;
  final bool tabTop;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final mw = w / 2;

    final path = Path();

    // ── Top-left rounded corner ───────────────────────────────────────────────
    path.moveTo(_r, 0);

    if (tabTop) {
      // Left segment of top edge → tab start
      path.lineTo(mw - _s / 2, 0);
      // Tab: convex bump going DOWN (stays inside bounds)
      path.cubicTo(
        mw - _s / 2, _d,
        mw - _s / 6, _d,
        mw, _d,
      );
      path.cubicTo(
        mw + _s / 6, _d,
        mw + _s / 2, _d,
        mw + _s / 2, 0,
      );
      // Right segment of top edge → top-right corner
      path.lineTo(w - _r, 0);
    } else {
      path.lineTo(w - _r, 0);
    }

    // ── Top-right rounded corner ──────────────────────────────────────────────
    path.quadraticBezierTo(w, 0, w, _r);

    // ── Right edge ────────────────────────────────────────────────────────────
    path.lineTo(w, h - _r);

    // ── Bottom-right rounded corner ───────────────────────────────────────────
    path.quadraticBezierTo(w, h, w - _r, h);

    if (notchBottom) {
      // Right segment of bottom edge → notch start (path goes right→left)
      path.lineTo(mw + _s / 2, h);
      // Notch: concave — curves UP inward
      path.cubicTo(
        mw + _s / 2, h - _d,
        mw + _s / 6, h - _d,
        mw, h - _d,
      );
      path.cubicTo(
        mw - _s / 6, h - _d,
        mw - _s / 2, h - _d,
        mw - _s / 2, h,
      );
      // Left segment of bottom edge → bottom-left corner
      path.lineTo(_r, h);
    } else {
      path.lineTo(_r, h);
    }

    // ── Bottom-left rounded corner ────────────────────────────────────────────
    path.quadraticBezierTo(0, h, 0, h - _r);

    // ── Left edge ─────────────────────────────────────────────────────────────
    path.lineTo(0, _r);

    // ── Top-left rounded corner ───────────────────────────────────────────────
    path.quadraticBezierTo(0, 0, _r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_PuzzleClipper old) =>
      old.notchBottom != notchBottom || old.tabTop != tabTop;
}

// ── puzzle box helper ─────────────────────────────────────────────────────────

Widget _puzzleBox(
  LipskeyCatalogProduct p, {
  bool notchBottom = false,
  bool tabTop = false,
}) {
  Widget child;
  if (p.imageAsset != null) {
    child = Image.asset(
      p.imageAsset!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Text(p.typeEmoji, style: const TextStyle(fontSize: 24)),
    );
  } else {
    child = Text(p.typeEmoji, style: const TextStyle(fontSize: 24));
  }

  return SizedBox(
    width: 50,
    height: 50,
    child: ClipPath(
      clipper: _PuzzleClipper(notchBottom: notchBottom, tabTop: tabTop),
      child: Container(
        color: _surface,
        alignment: Alignment.center,
        child: child,
      ),
    ),
  );
}

// ── filter state ─────────────────────────────────────────────────────────────

final compatGenderProvider  = StateProvider<String>((_) => 'הכל');
final compatSizeProvider    = StateProvider<String>((_) => 'הכל');
final compatMethodProvider  = StateProvider<String>((_) => 'הכל');
final compatSearchProvider  = StateProvider<String>((_) => '');

// ── plumbing chain state ──────────────────────────────────────────────────────

final chainProvider = StateProvider<List<LipskeyCatalogProduct>>((_) => []);

// Operating temperature of the line being built (°C). Drives the material
// suitability check — at 80°C, HDPE (capped ~40°C) is flagged unsuitable.
final lineMaxTempProvider = StateProvider<int>((_) => 20);

// Installation accessories confirmed for the line (insulation / clips / seal).
// Tracked separately from the series chain since they wrap/support, not flow.
final lineAccessoriesProvider = StateProvider<Set<String>>((_) => {});

// ── material / temperature helpers ──────────────────────────────────────────────

/// Max service temperature of a product, or null if unknown (no verified spec).
double? productMaxTempC(LipskeyCatalogProduct p) => kVerifiedSpecs[p.sku]?.maxTempC;

/// Material label of a product (HDPE / PEX / נחושת / פליז …), or null.
String? productMaterial(LipskeyCatalogProduct p) => kVerifiedSpecs[p.sku]?.material;

/// True when the product's material can serve a line at [tempC]. Unknown → true
/// (don't flag the 400+ legacy catalogue items that carry no verified spec).
bool productSuitableForTemp(LipskeyCatalogProduct p, int tempC) {
  final t = productMaxTempC(p);
  return t == null || tempC <= t;
}

// ── line compliance / completeness ──────────────────────────────────────────────

class LineCheck {
  const LineCheck(this.label, this.satisfied, this.why);
  final String label;   // required component
  final bool satisfied; // present in the chain?
  final String why;     // why it's required
}

/// The physical join method between two mating products, derived from end types
/// — so each transition states exactly how it's connected (Press / PTFE / …).
String connectionMethodLabel(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA == null || vB == null) return '';
  for (final eA in vA.ends) {
    for (final eB in vB.ends) {
      if (eA.directMatesWith(eB)) {
        switch (eA.type) {
          case EndType.pexPress:    return 'Press / טבעת כיווץ';
          case EndType.copperPress: return 'Press / O-ring';
          case EndType.bspMale:
          case EndType.bspFemale:   return 'תבריג + PTFE';
          case EndType.hdpeCompression: return 'אום הידוק';
        }
      }
      if (eA.pipeSharedWith(eB)) return 'אום הידוק (compression)';
    }
  }
  return '';
}

/// Detects the safety/durability components a hot line requires and whether the
/// current chain includes them — turning expert review into an automatic gate.
List<LineCheck> lineComplianceChecklist(
    List<LipskeyCatalogProduct> chain, int tempC, Set<String> accessories) {
  final skus = chain.map((p) => p.sku).toSet();
  final mats = chain.map(productMaterial).whereType<String>().toSet();
  bool has(Set<String> ok) => skus.any(ok.contains);
  bool acc(String s) => accessories.contains(s);

  final hot    = tempC >= 60;
  final hasPex = mats.contains('PEX');
  final recirc = skus.contains('HW-PUMP-25') || skus.contains('HW-TEE-RECIRC');
  // Galvanic risk: copper joined to ANY other metal (brass/steel) — conservative.
  final metals = mats.where((m) => m == 'נחושת' || m == 'פליז' || m == 'פלדה');
  final dissimilar = mats.contains('נחושת') && metals.toSet().length >= 2;
  final isolationCount =
      chain.where((p) => p.sku == 'HW-BALL-1' || p.sku == 'HW-BALL-15').length;

  return [
    LineCheck(
        recirc ? 'ברז ניתוק ×2 (משאבה + מניפולד)' : 'ברז ניתוק לתחזוקה',
        recirc ? isolationCount >= 2 : isolationCount >= 1,
        'בידוד אזורי לתחזוקה'),
    if (recirc) ...[
      LineCheck('שסתום אל-חזור', has({'HW-CHECK-15'}), 'מונע זרימה הפוכה בלולאה'),
      LineCheck('שסתום מאזן / TRV', has({'HW-BALANCE-15'}), 'איזון הלולאה'),
      LineCheck('מפוח אוויר', has({'HW-AIRVENT'}), 'פליטת אוויר בלולאה'),
    ],
    if (dissimilar)
      LineCheck('רקורד דיאלקטרי', has({'HW-DIELECTRIC-15'}), 'הפרדה גלוונית בין מתכות'),
    if (hasPex)
      LineCheck('מפצה התפשטות PEX', has({'HW-EXP-COMP-20'}), 'PEX מתרחב בחום'),
    if (hot)
      LineCheck('שסתום פורק לחץ (PRV)', has({'HW-PRV-34'}), 'מערכת חמה סגורה'),
    if (hot)
      LineCheck('בידוד תרמי', acc('HW-INSUL'), 'הפסדי חום + סכנת כוויות'),
    LineCheck('חבקים/תמיכת צנרת', acc('HW-CLIP'), 'קיבוע ושיפוע'),
    LineCheck('איטום (Press/PTFE/O-ring)', acc('HW-SEALANT'), 'אטימות כל מעבר'),
  ];
}

/// Site reminders that remain advisory (not auto-trackable line-items).
List<String> lineInstallReminders() => const [
      'שיפוע לקטע אופקי ארוך',
      'נקודת בדיקה/גישה לתחזוקה',
    ];

// ── compatibility logic ───────────────────────────────────────────────────────

bool canConnect(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  if (a.sku == b.sku) return false;

  // Prefer verified specs — 100% accurate physical data.
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA != null && vB != null) return vA.compatibleWith(vB);

  // Fallback: name-inference (less reliable, no verified data for this pair).
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty || sA.intersection(sB).isEmpty) return false;

  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA == null || gB == null) return false;
  if (gA == gB) return false;

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) return false;

  return true;
}

// Returns a Hebrew explanation of WHY two products cannot connect.
String connectionFailReason(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];

  if (vA != null && vB != null) {
    // Both have verified specs — explain which ends are present and why none match.
    Set<String> sizes(VerifiedSpec s, EndType t) =>
        s.ends.where((e) => e.type == t).map((e) => e.size).toSet();
    final comprA = sizes(vA, EndType.hdpeCompression), comprB = sizes(vB, EndType.hdpeCompression);
    final pexA   = sizes(vA, EndType.pexPress),        pexB   = sizes(vB, EndType.pexPress);
    final cuA    = sizes(vA, EndType.copperPress),     cuB    = sizes(vB, EndType.copperPress);
    final bsmA   = sizes(vA, EndType.bspMale),         bsmB   = sizes(vB, EndType.bspMale);
    final bsfA   = sizes(vA, EndType.bspFemale),       bsfB   = sizes(vB, EndType.bspFemale);

    // Same press family, different size
    if (comprA.isNotEmpty && comprB.isNotEmpty && comprA.intersection(comprB).isEmpty) {
      return 'גודל שונה: DN${comprA.first} ↔ DN${comprB.first}';
    }
    if (pexA.isNotEmpty && pexB.isNotEmpty && pexA.intersection(pexB).isEmpty) {
      return 'גודל PEX שונה: ${pexA.first} ↔ ${pexB.first}';
    }
    if (cuA.isNotEmpty && cuB.isNotEmpty && cuA.intersection(cuB).isEmpty) {
      return 'גודל נחושת שונה: DN${cuA.first} ↔ DN${cuB.first}';
    }

    // Thread conflict: both male or both female (same size)
    if (bsmA.intersection(bsmB).isNotEmpty) {
      return 'שני קצוות זכר ${bsmA.intersection(bsmB).first}" — אין חיבור';
    }
    if (bsfA.intersection(bsfB).isNotEmpty) {
      return 'שני קצוות נקבה ${bsfA.intersection(bsfB).first}" — אין חיבור';
    }

    // Thread size mismatch (male↔female but different size)
    if (bsmA.isNotEmpty && bsfB.isNotEmpty && bsmA.intersection(bsfB).isEmpty) {
      return 'גודל תבריג שונה: ${bsmA.first}" ↔ ${bsfB.first}"';
    }
    if (bsfA.isNotEmpty && bsmB.isNotEmpty && bsfA.intersection(bsmB).isEmpty) {
      return 'גודל תבריג שונה: ${bsfA.first}" ↔ ${bsmB.first}"';
    }

    // Different material families with no shared end → needs a transition adapter
    final matA = vA.material, matB = vB.material;
    if (matA != matB) return 'נדרש מתאם מעבר: $matA ↔ $matB';

    return 'אין נקודת חיבור משותפת';
  }

  // Fallback: name-inference failure reasons
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty) return 'גודל חיבור לא ידוע';
  if (sA.intersection(sB).isEmpty) return 'גודל שונה: ${sA.first} ↔ ${sB.first}';

  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA == null || gB == null) return 'מין חיבור לא ידוע';
  if (gA == gB) {
    final label = gA == 'male' ? 'זכר' : 'נקבה';
    return 'שני קצוות $label — אין חיבור';
  }

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) {
    final lA = mA == 'thread' ? 'תבריג' : mA == 'glue' ? 'הדבקה' : 'אלקטרו';
    final lB = mB == 'thread' ? 'תבריג' : mB == 'glue' ? 'הדבקה' : 'אלקטרו';
    return 'שיטה שונה: $lA ↔ $lB';
  }

  return 'אין נקודת חיבור משותפת';
}

// Returns the shared DN string if the two products connect via a pipe segment,
// null if they connect directly (thread-to-thread) or are incompatible.
String? pipeConnectionDn(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA == null || vB == null) return null;
  for (final eA in vA.ends) {
    for (final eB in vB.ends) {
      if (eA.pipeSharedWith(eB)) return eA.size;
    }
  }
  return null;
}

List<LipskeyCatalogProduct> compatibleWith(LipskeyCatalogProduct anchor) =>
    kCompatCatalog.where((p) => canConnect(anchor, p)).toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1));

List<LipskeyCatalogProduct> _filtered(WidgetRef ref) {
  final g = ref.watch(compatGenderProvider);
  final s = ref.watch(compatSizeProvider);
  final m = ref.watch(compatMethodProvider);
  final q = ref.watch(compatSearchProvider).trim().toLowerCase();
  return kCompatCatalog.where((p) {
    if (g == 'זכר'    && p.connectionGender  != 'male')          return false;
    if (g == 'נקבה'   && p.connectionGender  != 'female')        return false;
    if (s != 'הכל'   && !p.connectionSizes.contains(s))          return false;
    if (m == 'תבריג'  && p.connectionMethod  != 'thread')        return false;
    if (m == 'הדבקה'  && p.connectionMethod  != 'glue')          return false;
    if (m == 'אלקטרו' && p.connectionMethod  != 'electrofusion') return false;
    if (q.isNotEmpty  && !p.nameHe.toLowerCase().contains(q) &&
        !p.brand.toLowerCase().contains(q)) return false;
    return true;
  }).toList();
}

// ── label helpers ─────────────────────────────────────────────────────────────

String _gLbl(String? g) => switch (g) {
  'male'   => '♂ זכר',
  'female' => '♀ נקבה',
  _        => '⟷',
};

Color _gColor(String? g) => switch (g) {
  'male'   => const Color(0xFF3B82F6),
  'female' => const Color(0xFFEC4899),
  _        => _sub,
};

String _mLbl(String? m) => switch (m) {
  'thread'        => '🔩 תבריג',
  'glue'          => '💧 הדבקה',
  'electrofusion' => '⚡ אלקטרו',
  _               => '',
};

// ── main widget ───────────────────────────────────────────────────────────────

class CompatScreen extends ConsumerWidget {
  const CompatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(chainProvider);
    return Material(
      color: _bg,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          const _SearchBar(),
          const _Filters(),
          const _StatsRow(),
          const Expanded(child: _List()),
          if (chain.isNotEmpty) _ChainBar(chain: chain),
        ]),
      ),
    );
  }
}

// ── search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();
  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hasText = ref.watch(compatSearchProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7EA),  // matches catalog search bar
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: _sub, size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _ctrl,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: _title, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'חפש מוצר לתאימות...',
              hintStyle: TextStyle(color: _sub, fontSize: 14),
              isDense: true, contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) =>
                ref.read(compatSearchProvider.notifier).state = v,
          )),
          if (hasText)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                ref.read(compatSearchProvider.notifier).state = '';
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close, color: _sub, size: 16),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── filter chips ──────────────────────────────────────────────────────────────

class _Filters extends ConsumerWidget {
  const _Filters();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender  = ref.watch(compatGenderProvider);
    final size    = ref.watch(compatSizeProvider);
    final method  = ref.watch(compatMethodProvider);
    final anyOn   = gender != 'הכל' || size != 'הכל' || method != 'הכל';

    void setG(String v) => ref.read(compatGenderProvider.notifier).state  = gender == v ? 'הכל' : v;
    void setS(String v) => ref.read(compatSizeProvider.notifier).state    = size   == v ? 'הכל' : v;
    void setM(String v) => ref.read(compatMethodProvider.notifier).state  = method == v ? 'הכל' : v;

    Widget chip(String lbl, bool on, VoidCallback fn, {Color? c}) {
      final col = c ?? _brand;
      return GestureDetector(
        onTap: fn,
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: on ? col.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? col : const Color(0xFFD1D5DB), width: on ? 1.5 : 1),
          ),
          child: Text(lbl,
              style: TextStyle(
                color: on ? col : _sub,
                fontSize: 12,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Row(children: [
          chip('♂ זכר',    gender == 'זכר',    () => setG('זכר'),    c: const Color(0xFF3B82F6)),
          chip('♀ נקבה',   gender == 'נקבה',   () => setG('נקבה'),   c: const Color(0xFFEC4899)),
          chip('🔩 תבריג', method == 'תבריג',  () => setM('תבריג')),
          chip('💧 הדבקה', method == 'הדבקה',  () => setM('הדבקה')),
          chip('⚡ אלקטרו',method == 'אלקטרו', () => setM('אלקטרו')),
          if (anyOn) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ref.read(compatGenderProvider.notifier).state = 'הכל';
                ref.read(compatSizeProvider.notifier).state   = 'הכל';
                ref.read(compatMethodProvider.notifier).state = 'הכל';
              },
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: const Text('✕ איפוס',
                    style: TextStyle(color: _sub, fontSize: 12)),
              ),
            ),
          ],
        ]),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
        child: Row(children: [
          for (final s in ['25','32','40','50','63','75','90','110','160'])
            chip(s, size == s, () => setS(s)),
        ]),
      ),
    ]);
  }
}

// ── stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count  = _filtered(ref).length;
    final anyOn  = ref.watch(compatGenderProvider) != 'הכל' ||
                   ref.watch(compatSizeProvider)   != 'הכל' ||
                   ref.watch(compatMethodProvider) != 'הכל';
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: Row(children: [
        Text('$count מוצרים',
            style: const TextStyle(color: _sub, fontSize: 12)),
        if (anyOn) ...[
          const SizedBox(width: 6),
          const Text('·', style: TextStyle(color: _sub, fontSize: 12)),
          const SizedBox(width: 6),
          Text('מסונן', style: TextStyle(
              color: _brand, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
        const Spacer(),
        const Text('הקש ⇄ לתאימות',
            style: TextStyle(color: _sub, fontSize: 11)),
      ]),
    );
  }
}

// ── list ──────────────────────────────────────────────────────────────────────

class _List extends ConsumerWidget {
  const _List();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = _filtered(ref);
    if (products.isEmpty) {
      return const Center(child: Text('אין מוצרים תואמים לסינון',
          style: TextStyle(color: _sub, fontSize: 14)));
    }
    return ColoredBox(
      color: _bg,
      child: ListView.separated(
        key: const Key('compat-list'),
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 76, color: _divider),
        itemBuilder: (_, i) => _Row(product: products[i]),
      ),
    );
  }
}

// ── row — mirrors _CatalogRow with light palette ──────────────────────────────

class _Row extends ConsumerWidget {
  const _Row({required this.product});
  final LipskeyCatalogProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = compatibleWith(product);
    final gender  = product.connectionGender;
    final sizes   = product.connectionSizes;
    final method  = product.connectionMethod;

    final previewParts = <String>[
      if (sizes.isNotEmpty) sizes.map((s) => 'DN$s').join(' · '),
      if (method != null) _mLbl(method),
    ];
    final preview = previewParts.isEmpty ? 'אין נתוני חיבור' : previewParts.join('  ');

    return InkWell(
      onTap: () => _showSheet(context, product, matches),
      child: ColoredBox(
        color: _bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // puzzle piece avatar — notch on bottom
            _puzzleBox(product, notchBottom: true),
            const SizedBox(width: 12),
            // text
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(product.nameHe,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _title, fontSize: 15, fontWeight: FontWeight.w600))),
                  if (gender != null)
                    Text(_gLbl(gender),
                        style: TextStyle(color: _gColor(gender),
                            fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Expanded(child: Text(preview, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _sub, fontSize: 13))),
                  // compat badge
                  GestureDetector(
                    onTap: () => _showSheet(context, product, matches),
                    child: matches.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                            ),
                            child: Text('⇄ ${matches.length}',
                                style: const TextStyle(
                                    color: Color(0xFF059669), fontSize: 12,
                                    fontWeight: FontWeight.w700)))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _divider),
                            ),
                            child: const Text('⊘',
                                style: TextStyle(color: _sub, fontSize: 12))),
                  ),
                ]),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// ── compat sheet ──────────────────────────────────────────────────────────────

void _showSheet(BuildContext ctx, LipskeyCatalogProduct anchor,
    List<LipskeyCatalogProduct> matches) {
  showModalBottomSheet<void>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CompatSheet(anchor: anchor, matches: matches),
  );
}

class CompatSheet extends ConsumerStatefulWidget {
  const CompatSheet({super.key, required this.anchor, required this.matches});
  final LipskeyCatalogProduct anchor;
  final List<LipskeyCatalogProduct> matches;

  @override
  ConsumerState<CompatSheet> createState() => _CompatSheetState();
}

class _CompatSheetState extends ConsumerState<CompatSheet>
    with SingleTickerProviderStateMixin {
  LipskeyCatalogProduct? _connecting;
  bool _showActions = false;
  late final AnimationController _ctrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );
    _slideAnim = Tween<double>(begin: 90, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _connect(LipskeyCatalogProduct p) {
    setState(() { _connecting = p; _showActions = false; });
    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _showActions = true);
    });
  }

  void _addToChain(LipskeyCatalogProduct p, BuildContext ctx) {
    final chain = ref.read(chainProvider);

    // First addition: add anchor then the tapped match (guaranteed compatible).
    if (chain.isEmpty) {
      ref.read(chainProvider.notifier).state = [widget.anchor, p];
      Navigator.pop(context);
      return;
    }

    // Skip duplicates silently.
    if (chain.any((x) => x.sku == p.sku)) {
      Navigator.pop(context);
      return;
    }

    // Enforce: new piece must connect to the current tail.
    final tail = chain.last;
    if (!canConnect(tail, p)) {
      final reason = connectionFailReason(tail, p);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('לא ניתן לחבר — $reason',
            textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ));
      return; // keep sheet open so user can pick another product
    }

    ref.read(chainProvider.notifier).state = [...chain, p];
    Navigator.pop(context);
  }

  void _openDetails(LipskeyCatalogProduct p, BuildContext ctx) {
    Navigator.pop(context);
    showLipskeyProductSheet(
      ctx,
      p,
      kLipskeyCatalog.where((x) => x.categoryHe == p.categoryHe).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchor = widget.anchor;
    final matches = widget.matches;
    final chain = ref.watch(chainProvider);
    final chainTail = chain.isEmpty ? null : chain.last;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Stack(
          children: [
            // ── sheet content ─────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(children: [
                // handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _divider, borderRadius: BorderRadius.circular(2)),
                ),
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(children: [
                    // anchor puzzle piece — notch bottom, 44×44
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: ClipPath(
                        clipper: const _PuzzleClipper(notchBottom: true),
                        child: Container(
                          color: _surface,
                          alignment: Alignment.center,
                          child: Text(anchor.typeEmoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('מה מתחבר ל...',
                            style: TextStyle(color: _sub, fontSize: 11)),
                        Text(anchor.nameHe, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: _title, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    )),
                    if (anchor.connectionGender != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _gColor(anchor.connectionGender).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _gColor(anchor.connectionGender).withOpacity(0.4)),
                        ),
                        child: Text(_gLbl(anchor.connectionGender),
                            style: TextStyle(
                                color: _gColor(anchor.connectionGender),
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                  ]),
                ),
                const Divider(height: 1, color: _divider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(children: [
                    Text(
                      matches.isEmpty
                          ? 'לא נמצאו מוצרים תואמים'
                          : '${matches.length} מוצרים תואמים',
                      style: TextStyle(
                        color: matches.isEmpty ? _sub : const Color(0xFF059669),
                        fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
                if (matches.isEmpty)
                  const Expanded(child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⊘', style: TextStyle(fontSize: 48, color: _divider)),
                      SizedBox(height: 12),
                      Text('אין מוצרים בקטלוג שמתחברים לפריט זה',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _sub, fontSize: 13)),
                    ],
                  )))
                else
                  Expanded(child: ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72, color: _divider),
                    itemBuilder: (ctx2, i) {
                      final p = matches[i];
                      return InkWell(
                        onTap: () => _connect(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(children: [
                            // compatible piece — tab top, 44×44
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: ClipPath(
                                clipper: const _PuzzleClipper(tabTop: true),
                                child: Container(
                                  color: _surface,
                                  alignment: Alignment.center,
                                  child: p.imageAsset != null
                                      ? Image.asset(p.imageAsset!,
                                          width: 44, height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Text(p.typeEmoji,
                                                  style: const TextStyle(
                                                      fontSize: 20)))
                                      : Text(p.typeEmoji,
                                          style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(child: Text(p.nameHe,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: _title, fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                                  if (p.connectionGender != null)
                                    Text(_gLbl(p.connectionGender),
                                        style: TextStyle(
                                            color: _gColor(p.connectionGender),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                ]),
                                const SizedBox(height: 2),
                                Text(
                                  p.connectionSizes
                                      .map((s) => 'DN$s')
                                      .join(' · '),
                                  style: const TextStyle(
                                      color: _sub, fontSize: 12)),
                              ],
                            )),
                            // 🔗 button: orange = fits tail, grey = already in chain or incompatible
                            Builder(builder: (btnCtx) {
                              final inChain = chain.any((x) => x.sku == p.sku);
                              final fits = !inChain && (chainTail == null || canConnect(chainTail, p));
                              return GestureDetector(
                                onTap: () => _addToChain(p, btnCtx),
                                child: Opacity(
                                  opacity: fits ? 1.0 : 0.35,
                                  child: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: fits ? _brand : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      inChain ? Icons.check : Icons.link,
                                      size: 16, color: Colors.white),
                                  ),
                                ),
                              );
                            }),
                          ]),
                        ),
                      );
                    },
                  )),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ]),
            ),

            // ── connection animation overlay ──────────────────────────────────
            if (_connecting != null)
              Positioned.fill(
                child: Builder(builder: (ctx2) => AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => ColoredBox(
                    color: Colors.white.withOpacity(_fadeAnim.value * 0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 50, height: 50,
                            child: ClipPath(
                              clipper: const _PuzzleClipper(notchBottom: true),
                              child: Container(
                                color: _surface,
                                alignment: Alignment.center,
                                child: Text(anchor.typeEmoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                          if (_ctrl.value > 0.7)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              width: 2, height: 16,
                              color: const Color(0xFF059669),
                            ),
                          Transform.translate(
                            offset: Offset(0, _slideAnim.value),
                            child: _puzzleBox(_connecting!, tabTop: true),
                          ),
                          const SizedBox(height: 12),
                          if (_ctrl.value > 0.75)
                            const Text(
                              'מחובר! ✓',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 16, fontWeight: FontWeight.w700,
                              ),
                            ),
                          // Action buttons after animation completes
                          if (_showActions) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _brand,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                  ),
                                  icon: const Text('🔗',
                                      style: TextStyle(fontSize: 14)),
                                  label: const Text('הוסף לשרשרת',
                                      style: TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  onPressed: () => _addToChain(_connecting!, context),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _title,
                                    side: const BorderSide(color: _divider),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                  ),
                                  onPressed: () => _openDetails(_connecting!, ctx2),
                                  child: const Text('פרטים',
                                      style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )),
              ),
          ],
        ),
      ),
    );
  }
}

// ── chain bar ─────────────────────────────────────────────────────────────────

class _ChainBar extends ConsumerWidget {
  const _ChainBar({required this.chain});
  final List<LipskeyCatalogProduct> chain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showChainSheet(context),
      child: Container(
        color: _brand,
        padding: EdgeInsets.fromLTRB(
            16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          const Text('🔗', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'שרשרת: ${chain.length} פריטים — לחץ לצפייה',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          )),
          const Icon(Icons.chevron_left, color: Colors.white),
        ]),
      ),
    );
  }
}

void _showChainSheet(BuildContext ctx) {
  showModalBottomSheet<void>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChainBuilderSheet(),
  );
}

// ── chain builder sheet ───────────────────────────────────────────────────────

class ChainBuilderSheet extends ConsumerWidget {
  const ChainBuilderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(chainProvider);
    final lineTemp = ref.watch(lineMaxTempProvider);
    final accessories = ref.watch(lineAccessoriesProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: (0.45 + chain.length * 0.08).clamp(0.6, 0.92),
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            // handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [
                const Text('🔗', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('בונה קו אינסטלציה',
                      style: TextStyle(
                          color: _title,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(chainProvider.notifier).state = [];
                    Navigator.pop(context);
                  },
                  child: const Text('נקה',
                      style: TextStyle(color: _sub, fontSize: 13)),
                ),
              ]),
            ),
            const Divider(height: 1, color: _divider),

            // ── line operating temperature selector ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                const Text('🌡️ טמפ׳ הקו:',
                    style: TextStyle(color: _sub, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                for (final t in [20, 60, 80]) ...[
                  GestureDetector(
                    onTap: () =>
                        ref.read(lineMaxTempProvider.notifier).state = t,
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: lineTemp == t ? _brand : _surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('$t°C',
                          style: TextStyle(
                              color: lineTemp == t ? Colors.white : _sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ]),
            ),

            // ── installation accessories (insulation / clips / sealing) ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                const Text('🧰 אביזרים:',
                    style: TextStyle(color: _sub, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                for (final a in const [
                  ('HW-INSUL', 'בידוד'),
                  ('HW-CLIP', 'חבקים'),
                  ('HW-SEALANT', 'איטום'),
                ])
                  GestureDetector(
                    onTap: () {
                      final s = {...accessories};
                      s.contains(a.$1) ? s.remove(a.$1) : s.add(a.$1);
                      ref.read(lineAccessoriesProvider.notifier).state = s;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accessories.contains(a.$1)
                            ? const Color(0xFF059669) : _surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                          '${accessories.contains(a.$1) ? '✓ ' : ''}${a.$2}',
                          style: TextStyle(
                              color: accessories.contains(a.$1)
                                  ? Colors.white : _sub,
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ]),
            ),

            // ── chain visualization ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < chain.length; i++) ...[
                      _ChainNode(product: chain[i], index: i),
                      if (i < chain.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: pipeConnectionDn(chain[i], chain[i + 1]) != null
                              ? _PipeConnector(
                                  dn: pipeConnectionDn(chain[i], chain[i + 1])!)
                              : Row(children: [
                                  Container(width: 10, height: 3,
                                      color: const Color(0xFF059669)),
                                  const Icon(Icons.arrow_back_ios,
                                      size: 12, color: Color(0xFF059669)),
                                ]),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: _divider),

            // ── product list + compliance checklist (single scroll) ────────────
            Expanded(child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                for (int i = 0; i < chain.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 72, color: _divider),
                  _ChainListItem(
                    product: chain[i],
                    index: i,
                    isLast: i == chain.length - 1,
                    next: i < chain.length - 1 ? chain[i + 1] : null,
                    lineTemp: lineTemp,
                    onRemove: i == 0
                        ? null
                        : () {
                            ref.read(chainProvider.notifier).state =
                                [...chain]..removeAt(i);
                            Navigator.pop(context);
                          },
                  ),
                ],
                if (chain.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ComplianceChecklist(
                    checks: lineComplianceChecklist(chain, lineTemp, accessories),
                    reminders: lineInstallReminders(),
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}

// One row of the chain product list
class _ChainListItem extends StatelessWidget {
  const _ChainListItem({
    required this.product,
    required this.index,
    required this.isLast,
    required this.next,
    required this.lineTemp,
    required this.onRemove,
  });
  final LipskeyCatalogProduct product;
  final int index;
  final bool isLast;
  final LipskeyCatalogProduct? next;
  final int lineTemp;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: index == 0 ? _brand : const Color(0xFF059669),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('${index + 1}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.nameHe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _title, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Row(children: [
              if (p.connectionGender != null)
                Text(_gLbl(p.connectionGender),
                    style: TextStyle(
                        color: _gColor(p.connectionGender),
                        fontSize: 11, fontWeight: FontWeight.w600)),
              if (p.connectionSizes.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(p.connectionSizes.map((s) => 'DN$s').join(' · '),
                    style: const TextStyle(color: _sub, fontSize: 11)),
              ],
              if (productMaterial(p) != null) ...[
                const SizedBox(width: 6),
                Text('· ${productMaterial(p)}',
                    style: const TextStyle(color: _sub, fontSize: 11)),
              ],
            ]),
            if (!productSuitableForTemp(p, lineTemp))
              _TempWarn(
                  maxTemp: productMaxTempC(p)!.round(),
                  lineTemp: lineTemp,
                  material: productMaterial(p) ?? ''),
            if (!isLast && next != null) ...[
              _CompatCheck(a: p, b: next!),
              if (pipeConnectionDn(p, next!) != null)
                _PipeSegment(dn: pipeConnectionDn(p, next!)!),
            ],
          ],
        )),
        if (onRemove != null)
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: _sub),
            ),
          ),
      ]),
    );
  }
}

// Auto compliance / completeness checklist for the built line
class _ComplianceChecklist extends StatelessWidget {
  const _ComplianceChecklist({required this.checks, required this.reminders});
  final List<LineCheck> checks;
  final List<String> reminders;

  @override
  Widget build(BuildContext context) {
    final missing = checks.where((c) => !c.satisfied).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: missing == 0 ? const Color(0xFF059669) : Colors.red.shade300),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(missing == 0 ? Icons.verified : Icons.warning_amber_rounded,
              size: 16,
              color: missing == 0 ? const Color(0xFF059669) : Colors.red),
          const SizedBox(width: 6),
          Text(
            missing == 0
                ? 'בדיקת תקינות: הקו שלם ✓'
                : 'בדיקת תקינות: חסרים $missing רכיבים',
            style: TextStyle(
                color: missing == 0 ? const Color(0xFF059669) : Colors.red,
                fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ]),
        const SizedBox(height: 8),
        for (final c in checks)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(c.satisfied ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: c.satisfied ? const Color(0xFF059669) : Colors.red),
              const SizedBox(width: 6),
              Text(c.label,
                  style: TextStyle(
                      color: c.satisfied ? _title : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: c.satisfied ? null : null)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('· ${c.why}',
                    style: const TextStyle(color: _sub, fontSize: 10)),
              ),
            ]),
          ),
        const SizedBox(height: 4),
        const Divider(height: 12, color: _divider),
        const Text('דרישות התקנה (לאימות בשטח):',
            style: TextStyle(
                color: _sub, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        for (final r in reminders)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 12, color: _sub),
              const SizedBox(width: 6),
              Expanded(
                child: Text(r, style: const TextStyle(color: _sub, fontSize: 11)),
              ),
            ]),
          ),
      ]),
    );
  }
}

// Material/temperature warning when a product can't serve the line temperature
class _TempWarn extends StatelessWidget {
  const _TempWarn(
      {required this.maxTemp, required this.lineTemp, required this.material});
  final int maxTemp, lineTemp;
  final String material;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(children: [
        const Icon(Icons.local_fire_department, size: 12, color: Colors.red),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$material לא מתאים ל-$lineTemp°C (מקס׳ $maxTemp°C)',
            style: const TextStyle(
                color: Colors.red, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// Pipe connector shown between puzzle pieces in the horizontal row
class _PipeConnector extends StatelessWidget {
  const _PipeConnector({required this.dn});
  final String dn;

  @override
  Widget build(BuildContext context) {
    const pipeBlue = Color(0xFF1976D2);
    const pipeBg   = Color(0xFFE3F2FD);
    const pipeLine = Color(0xFF90CAF9);
    return SizedBox(
      width: 54,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: 5, decoration: BoxDecoration(
          color: pipeLine, borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: pipeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: pipeLine),
          ),
          child: Text('DN$dn',
              style: const TextStyle(fontSize: 9, color: pipeBlue,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 2),
        Container(height: 5, decoration: BoxDecoration(
          color: pipeLine, borderRadius: BorderRadius.circular(3))),
      ]),
    );
  }
}

// Pipe segment row shown in the list between two compression-connected fittings
class _PipeSegment extends StatelessWidget {
  const _PipeSegment({required this.dn});
  final String dn;

  @override
  Widget build(BuildContext context) {
    const pipeBlue = Color(0xFF1565C0);
    const pipeBg   = Color(0xFFE3F2FD);
    const pipeLine = Color(0xFF90CAF9);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(children: [
        Expanded(child: Container(height: 2,
            decoration: BoxDecoration(color: pipeLine,
                borderRadius: BorderRadius.circular(1)))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pipeBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pipeLine),
          ),
          child: Text('צינור HDPE DN$dn',
              style: const TextStyle(fontSize: 10, color: pipeBlue,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 2,
            decoration: BoxDecoration(color: pipeLine,
                borderRadius: BorderRadius.circular(1)))),
      ]),
    );
  }
}

class _ChainNode extends StatelessWidget {
  const _ChainNode({required this.product, required this.index});
  final LipskeyCatalogProduct product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(children: [
        Stack(alignment: Alignment.topRight, children: [
          SizedBox(
            width: 50, height: 50,
            child: ClipPath(
              clipper: _PuzzleClipper(
                notchBottom: index % 2 == 0,
                tabTop: index % 2 == 1,
              ),
              child: Container(
                color: index == 0 ? _brand.withOpacity(0.15) : _surface,
                alignment: Alignment.center,
                child: Text(product.typeEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: index == 0 ? _brand : const Color(0xFF059669),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          product.nameHe,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _title, fontSize: 9,
              fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }
}

class _CompatCheck extends StatelessWidget {
  const _CompatCheck({required this.a, required this.b});
  final LipskeyCatalogProduct a, b;

  @override
  Widget build(BuildContext context) {
    final ok = canConnect(a, b);
    if (ok) {
      final method = connectionMethodLabel(a, b);
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(children: [
          const Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
          const SizedBox(width: 4),
          const Text('חיבור תקין ✓',
              style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.w600)),
          if (method.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text('· $method',
                style: const TextStyle(color: _sub, fontSize: 10)),
          ],
        ]),
      );
    }
    final reason = connectionFailReason(a, b);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.error, size: 12, color: Colors.red),
          const SizedBox(width: 4),
          const Text('חיבור לא תקין',
              style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 2),
          child: Text(reason,
              style: const TextStyle(color: Colors.red, fontSize: 9)),
        ),
      ]),
    );
  }
}
