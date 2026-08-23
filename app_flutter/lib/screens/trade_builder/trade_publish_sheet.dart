// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 47 — the FK-GATED
// publish sheet (wizard step 6 surface, R2-7).
//
// The owner's go/no-go surface for a trade: FOUR readiness gates computed
// from the trade's slices of the authored doc, each rendered '✓' / '✗' with
// its Hebrew label —
//   r1 'לכל קטגוריה יש מוצר'                — every trade category has ≥1
//       trade product carrying its categoryId;
//   r2 'לכל ציר וריאנט יש ערכים'            — every AttributeDef flagged
//       isVariantAxis has values;
//   r3 'אין כלל-חיבור יתום'                 — every compat rule's aTypeId AND
//       bTypeId point at existing trade connector types, and (s50) every
//       completion rule's NON-EMPTY whenInLineHasTypeId / requireTypeId does
//       too — empty type-fields (material-based rules, e.g. galvanic) stay
//       valid;
//   r4 'כל המוצרים משויכים לקטגוריה קיימת' — every product's categoryId is a
//       real trade category (the R2-7 FK gate).
// Below the gates: the dry-run counts line 'קטגוריות: N · מוצרים: M ·
// כללים: K'. The 'פרסם' pill republishes the trade ONLY when all four pass —
// `upsertTrade` with published:true and EVERY other authored field preserved
// (the s45 _copy idiom — Trade has no copyWith) — then pops; any failing
// gate (or a trade id with no Trade in the store — the fail-ALL edge) is a
// no-op and the ✗ rows stay visible.
//
// Reached only via the 🚀 trailing action on TradeBuilderHomeScreen's trade
// tiles (itself behind kTradeBuilderFlag, default OFF) ⇒ zero regression;
// the live catalog keeps reading the baked seed unchanged (authored deltas
// only; the const files are untouched). LIGHT manager idiom + explicit RTL +
// Semantics on every tappable + the screen-local textScaler clamp (max 1.35)
// — the s44/s45 family (trade_builder_home.dart) verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rebuild a trade with the published flag flipped, preserving EVERY other
/// authored field (nameHe, emoji, color, personaId, schemaVersion, brandIds —
/// the domain type has no copyWith; the s45 _copy idiom).
Trade _copy(Trade t, {bool? published}) => Trade(
      id: t.id,
      nameHe: t.nameHe,
      emoji: t.emoji,
      color: t.color,
      personaId: t.personaId,
      published: published ?? t.published,
      schemaVersion: t.schemaVersion,
      brandIds: t.brandIds,
    );

/// 🚀 פרסום ענף — the trade's FK-gated publish sheet (Pillar-2 · step 47).
class TradePublishSheet extends ConsumerWidget {
  const TradePublishSheet({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => TradePublishSheet(tradeId: tradeId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(tradesStoreProvider);
    // ── the trade's slices of the authored doc ──────────────────────────
    Trade? trade;
    for (final t in doc.trades) {
      if (t.id == tradeId) {
        trade = t;
        break;
      }
    }
    final cats = [
      for (final c in doc.categories)
        if (c.tradeId == tradeId) c,
    ];
    final products = [
      for (final p in doc.products)
        if (p.tradeId == tradeId) p,
    ];
    final defs = [
      for (final a in doc.attributes)
        if (a.tradeId == tradeId) a,
    ];
    final types = [
      for (final t in doc.connectorTypes)
        if (t.tradeId == tradeId) t,
    ];
    final rules = [
      for (final r in doc.compatRules)
        if (r.tradeId == tradeId) r,
    ];
    final completions = [
      for (final r in doc.completionRules)
        if (r.tradeId == tradeId) r,
    ];
    final catIds = {for (final c in cats) c.id};
    final typeIds = {for (final t in types) t.id};
    // ── the four readiness gates (a missing trade fails ALL — the edge) ──
    final exists = trade != null;
    final r1 = exists &&
        cats.every((c) => products.any((p) => p.categoryId == c.id));
    final r2 = exists &&
        defs.every((d) => !d.isVariantAxis || d.values.isNotEmpty);
    final r3 = exists &&
        rules.every(
          (r) => typeIds.contains(r.aTypeId) && typeIds.contains(r.bTypeId),
        ) &&
        // s50: completion rules join the orphan gate — a NON-EMPTY type field
        // must resolve to a trade connector type; empty type fields
        // (material-based rules, e.g. galvanic) are valid by design.
        completions.every(
          (r) =>
              (r.whenInLineHasTypeId.isEmpty ||
                  typeIds.contains(r.whenInLineHasTypeId)) &&
              (r.requireTypeId.isEmpty || typeIds.contains(r.requireTypeId)),
        );
    final r4 = exists && products.every((p) => catIds.contains(p.categoryId));
    final allPass = r1 && r2 && r3 && r4;

    final mq = MediaQuery.of(context);
    // The SAME a11y clamp as the s44/s45 builder screens: cap the text scale
    // at 1.35× (never scales UP — min only caps).
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(math.min(mq.textScaler.scale(1), 1.35)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            iconTheme: const IconThemeData(color: BsTokens.inkLight),
            title: const CfgText(
              'trade_publish_sheet.t01',
              '🚀 פרסום ענף',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space5,
            ),
            children: [
              // ── the readiness card — the four gates ────────────────────
              Container(
                padding: const EdgeInsets.all(BsTokens.space4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CheckRow(pass: r1, label: 'לכל קטגוריה יש מוצר'),
                    const SizedBox(height: BsTokens.space3),
                    _CheckRow(pass: r2, label: 'לכל ציר וריאנט יש ערכים'),
                    const SizedBox(height: BsTokens.space3),
                    _CheckRow(pass: r3, label: 'אין כלל-חיבור יתום'),
                    const SizedBox(height: BsTokens.space3),
                    _CheckRow(
                      pass: r4,
                      label: 'כל המוצרים משויכים לקטגוריה קיימת',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BsTokens.space4),
              // ── the dry-run counts line ────────────────────────────────
              Text(
                'קטגוריות: ${cats.length} · מוצרים: ${products.length} · '
                'כללים: ${rules.length}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: BsTokens.space5),
              _PillButton(
                label: 'פרסם',
                enabled: allPass,
                onTap: () {
                  // The FK gate (R2-7): any failing check → no-op (the ✗
                  // rows stay visible); a missing trade is the fail-all
                  // edge. Publish = the SAME trade with published:true,
                  // every other authored field preserved.
                  final t = trade;
                  if (t == null || !allPass) return;
                  ref
                      .read(tradesStoreProvider.notifier)
                      .upsertTrade(_copy(t, published: true));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One readiness row — the leading verdict glyph ('✓' pass green / '✗' fail
/// red), then the Hebrew gate label (each its OWN Text — exact-match
/// finder-safe).
class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.pass, required this.label});

  final bool pass;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          pass ? '✓' : '✗',
          style: TextStyle(
            color: pass ? BsTokens.successDark : BsTokens.dangerDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// The family's brand-pill action (the s44 _SaveDraftButton idiom): always
/// tappable (guards no-op), [enabled] drives the disabled-grey visual + the
/// Semantics enabled flag. Shrink-wraps in a Row, stretches in a ListView.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
