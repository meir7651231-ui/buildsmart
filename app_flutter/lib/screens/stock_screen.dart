// T3.D · מלאי — proto §8 [L6202] (STOCK_DEMO) + [L8194-8241]
//   (pickStockTab / renderStock / moveStock). Verbatim behaviour:
//     • 2 tabs:  🏬 המחסן (warehouse)  ·  🏗️ האתר (site)
//     • rows filtered by the active tab; each row = thumb + name + why + move
//     • move button:  warehouse → "↦ לאתר"   site → "↤ למחסן"   (flips location)
//     • toast on move: 'הפריט הועבר'  (proto :8240)
//     • empty state per tab (se-ico / se-t / se-s) + hint (stock-hint)
//   Seed: kStockDemo (11) from data/phaseb_seeds.dart — name → 'warehouse'|'site'.
//
// Build entry: openStock (route()). The menu leaf wires here (REPORT WIRE).
//
// ANTI-COLLISION: NEW file (prefix stock_); no shared file edited.

import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/repositories/stock_local.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── editable stock state (mirrors proto STOCK_DEMO mutated by moveStock) ───────

class StockNotifier extends StateNotifier<Map<String, String>> {
  /// [seed] is the genesis stock map the screen starts from. It defaults to
  /// [kStockDemo] so direct construction stays byte-identical; the
  /// `stockProvider` injects it THROUGH the stock repository (T6.3) — the same
  /// 11-row map, just sourced via the seam.
  StockNotifier([Map<String, String>? seed])
      : super(Map<String, String>.from(seed ?? kStockDemo));

  /// moveStock(nm) (:8237) — flip a key between 'warehouse' and 'site'.
  void move(String name) {
    final cur = state[name];
    if (cur == null) return;
    state = {
      ...state,
      name: cur == 'warehouse' ? 'site' : 'warehouse',
    };
  }
}

final stockProvider =
    StateNotifierProvider<StockNotifier, Map<String, String>>((ref) {
  final repo = ref.read(stockRepositoryProvider);
  // Source the seed through the repository (the local impl exposes it). Any
  // non-local impl falls back to the const seed — identical 11-row map either way.
  final seed = repo is LocalStockRepository ? repo.stockDemo() : kStockDemo;
  return StockNotifier(seed);
});

final stockTabProvider = StateProvider<String>((_) => 'warehouse');

// ─── accessory lookup (proto accLookup over TREES.acc — img + why per name) ─────
// The 11 seeded items map to these accessory descriptions verbatim; anything
// unmatched falls back to 📦 with no "why" line, exactly like the prototype.
const Map<String, ({String img, String why})> _accInfo = {
  'סרט טפלון': (img: '🧵', why: 'איטום ההברגות'),
  'סרט טפלון (גליל)': (img: '🧵', why: 'איטום ההברגות'),
  'סרט טפלון לאיטום': (img: '🧵', why: 'איטום ההברגות'),
  'ברזי ניל זוויתיים': (img: '🚰', why: 'חיבור הברז לקו המים'),
  'ברז ניל זוויתי 1/2"': (img: '🚰', why: 'חיבור הברז לקו המים'),
  'ברז זוויתי לכיור 1/2"': (img: '🚰', why: 'חיבור הברז לקו המים'),
  'סיליקון סניטרי': (img: '🧴', why: 'איטום סניטרי עמיד מים'),
  'סיליקון סניטרי שקוף': (img: '🧴', why: 'איטום סניטרי עמיד מים'),
  'ברגי קיבוע': (img: '🔩', why: 'קיבוע לקיר'),
  'אטם גומי לברז': (img: '⭕', why: 'מניעת נזילות בחיבור'),
  'מחברים וזוויות': (img: '🔧', why: 'חיבור והסטה של הצנרת'),
};

const _ink = BsTokens.inkLight;
const _muted = Color(0xFF888888);

// ─── screen ─────────────────────────────────────────────────────────────────

/// Build entry `openStock` — "המלאי שלי" two-tab inventory with move.
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StockScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(stockTabProvider);
    final stock = ref.watch(stockProvider);
    final items = stock.entries
        .where((e) => e.value == tab)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: const Text('המלאי שלי',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // section title (📦 המלאי שלי)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('📦 המלאי שלי',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
            ),
          ),
          // tabs (stock-tabs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StockTab(
                  label: '🏬 המחסן',
                  on: tab == 'warehouse',
                  onTap: () => ref.read(stockTabProvider.notifier).state =
                      'warehouse',
                ),
                const SizedBox(width: 8),
                _StockTab(
                  label: '🏗️ האתר',
                  on: tab == 'site',
                  onTap: () =>
                      ref.read(stockTabProvider.notifier).state = 'site',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? _Empty(tab: tab)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final nm = items[i];
                      return _StockRow(
                        name: nm,
                        info: _accInfo[nm] ?? (img: '📦', why: ''),
                        warehouse: tab == 'warehouse',
                        onMove: () {
                          ref.read(stockProvider.notifier).move(nm);
                          showToast(context, 'הפריט הועבר');
                        },
                      );
                    },
                  ),
          ),
          // hint (stock-hint)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Text(
                '💡 כשתסמן פריט כ"במחסן" או "באתר" בעץ המוצרים — הוא יופיע כאן.',
                style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
          ),
        ],
      ),
    );
  }
}

class _StockTab extends StatelessWidget {
  const _StockTab(
      {required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? BsTokens.brand : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: on ? BsTokens.brand : const Color(0xFFEAEAEA)),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: on ? bsOnAccent(context) : _ink)),
          ),
        ),
      );
}

class _StockRow extends StatelessWidget {
  const _StockRow(
      {required this.name,
      required this.info,
      required this.warehouse,
      required this.onMove});
  final String name;
  final ({String img, String why}) info;
  final bool warehouse;
  final VoidCallback onMove;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(info.img, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  if (info.why.isNotEmpty)
                    Text(info.why,
                        style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onMove,
              style: OutlinedButton.styleFrom(
                foregroundColor: BsTokens.brand,
                side: const BorderSide(color: BsTokens.brand),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(warehouse ? '↦ לאתר' : '↤ למחסן',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab});
  final String tab;
  @override
  Widget build(BuildContext context) {
    final warehouse = tab == 'warehouse';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(warehouse ? '🏬' : '🏗️',
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(warehouse ? 'המחסן ריק' : 'אין פריטים באתר',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 6),
            Text(
                'סמן פריטים כ"${warehouse ? 'במחסן' : 'באתר'}" בעץ המוצרים והם יופיעו כאן',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _muted)),
          ],
        ),
      ),
    );
  }
}
