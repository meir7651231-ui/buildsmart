// 🧰 WORKER DAY-EQUIPMENT CHECKLIST (board W, task #112) — the DAY-level
// generalization of worker_task_detail_sheet.dart's per-task `_bringSection`
// (288-329): instead of "what to bring for THIS task", it aggregates the
// install-kit recommendation across EVERY task of the worker's current bucket
// into one deduped "ציוד נדרש להיום" checklist.
//
// REUSE (no new logic): the source of every line is the SAME pair the detail
// sheet uses — `productsForTask(t.id)` (task_skus_local.dart) →
// `recommendedKitForProduct(p)` (install_kit.dart, KitItem{kind,label,reason,
// severity}). Deduped by label across all tasks (a wrench two products both
// need shows once), merging the contributing task ids and keeping the
// most-severe occurrence. A task with NO SKU mapping (e.g. task 3 איטום — the
// plumbing catalogs carry no waterproofing products) contributes nothing and is
// listed honestly as "אין רשימת ציוד".
//
// HONESTY: the mapping is DEMO wiring (a manager does not attach products to a
// task yet) — the sheet says so in a visible DEMO-SEED hint.
//
// E2 (#112) — reads the EMPLOYER's stock READ-ONLY (via employerStockProvider):
// each equipment row is annotated with the EMPLOYING contractor's availability
// (🏬 מחסן / 🏗️ אתר / זמינות לא ידועה) so "do I have the gear?" reads the
// contractor's real stock. The worker still NEVER mutates that stock — moving
// items between warehouse and site stays the contractor's own action in
// stock_screen.dart — and we NEVER fabricate a label↔stock match (honest
// 'unknown' otherwise; see equipment_stock_join.dart). The employer is resolved
// from the worker's session `employerId` (board_auth.dart); the contractor's
// own stock is owned by the contractor, not surfaced as the worker's.
// The 'שלח רשימה לקבלן' action posts ONE chat line of the
// checked items into the existing th-worker-contractor thread via
// [chatEngineProvider] — guarded against an unknown thread (honest toast, no
// fake success) and against a double-send.

import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/logic/equipment_stock_join.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The worker↔contractor chat thread id (sys_chat seed `kWorkerChatThreads`).
/// A file-local copy of the literal the rest of the worker board uses verbatim
/// (worker_attendance_screen / worker_forms_screen send to the same id) — kept
/// here so this file owns its dependency without touching sys_chat's surface.
const String kWorkerContractorThreadId = 'th-worker-contractor';

/// One aggregated equipment line — a [KitItem] label seen across the day's
/// tasks, carrying its reason, severity (Hebrew string from
/// [KitItem.severityHe]: חובה/מומלץ/אופציונלי) and the ids of every task that
/// needs it (merged on dedup).
typedef DayEquipmentItem = ({
  String label,
  String reason,
  String severity,
  List<int> taskIds,
});

/// Numeric rank for a severity STRING (lower = more severe) — חובה<מומלץ<
/// אופציונלי. Drives both the "keep the most-severe occurrence" merge in
/// [equipmentForTasks] and the checklist sort in the sheet. An unknown string
/// sorts last (defensive — every real KitItem maps to one of the three).
int _severityRank(String severityHe) => switch (severityHe) {
      'חובה' => 0,
      'מומלץ' => 1,
      'אופציונלי' => 2,
      _ => 3,
    };

/// PURE day-level aggregation (the #112 core, unit-tested): over every task in
/// [tasks], collect `recommendedKitForProduct` for each product in
/// `productsForTask(t.id)`, DEDUP by [KitItem.label] — merging the contributing
/// task ids and keeping the most-severe occurrence (its reason rides along).
/// Tasks with NO SKU mapping (empty `productsForTask`) contribute nothing
/// (honest omission — the caller lists them separately). Order: severity then
/// label, so the result is deterministic for tests.
List<DayEquipmentItem> equipmentForTasks(List<TaskItem> tasks) {
  // label → (reason, severityHe, {taskIds}). A LinkedHashMap (default) keeps a
  // stable insertion order before the final sort.
  final byLabel = <String, ({String reason, String severity, Set<int> ids})>{};
  for (final t in tasks) {
    for (final p in productsForTask(t.id)) {
      for (final k in recommendedKitForProduct(p)) {
        final prev = byLabel[k.label];
        if (prev == null) {
          byLabel[k.label] = (
            reason: k.reason,
            severity: k.severityHe,
            ids: {t.id},
          );
        } else {
          // Merge this task into the line; keep the most-severe occurrence
          // (and adopt its reason) when this one outranks what we stored.
          prev.ids.add(t.id);
          if (_severityRank(k.severityHe) < _severityRank(prev.severity)) {
            byLabel[k.label] = (
              reason: k.reason,
              severity: k.severityHe,
              ids: prev.ids,
            );
          }
        }
      }
    }
  }
  final out = [
    for (final e in byLabel.entries)
      (
        label: e.key,
        reason: e.value.reason,
        severity: e.value.severity,
        taskIds: (e.value.ids.toList()..sort()),
      ),
  ];
  out.sort((a, b) {
    final s = _severityRank(a.severity).compareTo(_severityRank(b.severity));
    return s != 0 ? s : a.label.compareTo(b.label);
  });
  return out;
}

/// Opens the day-equipment checklist sheet for [tasks] (the worker's current
/// bucket — active/rejected — passed by the board, #112). Builder-A calls this
/// verbatim.
Future<void> showEquipmentChecklistSheet(
  BuildContext context,
  WidgetRef ref, {
  required List<TaskItem> tasks,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EquipmentChecklistSheet(tasks: tasks),
  );
}

class _EquipmentChecklistSheet extends ConsumerStatefulWidget {
  const _EquipmentChecklistSheet({required this.tasks});

  final List<TaskItem> tasks;

  @override
  ConsumerState<_EquipmentChecklistSheet> createState() =>
      _EquipmentChecklistSheetState();
}

class _EquipmentChecklistSheetState
    extends ConsumerState<_EquipmentChecklistSheet> {
  /// The aggregated lines — computed ONCE from the immutable [TaskItem] list
  /// (equipment is derived from the seed mapping, not live task status, so it
  /// does not change while the sheet is open).
  late final List<DayEquipmentItem> _items = equipmentForTasks(widget.tasks);

  /// Local checkbox state, keyed by equipment label. Default: every item
  /// checked (the worker un-checks what they already have on the van).
  late final Map<String, bool> _checked = {
    for (final it in _items) it.label: true,
  };

  /// The tasks with NO equipment mapping — listed honestly so the worker knows
  /// the day's coverage isn't silently dropping them.
  late final List<TaskItem> _unmapped =
      widget.tasks.where((t) => productsForTask(t.id).isEmpty).toList();

  /// Guard against a double 'שלח רשימה לקבלן' (one chat line per open sheet).
  bool _sent = false;

  void _sendToContractor() {
    if (_sent) return;
    final picked =
        _items.where((it) => _checked[it.label] ?? false).toList();
    if (picked.isEmpty) {
      showToast(context, 'אין פריטים מסומנים לשליחה');
      return;
    }
    // Honest unknown-thread guard: only post if the worker↔contractor thread
    // actually exists in the live engine — never fake a success toast.
    final threads = ref.read(chatEngineProvider);
    final hasThread =
        threads.any((t) => t.id == kWorkerContractorThreadId);
    if (!hasThread) {
      showToast(context, 'הצ׳אט עם הקבלן אינו זמין כרגע');
      return;
    }
    // ONE chat line: a titled, comma-joined list of the checked equipment.
    final line = 'ציוד נדרש להיום: ${picked.map((it) => it.label).join(', ')}';
    ref.read(chatEngineProvider.notifier).send(
          kWorkerContractorThreadId,
          BsRole.worker,
          line,
        );
    setState(() => _sent = true);
    showToast(context, '🧰 הרשימה נשלחה לקבלן');
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount =
        _items.where((it) => _checked[it.label] ?? false).length;
    // ── E2 (#112): READ-ONLY view of the EMPLOYER's stock ──
    // Resolve the worker's employer from the live session (null session — e.g.
    // the contractor app, or the bare-ProviderScope widget test — yields an
    // empty employerId → `const []` → every row honestly reads 'unknown').
    // The worker only SEES this stock; it is never mutated here.
    final employerId = ref.watch(boardAuthProvider)?.employerId ?? '';
    final stock = ref.watch(employerStockProvider(employerId));
    return _sheetShell(
      children: [
        const Text(
          '🧰 ציוד נדרש להיום',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _items.isEmpty
              ? 'אין פריטי ציוד למשימות היום'
              : 'סומנו $checkedCount מתוך ${_items.length} פריטים',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),

        // ── DEMO-SEED hint (clearly visible, contract §22) ──
        const SizedBox(height: BsTokens.space3),
        Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E3),
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: const Text(
            'רשימת הציוד נגזרת ממיפוי דמו של מוצרים למשימה — תחובר עם השרת',
            style: TextStyle(
              color: BsTokens.brandDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── aggregated checklist (severity-sorted), or honest empty line ──
        const SizedBox(height: BsTokens.space3),
        const _SecH('צ׳קליסט ציוד'),
        if (_items.isEmpty)
          const Text(
            'אין רשימת ציוד למשימות הנוכחיות',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          )
        else
          for (final it in _items)
            _EquipmentRow(
              item: it,
              checked: _checked[it.label] ?? false,
              // E2: the employer's READ-ONLY stock availability for this line
              // (honest 'unknown' when no stock / no match — never fabricated).
              availability: availabilityFor(it.label, stock),
              onChanged: (v) =>
                  setState(() => _checked[it.label] = v ?? false),
            ),

        // ── tasks with no equipment mapping (honest omission) ──
        if (_unmapped.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('משימות ללא רשימת ציוד'),
          for (final t in _unmapped)
            Padding(
              padding: const EdgeInsets.only(top: BsTokens.space1),
              child: Text(
                'אין רשימת ציוד: ${t.name}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              ),
            ),
        ],

        // ── send-to-contractor action ──
        const SizedBox(height: BsTokens.space4),
        _PrimaryBtn(
          key: const ValueKey('equipment-send-contractor'),
          label: _sent ? '✓ נשלח לקבלן' : 'שלח רשימה לקבלן',
          onTap: _sent ? null : _sendToContractor,
        ),
        const SizedBox(height: BsTokens.space2),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('סגור'),
        ),
      ],
    );
  }

  /// Shared sheet chrome — RTL + draggable rounded container with the grab
  /// handle and an explicit 48dp ✕ close (mirrors worker_task_detail_sheet's
  /// `_sheetShell`).
  Widget _sheetShell({required List<Widget> children}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
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

/// One checklist row (≥48dp) — a leading checkbox + the install-kit line
/// rendering of worker_task_detail_sheet's `_KitRow` (label + reason + severity
/// pill), with the contributing task count appended honestly.
class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({
    required this.item,
    required this.checked,
    required this.availability,
    required this.onChanged,
  });

  final DayEquipmentItem item;
  final bool checked;

  /// The EMPLOYER's READ-ONLY stock availability for this line (E2), rendered
  /// as a small chip. [StockAvailability.unknown] is honest — no stock or no
  /// match (never a fabricated correspondence).
  final StockAvailability availability;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isRequired = item.severity == 'חובה';
    final taskCount = item.taskIds.length;
    return InkWell(
      onTap: () => onChanged(!checked),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BsTokens.space1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ≥48dp tap target via the row min-height + the checkbox itself.
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: checked,
                  activeColor: BsTokens.brand,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: BsTokens.space1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      item.reason,
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                    // Honest: how many of the day's tasks need this item.
                    Text(
                      taskCount == 1
                          ? 'למשימה אחת'
                          : 'ל-$taskCount משימות',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 11,
                      ),
                    ),
                    // E2: the employer's READ-ONLY stock availability chip
                    // (its own top padding spaces it from the line above).
                    _AvailabilityChip(availability: availability),
                  ],
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRequired
                        ? const Color(0xFFFFF0E3)
                        : const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: Text(
                    item.severity,
                    style: TextStyle(
                      color:
                          isRequired ? BsTokens.brandDark : BsTokens.mutedLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// E2 (#112) — a small read-only chip showing the EMPLOYER's stock
/// availability for one equipment line: 🏬 מחסן (warehouse) / 🏗️ אתר (site) /
/// 'זמינות לא ידועה' (unknown — no stock or no honest match, never fabricated).
/// Mirrors the severity-pill styling so the row reads as one coherent line.
class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.availability});

  final StockAvailability availability;

  @override
  Widget build(BuildContext context) {
    final (String text, Color bg, Color fg) = switch (availability) {
      StockAvailability.warehouse => (
          '🏬 מחסן',
          const Color(0xFFE3F0FF),
          BsTokens.brandDark,
        ),
      StockAvailability.site => (
          '🏗️ אתר',
          const Color(0xFFE3F7E8),
          const Color(0xFF1B6B33),
        ),
      // Honest unknown — no stock connected / no match. Muted, never green.
      StockAvailability.unknown => (
          'זמינות לא ידועה',
          const Color(0xFFF2F3F5),
          BsTokens.mutedLight,
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Small section header — the `_SecH` idiom from worker_task_detail_sheet.
class _SecH extends StatelessWidget {
  const _SecH(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space1),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Brand-fill pill action (worker_task_detail_sheet's `_PrimaryBtn`) — a null
/// [onTap] renders the disabled "already sent" state (the double-send guard).
class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: 11,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
