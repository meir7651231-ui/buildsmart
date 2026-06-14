// 📦 WORKER → EMPLOYER STOCK (Wave E1, READ-ONLY) — the worker SEES the
// employing contractor's stock; it owns no stock and NEVER mutates it.
//
// Resolved via the Wave-0 link `session.employerId` (board_auth.dart) through
// [employerStockProvider] (state/employer_stock.dart) — the read-only
// projection of the contractor's live [stockProvider] map. NO edit/move
// controls (that is the contractor's own action in stock_screen.dart). Honest
// empty state when the list isEmpty (no link yet / the contractor hasn't
// shared stock / server not connected). RTL sheet with the ≥48dp ✕ close,
// mirroring worker_equipment_checklist_sheet's `_sheetShell` (sheet rule F-46).

import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the read-only employer-stock sheet — the worker views the employing
/// contractor's stock (resolved via `session.employerId`). Builder E1b/E2 call
/// this verbatim.
Future<void> showEmployerStockSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EmployerStockSheet(),
  );
}

class _EmployerStockSheet extends ConsumerWidget {
  const _EmployerStockSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The Wave-0 employment link → the employer's read-only stock. A null
    // session (defensive — the board gate means a worker is logged in here)
    // or an empty employerId both resolve to an empty list → the honest
    // empty state below.
    final session = ref.watch(boardAuthProvider);
    final items =
        ref.watch(employerStockProvider(session?.employerId ?? ''));

    return _sheetShell(
      context: context,
      children: [
        const Text(
          '📦 מלאי הקבלן',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          items.isEmpty
              ? 'תצוגה בלבד — המלאי של הקבלן המעסיק'
              : 'תצוגה בלבד · ${items.length} פריטים',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),
        if (items.isEmpty)
          // Honest empty state — no link yet / the contractor hasn't shared
          // stock / the server isn't connected. NEVER a fabricated list.
          Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'הקבלן טרם שיתף מלאי',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: BsTokens.space1),
                Text(
                  'רשימת המלאי תוצג כאן כשתחובר עם השרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
              ],
            ),
          )
        else
          for (final it in items) _StockRow(item: it),
        const SizedBox(height: BsTokens.space4),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('סגור'),
        ),
      ],
    );
  }

  /// Shared sheet chrome — RTL + draggable rounded container with the grab
  /// handle and an explicit 48dp ✕ close (mirrors
  /// worker_equipment_checklist_sheet's `_sheetShell`, sheet rule F-46).
  Widget _sheetShell({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: BsTokens.space1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: 'סגור',
                        child: IconButton(
                          tooltip: 'סגור',
                          icon: const Icon(Icons.close,
                              color: Color(0xFF888888)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// One read-only stock row — the item name + a 🏬 מחסן / 🏗️ אתר location chip.
/// NO move/edit control (the worker is read-only on employer stock). ≥48dp.
class _StockRow extends StatelessWidget {
  const _StockRow({required this.item});

  final EmployerStockItem item;

  @override
  Widget build(BuildContext context) {
    final warehouse = item.location == 'warehouse';
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: BsTokens.space2,
      ),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: BsTokens.space2),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: warehouse
                  ? const Color(0xFFF2F3F5)
                  : const Color(0xFFFFF0E3),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(
              warehouse ? '🏬 מחסן' : '🏗️ אתר',
              style: TextStyle(
                color: warehouse ? BsTokens.mutedLight : BsTokens.brandDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
