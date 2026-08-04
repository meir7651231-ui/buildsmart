// 🫀 CATALOG-CONFIG · פאזה 0 (הלב) — `ProductConfigSchema` נגזר-מהמנוע. כל מוצר
// "מצהיר" אילו גלגלים הוא צריך; הכרטיס-הגנרי (פאזה B) מרנדר אותם. **בונה על**
// `AttributeDef`/`AttributeValue`/`AttributeKind` הקיימים (`domain/trade_schema.dart`)
// — לא מאפס — ועל גשר-המנוע `familyOf`/`odOf` + `kDepth` (`features/fittings/`).
//
// 🔒 מגודר `kCatalogConfig` (default-OFF) · טהור · אף מסך-חי אינו מייבא ⇒ tree-shaken
// ⇒ הקטלוג-החי byte-identical. **רוב הסכמה נגזרת אוטומטית מהמנוע** (שלב 0.2):
// `familyOf(p)` → אילו תכונות · `kDepth`/`odOf` → ערכי-הקוטר. שומר: אין תכונה בלי
// ערכים · מוצר בלי-משפחה → כרטיס-בסיס (קוטר בלבד / ריק) — לעולם לא קורס (M1).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/features/fittings/engine/catalog_map.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart' show kDepth;
import 'package:flutter/foundation.dart' show immutable, listEquals;

/// `tradeId` סינתטי ל-`AttributeDef`-ים שנגזרים מהמנוע/קטלוג (לא בבעלות Trade-משתמש).
const String kCatalogConfigTradeId = 'catalog';

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

// ── תכונות-בסיס (גלגלים) — כל אחת עם ערכים (שומר: אין תכונה בלי ערכים) ──────────

/// ערכי-הקוטר מטבלת-העומק של המנוע (`kDepth`) — ממוינים. **נגזר מהמנוע** (0.2).
List<AttributeValue> diameterValues() {
  final ods = kDepth.keys.toList()..sort();
  return [
    for (var i = 0; i < ods.length; i++)
      AttributeValue(
        id: 'od-${ods[i]}',
        labelHe: '${ods[i]}',
        canonical: '${ods[i]}',
        sortIndex: i,
      ),
  ];
}

AttributeDef _diameter({
  String id = 'diameter',
  String nameHe = 'קוטר',
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
      values: diameterValues(),
    );

/// זווית-הברך — המנוע תומך ב-45°/90° (משפחות `ברך 45°`/`ברך 90°`). ערכים נוספים
/// (15/30) ידרשו דאטת-קטלוג (0.3); כאן נגזר אמת-המנוע בלבד.
AttributeDef _angle() => const AttributeDef(
      id: 'angle',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'זווית',
      emoji: '📐',
      kind: AttributeKind.choice,
      required: true,
      values: [
        AttributeValue(id: 'a45', labelHe: '45°', canonical: '45'),
        AttributeValue(id: 'a90', labelHe: '90°', canonical: '90', sortIndex: 1),
      ],
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

/// יציאות-המחלק (תבנית-קטלוג · 1–4). תכונת-משפחה מוצהרת (לא שדה-דאטה-חדש).
AttributeDef _ports() => const AttributeDef(
      id: 'ports',
      tradeId: kCatalogConfigTradeId,
      nameHe: 'יציאות',
      emoji: '🔀',
      kind: AttributeKind.number,
      required: true,
      values: [
        AttributeValue(id: 'p1', labelHe: '1', canonical: '1'),
        AttributeValue(id: 'p2', labelHe: '2', canonical: '2', sortIndex: 1),
        AttributeValue(id: 'p3', labelHe: '3', canonical: '3', sortIndex: 2),
        AttributeValue(id: 'p4', labelHe: '4', canonical: '4', sortIndex: 3),
      ],
    );

/// גלגל-צבע — **נגזר מהדאטה בלבד** (`p.color`). אין צבע מוצהר → הגלגל מושמט (שומר:
/// אין תכונה בלי ערכים · אפס-המצאת-swatches). אגירת-וריאנטי-צבע מהקטלוג = פאזה מאוחרת.
AttributeDef? _colorAttr(LipskeyCatalogProduct p) {
  final c = p.color;
  if (c == null || c.isEmpty) return null;
  return AttributeDef(
    id: 'color',
    tradeId: kCatalogConfigTradeId,
    nameHe: 'צבע',
    emoji: '🎨',
    kind: AttributeKind.color,
    values: [AttributeValue(id: 'c-$c', labelHe: c, canonical: c)],
  );
}

/// זיהוי מחלק (סעפת/מחלק) — לפי השם. מחלקים חיים תחת קטגוריית-צווארונים אך נבדלים
/// בשם; לכן מיירטים אותם **לפני** נתיב-משפחת-המנוע (אחרת יקבלו סכמת-צווארון).
bool _isManifold(LipskeyCatalogProduct p) =>
    p.nameHe.contains('מחלק') || p.nameHe.contains('סעפת');

/// סכמת-המחלק (0.3, קטלוג-נגזר): [יציאות · צבע(אם קיים) · קוטר]. הצבע נגזר-מדאטה.
List<AttributeDef> _manifoldAttributes(LipskeyCatalogProduct p) {
  final color = _colorAttr(p);
  return [
    _ports(),
    if (color != null) color,
    _diameter(),
  ];
}

/// תבנית-התכונות פר-משפחת-מנוע (0.2). `null` = משפחה לא-מוכרת (→ כרטיס-בסיס).
List<AttributeDef>? _attributesForFamily(String family) {
  switch (family) {
    case 'מצמד':
    case 'מסעף (טי)':
    case 'ברז כדורי':
    case 'פקק':
    case 'רוכב':
    case 'צווארון':
      return [_diameter()];
    case 'ברך 90°':
    case 'ברך 45°':
      return [_angle(), _diameter(), _length()];
    case 'מתאם תבריג':
      return [_diameter(), _thread()];
    case 'מצרה':
      return [
        _diameter(id: 'diameter-large', nameHe: 'קוטר גדול'),
        _diameter(id: 'diameter-small', nameHe: 'קוטר קטן'),
      ];
    default:
      return null;
  }
}

/// **הגזירה** (0.2): מוצר-קטלוג → `ProductConfigSchema`. משפחת-מנוע מוכרת → סכמת-
/// גלגלים מלאה; אחרת → כרטיס-בסיס (קוטר-בלבד אם ניתן לקרוא OD, אחרת ריק). לעולם
/// לא `null` ולא תכונה-בלי-ערכים — כרטיס תמיד ניתן-לרינדור (guard · M1).
ProductConfigSchema configSchemaFor(LipskeyCatalogProduct p) {
  // מחלק (קטלוג-נגזר) מיורט לפני משפחת-המנוע (אחרת יזוהה כצווארון).
  if (_isManifold(p)) {
    return ProductConfigSchema(
      sku: p.sku,
      nameHe: p.nameHe,
      familyId: 'מחלק',
      emoji: p.categoryEmoji,
      attributes: _manifoldAttributes(p),
    );
  }
  final family = familyOf(p);
  final attrs = family == null ? null : _attributesForFamily(family);
  if (family != null && attrs != null) {
    return ProductConfigSchema(
      sku: p.sku,
      nameHe: p.nameHe,
      familyId: family,
      emoji: p.categoryEmoji,
      attributes: attrs,
    );
  }
  // fallback: כרטיס-בסיס — קוטר-בלבד כשניתן לקרוא OD, אחרת ריק (כמות בלבד).
  final hasOd = odOf(p) != null;
  return ProductConfigSchema(
    sku: p.sku,
    nameHe: p.nameHe,
    familyId: p.categoryHe,
    emoji: p.categoryEmoji,
    attributes: hasOd ? [_diameter()] : const [],
  );
}
