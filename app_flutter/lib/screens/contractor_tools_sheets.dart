// Contractor catalog tools — the three R9 modal sheets reached from the catalog
// 3-dot menu (📐 סרוק תוכנית עבודה · 💡 חלופות זולות · 📊 השוואת מחירים) and
// from the menu-dial plan-* leaves. Canonical single implementations: the home
// shell and the AI hub both open these instead of carrying duplicate views.
//
// Data verbatim from data/contractor_seeds.dart (kPlanTypes proto §9 / §9b
// store offers; kHomeProductBrands proto §1b price tiers). The scan flow is
// simulated (sim, not a toast) and reuses the real smart-cart.

import 'dart:async';

import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/logic/money_format.dart' show groupThousands;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/screens/alt_explain_screen.dart'
    show AltExplainScreen;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the 📐 "סרוק תוכנית עבודה" sheet. [planKey] (plumbing/electrical/
/// architectural/finishing) optionally jumps straight into that plan's scan.
void openScanPlanSheet(BuildContext context, {String? planKey}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ScanPlanSheet(initialPlanKey: planKey),
  );
}

/// Opens the 💡 "חלופות זולות" sheet.
void openCheaperAlternativesSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _CheaperAlternativesSheet(),
  );
}

/// Opens the 📊 "השוואת מחירים" sheet.
void openPriceCompareSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _StorePriceComparisonSheet(),
  );
}

/// Shared header for the three contractor sheets: the centered grab-pill with an
/// explicit close (X) overlaid at the visual top-left (RTL → Alignment.centerLeft,
/// matching camera_sheet.dart). The X is orthogonal to drag/scrim dismissal and to
/// any in-sheet back-step; it always means "close the whole sheet". The drag handle
/// stays centered (Stack) so the title below it is not pushed off-centre.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            label: 'סגור',
            child: IconButton(
              tooltip: 'סגור',
              icon: const Icon(Icons.close, color: Color(0xFF888888)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }
}

/// (T1 · לוח-קבלן) A cheaper same-product brand alternative across the smart-tree.
class CheaperAlt {
  const CheaperAlt({
    required this.product,
    required this.recName,
    required this.recPrice,
    required this.altName,
    required this.altPrice,
  });
  final String product;
  final String recName;
  final int recPrice;
  final String altName;
  final int altPrice;
  int get savings => recPrice - altPrice;
}

/// (T1) Products whose recommended brand has a cheaper same-product
/// alternative, from [kHomeProductBrands] (proto §1b HOME_PRODUCTS price
/// tiers — verbatim). Cheaper same-item options, sorted by savings desc.
List<CheaperAlt> cheaperAlternativesAcrossCatalog() {
  final out = <CheaperAlt>[];
  for (final pb in kHomeProductBrands) {
    final recI = pb.tiers.indexWhere((t) => t.rec);
    final ri = recI >= 0 ? recI : 0;
    final rec = pb.tiers[ri];
    BrandTier? alt; // cheapest tier below the recommended one
    for (var i = 0; i < pb.tiers.length; i++) {
      if (i == ri) continue;
      final t = pb.tiers[i];
      if (t.price < rec.price && (alt == null || t.price < alt.price)) alt = t;
    }
    if (alt == null) continue;
    out.add(
      CheaperAlt(
        product: pb.product,
        recName: rec.brand,
        recPrice: rec.price,
        altName: alt.brand,
        altPrice: alt.price,
      ),
    );
  }
  out.sort((a, b) => b.savings.compareTo(a.savings));
  return out;
}

/// (T1) "חלופות זולות" sheet — cheaper same-product brand options + savings.
/// R9-inline (modal sheet, no new view); live supplier comparison is בפרודקשן.
/// A search field (T37) filters the full cross-catalog scan by product/brand
/// name, so the user can reach any specific product's cheaper alternative —
/// not only the auto top deals. Empty query → the full auto list (T1 default).
class _CheaperAlternativesSheet extends StatefulWidget {
  const _CheaperAlternativesSheet();

  @override
  State<_CheaperAlternativesSheet> createState() =>
      _CheaperAlternativesSheetState();
}

class _CheaperAlternativesSheetState extends State<_CheaperAlternativesSheet> {
  // T37 — the live product-name search query (case-insensitive substring over
  // the product name + recommended/alternative brand). Empty → full auto list.
  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always scan the FULL cross-catalog list (not a sliced top-N) so a
    // searched product that has a real alternative still surfaces.
    final all = cheaperAlternativesAcrossCatalog();
    final q = _query.trim().toLowerCase();
    final alts =
        q.isEmpty
            ? all
            : all
                .where(
                  (a) =>
                      a.product.toLowerCase().contains(q) ||
                      a.recName.toLowerCase().contains(q) ||
                      a.altName.toLowerCase().contains(q),
                )
                .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 14),
          CfgText(
            'contractor_tools_sheets.cheaper_title',
            '💡 חלופות זולות',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: BsTokens.inkLight,
            ),
          ),
          const SizedBox(height: 4),
          CfgText(
            'contractor_tools_sheets.cheaper_subtitle',
            'מותג חלופי זול יותר לאותו מוצר — אותה התקנה, פחות עלות.',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 12),
          // T37 — search any specific product (not only the auto top deals).
          TextField(
            controller: _searchCtl,
            textDirection: TextDirection.rtl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'חפש מוצר…',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
              suffixIcon:
                  _query.isEmpty
                      ? null
                      : IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF888888),
                        ),
                        tooltip: 'נקה',
                        onPressed:
                            () => setState(() {
                              _searchCtl.clear();
                              _query = '';
                            }),
                      ),
              isDense: true,
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
          ),
          const SizedBox(height: 14),
          if (alts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _query.trim().isEmpty
                    ? 'אין חלופות זולות כרגע.'
                    : 'לא נמצאו חלופות תואמות.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888888)),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: alts.length,
                separatorBuilder:
                    (_, __) =>
                        const Divider(height: 18, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) {
                  final a = alts[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.product,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'המלצה: ${a.recName} · ₪${groupThousands(a.recPrice)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'חלופה: ${a.altName} · ₪${groupThousands(a.altPrice)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: BsTokens.inkLight,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8D6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'חיסכון ₪${groupThousands(a.savings)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: BsTokens.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // #ai-alt-explain — when AI is live, offer a grounded
                      // "why is this worth it?" explainer for this real swap.
                      // gateway null (demo) → not in the tree → byte-identical.
                      Consumer(
                        builder: (context, ref, _) {
                          if (ref.watch(claudeGatewayProvider) == null) {
                            return const SizedBox.shrink();
                          }
                          return Align(
                            alignment: Alignment.centerRight,
                            // composite hide: whole button gone when the org hides this element
                            child: CfgVisible(
                              'contractor_tools_sheets.why_worth',
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  AltExplainScreen.route(
                                    product: a.product,
                                    recName: a.recName,
                                    recPrice: a.recPrice,
                                    altName: a.altName,
                                    altPrice: a.altPrice,
                                  ),
                                ),
                                icon: const Text('🤔'),
                                label: CfgText(
                                  'contractor_tools_sheets.why_worth',
                                  'למה כדאי?',
                                ),
                                // a11y (swarm): ≥48dp tap target (was 32dp+shrinkWrap).
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(0, 48),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          CfgText(
            'contractor_tools_sheets.cheaper_prod_note',
            '⚙️ בפרודקשן: השוואת-מחירים חיה מול מחירוני הספקים.',
            style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2)),
          ),
        ],
      ),
    );
  }
}

/// (T2 · לוח-קבלן) A per-product store price comparison: the named partner-store
/// offers (proto §9b, verbatim) and the index of the cheapest ([bestStore]).
class StoreCompareRow {
  const StoreCompareRow({
    required this.product,
    required this.emoji,
    required this.stores,
    required this.bestIndex,
  });
  final String product;
  final String emoji;
  final List<StoreOffer> stores;
  final int bestIndex;
  StoreOffer get best => stores[bestIndex];
}

/// (T2) Per-product store comparison across the plan-type catalog
/// ([kPlanTypes] — proto §9b store offers, verbatim). Each product carries its
/// partner-store prices; [bestStore] marks the cheapest. No invented numbers.
List<StoreCompareRow> storePriceComparisonAcrossCatalog() {
  final out = <StoreCompareRow>[];
  for (final pt in kPlanTypes) {
    for (final z in pt.zones) {
      for (final it in z.items) {
        if (it.stores.length < 2) continue;
        out.add(
          StoreCompareRow(
            product: it.name,
            emoji: it.emoji,
            stores: it.stores,
            bestIndex: bestStore(it.stores),
          ),
        );
      }
    }
  }
  return out;
}

/// (T2) "השוואת מחירים" sheet — each product's partner-store prices with the
/// cheapest highlighted. R9-inline (modal sheet, no new view). Prices §9b.
class _StorePriceComparisonSheet extends StatelessWidget {
  const _StorePriceComparisonSheet();

  @override
  Widget build(BuildContext context) {
    final rows = storePriceComparisonAcrossCatalog();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 14),
          CfgText(
            'contractor_tools_sheets.compare_title',
            '📊 השוואת מחירים',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: BsTokens.inkLight,
            ),
          ),
          const SizedBox(height: 4),
          CfgText(
            'contractor_tools_sheets.compare_subtitle',
            'מחירים מ-3 חנויות שותפות — הזול ביותר מסומן.',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: CfgText(
                'contractor_tools_sheets.compare_empty',
                'אין מחירים להשוואה כרגע.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF888888)),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder:
                    (_, __) =>
                        const Divider(height: 18, color: Color(0xFFEEEEEE)),
                itemBuilder: (_, i) {
                  final r = rows[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.emoji} ${r.product}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (var s = 0; s < r.stores.length; s++)
                            _StoreChip(
                              offer: r.stores[s],
                              best: s == r.bestIndex,
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          CfgText(
            'contractor_tools_sheets.compare_prices_note',
            '💰 המחירים נמשכים מ-3 חנויות שותפות. ${AppBrand.name} בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.',
            style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2)),
          ),
        ],
      ),
    );
  }
}

/// (T2) A single store-offer chip; the cheapest is brand-highlighted with ✓.
class _StoreChip extends StatelessWidget {
  const _StoreChip({required this.offer, required this.best});
  final StoreOffer offer;
  final bool best;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: best ? const Color(0xFFFFE8D6) : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
        border: best ? Border.all(color: BsTokens.brand) : null,
      ),
      child: Text(
        '${best ? '✓ ' : ''}${offer.store} · ₪${groupThousands(offer.price)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: best ? FontWeight.w700 : FontWeight.w500,
          color: best ? BsTokens.brand : const Color(0xFF555555),
        ),
      ),
    );
  }
}

/// (T3 · לוח-קבלן) Cart lines for a scanned plan type — each detected zone item
/// at its cheapest partner-store offer (proto §9 `addScanToCart`). Pure → tested.
List<SmartCartLine> scanPlanCartLines(PlanType plan) {
  final out = <SmartCartLine>[];
  for (final z in plan.zones) {
    for (final it in z.items) {
      if (it.stores.isEmpty) continue;
      final best = it.stores[bestStore(it.stores)];
      out.add(
        SmartCartLine(
          productKey: 'scan:${plan.key}:${it.name}',
          productName: it.name,
          productEmoji: it.emoji,
          brandName: best.store,
          brandPrice: best.price,
          productQty: 1,
          accessories: const [],
        ),
      );
    }
  }
  return out;
}

/// (T3) "סרוק תוכנית" — pick a plan type → scan animation → detected zones with
/// per-item store comparison → "הוסף לסל". R9-inline (modal sheet, no new route).
/// Data verbatim from [kPlanTypes] (proto §9); scan is simulated (sim, not toast).
/// [initialPlanKey] (menu leaf wiring) optionally auto-starts that plan's scan.
class _ScanPlanSheet extends ConsumerStatefulWidget {
  const _ScanPlanSheet({this.initialPlanKey});

  final String? initialPlanKey;

  @override
  ConsumerState<_ScanPlanSheet> createState() => _ScanPlanSheetState();
}

class _ScanPlanSheetState extends ConsumerState<_ScanPlanSheet> {
  PlanType? _plan; // null → picker phase
  bool _scanning = false;
  int _stepIdx = 0;
  Timer? _timer;

  // T41 — per-item manual selection in the results phase. Keyed by the same
  // productKey scanPlanCartLines() emits ('scan:<plan>:<name>'). null until the
  // results phase seeds it (all selected by default); reset on re-scan.
  Set<String>? _selected;

  @override
  void initState() {
    super.initState();
    // Menu leaf deep-link: jump straight into the requested plan's scan.
    final key = widget.initialPlanKey;
    if (key != null) {
      final hit = kPlanTypes.where((p) => p.key == key);
      if (hit.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _start(hit.first));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // T41 — the cart-line key for a scanned item (mirrors scanPlanCartLines).
  String _itemKey(PlanType p, ScanItem it) => 'scan:${p.key}:${it.name}';

  void _start(PlanType p) {
    setState(() {
      _plan = p;
      _scanning = true;
      _stepIdx = 0;
      _selected = null; // re-seeded (all selected) when results render.
    });
    _timer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_stepIdx < p.steps.length - 1) {
        setState(() => _stepIdx++);
      } else {
        t.cancel();
        setState(() => _scanning = false);
      }
    });
  }

  void _addToCart(PlanType p) {
    // T41 — only the items the user kept selected (default = all). Match by the
    // cart-line key, which scanPlanCartLines() builds as 'scan:<plan>:<name>'.
    final sel = _selected;
    final lines =
        scanPlanCartLines(
          p,
        ).where((l) => sel == null || sel.contains(l.productKey)).toList();
    if (lines.isEmpty) return; // guarded by the disabled button; defensive.
    final cart = ref.read(smartCartProvider.notifier);
    for (final l in lines) {
      cart.add(l);
    }
    // Stay in context — do NOT yank the user to the Store tab. The live cart FAB
    // (here, on the home shell, and on the AI hub) reflects the new count as
    // the immediate feedback; the "לאן לשלוח?" first-add popup still fires.
    Navigator.pop(context);
    showToast(context, '${lines.length} פריטים מהתוכנית נוספו לסל');
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 14),
          if (plan == null)
            ..._picker()
          else if (_scanning)
            ..._scanningView(plan)
          else
            ..._results(plan),
        ],
      ),
    );
  }

  List<Widget> _picker() => [
    CfgText(
      'contractor_tools_sheets.scan_title',
      '📐 סרוק תוכנית עבודה',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: BsTokens.inkLight,
      ),
    ),
    const SizedBox(height: 4),
    CfgText(
      'contractor_tools_sheets.scan_pick',
      'בחר סוג תוכנית לסריקה',
      style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
    ),
    const SizedBox(height: 8),
    for (final p in kPlanTypes)
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Text(p.icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          p.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: BsTokens.inkLight,
          ),
        ),
        subtitle: Text(
          p.sub,
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
        trailing: const Icon(Icons.chevron_left, color: Color(0xFF888888)),
        onTap: () => _start(p),
      ),
  ];

  List<Widget> _scanningView(PlanType p) => [
    const SizedBox(height: 10),
    const Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(strokeWidth: 3, color: BsTokens.brand),
      ),
    ),
    const SizedBox(height: 16),
    CfgText(
      'contractor_tools_sheets.scan_analyzing',
      'מנתח את תצורת הבנייה ומחלץ כמויות חומרים…',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: BsTokens.inkLight,
      ),
    ),
    const SizedBox(height: 10),
    Text(
      p.steps[_stepIdx],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
    ),
    const SizedBox(height: 18),
  ];

  List<Widget> _results(PlanType p) {
    final lines = scanPlanCartLines(p);
    // T41 — seed the per-item selection (all selected by default) the first
    // time the results render for this plan. Keys mirror scanPlanCartLines.
    final sel = _selected ??= {for (final l in lines) l.productKey};
    final total = lines.fold<int>(0, (s, l) => s + l.brandPrice);
    final selCount = lines.where((l) => sel.contains(l.productKey)).length;
    final allSelected = selCount == lines.length;
    return [
      Text(
        '✓ זוהו ${p.zones.length} ${p.summaryUnit}',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: BsTokens.inkLight,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '${lines.length} פריטים · ההצעה הזולה ₪${groupThousands(total)}',
        style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
      ),
      const SizedBox(height: 6),
      CfgText(
        'contractor_tools_sheets.scan_prices_note',
        '💰 המחירים נמשכים מ-3 חנויות שותפות. ${AppBrand.name} בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.',
        style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2)),
      ),
      const SizedBox(height: 8),
      Flexible(
        child: ListView(
          shrinkWrap: true,
          children: [for (final z in p.zones) ..._zoneCard(p, z)],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: BsTokens.brand),
          // T41 — guard 0 selected; otherwise add only the selected items.
          onPressed: selCount == 0 ? null : () => _addToCart(p),
          child: Text(
            allSelected
                ? 'אשר הכל — הוסף ${lines.length} פריטים לסל'
                : 'אשר את הבחירה — הוסף $selCount פריטים לסל',
          ),
        ),
      ),
      Center(
        // composite hide: whole button gone when the org hides this element
        child: CfgVisible(
          'contractor_tools_sheets.scan_another',
          child: TextButton(
            onPressed:
                () => setState(() {
                  _plan = null;
                  _scanning = false;
                }),
            child: CfgText(
              'contractor_tools_sheets.scan_another',
              'סרוק תוכנית אחרת',
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _zoneCard(PlanType p, ScanZone z) => [
    Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${z.emoji} ${z.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BsTokens.inkLight,
              ),
            ),
          ),
          Text(
            'ודאות ${z.conf}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  z.conf < 88
                      ? const Color(0xFFE08A00)
                      : const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    ),
    for (final it in z.items) _scanItemRow(p, it),
  ];

  Widget _scanItemRow(PlanType p, ScanItem it) {
    final bi = it.stores.isEmpty ? 0 : bestStore(it.stores);
    // T41 — only items that carry a store offer become cart lines, so only
    // those get a selection checkbox; a no-store item renders unchanged.
    final selectable = it.stores.isNotEmpty;
    final key = _itemKey(p, it);
    final checked = _selected?.contains(key) ?? false;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${it.emoji} ${it.name}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BsTokens.inkLight,
          ),
        ),
        Text(
          it.meta,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        if (it.stores.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (var s = 0; s < it.stores.length; s++)
                _StoreChip(offer: it.stores[s], best: s == bi),
            ],
          ),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child:
          selectable
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ≥48dp tap target (a11y) — the checkbox glyph itself is
                  // unchanged; only its hit area grows.
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Checkbox(
                      value: checked,
                      activeColor: BsTokens.brand,
                      onChanged:
                          (v) => setState(() {
                            final sel = _selected ??= {};
                            if (v ?? false) {
                              sel.add(key);
                            } else {
                              sel.remove(key);
                            }
                          }),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: details),
                ],
              )
              : details,
    );
  }
}
