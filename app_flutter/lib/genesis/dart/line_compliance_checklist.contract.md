# חוזה · lineComplianceChecklist

**מוצא (קדוש, L4):** `install_engine.dart:194-368` (origin/main, verbatim).
אטום נפרד ומלא — **לא** `compliance.dart` הגנרי (עוזר-dedup).
עוגני-main: enum `:84` · LineCheck `:86-93` · הגוף `:241-367`.
עוזרים-פרטיים (verbatim, מקודמים גם כברגים עצמאיים): `_galvanicallyDissimilar :158-164` ·
`_isDirectionalDevice :171-175` · `_directionalContext :181-188`.

## חתימה
```dart
enum CheckSeverity { critical, warning, info }
class LineCheck { const LineCheck(this.label, this.satisfied, this.why,
    {this.severity = CheckSeverity.warning}); final String label; final bool satisfied;
    final String why; final CheckSeverity severity; }
class ChainPart { final String sku; final String? productType; final String categoryHe;
    final String nameHe;
    const ChainPart(this.sku, this.categoryHe, {this.productType, this.nameHe = ''}); }
List<LineCheck> lineComplianceChecklist(
  List<ChainPart> chain, int tempC, Set<String> accessories, {
  required String? Function(String sku) materialOf,
  required bool Function(String sku) isSupplySku,
});
```

## קלט
- `chain` — מוצרי-הקו (sku · productType? · categoryHe · **nameHe** — נדרש לבדיקת-כיוון).
- `tempC` — טמפרטורת-הקו (int, °C; חם ≥ 60, מקור:28).
- `accessories` — קבוצת-SKU אביזרים שאושרו ידנית.
- `materialOf` — שקע: מגלם `productMaterial(p)` (מקור:61,242).
- `isSupplySku` — שקע: מגלם `lineIsSupply(chain)` פר-פריט (מקור:75-76,282).

## פלט
`List<LineCheck>` — פריטי-הצ׳קליסט הפעילים, בסדר-הבנייה של המקור (if-collection, :289-367).

## ‏⚠️ מחוץ-לאטום (גבול-תפקיד)
תפר-s41 (`trade`/TradeResolution, main:198-239) = האצלה-לפותר-מקצוע-אחר (חיווט-דומיין,
רמת-קופסה). האטום מגלם רק את ענף-האינסטלציה הקבוע (R1-2 KEYSTONE, main:241-367).

## התנהגות (עוגני-שורה למקור)
טריגרים: אספקה⇒ברז-ניתוק (:290-297) · **ברז-גן+אספקה⇒שובר-ואקום (חדש, :298-302)** ·
**כל שסתום-חד-כיווני⇒בדיקת-כיוון פר-פריט (חדש, :307-312)** · recirc(HW-PUMP-25/HW-TEE-RECIRC)⇒
×3+אל-חזור+מאזן+מפוח+דגימה · חם(≥60)⇒PRV+כלי-התפשטות+בידוד · מחלק/מקלחת⇒TMTV ·
משאבה-מסחרית(HW-PUMP-40)⇒מסנן-Y+גמיש+(חם:לגיונלה)+(מחלק:מאזן-ענף) ·
**מתכות קבוצות-שונות (נחושת/פליז ∩ פלדה/נירוסטה)⇒רקורד-דיאלקטרי (תוקן, :251)** ·
PEX⇒מפצה · תמיד⇒חבק+איטום.

## דוגמאות (עוגן install_engine.dart:289-367)
| # | תרחיש | tempC | supply | פלט (אורך + פריטי-מפתח) |
|---|-------|-------|--------|--------------------------|
| 1 | [HW-BALL-1] קר | 20 | HW-BALL-1 | len=3; 'ברז ניתוק לתחזוקה' satisfied=true (critical); חבק/איטום info |
| 2 | [HW-BALL-1, HW-MANIFOLD-4(מחלק)] חם | 60 | HW-BALL-1 | len=7; PRV+Bladder+TMTV false (critical); בידוד false (warning) |
| 3 | [3×BALL, HW-PUMP-25] recirc | 20 | yes | len=7; 'ברז ניתוק ×3…' satisfied=true; אל-חזור/מפוח/דגימה |
| 4 | [DRAIN-1] ניקוז | 20 | (אין) | len=2; **אין** 'ברז ניתוק' (רק חבק+איטום) |
| 5 | ניקוז + acc={CLIP,SEALANT,INSUL} | 60 | (אין) | בידוד/חבק/איטום satisfied=true |
| 6 | [CU=נחושת, BR=פליז] | 20 | (אין) | **אין** 'רקורד דיאלקטרי' (אותה קבוצה — תיקון :158-164) |
| 6b | [CU=נחושת, ST=פלדה] | 20 | (אין) | 'רקורד דיאלקטרי' present (critical — קבוצות-שונות) |
| 7 | [PX=PEX] | 20 | (אין) | 'מפצה התפשטות PEX' present (warning) |
| 8 | [HW-BALL-1, GARDEN-1(ברזי גן)] | 20 | HW-BALL-1 | 'שובר-ואקום…' present (warning, false) |
| 8b | [GARDEN-1] | 20 | (אין) | **אין** שובר-ואקום (דורש isSupply) |
| 9 | [ברז, CHK-1(אל חזור), משאבה] | 20 | HW-BALL-1 | 'כיוון התקנה: <nameHe>' present (warning); why='…בין "…" ל-"…"' |
| 9b | [nameHe='שסתום אל-חזור נחושת'] | 20 | (אין) | 'כיוון התקנה:…' present (זיהוי-לפי-שם) |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **תיקון-גלווני (#6 מול #6b):** נחושת↔פליז = אותה קבוצה ⇒ אין רקורד (מול ה-snapshot הישן
  שהיה מסמן); רק חצייה קבוצת-נחושת↔קבוצת-ברזל מפעילה (:158-164).
- שובר-ואקום דורש **גם** אספקה **וגם** ברז-גן (#8 מול #8b, :298).
- בדיקת-כיוון נפרדת פר-שסתום-חד-כיווני, מזוהה בקטגוריה='אל חזור' **או** nameHe מכיל
  'אלחזור'/'אלחוזר' (מנוקה מ-'-'/רווח) (#9,#9b, :171-175); ה-why ממקם בין השכנים (:181-188).
