// BuildSmart Studio — a cinematic installation designer built on install_engine.
// Dark "blueprint command-center": glowing product nodes wired by animated
// energy pipes, colour-coded by plumbing system, with a one-tap auto-assemble
// that fills every connector into an orderable bill of materials.
import 'dart:math' as math;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.3,
            colors: [_void1, _void0],
          ),
        ),
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
    );
  }

  // ── header: title + live system legend ──────────────────────────────────────
  Widget _header(List<LipskeyCatalogProduct> chain, int temp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(children: [
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
    final plan = buildInstallation([...chain],
        tempC: temp, accessories: ref.read(lineAccessoriesProvider));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BomSheet(
        plan: plan,
        anchorSkus: {for (final a in chain) a.sku},
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
class _BomSheet extends ConsumerWidget {
  const _BomSheet({required this.plan, required this.anchorSkus});
  final InstallationPlan plan;
  final Set<String> anchorSkus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ok = plan.isComplete;
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
                      Text('${plan.items.length} סוגים · ${plan.totalPieces} יחידות',
                          style: const TextStyle(color: _mute, fontSize: 12)),
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
              child: GestureDetector(
                onTap: () {
                  ref.read(chainProvider.notifier).state = plan.items;
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [_accent, Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 16)
                    ],
                  ),
                  child: Text('החל על הקו (${plan.totalPieces} יחידות)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: _panel, borderRadius: BorderRadius.circular(10)),
          child: Text('× $qty',
              style: const TextStyle(
                  color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
        ),
      ]),
    );
  }
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
