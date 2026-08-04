// 🫀 CATALOG-CONFIG · פאזה 0 (הלב) — `ProductConfigSchema` נגזר-מהמנוע. כל מוצר
// "מצהיר" אילו גלגלים הוא צריך; הכרטיס-הגנרי (פאזה B) מרנדר אותם. **בונה על**
// `AttributeDef`/`AttributeValue`/`AttributeKind` הקיימים (`domain/trade_schema.dart`)
// — לא מאפס — ועל גשר-המנוע `familyOf`/`odOf`/`od2Of` + `kDepth` (`features/fittings/`).
//
// 🔒 מגודר `kCatalogConfig` (default-OFF) · טהור · אף מסך-חי אינו מייבא ⇒ tree-shaken
// ⇒ הקטלוג-החי byte-identical. **רוב הסכמה נגזרת אוטומטית מהמנוע** (שלב 0.2):
// `familyOf(p)` → אילו תכונות · `odOf`/`od2Of` → ערכי-הקוטר. שומר: אין תכונה בלי
// ערכים · מוצר בלי-משפחה → כרטיס-בסיס (קוטר בלבד / ריק) — לעולם לא קורס (M1).
//
// ★ פאזה F — אגירת-ערכים אמיתית (owner directive · "הגלגלים נושאים ערכי-אמת"):
// ערכי-הקוטר/הזווית **נאגרים מהאוכלוסייה** (`universe`, ברירת-מחדל
// `resolvedCatalogProducts`) — ה-`odOf` הנבדלים על-פני אֲחֵי-המשפחה המדויקים (סולם-
// DN אמיתי פר-משפחה), הזוויות הנבדלות על-פני קבוצת-הברכיים כולה — במקום תבנית-
// `kDepth`/45-90 קשיחה. ה-ID/label/kind נשמרים; רק ה-**ערכים** הופכים לאמת-אגורה.
// כשאין אחים למשפחה → נסיגה לתבנית (לעולם לא ריק · לא קורס — שומר M1).

import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart' show kDepth;
import 'package:flutter/foundation.dart' show immutable, listEquals;

/// `tradeId` סינתטי ל-`AttributeDef`-ים שנגזרים מהמנוע/קטלוג (לא בבעלות Trade-משתמש).
const String kCatalogConfigTradeId = 'catalog';

/// קידומת-הברך — `familyOf` מחזיר 'ברך 90°'/'ברך 45°'/…, לכן כל וריאנט-ברך חולק
/// את גלגל-הזווית האחד המפתוח על הקידומת הזו (אגירת-קבוצה, לא משפחה-מדויקת).
const String _kElbowPrefix = 'ברך';

/// זוויות-התבנית (נסיגה) — המנוע תומך ב-45°/90°. ה-canonical נטול-°, כמו במנוע.
const List<AttributeValue> _kTemplateAngleValues = [
  AttributeValue(id: 'a45', labelHe: '45°', canonical: '45'),
  AttributeValue(id: 'a90', labelHe: '90°', canonical: '90', sortIndex: 1),
];

/// סכמת-ההגדרה של מוצר: התכונות (=הגלגלים) שהכרטיס-הגנרי מרנדר. תמונה/מחיר
/// (פאזות D/E) מתווספים בהמשך. `attributes` = `AttributeDef` קיים (reuse).
@immutable
class ProductConfigSchema {
  const ProductConfigSchema({
    required this.sku,
    required this.nameHe,
    required this.familyId,
    required this.emoji,
    required this.attributes,
  });

  final String sku;
  final String nameHe;
  final String familyId; // שם-משפחת-המנוע, או מחלקת-הקטלוג (fallback)
  final String emoji;
  final List<AttributeDef> attributes; // הגלגלים (פר-תכונה)

  /// האם המוצר קיבל סכמה-נגזרת-ממנוע (יש לו לפחות תכונה אחת)?
  bool get hasWheels => attributes.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is ProductConfigSchema &&
      other.sku == sku &&
      other.nameHe == nameHe &&
      other.familyId == familyId &&
      other.emoji == emoji &&
      listEquals(other.attributes, attributes);

  @override
  int get hashCode =>
      Object.hash(sku, nameHe, familyId, emoji, Object.hashAll(attributes));
}

// ── אגירת-ערכים (פאזה F) — ה-odOf/od2Of/הזוויות הנבדלים על-פני האוכלוסייה ───────

/// ה-OD-ים הנבדלים (nulls מדולגים) על-פני חברי [universe] ש-[matches] מקבל,
/// כפי ש-[reader] קורא אותם — ממוינים עולה. המנרמל המשותף (קוטר/קוטר-שני).
List<int> _distinctOds(
  List<LipskeyCatalogProduct> universe,
  bool Function(LipskeyCatalogProduct) matches,
  int? Function(LipskeyCatalogProduct) reader,
) {
  final set = <int>{};
  for (final peer in universe) {
    if (matches(peer)) {
      final od = reader(peer);
      if (od != null) {
        set.add(od);
      }
    }
  }
  return set.toList()..sort();
}

/// ערכי-קוטר מרשימת-OD ממוינת → `AttributeValue`-ים (`od-N` · label/canonical `N`).
List<AttributeValue> _diameterValuesFromOds(List<int> ods) => [
      for (var i = 0; i < ods.length; i++)
        AttributeValue(
          id: 'od-${ods[i]}',
          labelHe: '${ods[i]}',
          canonical: '${ods[i]}',
          sortIndex: i,
        ),
    ];

/// ערכי-הקוטר **מטבלת-העומק של המנוע** (`kDepth`) — ממוינים. תבנית-הנסיגה (0.2)
/// כשלמשפחה אין אחים באוכלוסייה. **נגזר מהמנוע**.
List<AttributeValue> diameterValues() {
  final ods = kDepth.keys.toList()..sort();
  return _diameterValuesFromOds(ods);
}

/// יציאות-המחלק **האמיתיות** — ה-`dims['יציאות']` הנבדלות על-פני אֲחֵי-המחלק
/// ([_isManifold]) ב-[universe], ממוינות מספרית. נסיגה לתבנית 1–4 כשאין דאטה
/// (שומר M1: לעולם לא ריק). **נאגר מהדאטה** (פאזה F) — לא תבנית-1-4 גנרית.
List<AttributeValue> _portValues(List<LipskeyCatalogProduct> universe) {
  final set = <int>{};
  for (final peer in universe) {
    if (!_isManifold(peer)) continue;
    final raw = peer.dims?['יציאות'];
    final n = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (n != null) set.add(n);
  }
  final ports = set.toList()..sort();
  if (ports.isEmpty) {
    return const [
      AttributeValue(id: 'p1', labelHe: '1', canonical: '1'),
      AttributeValue(id: 'p2', labelHe: '2', canonical: '2', sortIndex: 1),
      AttributeValue(id: 'p3', labelHe: '3', canonical: '3', sortIndex: 2),
      AttributeValue(id: 'p4', labelHe: '4', canonical: '4', sortIndex: 3),
    ];
  }
  return [
    for (var i = 0; i < ports.length; i++)
      AttributeValue(
        id: 'p${ports[i]}',
        labelHe: '${ports[i]}',
        canonical: '${ports[i]}',
        sortIndex: i,
      ),
  ];
}

/// צבעי-המחלק **האמיתיים** — ה-`color` הנבדלים (לא-ריקים) על-פני אֲחֵי-המחלק
/// ב-[universe], בסדר-הופעה → **בחירת-צבע אמיתית** (כחול/אדום), לא ערך-יחיד-מנוון.
List<AttributeValue> _colorValues(List<LipskeyCatalogProduct> universe) {
  final seen = <String>{};
  final out = <AttributeValue>[];
  for (final peer in universe) {
    if (!_isManifold(peer)) continue;
    final c = peer.color;
    if (c == null || c.isEmpty || !seen.add(c)) continue;
    out.add(AttributeValue(id: 'c-$c', labelHe: c, canonical: c, sortIndex: out.length));
  }
  return out;
}

/// סולם-הקוטר האמיתי של [family] — ה-`odOf` הנבדלים על-פני אֲחֵי-המשפחה המדויקים
/// ב-[universe]. נסיגה לתבנית-`kDepth` כשאין אחים (שומר M1: לעולם לא ריק).
List<AttributeValue> _familyDiameterValues(
  String family,
  List<LipskeyCatalogProduct> universe,
) {
  final ods = _distinctOds(universe, (p) => familyOf(p) == family, odOf);
  return ods.isEmpty ? diameterValues() : _diameterValuesFromOds(ods);
}

/// הקוטר-הקטן האמיתי של המצרה — ה-`od2Of` הנבדלים על-פני אֲחֵי-'מצרה'. נסיגה
/// לתבנית כשאין אחים דו-קוטריים.
List<AttributeValue> _reducerSmallValues(List<LipskeyCatalogProduct> universe) {
  final ods = _distinctOds(universe, (p) => familyOf(p) == 'מצרה', od2Of);
  return ods.isEmpty ? diameterValues() : _diameterValuesFromOds(ods);
}

/// סולם-הקוטר של המחלקים — ה-`odOf` הנבדלים על-פני אֲחֵי-המחלק (`_isManifold`,
/// שכן למחלק אין `familyOf`). נסיגה לתבנית כשאין OD-ים קריאים.
List<AttributeValue> _manifoldDiameterValues(
  List<LipskeyCatalogProduct> universe,
) {
  final ods = _distinctOds(universe, _isManifold, odOf);
  return ods.isEmpty ? diameterValues() : _diameterValuesFromOds(ods);
}

/// הזוויות האמיתיות על-פני קבוצת-הברכיים כולה ב-[universe] (`familyOf` פותח
/// ב-'ברך', המספר נקרא מהשם: 'ברך 90°'→90) — ממוינות, ב-canonical נטול-° של
/// המנוע. נסיגה לתבנית {45°,90°} כשאין ברכיים (שומר M1).
List<AttributeValue> _angleValues(List<LipskeyCatalogProduct> universe) {
  final degrees = <int>{};
  for (final peer in universe) {
    final family = familyOf(peer);
    if (family == null || !family.startsWith(_kElbowPrefix)) {
      continue;
    }
    final match = RegExp(r'\d+').firstMatch(family);
    final deg = match == null ? null : int.tryParse(match.group(0)!);
    if (deg != null) {
      degrees.add(deg);
    }
  }
  final sorted = degrees.toList()..sort();
  if (sorted.isEmpty) {
    return _kTemplateAngleValues;
  }
  return [
    for (var i = 0; i < sorted.length; i++)
      AttributeValue(
        id: 'a${sorted[i]}',
        labelHe: '${sorted[i]}°',
        canonical: '${sorted[i]}',
        sortIndex: i,
      ),
  ];
}

// ── תכונות-בסיס (גלגלים) — כל אחת עם ערכים (שומר: אין תכונה בלי ערכים) ──────────

/// גלגל-קוטר. [values] = הסולם האגור (פאזה F); ברירת-מחדל = תבנית-המנוע (`kDepth`).
AttributeDef _diameter({
  String id = 'diameter',
  String nameHe = 'קוטר',
  List<AttributeValue>? values,
}) =>
    AttributeDef(
      id: id,
      tradeId: kCatalogConfigTradeId,
      nameHe: nameHe,
      emoji: '📐',
      kind: AttributeKind.dimension,
      unitHe: 'מ"מ',
      isVariantAxis: true,
      required: true,
      values: values ?? diameterValues(),
    );

/// זווית-הברך. [values] = הזוויות האגורות מקבוצת-הברכיים (פאזה F · לא רק 45/90).
AttributeDef _angle(List<AttributeValue> values) => AttributeDef(
      id: 'angle',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'זווית',
      emoji: '📐',
      kind: AttributeKind.choice,
      required: true,
      values: values,
    );

/// אורך-הזרוע (תכונת-קטלוג · ברירת-מחדל בינוני). ברירת-מחדל 3 אפשרויות.
AttributeDef _length() => const AttributeDef(
      id: 'length',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'אורך',
      emoji: '📏',
      kind: AttributeKind.choice,
      values: [
        AttributeValue(id: 'short', labelHe: 'קצר'),
        AttributeValue(id: 'medium', labelHe: 'בינוני', sortIndex: 1),
        AttributeValue(id: 'long', labelHe: 'ארוך', sortIndex: 2),
      ],
    );

/// תבריג (למתאם) — מידות-אינץ' נפוצות (תכונת-קטלוג).
AttributeDef _thread() => const AttributeDef(
      id: 'thread',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'תבריג',
      emoji: '🔩',
      kind: AttributeKind.choice,
      values: [
        AttributeValue(id: 't12', labelHe: '1/2"', canonical: '1/2'),
        AttributeValue(id: 't34', labelHe: '3/4"', canonical: '3/4', sortIndex: 1),
        AttributeValue(id: 't1', labelHe: '1"', canonical: '1', sortIndex: 2),
      ],
    );

/// יציאות-המחלק — הגלגל נבנה מ-[values] **האמיתיות** ([_portValues]). תכונת-משפחה
/// מוצהרת (לא שדה-דאטה-חדש).
AttributeDef _ports(List<AttributeValue> values) => AttributeDef(
      id: 'ports',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'יציאות',
      emoji: '🔀',
      kind: AttributeKind.number,
      required: true,
      values: values,
    );

/// גלגל-צבע — מופיע רק למוצר **שיש-לו-צבע** (`p.color`, לא-מומצא), ואז נושא את
/// **בחירת-הצבעים האמיתית** של קבוצת-המחלקים ([_colorValues] — כחול/אדום),
/// לא ערך-יחיד-מנוון. אין צבע-מוצר → הגלגל מושמט (שומר: אין תכונה בלי ערכים).
AttributeDef? _colorAttr(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final own = p.color;
  if (own == null || own.isEmpty) return null;
  final aggregated = _colorValues(universe);
  final values = aggregated.isNotEmpty
      ? aggregated
      : [AttributeValue(id: 'c-$own', labelHe: own, canonical: own)];
  return AttributeDef(
    id: 'color',
    tradeId: kCatalogConfigTradeId,
    nameHe: 'צבע',
    emoji: '🎨',
    kind: AttributeKind.color,
    values: values,
  );
}

/// זיהוי מחלק (סעפת/מחלק) — לפי השם. מחלקים חיים תחת קטגוריית-צווארונים אך נבדלים
/// בשם; לכן מיירטים אותם **לפני** נתיב-משפחת-המנוע (אחרת יקבלו סכמת-צווארון).
bool _isManifold(LipskeyCatalogProduct p) =>
    p.nameHe.contains('מחלק') || p.nameHe.contains('סעפת');

/// סכמת-המחלק (0.3, קטלוג-נגזר): [יציאות · צבע(אם קיים) · קוטר]. הצבע נגזר-מדאטה
/// (`p.color` · יחיד-מוצר, לא-מומצא); הקוטר נאגר מאֲחֵי-המחלק (פאזה F).
List<AttributeDef> _manifoldAttributes(
  LipskeyCatalogProduct p,
  List<LipskeyCatalogProduct> universe,
) {
  final color = _colorAttr(p, universe);
  return [
    _ports(_portValues(universe)),
    if (color != null) color,
    _diameter(values: _manifoldDiameterValues(universe)),
  ];
}

/// תבנית-התכונות פר-משפחת-מנוע (0.2). `null` = משפחה לא-מוכרת (→ כרטיס-בסיס).
/// ערכי-הקוטר/הזווית נאגרים מ-[universe] (פאזה F); ה-ID/label/kind נשמרים.
List<AttributeDef>? _attributesForFamily(
  String family,
  List<LipskeyCatalogProduct> universe,
) {
  final diameter = _familyDiameterValues(family, universe);
  switch (family) {
    case 'מצמד':
    case 'מסעף (טי)':
    case 'ברז כדורי':
    case 'פקק':
    case 'רוכב':
    case 'צווארון':
      return [_diameter(values: diameter)];
    case 'ברך 90°':
    case 'ברך 45°':
      // dive-bs2b positional axis-map: attr[0]=angle (↕) · attr[1]=length (↔) ·
      // attr[2]=diameter (side wheel). Aggregation unchanged — only the ORDER.
      return [_angle(_angleValues(universe)), _length(), _diameter(values: diameter)];
    case 'מתאם תבריג':
      return [_diameter(values: diameter), _thread()];
    case 'מצרה':
      return [
        _diameter(id: 'diameter-large', nameHe: 'קוטר גדול', values: diameter),
        _diameter(
          id: 'diameter-small',
          nameHe: 'קוטר קטן',
          values: _reducerSmallValues(universe),
        ),
      ];
    default:
      return null;
  }
}

/// **הגזירה** (0.2 + פאזה F): מוצר-קטלוג → `ProductConfigSchema`. משפחת-מנוע מוכרת
/// → סכמת-גלגלים מלאה עם ערכים-אגורים מ-[universe] (ברירת-מחדל `resolvedCatalogProducts`);
/// אחרת → כרטיס-בסיס (קוטר-בלבד אם ניתן לקרוא OD, אחרת ריק). לעולם לא `null` ולא
/// תכונה-בלי-ערכים — כרטיס תמיד ניתן-לרינדור (guard · M1).
ProductConfigSchema configSchemaFor(
  LipskeyCatalogProduct p, {
  List<LipskeyCatalogProduct>? universe,
}) {
  final products = universe ?? resolvedCatalogProducts;
  // מחלק (קטלוג-נגזר) מיורט לפני משפחת-המנוע (אחרת יזוהה כצווארון).
  if (_isManifold(p)) {
    return ProductConfigSchema(
      sku: p.sku,
      nameHe: p.nameHe,
      familyId: 'מחלק',
      emoji: p.categoryEmoji,
      attributes: _manifoldAttributes(p, products),
    );
  }
  final family = familyOf(p);
  final attrs = family == null ? null : _attributesForFamily(family, products);
  if (family != null && attrs != null) {
    return ProductConfigSchema(
      sku: p.sku,
      nameHe: p.nameHe,
      familyId: family,
      emoji: p.categoryEmoji,
      attributes: attrs,
    );
  }
  // fallback: כרטיס-בסיס — קוטר-בלבד (תבנית) כשניתן לקרוא OD, אחרת ריק (כמות בלבד).
  final hasOd = odOf(p) != null;
  return ProductConfigSchema(
    sku: p.sku,
    nameHe: p.nameHe,
    familyId: p.categoryHe,
    emoji: p.categoryEmoji,
    attributes: hasOd ? [_diameter()] : const [],
  );
}
