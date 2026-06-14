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
//
// Wave E3 — the worker also files a STRUCTURED material request to the
// employing contractor from this sheet ("🧱 בקש חומרים"): free-text items
// (one per line) + an optional note → `materialRequestsProvider.submit(...)`.
// This is a REQUEST entity (`material_requests_engine.dart`), NOT a stock edit
// — the worker stays read-only on stock. The worker's OWN recent requests +
// their live status (advanced by the contractor in E3b) render here too,
// filtered by `requestsForWorker(session.uid)`. אין-המצאות: items are only
// what the worker typed; empty input never sends.

import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
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

class _EmployerStockSheet extends ConsumerStatefulWidget {
  const _EmployerStockSheet();

  @override
  ConsumerState<_EmployerStockSheet> createState() =>
      _EmployerStockSheetState();
}

class _EmployerStockSheetState extends ConsumerState<_EmployerStockSheet> {
  /// The "🧱 בקש חומרים" input — one item per line + an optional note. Local
  /// to the sheet (no provider): the worker types, presses send, the engine
  /// owns the persisted request from there.
  final TextEditingController _itemsCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  /// Whether the request composer is expanded (collapsed by default so the
  /// sheet still leads with the read-only stock — the E1 surface).
  bool _composing = false;

  @override
  void dispose() {
    _itemsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Wave-0 employment link → the employer's read-only stock. A null
    // session (defensive — the board gate means a worker is logged in here)
    // or an empty employerId both resolve to an empty list → the honest
    // empty state below.
    final session = ref.watch(boardAuthProvider);
    final items =
        ref.watch(employerStockProvider(session?.employerId ?? ''));
    // The worker's OWN material requests (newest-first) + their live status —
    // the contractor advances status in E3b and it flips here live.
    final myRequests =
        ref.watch(requestsForWorker(session?.uid ?? ''));

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

        // ── Wave E3 — request materials (a REQUEST, not a stock edit) ──────
        const SizedBox(height: BsTokens.space4),
        const Divider(height: 1, color: BsTokens.divider),
        const SizedBox(height: BsTokens.space4),
        _RequestComposer(
          composing: _composing,
          itemsCtrl: _itemsCtrl,
          noteCtrl: _noteCtrl,
          onToggle: () => setState(() => _composing = !_composing),
          onSend: () => _send(session),
        ),

        // ── The worker's OWN recent requests + live status ────────────────
        if (myRequests.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space4),
          const Text(
            'הבקשות שלי',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          for (final r in myRequests) _MyRequestRow(request: r),
        ],

        const SizedBox(height: BsTokens.space4),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('סגור'),
        ),
      ],
    );
  }

  /// Submit the typed items to the employing contractor. אין-המצאות: empty
  /// items → NO send + an honest toast; otherwise file the request via the
  /// engine (empty lines are dropped there too) and confirm honestly.
  void _send(BoardSession? session) {
    final lines = _itemsCtrl.text.split('\n');
    final hasItem = lines.any((l) => l.trim().isNotEmpty);
    if (!hasItem) {
      _toast('כתוב לפחות פריט אחד כדי לשלוח בקשה');
      return;
    }
    ref.read(materialRequestsProvider.notifier).submit(
          employerId: session?.employerId ?? '',
          workerUid: session?.uid ?? '',
          workerName: session?.displayName ?? '',
          items: lines,
          note: _noteCtrl.text,
        );
    _itemsCtrl.clear();
    _noteCtrl.clear();
    setState(() => _composing = false);
    _toast('הבקשה נשלחה לקבלן');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
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

/// Wave E3 — the "🧱 בקש חומרים" action. Collapsed it is a single ≥48dp button
/// (the sheet still leads with the read-only stock); expanded it reveals the
/// items input (one per line) + an optional note + a send button. This is a
/// REQUEST composer — it NEVER touches stock.
class _RequestComposer extends StatelessWidget {
  const _RequestComposer({
    required this.composing,
    required this.itemsCtrl,
    required this.noteCtrl,
    required this.onToggle,
    required this.onSend,
  });

  final bool composing;
  final TextEditingController itemsCtrl;
  final TextEditingController noteCtrl;
  final VoidCallback onToggle;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (!composing) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onToggle,
          style: FilledButton.styleFrom(
            backgroundColor: BsTokens.brand,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: const Text('🧱', style: TextStyle(fontSize: 16)),
          label: const Text(
            'בקש חומרים',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🧱 בקשת חומרים מהקבלן',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          const Text(
            'כתוב פריט אחד בכל שורה. הבקשה נשלחת לקבלן המעסיק — לא משנה את המלאי.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
          const SizedBox(height: BsTokens.space3),
          TextField(
            controller: itemsCtrl,
            maxLines: 4,
            minLines: 3,
            textDirection: TextDirection.rtl,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'לדוגמה:\nסרט טפלון\nברך 1/2 צול\nאטם גומי',
              filled: true,
              fillColor: BsTokens.cardLight,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          TextField(
            controller: noteCtrl,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'הערה (לא חובה)',
              hintText: 'לדוגמה: דחוף, נגמר באתר',
              filled: true,
              fillColor: BsTokens.cardLight,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onSend,
                  style: FilledButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    'שלח בקשה',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              OutlinedButton(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('בטל'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the worker's OWN requests — its items + a live status chip the
/// contractor advances (requested → ordered → supplied / declined). Read-only:
/// the worker sees the status, the contractor moves it (E3b).
class _MyRequestRow extends StatelessWidget {
  const _MyRequestRow({required this.request});

  final MaterialRequest request;

  /// Hebrew label + color per status — the single place the lifecycle is
  /// surfaced to the worker. Falls back to the raw status (defensive; the
  /// engine guards to [kMatReqStatuses] so this should not be hit).
  ({String label, Color fg, Color bg}) get _statusChip {
    switch (request.status) {
      case kMatReqOrdered:
        return (label: 'הוזמן', fg: BsTokens.warnText, bg: const Color(0xFFFFF4E0));
      case kMatReqSupplied:
        return (label: 'סופק', fg: BsTokens.successDark, bg: const Color(0xFFE7F7ED));
      case kMatReqDeclined:
        return (label: 'נדחה', fg: BsTokens.dangerDark, bg: const Color(0xFFFDE8E8));
      case kMatReqRequested:
        return (label: 'ממתין', fg: BsTokens.mutedLight, bg: const Color(0xFFF2F3F5));
      default:
        return (label: request.status, fg: BsTokens.mutedLight, bg: const Color(0xFFF2F3F5));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _statusChip;
    final itemsLine =
        request.items.isEmpty ? '—' : request.items.join(' · ');
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemsLine,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (request.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    request.note,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: BsTokens.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chip.bg,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(
              chip.label,
              style: TextStyle(
                color: chip.fg,
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
