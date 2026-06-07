// T3.E · סריקה-תפריט — proto §9 [L9658-9760] (PLAN_TYPES + renderPlanPicker /
//   pickPlan / bestStore / startScan / addScanToCart). Full menu-reachable scan
//   flow over the 4 plan types:
//     picker (4 kPlanTypes) → scan animation (4 steps verbatim) → detected zones
//     with per-item 3-store price comparison (cheapest highlighted) → scan→cart.
//   scan→cart is SIMULATED: it adds the cheapest offer of every detected item to
//   the real smart-cart and shows an IN-SCREEN confirmation panel (NOT a toast),
//   per the track spec ("scan→cart simulated result, NOT toast").
//   Seed: kPlanTypes / bestStore from data/contractor_seeds.dart.
//   Reuses lib/state/smart_cart.dart (cart).
//
// Build entry: openScan (route()). The menu leaves wire here (REPORT WIRE) —
//   the picker honours an optional initial plan key (plan-plumbing/electric/…).
//
// ANTI-COLLISION: NEW file (prefix scan_); no shared file edited.

import 'dart:async';

import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF888888);

/// Cart lines for a scanned plan — each detected zone item at its cheapest
/// partner-store offer (proto §9 addScanToCart). Pure helper.
List<SmartCartLine> scanMenuCartLines(PlanType plan) {
  final out = <SmartCartLine>[];
  for (final z in plan.zones) {
    for (final it in z.items) {
      if (it.stores.isEmpty) continue;
      final best = it.stores[bestStore(it.stores)];
      out.add(SmartCartLine(
        productKey: 'scan:${plan.key}:${it.name}',
        productName: it.name,
        productEmoji: it.emoji,
        brandName: best.store,
        brandPrice: best.price,
        productQty: 1,
        accessories: const [],
      ));
    }
  }
  return out;
}

/// Build entry `openScan` — "סרוק תוכנית עבודה".
/// [initialPlanKey] optionally jumps straight into a plan (menu leaf wiring).
class ScanMenuScreen extends ConsumerStatefulWidget {
  const ScanMenuScreen({super.key, this.initialPlanKey});

  final String? initialPlanKey;

  static Route<void> route({String? planKey}) => MaterialPageRoute<void>(
      builder: (_) => ScanMenuScreen(initialPlanKey: planKey));

  @override
  ConsumerState<ScanMenuScreen> createState() => _ScanMenuScreenState();
}

enum _Phase { picker, scanning, results, added }

class _ScanMenuScreenState extends ConsumerState<ScanMenuScreen> {
  _Phase _phase = _Phase.picker;
  PlanType? _plan;
  int _stepIdx = 0;
  int _addedCount = 0;
  int _addedTotal = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final key = widget.initialPlanKey;
    if (key != null) {
      final hit = kPlanTypes.where((p) => p.key == key);
      if (hit.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _start(hit.first));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // startScan(:9744) — step through the 4 plan steps then reveal results.
  void _start(PlanType p) {
    setState(() {
      _plan = p;
      _phase = _Phase.scanning;
      _stepIdx = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_stepIdx < p.steps.length - 1) {
        setState(() => _stepIdx++);
      } else {
        t.cancel();
        setState(() => _phase = _Phase.results);
      }
    });
  }

  // addScanToCart — simulated scan→cart: add cheapest offers, show in-screen
  // confirmation (NOT a toast).
  void _addToCart(PlanType p) {
    final lines = scanMenuCartLines(p);
    final cart = ref.read(smartCartProvider.notifier);
    for (final l in lines) {
      cart.add(l);
    }
    setState(() {
      _phase = _Phase.added;
      _addedCount = lines.length;
      _addedTotal = lines.fold<int>(0, (s, l) => s + l.brandPrice);
    });
  }

  void _reset() => setState(() {
        _phase = _Phase.picker;
        _plan = null;
        _stepIdx = 0;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: const Text('סרוק תוכנית עבודה',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
      ),
      body: switch (_phase) {
        _Phase.picker => _picker(),
        _Phase.scanning => _scanning(_plan!),
        _Phase.results => _results(_plan!),
        _Phase.added => _added(_plan!),
      },
    );
  }

  // renderPlanPicker(:9734) — 4 plan-type cards.
  Widget _picker() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('📐 בחר סוג תוכנית לסריקה',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 12),
          for (final p in kPlanTypes)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: ListTile(
                leading: Text(p.icon, style: const TextStyle(fontSize: 28)),
                title: Text(p.label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                subtitle: Text(p.sub,
                    style: const TextStyle(fontSize: 12, color: _muted)),
                trailing:
                    const Icon(Icons.chevron_left, color: _muted),
                onTap: () => _start(p),
              ),
            ),
        ],
      );

  Widget _scanning(PlanType p) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: BsTokens.brand)),
              const SizedBox(height: 20),
              Text('${p.icon} ${p.label}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink)),
              const SizedBox(height: 8),
              const Text('מנתח את תצורת הבנייה ומחלץ כמויות חומרים…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink)),
              const SizedBox(height: 10),
              Text(p.steps[_stepIdx],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _muted)),
            ],
          ),
        ),
      );

  // results — detected zones + per-item store comparison + scan→cart button.
  Widget _results(PlanType p) {
    final lines = scanMenuCartLines(p);
    final total = lines.fold<int>(0, (s, l) => s + l.brandPrice);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('✓ זוהו ${p.zones.length} ${p.summaryUnit}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              const SizedBox(height: 2),
              Text('${lines.length} פריטים · ההצעה הזולה ₪$total',
                  style: const TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 8),
              const Text(
                  '💰 המחירים נמשכים מ-3 חנויות שותפות. BuildSmart בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
              const SizedBox(height: 12),
              for (final z in p.zones) ..._zone(z),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style:
                        FilledButton.styleFrom(backgroundColor: BsTokens.brand),
                    onPressed: () => _addToCart(p),
                    child: Text('אשר הכל — הוסף ${lines.length} פריטים לסל'),
                  ),
                ),
                TextButton(
                    onPressed: _reset,
                    child: const Text('סרוק תוכנית אחרת')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _zone(ScanZone z) => [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text('${z.emoji} ${z.name}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ),
              Text('ודאות ${z.conf}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: z.conf < 88
                          ? const Color(0xFFE08A00)
                          : const Color(0xFF2E9E5B))),
            ],
          ),
        ),
        for (final it in z.items) _itemRow(it),
      ];

  Widget _itemRow(ScanItem it) {
    final bi = it.stores.isEmpty ? 0 : bestStore(it.stores);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${it.emoji} ${it.name}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink)),
          Text(it.meta,
              style: const TextStyle(fontSize: 11, color: _muted)),
          if (it.stores.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var s = 0; s < it.stores.length; s++)
                  _chip(it.stores[s], s == bi),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(StoreOffer o, bool best) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: best ? const Color(0xFFE8F7EE) : const Color(0xFFF1F2F5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: best ? const Color(0xFF2E9E5B) : const Color(0xFFE3E5EA)),
        ),
        child: Text('${o.store} ₪${o.price}${best ? ' ✓' : ''}',
            style: TextStyle(
                fontSize: 11,
                fontWeight: best ? FontWeight.w700 : FontWeight.w500,
                color: best ? const Color(0xFF2E9E5B) : _ink)),
      );

  // simulated scan→cart confirmation panel (NOT a toast).
  Widget _added(PlanType p) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text('$_addedCount פריטים מהתוכנית נוספו לסל',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
              const SizedBox(height: 4),
              Text('${p.icon} ${p.label} · סה״כ ₪$_addedTotal',
                  style: const TextStyle(fontSize: 13, color: _muted)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: BsTokens.brand),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('סגור'),
                ),
              ),
              TextButton(
                  onPressed: _reset,
                  child: const Text('סרוק תוכנית נוספת')),
            ],
          ),
        ),
      );
}
