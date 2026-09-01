// ⚛️ אטום-Dart (דרגת-חוזה) · plumbingAccessories
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:174-198 (חוק-4 — התנהגות זהה, לא-משופרת).
// הכרעת-קידום (טיוטה-קשה): 🔌 שכן+דאטה ⇒ שקעים —
//   • `catalog`        ← ‏kSmartProducts (דאטה-מוזרקת, smart_tree.dart:156 — מתחלף פר-ורטיקל)
//   • `smartKeyToId`   ← ‏_smartKeyToId() (שכן, plumbing_trade_seed.dart:97-100 — פותר key⇒קטגוריה)
//   • `kPlumbingTradeId` / `kUncategorizedCategoryId` ← קבועי-המקור (שורות 30·61), בשמם כמו category_id.dart
// ⚛️ טיפוסים הוטבעו מינימלי-verbatim: AccessoryRule (trade_schema.dart:387-423) ·
//   SmartProduct/SmartAcc (smart_tree.dart:116-134 / 98-113) — רק השדות שהמנוע נוגע בהם.
// טוהר: אפס-import, אפס-דאטה-צרובה; המיון = השוואת-מחרוזת של המקור (אינדקס 10 לפני 2).

/// צורת-מינימום של SmartAcc — רק מה ש-plumbingAccessories קורא (smart_tree.dart:98-113).
class SmartAcc {
  const SmartAcc({
    required this.name,
    required this.emoji,
    required this.why,
    required this.must,
    this.price,
    this.sku,
  });
  final String name;
  final String emoji;
  final int? price; // null = מחיר לפי ספק
  final String why;
  final bool must;
  final String? sku; // מק"ט ספק
}

/// צורת-מינימום של SmartProduct — רק `key` + `acc` (smart_tree.dart:116-134).
class SmartProduct {
  const SmartProduct({required this.key, required this.acc});
  final String key;
  final List<SmartAcc> acc;
}

/// צורת-מינימום של AccessoryRule — שדות-הבנייה של המנוע (trade_schema.dart:387-423).
class AccessoryRule {
  const AccessoryRule({
    required this.id,
    required this.tradeId,
    required this.appliesToCategoryId,
    required this.nameHe,
    required this.emoji,
    required this.whyHe,
    this.mustHave = false,
    this.price,
    this.linkSku,
  });
  final String id;
  final String tradeId;
  final String appliesToCategoryId;
  final String nameHe;
  final String emoji;
  final String whyHe;
  final bool mustHave;
  final int? price;
  final String? linkSku; // מקשר ל-TradeProduct

  @override
  bool operator ==(Object other) =>
      other is AccessoryRule &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.appliesToCategoryId == appliesToCategoryId &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.whyHe == whyHe &&
      other.mustHave == mustHave &&
      other.price == price &&
      other.linkSku == linkSku;

  @override
  int get hashCode => Object.hash(id, tradeId, appliesToCategoryId, nameHe,
      emoji, whyHe, mustHave, price, linkSku);
}

/// כלל-[AccessoryRule] אחד פר-אביזר-מוצר ("אביזרים נלווים"), מפתח יציב
/// `<trade>.acc.<key>.<i>`; ‏`appliesToCategoryId` נפתר דרך [smartKeyToId]
/// ונופל ל-[kUncategorizedCategoryId] (שלמות-FK). ממוין לפי id (מחרוזת).
/// ‏verbatim plumbing_trade_seed.dart:174-198.
List<AccessoryRule> plumbingAccessories({
  required List<SmartProduct> catalog,
  required Map<String, String> smartKeyToId,
  required String kPlumbingTradeId,
  required String kUncategorizedCategoryId,
}) {
  final out = <AccessoryRule>[];
  for (final sp in catalog) {
    for (var i = 0; i < sp.acc.length; i++) {
      final a = sp.acc[i];
      out.add(
        AccessoryRule(
          id: '$kPlumbingTradeId.acc.${sp.key}.$i',
          tradeId: kPlumbingTradeId,
          appliesToCategoryId: smartKeyToId[sp.key] ?? kUncategorizedCategoryId,
          nameHe: a.name,
          emoji: a.emoji,
          whyHe: a.why,
          mustHave: a.must,
          price: a.price,
          linkSku: a.sku,
        ),
      );
    }
  }
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}
