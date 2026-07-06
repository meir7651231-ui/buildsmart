// Pillar-2 Step 48 (G-import) — pins the BULK-IMPORT contract
// (domain/trade_import.dart): template → column-map → dry-run → ATOMIC
// commit; no write on error; referential category check (R2-7);
// schema-valued cells blocked out-of-range.
//
//   1. the CSV template: kImportFixedColumns verbatim + one column per
//      AttributeDef (its nameHe) + one example row of empty cells;
//   2. a fully valid file: every row becomes a real TradeProduct — id == the
//      sku VERBATIM, the category CELL (titleHe OR id) resolves to the
//      category ID (never the title), attributes carry {defId: valueId} (a
//      labelHe cell lands as the VALUE ID; a freeText def keeps the raw
//      cell), brandId ''/nameEn '' — zero errors, canCommit true. A
//      header-only file has zero errors AND zero rows ⇒ canCommit stays
//      false (the `valid.isNotEmpty` clause of the gate);
//   3. a bad header short-circuits: ONE row-0 'כותרות לא תקינות', nothing else;
//   4. required cells (sku/name/category) → row-indexed 'שדה חובה חסר'
//      (data rows are 1-based);
//   5. duplicate מק"ט — within the FILE and vs existingProducts → 'מק"ט כפול';
//   6. an unknown category cell is the referential R2-7 error
//      'קטגוריה לא קיימת' — never a silent new category;
//   7. a non-empty cell under a def WITH values must match a value labelHe
//      or id — out-of-schema → 'ערך לא בסכמה'; an EMPTY cell under that def
//      is legal (no error, the attribute is simply absent);
//   8. ATOMICITY through the real store — the caller contract is that the
//      commit loop (`for (p in report.valid) upsertProduct(p)`) runs ONLY
//      when canCommit: a MIXED file (1 good + 1 bad) leaves doc.products
//      byte-identical (empty), then a clean file commits ALL rows.
//
// PURE LOGIC ONLY — the import section of ProductAuthoringScreen (gated by
// kTradeImportFlag == 'kTradeImport', trade_builder_flags.dart) is the
// builder's widget seam and is deliberately NOT tested here. Store idioms
// (mock prefs + ProviderContainer + the async-_load settle trick) come from
// active_trade_provider_test.dart; every store assertion reads the PUBLIC
// tradesStoreProvider doc, never a notifier internal.
import 'package:buildsmart/domain/trade_import.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

const _tradeId = 't.gyp';

/// The trade test 8 seeds through the notifier. A draft is fine — the import
/// keys purely off tradeId. `published` is omitted ⇒ false (an explicit
/// `published: false` trips avoid_redundant_argument_values).
const _trade = Trade(
  id: _tradeId,
  nameHe: 'גבס',
  emoji: '🧱',
  color: 0xFF445566,
  personaId: 'p.gyp',
);

/// The one authored category every valid row must resolve INTO — by titleHe
/// ('לוחות') or by id; either cell spelling must land the ID.
const _boards = TradeCategory(
  id: 't.gyp.cat.boards',
  tradeId: _tradeId,
  titleHe: 'לוחות',
  emoji: '🟩',
);

/// A def WITH values. The value IDS deliberately DIFFER from the labels
/// ('v.16' vs '16') so the {defId: valueId} assertion cannot be dodged — a
/// labelHe cell '16' must be RESOLVED to 'v.16', never stored raw.
const _diameter = AttributeDef(
  id: 't.gyp.attr.diameter',
  tradeId: _tradeId,
  nameHe: 'קוטר',
  emoji: '📏',
  kind: AttributeKind.dimension,
  isVariantAxis: true,
  values: [
    AttributeValue(id: 'v.16', labelHe: '16'),
    AttributeValue(id: 'v.20', labelHe: '20'),
  ],
);

/// A freeText def with NO values — its cells are kept verbatim.
const _color = AttributeDef(
  id: 't.gyp.attr.color',
  tradeId: _tradeId,
  nameHe: 'צבע',
  emoji: '🎨',
  kind: AttributeKind.freeText,
);

const _defs = [_diameter, _color];

/// An already-stored product — the vs-store half of the duplicate-מק"ט rule.
const _existing = TradeProduct(
  id: 'G-9',
  tradeId: _tradeId,
  categoryId: 't.gyp.cat.boards',
  brandId: '',
  nameHe: 'קיים',
  nameEn: '',
);

/// The exact header the template promises for [_defs]: the fixed columns then
/// one column per def (nameHe) — verbatim 'sku,name,category,קוטר,צבע'.
/// Built by join so the bidi-rendered source can't hide a misplaced comma.
final _header = ['sku', 'name', 'category', 'קוטר', 'צבע'].join(',');

/// One data row in [_header]'s column order. Named cells keep the RTL source
/// readable and make an omitted (empty) cell explicit at the call site.
String _row({
  String sku = '',
  String name = '',
  String category = '',
  String diameter = '',
  String color = '',
}) =>
    [sku, name, category, diameter, color].join(',');

ImportReport _parse(String csv, {List<TradeProduct> existing = const []}) =>
    parseAndValidateCsv(
      csv: csv,
      tradeId: _tradeId,
      categories: const [_boards],
      defs: _defs,
      existingProducts: existing,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the template carries the fixed columns + one column per def (nameHe)',
      () {
    expect(kImportFixedColumns, ['sku', 'name', 'category']);

    final lines = generateCsvTemplate(_defs).split('\n');
    expect(lines.first, _header);
    // the promised example row: one EMPTY cell per column (5 cells ⇒ 4 ',').
    expect(lines[1], ',,,,');
  });

  test('a fully valid file yields valid rows, zero errors, canCommit', () {
    final csv = [
      _header,
      _row(
        sku: 'G-100',
        name: 'לוח ירוק',
        category: 'לוחות', // by titleHe
        diameter: '16', // by labelHe
        color: 'לבן',
      ),
      _row(
        sku: 'G-200',
        name: 'לוח כחול',
        category: 't.gyp.cat.boards', // the same category, by ID
        diameter: '20',
        color: 'אפור',
      ),
    ].join('\n');

    final r = _parse(csv);
    expect(r.errors, isEmpty);
    expect(r.valid, hasLength(2));
    expect(r.canCommit, isTrue);

    final a = r.valid.firstWhere((p) => p.id == 'G-100');
    expect(a.tradeId, _tradeId);
    expect(
      a.categoryId,
      _boards.id,
      reason: 'the titleHe CELL must resolve to the category ID, not stick '
          'as the title',
    );
    expect(a.nameHe, 'לוח ירוק');
    expect(a.brandId, '');
    expect(a.nameEn, '');
    expect(
      a.attributes[_diameter.id],
      'v.16',
      reason: 'a labelHe cell resolves to {defId: valueId} — never the label',
    );
    expect(
      a.attributes[_color.id],
      'לבן',
      reason: 'a freeText def keeps the raw cell',
    );

    final b = r.valid.firstWhere((p) => p.id == 'G-200');
    expect(b.categoryId, _boards.id, reason: 'the by-ID cell lands the same');
    expect(b.attributes[_diameter.id], 'v.20');

    // header-only file: zero errors but ALSO zero rows ⇒ the commit gate
    // stays shut (canCommit == errors.isEmpty && valid.isNotEmpty).
    final empty = _parse(_header);
    expect(empty.errors, isEmpty);
    expect(empty.valid, isEmpty);
    expect(empty.canCommit, isFalse);
  });

  test('a bad header short-circuits', () {
    final r = _parse('foo,bar\nG-1,X');
    expect(
      r.errors,
      hasLength(1),
      reason: 'a broken header yields the single row-0 error and NOTHING '
          'else — the data rows are never row-validated',
    );
    expect(r.errors.single.rowIndex, 0);
    expect(r.errors.single.messageHe, contains('כותרות לא תקינות'));
    expect(r.valid, isEmpty);
    expect(r.canCommit, isFalse);
  });

  test('missing required cells are row-indexed errors', () {
    final csv = [
      _header,
      _row(name: 'לוח', category: 'לוחות'), // sku omitted ⇒ empty cell
    ].join('\n');

    final r = _parse(csv);
    expect(
      r.errors.single.messageHe,
      allOf(contains('שדה חובה חסר'), contains('sku')),
    );
    expect(
      r.errors.single.rowIndex,
      1,
      reason: 'data rows are 1-based — the first row under the header is 1',
    );
    expect(r.valid, isEmpty);
    expect(r.canCommit, isFalse);
  });

  test('duplicate sku — in-file AND vs the store', () {
    // (a) the same מק"ט twice within the FILE.
    final inFile = [
      _header,
      _row(sku: 'G-1', name: 'לוח א', category: 'לוחות'),
      _row(sku: 'G-1', name: 'לוח ב', category: 'לוחות'),
    ].join('\n');
    final a = _parse(inFile);
    expect(
      a.errors.map((e) => e.messageHe),
      anyElement(allOf(contains('מק"ט כפול'), contains('G-1'))),
    );
    expect(a.canCommit, isFalse);

    // (b) a fresh file colliding with an id ALREADY in existingProducts.
    final vsStore = [
      _header,
      _row(sku: 'G-9', name: 'לוח ג', category: 'לוחות'),
    ].join('\n');
    final b = _parse(vsStore, existing: const [_existing]);
    expect(
      b.errors.single.messageHe,
      allOf(contains('מק"ט כפול'), contains('G-9')),
    );
    expect(b.errors.single.rowIndex, 1);
    expect(b.valid, isEmpty);
    expect(b.canCommit, isFalse);
  });

  test('unknown category is a referential error (R2-7)', () {
    final csv = [
      _header,
      _row(sku: 'G-1', name: 'לוח', category: 'רפאים'),
    ].join('\n');

    final r = _parse(csv);
    expect(
      r.errors.single.messageHe,
      allOf(contains('קטגוריה לא קיימת'), contains('רפאים')),
      reason: 'R2-7: a product may only point at an EXISTING category — the '
          'import never invents one',
    );
    expect(r.errors.single.rowIndex, 1);
    expect(r.valid, isEmpty);
    expect(r.canCommit, isFalse);
  });

  test('out-of-schema value under a valued def is blocked', () {
    final csv = [
      _header,
      _row(sku: 'G-1', name: 'לוח א', category: 'לוחות', diameter: '25'),
      _row(sku: 'G-2', name: 'לוח ב', category: 'לוחות'), // diameter EMPTY
    ].join('\n');

    final r = _parse(csv);
    expect(
      r.errors.single.messageHe,
      allOf(contains('ערך לא בסכמה'), contains('25')),
      reason: "'25' is neither a labelHe nor a value id of קוטר [16, 20]",
    );
    expect(r.errors.single.rowIndex, 1);

    // the violating row is NOT ready-to-commit; the clean row still is —
    // `valid` holds the parseable ones even while errors gate the commit.
    expect(r.valid.single.id, 'G-2');
    expect(
      r.valid.single.attributes.containsKey(_diameter.id),
      isFalse,
      reason: 'an EMPTY cell under a valued def is fine — no error, the '
          'attribute is simply absent',
    );
    expect(r.canCommit, isFalse);
  });

  test('ATOMIC no-write-on-error through the store', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(tradesStoreProvider); // instantiate ⇒ kicks off the async _load
    await _settle();

    final notifier = c.read(tradesStoreProvider.notifier)
      ..upsertTrade(_trade)
      ..upsertCategory(_boards);
    expect(c.read(tradesStoreProvider).products, isEmpty);

    // dry-run a MIXED file (1 good + 1 bad): canCommit false ⇒ the caller
    // contract forbids the commit loop ⇒ NOTHING may reach the store — not
    // even the good row.
    final mixed = [
      _header,
      _row(sku: 'G-1', name: 'לוח א', category: 'לוחות', diameter: '16'),
      _row(sku: 'G-2', category: 'לוחות'), // name missing ⇒ the bad row
    ].join('\n');
    final dryRun = _parse(
      mixed,
      existing: c.read(tradesStoreProvider).products,
    );
    expect(dryRun.errors, isNotEmpty);
    expect(dryRun.canCommit, isFalse);
    expect(
      c.read(tradesStoreProvider).products,
      isEmpty,
      reason: 'ATOMIC: on any error the import writes NOTHING — no partial '
          'commit of the valid subset',
    );

    // the corrected file passes ⇒ the commit loop runs and lands ALL rows.
    final clean = [
      _header,
      _row(sku: 'G-1', name: 'לוח א', category: 'לוחות', diameter: '16'),
      _row(sku: 'G-2', name: 'לוח ב', category: 'לוחות', diameter: '20'),
    ].join('\n');
    final report = _parse(
      clean,
      existing: c.read(tradesStoreProvider).products,
    );
    expect(report.canCommit, isTrue);
    for (final p in report.valid) {
      notifier.upsertProduct(p);
    }

    final products = c.read(tradesStoreProvider).products;
    expect(products, hasLength(2));
    expect(products.map((p) => p.id).toSet(), {'G-1', 'G-2'});
    expect(products.every((p) => p.tradeId == _tradeId), isTrue);
    expect(products.every((p) => p.categoryId == _boards.id), isTrue);
  });
}
