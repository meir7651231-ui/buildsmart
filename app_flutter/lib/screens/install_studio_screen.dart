// BuildSmart Studio — a cinematic installation designer built on install_engine.
// Dark "blueprint command-center": glowing product nodes wired by animated
// energy pipes, colour-coded by plumbing system, with a one-tap auto-assemble
// that fills every connector into an orderable bill of materials.
import 'dart:math' as math;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── palette ───────────────────────────────────────────────────────────────────
const _void0 = Color(0xFF0A0E1A); // deep background
const _void1 = Color(0xFF111827);
const _panel = Color(0xFF161D2E);
const _grid = Color(0x14_38BDF8);
const _ink = Color(0xFFF1F5F9);
const _mute = Color(0xFF7C8AA5);
const _supply = Color(0xFF22D3EE); // cyan — water supply
const _drain = Color(0xFFFBBF24); // amber — drainage
const _fixture = Color(0xFFA78BFA); // violet — fixtures (the bridge)
const _accent = Color(0xFF34D399); // emerald — assemble action

Color _systemColor(LipskeyCatalogProduct p) {
  final s = productSystems(p);
  if (s.length > 1) return _fixture;
  return s.contains(WaterSystem.drainage) ? _drain : _supply;
}

String _roleLabel(LipskeyCatalogProduct p, bool anchor) {
  if (anchor) return 'עוגן';
  switch (flowRole(p)) {
    case FlowRole.accessory:
      return 'אביזר';
    case FlowRole.fixture:
      return 'קבועה';
    case FlowRole.connector:
      return 'מחבר';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class InstallStudioScreen extends ConsumerStatefulWidget {
  const InstallStudioScreen({super.key});
  @override
  ConsumerState<InstallStudioScreen> createState() => _InstallStudioScreenState();
}

class _InstallStudioScreenState extends ConsumerState<InstallStudioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chain = ref.watch(chainProvider);
    final temp = ref.watch(lineMaxTempProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _void0,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.3,
              colors: [_void1, _void0],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _flow,
              builder: (_, __) => CustomPaint(
                painter: _BlueprintPainter(_flow.value),
                child: Column(children: [
                  _header(chain, temp),
                  Expanded(child: _canvas(chain)),
                  _dock(chain, temp),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── header: title + live system legend ──────────────────────────────────────
  Widget _header(List<LipskeyCatalogProduct> chain, int temp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 6),
      child: Row(children: [
        if (Navigator.canPop(context))
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward, color: _ink, size: 22),
            ),
          ),
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_supply, _fixture]),
            boxShadow: [
              BoxShadow(color: _supply.withOpacity(0.5), blurRadius: 14),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hub, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('סטודיו התקנות',
                style: TextStyle(
                    color: _ink, fontSize: 18, fontWeight: FontWeight.w900)),
            Text('תכנן · חבר · הזמן',
                style: TextStyle(color: _mute, fontSize: 11, letterSpacing: 1)),
          ]),
        ),
        _tempPill(temp),
      ]),
    );
  }

  Widget _tempPill(int temp) {
    return GestureDetector(
      onTap: () {
        const opts = [20, 60, 80];
        final next = opts[(opts.indexOf(temp) + 1) % opts.length];
        ref.read(lineMaxTempProvider.notifier).state = next;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _supply.withOpacity(0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.thermostat, color: _supply, size: 14),
          const SizedBox(width: 4),
          Text('$temp°C',
              style: const TextStyle(
                  color: _ink, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }

  // ── the flow canvas — nodes wired by animated pipes ─────────────────────────
  Widget _canvas(List<LipskeyCatalogProduct> chain) {
    if (chain.isEmpty) return _emptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      itemCount: chain.length,
      itemBuilder: (_, i) {
        final p = chain[i];
        final last = i == chain.length - 1;
        return _NodeRow(
          product: p,
          index: i,
          isLast: last,
          flow: _flow.value,
          nextColor: last ? null : _systemColor(chain[i + 1]),
          onRemove: () {
            final c = [...chain]..removeAt(i);
            ref.read(chainProvider.notifier).state = c;
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _supply.withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: _supply.withOpacity(0.15), blurRadius: 40)],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.account_tree_outlined,
              color: _supply.withOpacity(0.8), size: 40),
        ),
        const SizedBox(height: 20),
        const Text('בנה קו אינסטלציה',
            style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'הוסף מוצרי-קצה — הזנה, קבועה, ניקוז — והמנוע יחבר ביניהם אוטומטית לרשימת-קנייה שלמה.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mute, fontSize: 13, height: 1.5),
          ),
        ),
      ]),
    );
  }

  // ── bottom dock: legend + actions ───────────────────────────────────────────
  Widget _dock(List<LipskeyCatalogProduct> chain, int temp) {
    return Container(
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 24)],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          _legendDot(_supply, 'אספקה'),
          _legendDot(_drain, 'ניקוז'),
          _legendDot(_fixture, 'קבועה'),
          const Spacer(),
          Text('${chain.length} עוגנים',
              style: const TextStyle(color: _mute, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ghostButton(
              icon: Icons.add,
              label: 'הוסף מוצר',
              onTap: () => _openPicker(temp),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _glowButton(
              icon: Icons.bolt,
              label: 'השלם התקנה',
              enabled: chain.length >= 2,
              onTap: () => _assemble(chain, temp),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color c, String label) => Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Row(children: [
          Container(
            width: 9, height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: c,
              boxShadow: [BoxShadow(color: c.withOpacity(0.7), blurRadius: 7)],
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: _mute, fontSize: 11)),
        ]),
      );

  Widget _ghostButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _void1,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _mute.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _ink, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: _ink, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _glowButton(
      {required IconData icon,
      required String label,
      required bool enabled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_accent, Color(0xFF059669)]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: enabled
                ? [BoxShadow(color: _accent.withOpacity(0.45), blurRadius: 18)]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          ]),
        ),
      ),
    );
  }

  // ── actions ──────────────────────────────────────────────────────────────────
  void _assemble(List<LipskeyCatalogProduct> chain, int temp) {
    final acc = ref.read(lineAccessoriesProvider);
    // A manifold mid-chain with items after it → branched (tree) installation:
    // [feed … manifold] is the trunk, everything after are parallel branches.
    final mi = chain.indexWhere((p) => manifoldOutlets(p) > 0);
    final isTree = mi >= 0 && mi < chain.length - 1;
    final InstallationPlan plan;
    int branches = 0, outlets = 0;
    if (isTree) {
      final trunk = chain.sublist(0, mi + 1);
      final branchTargets = chain.sublist(mi + 1);
      branches = branchTargets.length;
      outlets = manifoldOutlets(chain[mi]);
      plan = buildTreeInstallation(trunk, branchTargets,
          tempC: temp, accessories: acc);
    } else {
      plan = buildInstallation([...chain], tempC: temp, accessories: acc);
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BomSheet(
        plan: plan,
        anchorSkus: {for (final a in chain) a.sku},
        branches: branches,
        outlets: outlets,
      ),
    );
  }

  void _openPicker(int temp) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPicker(lineTemp: temp),
    );
  }
}

// ── one node + the pipe to the next ────────────────────────────────────────────
class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.product,
    required this.index,
    required this.isLast,
    required this.flow,
    required this.nextColor,
    required this.onRemove,
  });
  final LipskeyCatalogProduct product;
  final int index;
  final bool isLast;
  final double flow;
  final Color? nextColor;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = _systemColor(product);
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withOpacity(0.55), width: 1.5),
          boxShadow: [BoxShadow(color: c.withOpacity(0.18), blurRadius: 20)],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withOpacity(0.16),
              border: Border.all(color: c, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: TextStyle(
                    color: c, fontSize: 17, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.nameHe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Row(children: [
                _chip(_roleLabel(product, true), c),
                const SizedBox(width: 6),
                Text(product.sku,
                    style: const TextStyle(color: _mute, fontSize: 11)),
              ]),
            ]),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: _mute, size: 18),
          ),
        ]),
      ),
      if (!isLast) _PipeLink(from: c, to: nextColor ?? c, flow: flow),
    ]);
  }

  Widget _chip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: c.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8)),
        child: Text(t,
            style: TextStyle(
                color: c, fontSize: 10, fontWeight: FontWeight.w800)),
      );
}

// animated energy pipe between two nodes
class _PipeLink extends StatelessWidget {
  const _PipeLink({required this.from, required this.to, required this.flow});
  final Color from;
  final Color to;
  final double flow;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Center(
        child: CustomPaint(
          size: const Size(4, 34),
          painter: _PipePainter(from, to, flow),
        ),
      ),
    );
  }
}

class _PipePainter extends CustomPainter {
  _PipePainter(this.from, this.to, this.flow);
  final Color from, to;
  final double flow;
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final track = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), track);
    // flowing pulse travelling down the pipe
    final t = (flow * 1.0) % 1.0;
    final y = t * size.height;
    final glow = Paint()
      ..shader = LinearGradient(colors: [from, to])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
        Offset(x, math.max(0, y - 8)), Offset(x, math.min(size.height, y + 8)),
        glow);
  }

  @override
  bool shouldRepaint(_PipePainter old) => old.flow != flow;
}

// faint blueprint grid + drifting scanline
class _BlueprintPainter extends CustomPainter {
  _BlueprintPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _grid
      ..strokeWidth = 1;
    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // drifting horizontal scan glow
    final sy = (t * size.height) % size.height;
    final scan = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, _supply.withOpacity(0.05), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, sy - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, sy - 60, size.width, 120), scan);
  }

  @override
  bool shouldRepaint(_BlueprintPainter old) => old.t != t;
}

// ── bill-of-materials sheet (dark) ─────────────────────────────────────────────
class _BomSheet extends ConsumerStatefulWidget {
  const _BomSheet(
      {required this.plan,
      required this.anchorSkus,
      this.branches = 0,
      this.outlets = 0});
  final InstallationPlan plan;
  final Set<String> anchorSkus;
  final int branches; // >0 when this is a branched (manifold) installation
  final int outlets; // manifold outlet count, for over-capacity warning

  @override
  ConsumerState<_BomSheet> createState() => _BomSheetState();
}

class _BomSheetState extends ConsumerState<_BomSheet> {
  // Per-pipe length in metres (pipes are sold by length, not by piece).
  final Map<String, double> _meters = {};
  double _metersOf(String sku) => _meters[sku] ?? 2.0;

  double get _totalMeters => widget.plan.items
      .where(isPipe)
      .fold(0.0, (s, p) => s + _metersOf(p.sku));

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final anchorSkus = widget.anchorSkus;
    final branches = widget.branches;
    final outlets = widget.outlets;
    final ok = plan.isComplete;
    final overCapacity = branches > 0 && outlets > 0 && branches > outlets;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.96,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _void1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _accent, width: 2)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 42, height: 4,
              decoration: BoxDecoration(
                  color: _mute, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(children: [
                Icon(ok ? Icons.verified : Icons.warning_amber_rounded,
                    color: ok ? _accent : _drain, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ok ? 'התקנה שלמה' : 'חסרים ${plan.gaps.length} חיבורים',
                          style: TextStyle(
                              color: ok ? _ink : _drain,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      Text(
                          '${plan.items.length} סוגים · ${plan.totalPieces} יחידות'
                          '${_totalMeters > 0 ? ' · ${_totalMeters.toStringAsFixed(1)} מ׳ צנרת' : ''}'
                          '${branches > 0 ? ' · ⑂ $branches ענפים' : ''}',
                          style: const TextStyle(color: _mute, fontSize: 12)),
                      if (overCapacity)
                        Text('⚠️ $branches ענפים על מחלק $outlets-יציאות',
                            style: const TextStyle(
                                color: _drain,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(height: 1, color: Color(0xFF243049)),
            Expanded(
              child: ListView(controller: ctrl, children: [
                for (var i = 0; i < plan.items.length; i++)
                  _bomRow(plan.items[i], i + 1,
                      anchorSkus.contains(plan.items[i].sku),
                      plan.qtyOf(plan.items[i].sku)),
                if (plan.gaps.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
                    child: Text('⚠️ חיבורים שחסרים בקטלוג',
                        style: TextStyle(
                            color: _drain,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  for (final g in plan.gaps)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
                      child: Text('✗ ${g.from.nameHe} ↮ ${g.to.nameHe}',
                          style: const TextStyle(color: _mute, fontSize: 12)),
                    ),
                ],
                const SizedBox(height: 10),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  14, 10, 14, 12 + MediaQuery.of(context).padding.bottom),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(chainProvider.notifier).state = plan.items;
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _mute.withOpacity(0.4)),
                      ),
                      child: const Text('החל על הקו',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _addToCart(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_accent, Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 16)
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('הוסף ${plan.items.length} לעגלה',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900)),
                          ]),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // Adds every BOM line to the cart with its quantity (pipes by ceil(metres)).
  void _addToCart(BuildContext context, WidgetRef ref) {
    final cart = ref.read(smartCartProvider.notifier);
    for (final p in widget.plan.items) {
      final qty =
          isPipe(p) ? _metersOf(p.sku).ceil() : widget.plan.qtyOf(p.sku);
      cart.add(SmartCartLine(
        productKey: p.sku,
        productName: p.nameHe,
        productEmoji: p.typeEmoji,
        brandName: p.categoryHe,
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      ));
    }
    Navigator.pop(context);
    showToast(context, 'נוסף לעגלה: ${widget.plan.items.length} פריטים');
  }

  Widget _bomRow(LipskeyCatalogProduct p, int n, bool anchor, int qty) {
    final c = _systemColor(p);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: c.withOpacity(0.18),
              border: Border.all(color: c)),
          alignment: Alignment.center,
          child: Text('$n',
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.nameHe,
                style: const TextStyle(
                    color: _ink, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${_roleLabel(p, anchor)} · ${p.sku}',
                style: const TextStyle(color: _mute, fontSize: 11)),
          ]),
        ),
        if (isPipe(p)) _metersStepper(p.sku) else _qtyBadge(qty),
      ]),
    );
  }

  Widget _qtyBadge(int qty) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: _panel, borderRadius: BorderRadius.circular(10)),
        child: Text('× $qty',
            style: const TextStyle(
                color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
      );

  // metres control for pipe products (sold by length)
  Widget _metersStepper(String sku) {
    final m = _metersOf(sku);
    return Container(
      decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _supply.withOpacity(0.4))),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _stepBtn(Icons.remove, () {
          setState(() => _meters[sku] = (m - 0.5).clamp(0.5, 999));
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('${m.toStringAsFixed(1)} מ׳',
              style: const TextStyle(
                  color: _supply, fontSize: 13, fontWeight: FontWeight.w900)),
        ),
        _stepBtn(Icons.add, () {
          setState(() => _meters[sku] = (m + 0.5).clamp(0.5, 999));
        }),
      ]),
    );
  }

  Widget _stepBtn(IconData ic, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              color: _void1, borderRadius: BorderRadius.circular(8)),
          child: Icon(ic, color: _ink, size: 15),
        ),
      );
}

// ── dark product picker ────────────────────────────────────────────────────────
class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker({required this.lineTemp});
  final int lineTemp;
  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim();
    final items = kCompatCatalog
        .where((p) =>
            productSuitableForTemp(p, widget.lineTemp) &&
            (q.isEmpty ||
                p.nameHe.contains(q) ||
                p.categoryHe.contains(q) ||
                p.sku.contains(q)))
        .take(120)
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _void1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _supply, width: 2)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 42, height: 4,
              decoration: BoxDecoration(
                  color: _mute, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                autofocus: false,
                style: const TextStyle(color: _ink),
                textDirection: TextDirection.rtl,
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'חפש מוצר להוספה…',
                  hintStyle: const TextStyle(color: _mute),
                  prefixIcon: const Icon(Icons.search, color: _mute, size: 20),
                  filled: true,
                  fillColor: _panel,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final p = items[i];
                  final c = _systemColor(p);
                  return ListTile(
                    onTap: () {
                      ref.read(chainProvider.notifier).state = [
                        ...ref.read(chainProvider),
                        p,
                      ];
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          boxShadow: [
                            BoxShadow(color: c.withOpacity(0.6), blurRadius: 6)
                          ]),
                    ),
                    title: Text(p.nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _ink, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.categoryHe} · ${p.sku}',
                        style: const TextStyle(color: _mute, fontSize: 11)),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
