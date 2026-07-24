// 📊 מרכז פיננסים — the finance-hub UI (Track T1, proto §4 / index.html
// 19459-19806). Ten leaf tools, each opening a bottom-sheet (or a full
// report-view screen for the PDF report) with VERBATIM Hebrew strings + math
// ported 1:1 from the prototype's `fin*` functions.
//
// Math + live state are REUSED, not rebuilt:
//   • const seeds          → data/phaseb_seeds.dart (kBuildIndex, kPaymentTerms,
//                            kSubcontractors, kApprovalQueue, kFxRates …) +
//                            data/contractor_seeds.dart (budget seeds + fMoney).
//   • pure math helpers    → phaseb_seeds.dart (buildIndexDeltaPct, linkedBudget,
//                            roiValue, projectRoi, invoiceSplit, budgetPct).
//   • live runtime state   → state/finance_hub_state.dart (activePaymentTerm,
//                            approvalQueue, penaltyLedger, RBAC requirePerm + audit).
//
// Style matches the app's existing bottom-sheet tools (persona_portal.dart):
// rounded-top white sheet · RTL · md-head (icon + title + sub) · scrollable.
//
// Public entries (the menu wires the `fin-*` leaf ids here — see openFinanceLeaf):
//   • openFinanceHub(context)            — the 10-tile grid (parent `fin-hub`).
//   • openFinanceLeaf(context, id)       — dispatch a single `fin-*` leaf.

import 'package:buildsmart/config/app_brand.dart' show AppBrand;
import 'package:buildsmart/data/contractor_seeds.dart' show caToday, fMoney;
// Const budget data (total/spent/categories/pct) is read THROUGH the finance
// repository's GLOBAL, Ref-free accessor `financeRepo()` (the server-ready seam,
// T6.3) instead of the raw consts — these top-level `_open*` functions have no
// [WidgetRef], and the accessor returns the SAME consts, so every displayed
// value stays byte-identical. The phaseb_seeds math helpers (linkedBudget,
// projectRoi, invoiceSplit, buildIndexDeltaPct, kFxRates …) are unchanged.
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/repositories/backend.dart'
    show useFirebaseBackend;
import 'package:buildsmart/data/repositories/finance_firebase.dart'
    show FirebaseFinanceRepository;
import 'package:buildsmart/data/repositories/finance_local.dart' show financeRepo;
import 'package:buildsmart/logic/finance_report_pdf.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/finance_hub_state.dart';
import 'package:buildsmart/state/pdf_print_seam.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PALETTE — finance-sheet specific colours (proto fin-up / fin-dn / danger).
// ═════════════════════════════════════════════════════════════════════════════
const Color _kUp = Color(0xFF1FA971); // fin-up (green, positive change/profit)
const Color _kDn = Color(
  0xFFE5484D,
); // fin-dn / --danger (red, negative/penalty)
const Color _kBrandTeal = BsTokens.brand; // W0: unified to brand (was teal); name kept

// ═════════════════════════════════════════════════════════════════════════════
// PUBLIC ENTRIES
// ═════════════════════════════════════════════════════════════════════════════

/// Opens the מרכז פיננסים hub — a 2-col grid of the 10 finance tiles.
/// proto `openFinanceHub` @index.html:19489. Tapping a tile opens its leaf sheet.
void openFinanceHub(BuildContext context) {
  _showFinSheet(context, child: _FinanceHubGrid(parentCtx: context));
}

/// Dispatch a single finance leaf by its menu `fin-*` id (see kFinanceHub in
/// data/menu_trees.dart). Unknown ids fall through to the hub grid.
void openFinanceLeaf(BuildContext context, String id) {
  switch (id) {
    case 'fin-index':
      _openIndex(context);
    case 'fin-payterms':
      _openPayTerms(context);
    case 'fin-subs':
      _openSubs(context);
    case 'fin-approvals':
      _openApprovals(context);
    case 'fin-thresh':
      _openThresholds(context);
    case 'fin-roi':
      _openRoi(context);
    case 'fin-invsplit':
      _openInvoiceSplit(context);
    case 'fin-penalty':
      _openPenalties(context);
    case 'fin-reports':
      _openReports(context);
    case 'fin-fx':
      _openFx(context);
    case 'fin-hub':
    default:
      openFinanceHub(context);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHEET SCAFFOLD — shared rounded-top white sheet (matches persona_portal style).
// ═════════════════════════════════════════════════════════════════════════════
void _showFinSheet(BuildContext context, {required Widget child}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BsTokens.cardLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.86,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  BsTokens.space4,
                  BsTokens.space4,
                  BsTokens.space5,
                ),
                child: child,
              ),
            ),
          ),
        ),
  );
}

/// The `md-head` block — big emoji + title + sub-line (proto every fin* head).
class _FinHead extends StatelessWidget {
  const _FinHead({required this.ic, required this.title, required this.sub});
  final String ic;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(ic, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),
      ],
    );
  }
}

/// A `fin-row` — label on the right, bold value on the left (RTL). Optional
/// value colour for fin-up/fin-dn deltas.
class _FinRow extends StatelessWidget {
  const _FinRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// A boxed group of [_FinRow]s (proto `.fin-rows`).
class _FinRows extends StatelessWidget {
  const _FinRows(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE6E8EC)),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// The teal `.fin-callout` highlight box — label + value (+ optional big / note).
class _FinCallout extends StatelessWidget {
  const _FinCallout({
    required this.label,
    required this.value,
    this.big = false,
    this.valueColor,
    this.note,
    this.secondLabel,
    this.secondValue,
  });
  final String label;
  final String value;
  final bool big;
  final Color? valueColor;
  final String? note;
  final String? secondLabel;
  final String? secondValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: BsTokens.space4),
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F4),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFCDE7E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: _kBrandTeal, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: big ? 26 : 18,
            ),
          ),
          if (secondLabel != null) ...[
            const SizedBox(height: BsTokens.space2),
            Text(
              secondLabel!,
              style: const TextStyle(color: _kBrandTeal, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            Text(
              secondValue ?? '',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(
              note!,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// The orange primary CTA button (proto `.ca-primary`).
class _CaPrimary extends StatelessWidget {
  const _CaPrimary({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: BsTokens.brand,
          foregroundColor: bsOnAccent(context),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        child: Text(label),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// THE HUB GRID — 10 tiles (proto openFinanceHub items, verbatim ic/t/s).
// ═════════════════════════════════════════════════════════════════════════════
class _FinTile {
  const _FinTile(this.id, this.ic, this.t, this.s);
  final String id;
  final String ic;
  final String t;
  final String s;
}

const List<_FinTile> _kFinTiles = [
  _FinTile('fin-index', '📈', 'הצמדה למדד', 'מדד תשומות הבנייה'),
  _FinTile('fin-payterms', '🗓️', 'תנאי תשלום', 'שוטף+30/60, אבני דרך'),
  _FinTile('fin-subs', '👷', 'קבלני משנה', 'תקציב וחלוקה'),
  _FinTile('fin-approvals', '✅', 'אישורי רכש', 'Approval workflow'),
  _FinTile('fin-thresh', '🔔', 'התראות חריגה', '80% / 90% מהתקציב'),
  _FinTile('fin-roi', '📊', 'ניתוח ROI', 'תשואה על ההשקעה'),
  _FinTile('fin-invsplit', '🧾', 'פיצול חשבוניות', 'לפי סעיפי תקציב'),
  _FinTile('fin-penalty', '⏰', 'פיצויים וקנסות', 'איחורים באספקה'),
  _FinTile('fin-reports', '📄', 'דוחות PDF', 'דוח רשמי להורדה'),
  _FinTile('fin-fx', '💱', 'רכש במט״ח', 'שערים בזמן אמת'),
];

class _FinanceHubGrid extends StatelessWidget {
  const _FinanceHubGrid({required this.parentCtx});
  final BuildContext parentCtx;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FinHead(
          ic: '📊',
          title: 'מרכז פיננסים',
          sub: 'ניהול פיננסי מלא של הפרויקט — תקציב, תשלומים, אישורים ודוחות.',
        ),
        Flexible(
          child: SingleChildScrollView(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: BsTokens.space3,
              crossAxisSpacing: BsTokens.space3,
              childAspectRatio: 1.25,
              children: [
                for (final t in _kFinTiles)
                  _FinTileButton(
                    tile: t,
                    onTap: () {
                      Navigator.of(context).pop();
                      openFinanceLeaf(parentCtx, t.id);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FinTileButton extends StatelessWidget {
  const _FinTileButton({required this.tile, required this.onTap});
  final _FinTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(cfgRadius(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(color: const Color(0xFFE6E8EC)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tile.ic, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                tile.t,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tile.s,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.1 — הצמדה למדד · proto finIndex @index.html:19520
//   base 121.3 → cur 128.7 = +6.10% · linked budget = round(total*(1+pct/100))
// ═════════════════════════════════════════════════════════════════════════════
void _openIndex(BuildContext context) {
  final pct = buildIndexDeltaPct(); // +6.0997…
  final budget = financeRepo().budgetTotal(); // == kBudgetTotal (15000)
  final linked = linkedBudget(budget);
  final up = pct >= 0;
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '📈',
            title: 'הצמדה למדד',
            // proto: BUILD_INDEX.label + ' — עדכון אוטומטי של ערכי החוזה.'
            sub: 'מדד תשומות הבנייה — עדכון אוטומטי של ערכי החוזה.',
          ),
          // proto `.ca-server-note`
          Container(
            padding: const EdgeInsets.all(BsTokens.space3),
            margin: const EdgeInsets.only(bottom: BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: const CfgText(
              'finance_hub_sheets.index_server_note',
              '⚙️ נתוני המדד מתעדכנים מהשרת',
              style: TextStyle(color: Color(0xFF8A6D00), fontSize: 12.5),
            ),
          ),
          _FinRows(useFirebaseBackend ? const <Widget>[] : [
            _FinRow(
              'מדד בסיס (חתימת חוזה)',
              kBuildIndex.base.toStringAsFixed(1),
            ),
            _FinRow('מדד נוכחי', kBuildIndex.current.toStringAsFixed(1)),
            _FinRow(
              'שינוי',
              '${up ? '+' : ''}${pct.toStringAsFixed(2)}%',
              valueColor: up ? _kUp : _kDn,
            ),
          ]),
          if (!useFirebaseBackend) _FinCallout(
            label: 'תקציב מקורי',
            value: fMoney(budget),
            secondLabel: 'תקציב צמוד-מדד',
            secondValue: fMoney(linked),
            note: 'תוספת הצמדה: ${fMoney(linked - budget)}',
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.2 — תנאי תשלום · proto finPayTerms @index.html:19545 + setPaymentTerm @19560
//   4 PAYMENT_TERMS · select (persist via activePaymentTermProvider) + toast.
// ═════════════════════════════════════════════════════════════════════════════
void _openPayTerms(BuildContext context) {
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '🗓️',
            title: 'תנאי תשלום',
            sub: 'בחר את תנאי התשלום של הפרויקט — משפיע על מועדי החיוב.',
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final active = ref.watch(activePaymentTermProvider);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final t in kPaymentTerms)
                    Padding(
                      padding: const EdgeInsets.only(bottom: BsTokens.space2),
                      child: _PayOpt(
                        term: t,
                        on: active == t.id,
                        onTap: () {
                          ref.read(activePaymentTermProvider.notifier).state =
                              t.id;
                          // S-connect: on the live backend ALSO persist via the
                          // finance repo. The in-memory notifier above is the
                          // demo path; when connected the reads come from
                          // financeRepo(), so the term must reach Firestore too.
                          if (useFirebaseBackend) {
                            final r = financeRepo();
                            if (r is FirebaseFinanceRepository) {
                              r.setPaymentTerm(t.id);
                            }
                          }
                          // proto: toast('תנאי התשלום עודכנו: '+t.name)
                          showToast(context, 'תנאי התשלום עודכנו: ${t.name}');
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _PayOpt extends StatelessWidget {
  const _PayOpt({required this.term, required this.on, required this.onTap});
  final PaymentTerm term;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // proto due-line: days==null → 'משולם בכל אבן דרך'; days==0 → 'תשלום מיידי';
    //                 else → 'התשלום מתבצע '+days+' יום מקבלת החשבונית'
    final due =
        term.days == null
            ? 'משולם בכל אבן דרך'
            : term.days == 0
            ? 'תשלום מיידי'
            : 'התשלום מתבצע ${term.days} יום מקבלת החשבונית';
    return Material(
      color: on ? const Color(0xFFEAF5F4) : const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(cfgRadius(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(
              color: on ? _kBrandTeal : const Color(0xFFE6E8EC),
              width: on ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // proto: name + (active ? ' ✓' : '')
                on ? '${term.name} ✓' : term.name,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                due,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.3 — קבלני משנה · proto finSubs @index.html:19569
//   3 subcontractors · allocated/spent/% + utilisation bar · over→danger.
// ═════════════════════════════════════════════════════════════════════════════
void _openSubs(BuildContext context) {
  final totAlloc = kSubcontractors.fold<int>(0, (s, x) => s + x.allocated);
  final totSpent = kSubcontractors.fold<int>(0, (s, x) => s + x.spent);
  final totPct = (totSpent / totAlloc * 100).round();
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '👷',
            title: 'קבלני משנה',
            sub: 'חלוקת תקציב הפרויקט בין קבלני המשנה ומעקב ניצול.',
          ),
          // proto `.ca-server-note`
          Container(
            padding: const EdgeInsets.all(BsTokens.space3),
            margin: const EdgeInsets.only(bottom: BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: const CfgText(
              'finance_hub_sheets.subs_server_note',
              '⚙️ נתוני קבלני המשנה מתעדכנים מהשרת',
              style: TextStyle(color: Color(0xFF8A6D00), fontSize: 12.5),
            ),
          ),
          if (!useFirebaseBackend) _FinCallout(
            label: 'סך הוקצה לקבלני משנה',
            value: fMoney(totAlloc),
            note: 'נוצל: ${fMoney(totSpent)} ($totPct%)',
          ),
          const SizedBox(height: BsTokens.space4),
          if (!useFirebaseBackend)
            for (final s in kSubcontractors) _SubRow(sub: s),
        ],
      ),
    ),
  );
}

class _SubRow extends StatelessWidget {
  const _SubRow({required this.sub});
  final Subcontractor sub;

  @override
  Widget build(BuildContext context) {
    final pct = (sub.spent / sub.allocated * 100).round();
    final over = pct > 100;
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space3),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${sub.ic} ${sub.name}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: over ? _kDn : BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: (pct.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE6E8EC),
              valueColor: AlwaysStoppedAnimation<Color>(
                over ? _kDn : BsTokens.brand,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'נוצל ${fMoney(sub.spent)} מתוך ${fMoney(sub.allocated)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.4 — אישורי רכש · proto finApprovals @19594 + decideApproval @19617
//   RBAC requirePerm('order.approve') + audit log · approve/reject inline.
// ═════════════════════════════════════════════════════════════════════════════
void _openApprovals(BuildContext context) {
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '✅',
            title: 'אישורי רכש',
            sub: 'בקשות רכש הממתינות לאישור מנהל לפני ביצוע ההזמנה.',
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final queue = ref.watch(approvalQueueProvider);
              if (queue.isEmpty) {
                return const _CaEmpty('אין בקשות לאישור');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final a in queue)
                    _ApprovalCard(
                      item: a,
                      onDecide: (ok) => _decide(ctx, ref, a, ok),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

/// proto decideApproval: requirePerm gate → flip status → audit → toast.
void _decide(BuildContext context, WidgetRef ref, FinanceApproval a, bool ok) {
  // RBAC: only a manager role may approve/reject (proto requirePerm @19619).
  if (!requirePerm(ref, 'order.approve', 'אישור בקשת רכש')) {
    showToast(context, '⛔ אין הרשאה לאישור בקשת רכש');
    return;
  }
  // fake-data-sweep: the notifier now owns the dual-write — decide() flips the
  // local state AND persists to the repo (Firebase → Firestore). No manual
  // backend call here (it would double-write).
  ref.read(approvalQueueProvider.notifier).decide(a.id, ok);
  // proto auditLog('החלטת רכש', id+': '+(ok?'אושר':'נדחה'))
  ref
      .read(auditTrailProvider.notifier)
      .log(
        'החלטת רכש',
        '${a.id}: ${ok ? 'אושר' : 'נדחה'}',
        ref.read(securityRoleProvider),
      );
  // proto toast('בקשה '+id+' '+(ok?'אושרה ✓':'נדחתה'))
  showToast(context, 'בקשה ${a.id} ${ok ? 'אושרה ✓' : 'נדחתה'}');
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.item, required this.onDecide});
  final FinanceApproval item;
  final void Function(bool ok) onDecide;

  @override
  Widget build(BuildContext context) {
    final pending = item.status == 'ממתין';
    final rejected = item.status == 'נדחה';
    final pillColor = rejected ? _kDn : (pending ? BsTokens.mutedLight : _kUp);
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space3),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.id,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: pillColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.what,
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            '${fMoney(item.amount)} · מבקש: ${item.by}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
          if (pending) ...[
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onDecide(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kUp,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const CfgText(
                      'finance_hub_sheets.approve',
                      'אשר',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onDecide(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kDn,
                      side: const BorderSide(color: _kDn),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const CfgText(
                      'finance_hub_sheets.reject',
                      'דחה',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// proto `.ca-empty` — muted centred empty-state line.
class _CaEmpty extends StatelessWidget {
  const _CaEmpty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 14),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.5 — התראות חריגה · proto finThresholds @index.html:19633
//   gauge pct = round(spent/total*100) · level ok/h(80)/x(90) · 80/90/100 list.
// ═════════════════════════════════════════════════════════════════════════════
void _openThresholds(BuildContext context) {
  final pct = financeRepo().budgetPct(); // == budgetPct() · round(9840/15000*100) = 66
  // proto: >=90 → 'חריגה קריטית' (x); >=80 → 'התראת חריגה' (h); else 'תקין' (ok)
  var level = 'תקין';
  var col = _kUp;
  if (pct >= 90) {
    level = 'חריגה קריטית';
    col = _kDn;
  } else if (pct >= 80) {
    level = 'התראת חריגה';
    col = const Color(0xFFE08A00); // amber 'h'
  }
  // proto threshold list: [['80%',…,80],['90%',…,90],['100%',…,100]]
  final thr = [
    ('80%', 'התראת חריגה ראשונית', 80),
    ('90%', 'חריגה קריטית — נדרש אישור', 90),
    ('100%', 'חריגה מלאה מהתקציב', 100),
  ];
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '🔔',
            title: 'התראות חריגת תקציב',
            sub: 'ניטור דינמי — התראה אוטומטית בהגעה ל-80% ול-90% מהתקציב.',
          ),
          // proto `.fin-gauge` — big circular pct + level label.
          Center(
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: col.withValues(alpha: 0.10),
                border: Border.all(color: col, width: 6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      color: col,
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                    ),
                  ),
                  Text(
                    level,
                    style: TextStyle(
                      color: col,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: BsTokens.space4),
          for (final t in thr)
            _ThrRow(label: '${t.$1} — ${t.$2}', hit: pct >= t.$3),
        ],
      ),
    ),
  );
}

class _ThrRow extends StatelessWidget {
  const _ThrRow({required this.label, required this.hit});
  final String label;
  final bool hit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space3,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: hit ? const Color(0xFFFFF3E0) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(
          color: hit ? const Color(0xFFFFCC80) : const Color(0xFFE6E8EC),
        ),
      ),
      child: Row(
        children: [
          // proto: hit ? '⚠️' : '○'
          Text(hit ? '⚠️' : '○', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.6 — ניתוח ROI · proto finROI @index.html:19657
//   value=round(total*1.42) · profit=value-total · roi=profit/total*100.
// ═════════════════════════════════════════════════════════════════════════════
void _openRoi(BuildContext context) {
  final r = projectRoi(); // contractValue / profit / roiPct
  final invested = financeRepo().budgetSpent(); // == kBudgetSpent (9840)
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '📊',
            title: 'ניתוח ROI',
            sub: 'תשואה צפויה על ההשקעה בפרויקט.',
          ),
          // proto `.ca-server-note`
          Container(
            padding: const EdgeInsets.all(BsTokens.space3),
            margin: const EdgeInsets.only(bottom: BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: const CfgText(
              'finance_hub_sheets.roi_server_note',
              '⚙️ נתוני ה-ROI מתעדכנים מהשרת',
              style: TextStyle(color: Color(0xFF8A6D00), fontSize: 12.5),
            ),
          ),
          _FinRows([
            _FinRow('תקציב הפרויקט', fMoney(financeRepo().budgetTotal())),
            _FinRow('הושקע עד כה', fMoney(invested)),
            if (!useFirebaseBackend)
              _FinRow('שווי חוזה צפוי', fMoney(r.contractValue)),
            if (!useFirebaseBackend)
              _FinRow('רווח גולמי צפוי', fMoney(r.profit), valueColor: _kUp),
          ]),
          if (!useFirebaseBackend) _FinCallout(
            label: 'ROI צפוי',
            value: '${r.roiPct.toStringAsFixed(1)}%',
            big: true,
            valueColor: _kUp,
            note: 'תשואה על כל שקל שהושקע בפרויקט',
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.7 — פיצול חשבונית · proto finInvoiceSplit @index.html:19678
//   ₪12,800 split by category weight = round(total*(amount/Σamount)).
// ═════════════════════════════════════════════════════════════════════════════
void _openInvoiceSplit(BuildContext context) {
  final split = invoiceSplit(); // name → ₪ share
  final cats = financeRepo().budgetCategories(); // == kBudgetCategories
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FinHead(
            ic: '🧾',
            title: 'פיצול חשבונית',
            sub: useFirebaseBackend
                ? 'פיצול חשבונית לסעיפי התקציב.'
                : 'פיצול חשבונית בסך ${fMoney(kInvoiceTotal)} לסעיפי התקציב.',
          ),
          // proto `.ca-server-note`
          Container(
            padding: const EdgeInsets.all(BsTokens.space3),
            margin: const EdgeInsets.only(bottom: BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: const CfgText(
              'finance_hub_sheets.invoice_server_note',
              '⚙️ נתוני פיצול החשבונית מתעדכנים מהשרת',
              style: TextStyle(color: Color(0xFF8A6D00), fontSize: 12.5),
            ),
          ),
          _FinRows(useFirebaseBackend ? const <Widget>[] : [
            for (final c in cats)
              _FinRow('${c.icon} ${c.name}', fMoney(split[c.name] ?? 0)),
          ]),
          if (!useFirebaseBackend) _FinCallout(
            label: 'סך החשבונית',
            value: fMoney(kInvoiceTotal),
            note: 'פוצלה ל-${cats.length} סעיפי תקציב לפי משקל',
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.8 — פיצויים וקנסות · proto finPenalties @19698 + addPenalty @19712
//   inline days input · row = days × ₪500 · ledger (penaltyLedgerProvider).
// ═════════════════════════════════════════════════════════════════════════════
void _openPenalties(BuildContext context) {
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '⏰',
            title: 'פיצויים וקנסות',
            sub: 'ניהול קנסות על איחור באספקה — פיצוי מוסכם לפי יום.',
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final ledger = ref.watch(penaltyLedgerProvider);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // inline replacement for the proto's prompt() (R: inline input).
                  _PenaltyInput(
                    onAdd: (days) {
                      final amt = ref
                          .read(penaltyLedgerProvider.notifier)
                          .add(days);
                      // S-connect: record the penalty on the live backend too
                      // (same amount; the notifier is the demo path).
                      if (useFirebaseBackend) {
                        final r = financeRepo();
                        if (r is FirebaseFinanceRepository) r.addPenalty(days);
                      }
                      // proto toast('קנס איחור נרשם: '+finMoney(days*perDay))
                      showToast(context, 'קנס איחור נרשם: ${fMoney(amt)}');
                    },
                  ),
                  const SizedBox(height: BsTokens.space3),
                  if (ledger.isEmpty)
                    const _CaEmpty('לא נרשמו קנסות')
                  else ...[
                    _FinCallout(
                      label: 'סך קנסות שנצברו',
                      value: fMoney(
                        ledger.fold<int>(0, (s, p) => s + p.amount),
                      ),
                      valueColor: _kDn,
                    ),
                    const SizedBox(height: BsTokens.space3),
                    for (final p in ledger) _PenaltyCard(p: p),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _PenaltyInput extends StatefulWidget {
  const _PenaltyInput({required this.onAdd});
  final void Function(int days) onAdd;

  @override
  State<_PenaltyInput> createState() => _PenaltyInputState();
}

class _PenaltyInputState extends State<_PenaltyInput> {
  final _ctl = TextEditingController(text: '2'); // proto prompt default '2'

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit() {
    // proto: Math.max(1, parseInt(daysStr,10)||1)
    final parsed = int.tryParse(_ctl.text.trim()) ?? 1;
    final days = parsed < 1 ? 1 : parsed;
    widget.onAdd(days);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CfgText(
          'finance_hub_sheets.late_days_q',
          'כמה ימי איחור?',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _ctl,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: BsTokens.space2),
        _CaPrimary(label: '+ רישום קנס איחור', onTap: _submit),
      ],
    );
  }
}

class _PenaltyCard extends StatelessWidget {
  const _PenaltyCard({required this.p});
  final Penalty p;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.id,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kDn.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  fMoney(p.amount),
                  style: const TextStyle(
                    color: _kDn,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            // proto: days+' ימי איחור · '+finMoney(perDay)+' ליום · 📅 '+createdAt
            '${p.days} ימי איחור · ${fMoney(p.perDay)} ליום · 📅 ${p.createdAt}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.9 — דוחות PDF · proto finReports @19729 + downloadFinReport @19737
//   "הפק והורד דוח PDF" → printed report-view (an in-app rendered document,
//   NOT a toast — the print-to-PDF surface from the prototype).
// ═════════════════════════════════════════════════════════════════════════════
void _openReports(BuildContext context) {
  final repo = financeRepo();
  final left = repo.budgetTotal() - repo.budgetSpent(); // == kBudgetTotal - kBudgetSpent
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '📄',
            title: 'דוחות PDF רשמיים',
            sub: 'הפקת דוח פיננסי רשמי של הפרויקט להורדה והדפסה.',
          ),
          _FinRows([
            _FinRow('תקציב הפרויקט', fMoney(repo.budgetTotal())),
            _FinRow('הוצאות בפועל', fMoney(repo.budgetSpent())),
            _FinRow('יתרה', fMoney(left)),
          ]),
          const SizedBox(height: BsTokens.space4),
          _CaPrimary(
            label: '⬇️ הפק והורד דוח PDF',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _FinReportView()),
              );
            },
          ),
        ],
      ),
    ),
  );
}

/// The rendered report "document" — the simulated print-to-PDF surface that the
/// prototype's `downloadFinReport` opens in a print window. Verbatim copy.
class _FinReportView extends ConsumerWidget {
  const _FinReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = financeRepo();
    final pct = repo.budgetPct(); // == budgetPct() · round(spent/total*100)
    final left = repo.budgetTotal() - repo.budgetSpent(); // == kBudgetTotal - kBudgetSpent
    final today = caToday();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEEF0),
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          foregroundColor: BsTokens.inkLight,
          elevation: 0.5,
          title: const CfgText(
            'finance_hub_sheets.report_appbar',
            'דוח פיננסי — BuildSmart',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                // REAL print-to-PDF: build the document from the SAME data this
                // view shows, then hand it to the print/save dialog (via the
                // injectable seam so a test captures the doc).
                final doc = await buildFinanceReportPdf(
                  FinanceReportData(
                    budgetTotal: repo.budgetTotal(),
                    budgetSpent: repo.budgetSpent(),
                    budgetPct: pct,
                    balance: left,
                    today: today,
                    categories: repo.budgetCategories(),
                  ),
                );
                await ref.read(pdfPrintProvider)(
                  doc,
                  name: '${AppBrand.name}-finance-report',
                );
              },
              icon: const Icon(Icons.print, size: 18),
              label: const CfgText('finance_hub_sheets.print', 'הדפסה'),
              style: TextButton.styleFrom(foregroundColor: _kBrandTeal),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              // The printable "page" — white sheet with the report content.
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BsTokens.space5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CfgText(
                      'finance_hub_sheets.report_title',
                      'BuildSmart — דוח פיננסי לפרויקט',
                      style: TextStyle(
                        color: Color(0xFF16191D),
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'תאריך הפקה: $today',
                      style: const TextStyle(
                        color: Color(0xFF16191D),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space5),
                    const _ReportH2('תמצית תקציב'),
                    _ReportTable(
                      rows: [
                        ('תקציב כולל', fMoney(repo.budgetTotal()), true),
                        (
                          'הוצאות בפועל',
                          '${fMoney(repo.budgetSpent())} ($pct%)',
                          false,
                        ),
                        ('יתרה', fMoney(left), false),
                      ],
                    ),
                    const SizedBox(height: BsTokens.space5),
                    const _ReportH2('פירוט לפי סעיפים'),
                    _ReportTable(
                      rows: [
                        for (final c in repo.budgetCategories())
                          ('${c.icon} ${c.name}', fMoney(c.amount), false),
                      ],
                    ),
                    const SizedBox(height: BsTokens.space6),
                    Text(
                      'הופק על ידי מערכת ${AppBrand.name} · $today',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportH2 extends StatelessWidget {
  const _ReportH2(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Text(
      text,
      style: const TextStyle(
        color: _kBrandTeal,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  );
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.rows});
  final List<(String, String, bool)> rows; // (label, value, big)
  @override
  Widget build(BuildContext context) {
    const border = BorderSide(color: Color(0xFFDDDDDD));
    return Table(
      border: const TableBorder(
        top: border,
        bottom: border,
        left: border,
        right: border,
        horizontalInside: border,
        verticalInside: border,
      ),
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth()},
      children: [
        for (final r in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r.$1,
                  style: const TextStyle(
                    color: Color(0xFF16191D),
                    fontSize: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r.$2,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: const Color(0xFF16191D),
                    fontSize: r.$3 ? 16 : 13,
                    fontWeight: r.$3 ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T1.10 — רכש במט״ח · proto finFX @19773 + updateFXCalc @19797
//   USD/EUR/GBP rates + live amount×rate converter (kFxRates).
// ═════════════════════════════════════════════════════════════════════════════

/// The FX rates to SHOW — gated at the consumer (the minimal correct gate, since
/// `kFxRates` is a plain const map read directly here, not through a repository).
/// On the live Firebase backend there is NO real FX feed yet, so the const DEMO
/// rates (USD 3.72 / EUR 4.05 / GBP 4.71) MUST NOT be shown to a real signed-in
/// user as if they were live server rates — return an EMPTY map there. With the
/// backend OFF (the shipped demo path) this is byte-identical to reading
/// `kFxRates` directly (zero regression). The seed const itself is untouched.
Map<String, double> _fxRatesToShow() =>
    useFirebaseBackend ? const {} : kFxRates;

void _openFx(BuildContext context) {
  _showFinSheet(
    context,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FinHead(
            ic: '💱',
            title: 'רכש במט״ח',
            sub: 'שערי חליפין לרכש מספקים בחו״ל.',
          ),
          // proto `.ca-server-note`
          Container(
            padding: const EdgeInsets.all(BsTokens.space3),
            margin: const EdgeInsets.only(bottom: BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0A3)),
            ),
            child: const CfgText(
              'finance_hub_sheets.fx_server_note',
              '⚙️ שערי המט״ח מתעדכנים מהשרת — כאן מוצגים שערי דמו',
              style: TextStyle(color: Color(0xFF8A6D00), fontSize: 12.5),
            ),
          ),
          _FinRows([
            for (final entry in _fxRatesToShow().entries)
              _FinRow('1 ${entry.key}', '₪${entry.value.toStringAsFixed(2)}'),
          ]),
          const SizedBox(height: BsTokens.space4),
          const _FxCalc(),
        ],
      ),
    ),
  );
}

class _FxCalc extends StatefulWidget {
  const _FxCalc();
  @override
  State<_FxCalc> createState() => _FxCalcState();
}

class _FxCalcState extends State<_FxCalc> {
  final _ctl = TextEditingController(text: '1000'); // proto value="1000"
  String _cur = 'USD';

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  String _result() {
    // proto updateFXCalc: amt*rate (round), thousands-grouped. On the live
    // backend the gated map is empty (no fabricated rate) → falls back to 1.
    final amt = double.tryParse(_ctl.text.trim()) ?? 0;
    final rate = _fxRatesToShow()[_cur] ?? 1;
    final ils = (amt * rate).round();
    return '${_group(amt)} $_cur = ₪${_groupInt(ils)}';
  }

  static String _group(double v) {
    // toLocaleString — group integer part with commas, drop trailing .0.
    final isInt = v == v.roundToDouble();
    if (isInt) return _groupInt(v.round());
    return v.toString();
  }

  static String _groupInt(int v) {
    final neg = v < 0;
    final d = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) buf.write(',');
      buf.write(d[i]);
    }
    return '${neg ? '-' : ''}$buf';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CfgText(
            'finance_hub_sheets.convert_amount',
            'המרת סכום',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctl,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'סכום',
              // task #64: format-only check — must be a positive number.
              errorText: _ctl.text.trim().isEmpty ||
                      validPositiveAmount(double.tryParse(_ctl.text.trim()))
                  ? null
                  : 'סכום לא תקין',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space3,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
              ),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          DropdownButtonFormField<String>(
            value: _cur,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space3,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
              ),
            ),
            items: const [
              // proto <option> labels verbatim.
              DropdownMenuItem(
                value: 'USD',
                child: CfgText('finance_hub_sheets.cur_usd', 'דולר אמריקאי (USD)'),
              ),
              DropdownMenuItem(
                value: 'EUR',
                child: CfgText('finance_hub_sheets.cur_eur', 'אירו (EUR)'),
              ),
              DropdownMenuItem(
                value: 'GBP',
                child: CfgText('finance_hub_sheets.cur_gbp', 'לירה שטרלינג (GBP)'),
              ),
            ],
            onChanged: (v) => setState(() => _cur = v ?? 'USD'),
          ),
          const SizedBox(height: BsTokens.space3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              _result(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kBrandTeal,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
