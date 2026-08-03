// 🔌 מנוע-הקטלוג-3D · פאזה A (שלבים 13-16): `familySpecFor` — מכליל את התבנית
// המוכחת `polyrollSpecFor` לכל מותג, ומזריע `kVerifiedSpecs` דרך `putIfAbsent`
// בלבד (keystone R2: אף spec ידני-קיים לא נדרס · אינסטלציה byte-identical).
//
// **⊇ `polyrollSpecFor`** (שלב 14): למוצר-פולירול מוחזר בדיוק ה-spec המוכח; אחרת
// נגזרת קונסטרוקציה למותג-מכני (Huliot-789 = מערכת-ניקוז HDPE — קטגוריות
// מסעף/ברך/מחסום/סיפון; ה-SmartLock-אספקה הם רשימה נפרדת). מוצר בלי-קצוות
// (אטם/חבק) או בלי-מידה → `null` = **fallback כן** (M1), לעולם לא spec שגוי (M2).

import 'package:buildsmart/data/huliot_catalog.dart' show kHuliotProducts;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_specs.dart';

/// ספירת-קצוות פר-קטגוריה של Huliot (= מספר שקעי-החיבור). ברירת-מחדל 2.
const Map<String, int> _kHuliotPorts = {
  'מסעף': 3, 'רוכב': 3, 'מאסף': 3, // הסתעפות
  'פקק': 1, 'מכסה': 1, 'אוגן': 1, // סתימה/קצה
};

/// קטגוריות Huliot שאינן אביזר-מחבר (אין להן קצוות) → fallback כן.
const Set<String> _kHuliotNonFitting = {'אטם', 'חבק'};

/// גזירת ה-DN (מ״מ) משם-המוצר של Huliot. מטפל ב: דו-קוטרי (NxM→הגדול) · Ø-notation
/// · DN-נגרר · טוקן-מספרי כללי. מחזיר `null` לאביזר-נטול-מידה (כיסוי/אוגן).
String? _huliotDn(LipskeyCatalogProduct p) {
  final n = p.nameHe;
  // דו-קוטרי: "מצרה 110x75" → 110.
  final r = RegExp(r'(\d{2,4})\s*[×xX]\s*(\d{2,4})').firstMatch(n);
  if (r != null) return r.group(1);
  // Ø-notation: "בקוטר Ø200" → 200.
  final o = RegExp(r'Ø\s*(\d{2,4})').firstMatch(n);
  if (o != null) return o.group(1);
  // DN-נגרר: "ברך 45° 110" → 110.
  final t = RegExp(r'(\d{2,4})\s*$').firstMatch(n.replaceAll('°', ''));
  if (t != null) return t.group(1);
  // טוקן-מספרי כללי (2–4 ספרות) כמוצא-אחרון.
  final m = RegExp(r'\b(\d{2,4})\b').firstMatch(n);
  return m?.group(1);
}

/// קונסטרוקציה למוצר-Huliot (מערכת-ניקוז HDPE). קצוות `hdpeCompression` × ספירה,
/// חומר HDPE, מערכת **ניקוז** (`systemOverride` — הניקוז interoperable-לפי-DN,
/// תואם לפיזיקה: כל אביזר-DN110 מתחבר לצינור-DN110). `null` כשלא-מחבר/נטול-מידה.
VerifiedSpec? _huliotSpecFor(LipskeyCatalogProduct p) {
  if (p.brand != 'Huliot') return null; // ההכללה מוגבלת ל-Huliot בפרוסה זו
  if (_kHuliotNonFitting.contains(p.categoryHe)) return null;
  final dn = _huliotDn(p);
  if (dn == null) return null;
  final ports = _kHuliotPorts[p.categoryHe] ?? 2;
  return VerifiedSpec(
    sku: p.sku,
    ends: List<ConnectorEnd>.generate(
      ports,
      (_) => ConnectorEnd(EndType.hdpeCompression, dn),
    ),
    material: 'HDPE',
    systemOverride: WaterSystem.drainage, // מערכת-ניקוז (soil & waste)
  );
}

/// חוזה-הפאזה: מוצר-קטלוג → `VerifiedSpec` נגזר, או `null` (fallback).
/// **⊇ `polyrollSpecFor`**: פולירול מקבל בדיוק את ה-spec המוכח; אחרת הכללה.
VerifiedSpec? familySpecFor(LipskeyCatalogProduct p) =>
    polyrollSpecFor(p) ?? _huliotSpecFor(p);

/// הזרעה חד-פעמית — מוסיפה כל spec-נגזר ל-`kVerifiedSpecs` דרך **`putIfAbsent`
/// בלבד** (keystone R2: לא דורס specs ידניים/פולירול קיימים). idempotent.
/// נקראת מ-`main.dart` **אחרי** `registerPolyrollSpecs`, מאחורי `kFittingEngine`.
void registerFamilySpecs() {
  for (final p in kHuliotProducts) {
    final spec = _huliotSpecFor(p);
    if (spec == null) continue;
    kVerifiedSpecs.putIfAbsent(p.sku, () => spec);
  }
}
