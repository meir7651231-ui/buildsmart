// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 46 — the ACCESSORY-
// RULE editor (wizard step 5 surface).
//
// The owner authors the trade's [AccessoryRule]s (the generalization of
// `SmartAcc`, smart_tree.dart): a list of the existing rules (nameHe + whyHe,
// the amber 'חובה' pill when mustHave — plan addition-B: must-have marked
// visually distinct from recommended — and the '₪<price>' pill when a price
// is set, each with a Semantics-'מחק' delete), and an add-form — 'שם אביזר' ·
// 'למה חשוב' · the 'חובה?' switch · 'מחיר' (digits only: a non-digit price is
// a no-op + the red inline error 'מחיר לא תקין') · a REQUIRED 'קטגוריה'
// dropdown over the trade's authored categories · the 'מוצר מקושר' dropdown
// ('ללא' first, then ONLY the trade's own products — a `linkSku` can never
// point at a SKU outside the trade, so an orphan link is impossible to
// author). 'הוסף אביזר' writes through `upsertAccessory` under a
// DETERMINISTIC slug id '<tradeId>.acc.<slug>' (the s44/s45 idiom — NO
// DateTime/random; a collision appends '-2', '-3', …).
//
// Reached only via ProductAuthoringScreen's 🧩 AppBar action (itself behind
// kTradeBuilderFlag, default OFF) ⇒ zero regression; the live catalog keeps
// reading the baked seed unchanged (authored deltas only; the const files
// are untouched). LIGHT manager idiom + explicit RTL + Semantics on every
// tappable + the screen-local textScaler clamp (max 1.35) — the s44/s45
// family (trade_builder_home.dart) verbatim.
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

/// The emoji a new accessory rule is stamped with (AccessoryRule.emoji is
/// REQUIRED by the real ctor; the add-form keeps the minimal s46 surface —
/// no emoji field yet).
const String _kDefaultAccessoryEmoji = '🧩';

/// The draft-amber of the family's emphasis chips (the _StatusChip 'טיוטה'
/// idiom) — carries the 'חובה' pill.
const Color _kMustColor = Color(0xFFB45309);

/// The s44 deterministic slug: trimmed, lowercased, whitespace runs → '-'.
/// NO DateTime/random — the same text always yields the same slug.
String _slug(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

/// Strict digits-only check for the price field (int.tryParse alone would
/// also accept '-5' / '+5' / hex-ish forms — a price is plain digits).
final RegExp _kDigitsOnly = RegExp(r'^[0-9]+$');

/// 🧩 אביזרים — the trade's accessory-rule editor (Pillar-2 · step 46).
class AccessoryRuleEditorScreen extends ConsumerStatefulWidget {
  const AccessoryRuleEditorScreen({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => AccessoryRuleEditorScreen(tradeId: tradeId),
      );

  @override
  ConsumerState<AccessoryRuleEditorScreen> createState() =>
      _AccessoryRuleEditorState();
}

class _AccessoryRuleEditorState
    extends ConsumerState<AccessoryRuleEditorScreen> {
  final _name = TextEditingController();
  final _why = TextEditingController();
  final _price = TextEditingController();
  bool _mustHave = false;

  /// The REQUIRED category pick (kept across adds so consecutive rules land
  /// in the same category without re-picking).
  String? _categoryId;

  /// The optional linked-product pick (null = 'ללא').
  String? _linkSku;

  /// The non-digit-price inline error flag.
  bool _priceError = false;

  /// Bumped on every successful add — keys the linked-product dropdown so
  /// its FormField state hard-resets with the cleared form.
  int _epoch = 0;

  @override
  void dispose() {
    _name.dispose();
    _why.dispose();
    _price.dispose();
    super.dispose();
  }

  /// The trade's categories STABLE-sorted by sortIndex (the s45 idiom — ties
  /// keep the stored order, so a legacy doc never shuffles between builds).
  List<TradeCategory> _cats(TradesDoc doc) {
    final own = [
      for (final c in doc.categories)
        if (c.tradeId == widget.tradeId) c,
    ];
    final indexed = own.asMap().entries.toList()
      ..sort((a, b) {
        final bySort = a.value.sortIndex.compareTo(b.value.sortIndex);
        return bySort != 0 ? bySort : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  /// The trade's products, in authored order — the ONLY candidates the
  /// linked-product dropdown ever offers (orphan-proof by construction).
  List<TradeProduct> _products(TradesDoc doc) => [
        for (final p in doc.products)
          if (p.tradeId == widget.tradeId) p,
      ];

  /// The trade's accessory rules, in authored order (rules carry no
  /// sortIndex).
  List<AccessoryRule> _rules(TradesDoc doc) => [
        for (final a in doc.accessories)
          if (a.tradeId == widget.tradeId) a,
      ];

  /// '<tradeId>.acc.<slug>' — deterministic; an id collision appends '-2',
  /// then '-3', … (the s45 contract), so a same-named rule never silently
  /// overwrites an existing one.
  String _newAccessoryId(List<AccessoryRule> all, String name) {
    final base = '${widget.tradeId}.acc.${_slug(name)}';
    var id = base;
    var n = 2;
    while (all.any((a) => a.id == id)) {
      id = '$base-${n++}';
    }
    return id;
  }

  /// Add from the form. Guards: empty name / no category → no-op; a
  /// non-digit price → no-op + the red 'מחיר לא תקין'; an empty price is
  /// simply "no price" (null). linkSku is re-validated against the trade's
  /// products at write time, so it can never land as an orphan.
  void _add() {
    final name = _name.text.trim();
    final catId = _categoryId;
    if (name.isEmpty || catId == null) return;
    final doc = ref.read(tradesStoreProvider);
    if (!_cats(doc).any((c) => c.id == catId)) return;
    final priceText = _price.text.trim();
    int? price;
    if (priceText.isNotEmpty) {
      if (!_kDigitsOnly.hasMatch(priceText)) {
        setState(() => _priceError = true);
        return;
      }
      price = int.parse(priceText);
    }
    final link =
        _products(doc).any((p) => p.id == _linkSku) ? _linkSku : null;
    ref.read(tradesStoreProvider.notifier).upsertAccessory(
          AccessoryRule(
            id: _newAccessoryId(doc.accessories, name),
            tradeId: widget.tradeId,
            appliesToCategoryId: catId,
            nameHe: name,
            emoji: _kDefaultAccessoryEmoji,
            whyHe: _why.text.trim(),
            mustHave: _mustHave,
            price: price,
            linkSku: link,
          ),
        );
    setState(() {
      _name.clear();
      _why.clear();
      _price.clear();
      _mustHave = false;
      _linkSku = null;
      _priceError = false;
      _epoch++; // hard-reset the linked-product dropdown's FormField state
    });
  }

  // NOTE deliberately NO hintText anywhere on this screen: a hint renders as
  // a real (transparent) Text widget, and the step-46 tests count VISIBLE
  // Text widgets containing authored names — a 'למשל: …' hint echoing a
  // plausible name would poison those counts.
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BsTokens.cardLight,
        labelStyle:
            const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BsTokens.brand, width: 1.4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(tradesStoreProvider);
    final rules = _rules(doc);
    final cats = _cats(doc);
    final products = _products(doc);
    // Guard the kept picks against rows deleted meanwhile (a Dropdown
    // asserts its value is among its items).
    final catValue =
        cats.any((c) => c.id == _categoryId) ? _categoryId : null;
    final linkValue =
        products.any((p) => p.id == _linkSku) ? _linkSku : null;
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
          backgroundColor: BsTokens.bgLight,
          appBar: AppBar(
            backgroundColor: BsTokens.cardLight,
            elevation: 0,
            iconTheme: const IconThemeData(color: BsTokens.inkLight),
            title: const CfgText(
              'accessory_rule_editor.t01',
              '🧩 אביזרים',
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
              // ── the authored rules ─────────────────────────────────────
              if (rules.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: BsTokens.space4),
                  child: _EmptyAccessories(),
                )
              else
                for (final r in rules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space3),
                    child: _AccessoryTile(
                      rule: r,
                      onDelete: () => ref
                          .read(tradesStoreProvider.notifier)
                          .removeAccessory(r.id),
                    ),
                  ),
              const SizedBox(height: BsTokens.space2),
              // ── the add-form ───────────────────────────────────────────
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('שם אביזר'),
              ),
              const SizedBox(height: BsTokens.space4),
              TextField(
                controller: _why,
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('למה חשוב'),
              ),
              const SizedBox(height: BsTokens.space2),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: BsTokens.brand,
                title: const CfgText(
                  'accessory_rule_editor.t02',
                  'חובה?',
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 14),
                ),
                value: _mustHave,
                onChanged: (v) => setState(() => _mustHave = v),
              ),
              const SizedBox(height: BsTokens.space2),
              TextField(
                controller: _price,
                // No input formatter here ON PURPOSE: the contract's error
                // path ('מחיר לא תקין') must stay reachable — a digits-only
                // formatter would silently swallow the bad input instead.
                onChanged: (_) => setState(() => _priceError = false),
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('מחיר'),
              ),
              if (_priceError) ...[
                const SizedBox(height: BsTokens.space2),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CfgText(
                    'accessory_rule_editor.t03',
                    'מחיר לא תקין',
                    style: TextStyle(
                      color: BsTokens.dangerDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: BsTokens.space4),
              DropdownButtonFormField<String>(
                value: catValue,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('קטגוריה'),
                items: [
                  for (final c in cats)
                    DropdownMenuItem(value: c.id, child: Text(c.titleHe)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: BsTokens.space4),
              DropdownButtonFormField<String?>(
                key: ValueKey('acc-link-$_epoch'),
                value: linkValue,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('מוצר מקושר'),
                items: [
                  // 'ללא' first (the null pick), then ONLY the trade's own
                  // products — an out-of-trade / non-existent SKU is
                  // impossible to author (orphan-proof).
                  const DropdownMenuItem<String?>(
                    child: CfgText('accessory_rule_editor.t04', 'ללא'),
                  ),
                  for (final p in products)
                    DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text(p.nameHe),
                    ),
                ],
                onChanged: (v) => setState(() => _linkSku = v),
              ),
              const SizedBox(height: BsTokens.space4),
              _PillButton(
                label: 'הוסף אביזר',
                enabled:
                    _name.text.trim().isNotEmpty && catValue != null,
                onTap: _add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The calm empty-state — the s45 _EmptyCategories idiom with the s46
/// literal.
class _EmptyAccessories extends StatelessWidget {
  const _EmptyAccessories();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space5,
      ),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: const Column(
        children: [
          Text('🧩', style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          CfgText(
            'accessory_rule_editor.t05',
            'אין עדיין אביזרים',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// One authored-rule tile — the family's WHITE card: emoji square + nameHe +
/// the whyHe line, a Semantics-'מחק' delete button, and the pills row (the
/// amber 'חובה' when mustHave, '₪<price>' when a price is set).
class _AccessoryTile extends StatelessWidget {
  const _AccessoryTile({required this.rule, required this.onDelete});

  final AccessoryRule rule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final price = rule.price;
    final hasPills = rule.mustHave || price != null;
    return Semantics(
      label: '${rule.emoji} ${rule.nameHe}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BsTokens.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rule.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (rule.whyHe.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          rule.whyHe,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Semantics(
                  label: 'מחק',
                  button: true,
                  child: IconButton(
                    onPressed: onDelete,
                    // A real tooltip: a semantics label for screen-readers
                    // AND a long-press hint — independent of semantics-tree
                    // timing.
                    tooltip: 'מחק',
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            if (hasPills) ...[
              const SizedBox(height: BsTokens.space3),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Plan addition-B: mustHave marked visually distinct
                  // (חובה vs מומלץ) — parity to SmartAcc.must.
                  if (rule.mustHave) const _MustChip(),
                  if (price != null) _PriceChip(price: price),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The amber 'חובה' chip (the family's _StatusChip 'טיוטה' amber idiom — a
/// 12% wash with full-colour AA text). A REAL Material [Chip] (it builds a
/// RawChip internally) — the step-46 contract pins the חובה text INSIDE a
/// chip, visually distinct from the plain 'חובה?' switch title.
class _MustChip extends StatelessWidget {
  const _MustChip();

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: const CfgText(
        'accessory_rule_editor.t06',
        'חובה',
        style: TextStyle(
          color: _kMustColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      backgroundColor: _kMustColor.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}

/// The '₪<price>' chip — neutral bordered white (read-only display; the
/// same Material [Chip] flavor as [_MustChip] so the pills row sits level).
class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '₪$price',
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: BsTokens.cardLight,
      side: const BorderSide(color: Color(0xFFEDEDED)),
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
