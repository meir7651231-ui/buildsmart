// Live, in-app audit screen — generates 20 RANDOM installation scenarios
// each run and shows the auto-built plan + compliance result for each.
// Random anchors are sampled from the verified-spec catalog with bias
// toward diversity (supply vs drainage, hot vs cold, different materials),
// so every press of "הרץ" exercises a different slice of the engine.

import 'dart:math' as math;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter/material.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _ScenarioResult {
  _ScenarioResult({
    required this.title,
    required this.itemCount,
    required this.passed,
    required this.total,
    required this.criticalOpen,
    required this.dropBar,
    required this.minBoreMm,
    required this.items,
  });
  final String title;
  final int itemCount;
  final int passed;
  final int total;
  final int criticalOpen;
  final double dropBar;
  final double minBoreMm;
  final List<LipskeyCatalogProduct> items;
  bool get ok => criticalOpen == 0;
}

class _AuditScreenState extends State<AuditScreen> {
  final _results = <_ScenarioResult>[];
  bool _running = false;

  LipskeyCatalogProduct? _bySku(String sku) {
    final hits = kLipskeyCatalog.where((p) => p.sku == sku);
    return hits.isEmpty ? null : hits.first;
  }

  LipskeyCatalogProduct? _byCat(String cat, {String? type}) {
    final hits = kLipskeyCatalog.where((p) =>
        p.categoryHe == cat &&
        (type == null || p.productType == type) &&
        !p.sku.startsWith('HW-'));
    return hits.isEmpty ? null : hits.first;
  }

  /// Pool of catalog products that have a verified spec — these are the
  /// only anchors the engine can chain reliably. Built once on first run.
  late final List<LipskeyCatalogProduct> _pool = kLipskeyCatalog
      .where((p) => kVerifiedSpecs.containsKey(p.sku) && !p.sku.startsWith('HW-'))
      .toList();

  /// Group products by water system (supply vs drainage), so a random
  /// scenario picks two anchors that can plausibly connect.
  late final List<LipskeyCatalogProduct> _supplyPool = _pool
      .where((p) => productSystems(p).contains(WaterSystem.supply))
      .toList();
  late final List<LipskeyCatalogProduct> _drainagePool = _pool
      .where((p) => productSystems(p).contains(WaterSystem.drainage))
      .toList();

  String _titleFor(LipskeyCatalogProduct a, LipskeyCatalogProduct b,
      int tempC, bool loop) {
    final tempTag = tempC >= 60 ? '🔥 חם' : '❄ קר';
    final loopTag = loop ? ' (ריזרקולציה)' : '';
    final name = (LipskeyCatalogProduct p) =>
        p.nameHe.length > 28 ? '${p.nameHe.substring(0, 28)}…' : p.nameHe;
    return '$tempTag$loopTag: ${name(a)} → ${name(b)}';
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _results.clear();
    });

    final rnd = math.Random();
    for (var i = 0; i < 20; i++) {
      // Pick the system bucket: 70% supply, 30% drainage (matches catalog
      // distribution roughly).
      final useDrainage = rnd.nextDouble() < 0.30 && _drainagePool.length > 2;
      final pool = useDrainage ? _drainagePool : _supplyPool;
      // Random temperature: 60% cold, 30% hot, 10% hot+recirc (only for supply)
      final r = rnd.nextDouble();
      int tempC = 20;
      bool loop = false;
      if (!useDrainage) {
        if (r < 0.30) tempC = 60;
        else if (r < 0.40) {
          tempC = 60;
          loop = true;
        }
      }
      // Pick two DIFFERENT anchors
      final a = pool[rnd.nextInt(pool.length)];
      LipskeyCatalogProduct b;
      do {
        b = pool[rnd.nextInt(pool.length)];
      } while (b.sku == a.sku);

      final title = '${i + 1}) ${_titleFor(a, b, tempC, loop)}';
      final acc = <String>{'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'};
      final plan = buildInstallation([a, b],
          tempC: tempC, accessories: acc, loop: loop, autoCompliance: true);
      final checks = lineComplianceChecklist(plan.items, tempC, acc);
      final pd = estimatePressureDrop(plan.items,
          pipeLengthMeters: 5.0, flowRateLPS: 0.3);
      _results.add(_ScenarioResult(
        title: title,
        itemCount: plan.items.length,
        passed: checks.where((c) => c.satisfied).length,
        total: checks.length,
        criticalOpen: checks
            .where((c) => !c.satisfied && c.severity == CheckSeverity.critical)
            .length,
        dropBar: pd.dropBar,
        minBoreMm: pd.minBoreMm,
        items: plan.items,
      ));
      setState(() {}); // progressive update — user sees rows appear live
      await Future.delayed(const Duration(milliseconds: 80));
    }

    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final allOk = _results.isNotEmpty && _results.every((r) => r.ok);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111827),
          title: const Text('אודיט תרחישים',
              style: TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          actions: [
            if (_results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allOk
                          ? const Color(0xFF22C55E).withOpacity(0.2)
                          : const Color(0xFFEF4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_results.where((r) => r.ok).length}/${_results.length}',
                      style: TextStyle(
                          color: allOk
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _running ? null : _run,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE),
                    foregroundColor: const Color(0xFF06251C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(_running
                      ? Icons.hourglass_top
                      : Icons.play_arrow_rounded),
                  label: Text(
                      _running
                          ? 'מריץ ${_results.length}/20…'
                          : '⚡ הרץ 20 תרחישי בדיקה',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildRow(_results[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_ScenarioResult r) {
    final color = r.ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final overBudget = r.dropBar > 1.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(r.ok ? Icons.check_circle : Icons.error,
                color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(r.title,
                  style: const TextStyle(
                      color: Color(0xFFF1F5F9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${r.passed}/${r.total}',
                  style: TextStyle(
                      color: color,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.inventory_2_outlined,
                color: Color(0xFF7C8AA5), size: 13),
            const SizedBox(width: 4),
            Text('${r.itemCount} פריטים',
                style: const TextStyle(
                    color: Color(0xFF7C8AA5), fontSize: 11)),
            const SizedBox(width: 14),
            Icon(Icons.water_drop_outlined,
                color: overBudget
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF7C8AA5),
                size: 13),
            const SizedBox(width: 4),
            Text('ΔP ${r.dropBar.toStringAsFixed(2)} בר',
                style: TextStyle(
                    color: overBudget
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF7C8AA5),
                    fontSize: 11,
                    fontFamily: 'monospace')),
            const SizedBox(width: 14),
            const Icon(Icons.straighten,
                color: Color(0xFF7C8AA5), size: 13),
            const SizedBox(width: 4),
            Text('⌀${r.minBoreMm.toStringAsFixed(0)}mm',
                style: const TextStyle(
                    color: Color(0xFF7C8AA5),
                    fontSize: 11,
                    fontFamily: 'monospace')),
            if (r.criticalOpen > 0) ...[
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${r.criticalOpen} קריטי',
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ]),
          if (r.items.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final p in r.items.take(8))
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${p.typeEmoji} ${p.productType ?? "?"}',
                      style: const TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                if (r.items.length > 8)
                  Text('+${r.items.length - 8}',
                      style: const TextStyle(
                          color: Color(0xFF7C8AA5),
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
