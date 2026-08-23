// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 46 — the PRODUCT-
// AUTHORING screen (wizard step 4 surface).
//
// The owner authors the trade's [TradeProduct]s: a list of the existing
// products (nameHe + the sku id + the owning category's titleHe, each with a
// Semantics-'מחק' delete), and an add-form — 'שם מוצר' · 'מק"ט' · a REQUIRED
// 'קטגוריה' dropdown over the trade's authored categories (a trade with NO
// categories renders 'צור קטגוריה קודם' instead of the category-dependent
// form-fields — the picker + the schema inputs — and the add button
// no-ops) · one dynamic input PER trade [AttributeDef]: a def
// WITH values renders a dropdown of its values' labelHe (schema-driven — an
// out-of-schema value is impossible to enter), a def with NO values
// (freeText / number) renders a TextField (number kind: digits-only input).
// 'הוסף מוצר' writes through `upsertProduct` with id = the typed מק"ט
// VERBATIM (the sku IS the id — no slug), attributes keyed
// attributeDefId → valueId | free text (the trade_schema.dart:327 contract);
// a מק"ט already present in doc.products is a no-op + the red inline error
// 'מק"ט כבר קיים' (an upsert would silently overwrite that product). The 🧩
// AppBar action pushes the trade's AccessoryRuleEditorScreen. Lists stay
// non-virtualized ON PURPOSE (≤10K rows — Pillar 5 owns at-scale perf).
//
// s48 — the BULK-IMPORT section ('ייבוא מ-CSV', below the add-form), a
// collection-`if` on [featureFlagsProvider] (kTradeImportFlag, default OFF —
// absent from prefs AND `_forcedOnFlags`), so with the flag off the section
// is ABSENT from the widget tree and this screen is byte-identical to s47.
// Template → dry-run → ATOMIC commit: 'הורד תבנית' fills the paste box with
// `generateCsvTemplate(the trade's defs)`; 'בדוק (dry-run)' runs the PURE
// `parseAndValidateCsv` (domain/trade_import.dart) over the trade's slices +
// ALL authored products and renders 'תקינים: N · שגיאות: M' plus the first 5
// error lines ('שורה R: <msg>'); 'ייבא' exists ONLY while the LAST report's
// canCommit holds (zero errors AND ≥1 valid row — the atomicity is the gate:
// anything less commits NOTHING), upserts every report.valid product, clears
// the box and confirms 'יובאו N מוצרים'. Editing the paste voids the report —
// a stale dry-run can never commit.
//
// Reached only via CategoryTreeEditorScreen's 📦 AppBar action (itself
// behind kTradeBuilderFlag, default OFF) ⇒ zero regression; the live catalog
// keeps reading the baked seed unchanged (authored deltas only; the const
// files are untouched). LIGHT manager idiom + explicit RTL + Semantics on
// every tappable + the screen-local textScaler clamp (max 1.35) — the
// s44/s45 family (trade_builder_home.dart) verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/domain/trade_import.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/accessory_rule_editor.dart';
import 'package:buildsmart/screens/trade_builder/connection_rule_studio.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:buildsmart/state/trade_builder_flags.dart'
    show kTradeImportFlag;
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The screen glyph (TradeProduct itself carries no emoji — the tiles and
/// the empty state reuse it).
const String _kProductEmoji = '📦';

/// 📦 מוצרים — the trade's product-authoring screen (Pillar-2 · step 46).
class ProductAuthoringScreen extends ConsumerStatefulWidget {
  const ProductAuthoringScreen({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => ProductAuthoringScreen(tradeId: tradeId),
      );

  @override
  ConsumerState<ProductAuthoringScreen> createState() =>
      _ProductAuthoringState();
}

class _ProductAuthoringState extends ConsumerState<ProductAuthoringScreen> {
  final _name = TextEditingController();
  final _sku = TextEditingController();

  /// The REQUIRED category pick (kept across adds so consecutive products
  /// land in the same category without re-picking).
  String? _categoryId;

  /// Chosen value id per attribute-def id (defs WITH values — the schema
  /// dropdowns; out-of-schema is impossible by construction).
  final Map<String, String> _attrChoice = {};

  /// Free-text controller per attribute-def id (defs with NO values —
  /// freeText / number), created lazily, all disposed with the screen.
  final Map<String, TextEditingController> _attrText = {};

  /// The duplicate-מק"ט inline error flag.
  bool _skuTaken = false;

  /// Bumped on every successful add — keys the attribute dropdowns so their
  /// FormField state hard-resets with the cleared form.
  int _epoch = 0;

  /// s48: the bulk-import paste box (flag-gated section only).
  final _csv = TextEditingController();

  /// s48: the LAST dry-run verdict — the ONLY gate to 'ייבא'. Voided (null)
  /// the moment the paste is edited, so a stale report can never commit.
  ImportReport? _report;

  /// s48: how many products the last commit imported (null = no fresh
  /// confirmation to show).
  int? _importedCount;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _csv.dispose();
    for (final c in _attrText.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _attrCtl(String defId) =>
      _attrText.putIfAbsent(defId, TextEditingController.new);

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

  /// The trade's products, in authored order (products carry no sortIndex).
  List<TradeProduct> _products(TradesDoc doc) => [
        for (final p in doc.products)
          if (p.tradeId == widget.tradeId) p,
      ];

  /// The trade's attribute defs, in authored order.
  List<AttributeDef> _defs(TradesDoc doc) => [
        for (final a in doc.attributes)
          if (a.tradeId == widget.tradeId) a,
      ];

  /// The owning category's titleHe ('' when the category no longer exists —
  /// the tile stays orphan-safe instead of throwing).
  String _categoryTitle(TradesDoc doc, String id) {
    for (final c in doc.categories) {
      if (c.id == id) return c.titleHe;
    }
    return '';
  }

  /// Add from the form. Guards: empty name / empty מק"ט / no category →
  /// no-op; a מק"ט already present in doc.products → no-op + the red
  /// 'מק"ט כבר קיים' (an upsert would silently overwrite that product). The
  /// id is the typed מק"ט VERBATIM (no slug — the sku IS the id); attributes
  /// land keyed attributeDefId → valueId | free text, non-empty entries only.
  void _add() {
    final name = _name.text.trim();
    final sku = _sku.text.trim();
    final catId = _categoryId;
    if (name.isEmpty || sku.isEmpty || catId == null) return;
    final doc = ref.read(tradesStoreProvider);
    if (!_cats(doc).any((c) => c.id == catId)) return;
    if (doc.products.any((p) => p.id == sku)) {
      setState(() => _skuTaken = true);
      return;
    }
    final attrs = <String, String>{};
    for (final d in _defs(doc)) {
      if (d.values.isNotEmpty) {
        final v = _attrChoice[d.id];
        if (v != null && d.values.any((x) => x.id == v)) {
          attrs[d.id] = v;
        }
      } else {
        final t = _attrText[d.id]?.text.trim() ?? '';
        if (t.isNotEmpty) {
          attrs[d.id] = t;
        }
      }
    }
    ref.read(tradesStoreProvider.notifier).upsertProduct(
          TradeProduct(
            id: sku,
            tradeId: widget.tradeId,
            categoryId: catId,
            // The minimal s46 surface authors neither a brand nor an English
            // name — both are REQUIRED by the real ctor and land empty (the
            // exact shape a tolerant fromJson would default them to).
            brandId: '',
            nameHe: name,
            nameEn: '',
            attributes: attrs,
          ),
        );
    setState(() {
      _name.clear();
      _sku.clear();
      _attrChoice.clear();
      for (final c in _attrText.values) {
        c.clear();
      }
      _skuTaken = false;
      _epoch++; // hard-reset the attribute dropdowns' FormField state
    });
  }

  /// s48: the dry-run — the PURE parse/validate over the paste, against the
  /// trade's OWN slices (categories · defs) but the GLOBAL product set for the
  /// duplicate-sku check: `upsertProduct` matches by GLOBAL id (the sku IS the
  /// id), so a sku already owned by ANOTHER trade must collide as an error
  /// here (else the commit silently re-homes it — data loss), the same global
  /// guard the add-form uses. Empty paste guards no-op (the pill is
  /// disabled-grey then anyway).
  void _dryRun() {
    if (_csv.text.trim().isEmpty) return;
    final doc = ref.read(tradesStoreProvider);
    setState(() {
      _report = parseAndValidateCsv(
        csv: _csv.text,
        tradeId: widget.tradeId,
        categories: _cats(doc),
        defs: _defs(doc),
        // GLOBAL, not `_products(doc)`: `upsertProduct` matches by GLOBAL id
        // (the sku IS the id), so a sku owned by ANOTHER trade MUST collide as
        // an error here — else the commit silently re-homes it (data loss).
        // Mirrors the add-form guard `doc.products.any((p) => p.id == sku)`.
        existingProducts: doc.products,
      );
      _importedCount = null;
    });
  }

  /// s48: the ATOMIC commit — reachable ONLY through a canCommit report
  /// (zero errors AND ≥1 valid row; the atomicity IS that gate — anything
  /// less commits nothing). Upserts every validated product, then clears the
  /// import state and leaves the 'יובאו N מוצרים' confirmation.
  void _commitImport() {
    final report = _report;
    if (report == null || !report.canCommit) return; // guard no-op
    final store = ref.read(tradesStoreProvider.notifier);
    for (final p in report.valid) {
      store.upsertProduct(p);
    }
    setState(() {
      _csv.clear();
      _report = null;
      _importedCount = report.valid.length;
    });
  }

  // NOTE deliberately NO hintText anywhere on this screen: a hint renders as
  // a real (transparent) Text widget, and the step-46 tests count VISIBLE
  // Text widgets containing authored names — a 'למשל: …' hint echoing a
  // plausible name would poison those counts.
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
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
    final products = _products(doc);
    final cats = _cats(doc);
    final defs = _defs(doc);
    // Guard the kept pick against a category deleted meanwhile (a Dropdown
    // asserts its value is among its items).
    final catValue =
        cats.any((c) => c.id == _categoryId) ? _categoryId : null;
    // s48: a LOCAL of the last dry-run verdict (a field never promotes).
    final report = _report;
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
              'product_authoring_screen.t01',
              '📦 מוצרים',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            actions: [
              // s46: the sibling authoring surface — the trade's
              // accessory-rule editor.
              Semantics(
                button: true,
                label: 'אביזרים',
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    AccessoryRuleEditorScreen.route(widget.tradeId),
                  ),
                  icon: const Text('🧩', style: TextStyle(fontSize: 18)),
                ),
              ),
              // s47: the sibling authoring surface — the trade's
              // connection-rule studio (wizard step 5).
              Semantics(
                button: true,
                label: 'כללי חיבור',
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    ConnectionRuleStudioScreen.route(widget.tradeId),
                  ),
                  icon: const Text('🔌', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space5,
            ),
            children: [
              // ── the authored products ──────────────────────────────────
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: BsTokens.space4),
                  child: _EmptyProducts(),
                )
              else
                for (final p in products)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space3),
                    child: _ProductTile(
                      product: p,
                      categoryTitle: _categoryTitle(doc, p.categoryId),
                      onDelete: () => ref
                          .read(tradesStoreProvider.notifier)
                          .removeProduct(p.id),
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
                decoration: _dec('שם מוצר'),
              ),
              const SizedBox(height: BsTokens.space4),
              TextField(
                controller: _sku,
                onChanged: (_) => setState(() => _skuTaken = false),
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('מק"ט'),
              ),
              const SizedBox(height: BsTokens.space4),
              if (cats.isEmpty)
                // A product REQUIRES a category; with none authored yet the
                // pointer replaces the category-dependent form-fields (the
                // picker + the schema inputs) and the add button below
                // stays a no-op.
                const Padding(
                  padding: EdgeInsets.only(bottom: BsTokens.space2),
                  child: CfgText(
                    'product_authoring_screen.t02',
                    'צור קטגוריה קודם',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else ...[
                DropdownButtonFormField<String>(
                  value: catValue,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style:
                      const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                  decoration: _dec('קטגוריה'),
                  items: [
                    for (final c in cats)
                      DropdownMenuItem(value: c.id, child: Text(c.titleHe)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                // ── one dynamic input PER AttributeDef (schema-driven) ───
                for (final d in defs) ...[
                  const SizedBox(height: BsTokens.space4),
                  if (d.values.isNotEmpty)
                    // A def WITH values: only its authored values are
                    // offered — an out-of-schema value cannot be entered.
                    DropdownButtonFormField<String>(
                      key: ValueKey('attr-${d.id}-$_epoch'),
                      value: _attrChoice[d.id],
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 14,
                      ),
                      decoration: _dec(d.nameHe),
                      items: [
                        for (final v in d.values)
                          DropdownMenuItem(
                            value: v.id,
                            child: Text(v.labelHe),
                          ),
                      ],
                      onChanged: (v) => setState(() {
                        if (v == null) {
                          _attrChoice.remove(d.id);
                        } else {
                          _attrChoice[d.id] = v;
                        }
                      }),
                    )
                  else
                    // A def with NO values (freeText / number): free input;
                    // the number kind is digits-only at the keystroke level.
                    TextField(
                      controller: _attrCtl(d.id),
                      onChanged: (_) => setState(() {}),
                      keyboardType: d.kind == AttributeKind.number
                          ? TextInputType.number
                          : null,
                      inputFormatters: d.kind == AttributeKind.number
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 14,
                      ),
                      decoration: _dec(d.nameHe),
                    ),
                ],
              ],
              if (_skuTaken) ...[
                const SizedBox(height: BsTokens.space2),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CfgText(
                    'product_authoring_screen.t03',
                    'מק"ט כבר קיים',
                    style: TextStyle(
                      color: BsTokens.dangerDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: BsTokens.space4),
              _PillButton(
                label: 'הוסף מוצר',
                enabled: cats.isNotEmpty &&
                    _name.text.trim().isNotEmpty &&
                    _sku.text.trim().isNotEmpty &&
                    catValue != null,
                onTap: _add,
              ),
              // ── s48 · bulk import (kTradeImportFlag, default OFF) ───────
              // A collection-`if` on [featureFlagsProvider] — the EXACT
              // manager-dashboard idiom (kTradeBuilderFlag): flag off ⇒ the
              // whole section is ABSENT from the widget tree, this screen is
              // byte-identical to s47; the only path in is the owner-staged
              // `enable('kTradeImport')`.
              if (ref.watch(featureFlagsProvider).contains(kTradeImportFlag)) ...[
                const SizedBox(height: BsTokens.space5),
                const _SectionHeader('ייבוא מ-CSV'),
                const SizedBox(height: BsTokens.space3),
                // Fills the paste box with the trade's template (fixed
                // columns + one per AttributeDef) — v1 "download" is
                // fill-in-place; a real file save is a Pillar-5 concern.
                _PillButton(
                  label: 'הורד תבנית',
                  onTap: () => setState(() {
                    _csv.text = generateCsvTemplate(defs);
                    _report = null;
                    _importedCount = null;
                  }),
                ),
                const SizedBox(height: BsTokens.space4),
                TextField(
                  controller: _csv,
                  // Any edit voids the last dry-run — 'ייבא' vanishes until
                  // the NEW text passes 'בדוק' (a stale report never commits).
                  onChanged: (_) => setState(() {
                    _report = null;
                    _importedCount = null;
                  }),
                  maxLines: 6,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                  ),
                  decoration: _dec('הדבק CSV'),
                ),
                const SizedBox(height: BsTokens.space4),
                _PillButton(
                  label: 'בדוק (dry-run)',
                  enabled: _csv.text.trim().isNotEmpty,
                  onTap: _dryRun,
                ),
                if (report != null) ...[
                  const SizedBox(height: BsTokens.space4),
                  Text(
                    'תקינים: ${report.valid.length} · '
                    'שגיאות: ${report.errors.length}',
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // The first 5 error lines, each its OWN Text (exact-match
                  // finder-safe), 'שורה R: <msg>' — R is the error's OWN
                  // rowIndex (0 = the header line, else the 1-based data row).
                  for (final e in report.errors.take(5)) ...[
                    const SizedBox(height: BsTokens.space2),
                    Text(
                      'שורה ${e.rowIndex}: ${e.messageHe}',
                      style: const TextStyle(
                        color: BsTokens.dangerDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  // The commit action EXISTS only while the last report can
                  // commit (zero errors AND ≥1 valid row) — the atomic gate.
                  if (report.canCommit) ...[
                    const SizedBox(height: BsTokens.space4),
                    _PillButton(label: 'ייבא', onTap: _commitImport),
                  ],
                ],
                if (_importedCount != null) ...[
                  const SizedBox(height: BsTokens.space4),
                  Text(
                    'יובאו $_importedCount מוצרים',
                    style: const TextStyle(
                      color: BsTokens.successDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The s47 section-title idiom verbatim (connection_rule_studio.dart) — the
/// s48 import header reuses it.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: BsTokens.inkLight,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}

/// The calm empty-state — the s45 _EmptyCategories idiom with the s46
/// literal.
class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: const Column(
        children: [
          Text(_kProductEmoji, style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          CfgText(
            'product_authoring_screen.t04',
            'אין עדיין מוצרים',
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

/// One authored-product tile — the family's WHITE card: emoji square +
/// nameHe + the sku id + the owning category's titleHe (each its OWN Text —
/// exact-match finder-safe), and a Semantics-'מחק' trailing delete.
class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.categoryTitle,
    required this.onDelete,
  });

  final TradeProduct product;
  final String categoryTitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$_kProductEmoji ${product.nameHe}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BsTokens.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                _kProductEmoji,
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: BsTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameHe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                  if (categoryTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      categoryTitle,
                      maxLines: 1,
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
                // A real tooltip: a semantics label for screen-readers AND
                // a long-press hint — independent of semantics-tree timing.
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
      ),
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
