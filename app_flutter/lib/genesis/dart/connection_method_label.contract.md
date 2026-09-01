# חוזה · connectionMethodLabel

**מוצא (קדוש, L4):** `install_engine.dart:111-150` (origin/main, verbatim).
עוגן-חתימה: `:111-115` = `String connectionMethodLabel(a, b, {TradeResolution? trade})`.
TradeResolution: `:99-105` · תפר-s41: `:120-129` · legacy: `:132-149`.

## חתימה
```dart
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }
class ConnEnd { final EndType type; final String size; const ConnEnd(this.type, this.size); }
class TradeResolution<P> { final String tradeId;
    final Object? Function(P p) specOf;
    final String Function(Object a, Object b) resolve;
    const TradeResolution({required this.tradeId, required this.specOf, required this.resolve}); }
String connectionMethodLabel<P>(P a, P b, {
  required List<ConnEnd>? Function(P) endsOf,
  TradeResolution<P>? trade,
});
```

## קלט
- `a`, `b` — שני המוצרים המחוברים.
- `endsOf` — שקע: `p → List<ConnEnd>?` — מגלם `kVerifiedSpecs[p.sku]?.ends`; `null` כשאין spec.
- `trade` — שקע-אופציונלי (תפר-s41). `null` ⇒ legacy בלבד (ביט-זהה ל-snapshot). מגלם:
  - `tradeId` — `'plumbing'` לעולם אינו מאציל (R1-2, install_engine.dart:120).
  - `specOf(p) → Object?` — מגלם `trade.specOf(sku)` (sku מוסתר במוצר); `null` בצד ⇒ `''` (:124).
  - `resolve(sa, sb) → String` — מגלם `resolver.canConnect(sa,sb).methodLabelHe` (:125).

## פלט
`String` — שם-שיטת-החיבור, או `''` כשלא-ניתן-לגזור.

## התנהגות (עוגני-שורה למקור)
1. **תפר-s41** (`:120-129`): `trade!=null && trade.tradeId!='plumbing'` ⇒ מנסים האצלה:
   - spec לצד-אחד `null` ⇒ `''` (:124) — **לא** נופל ל-legacy.
   - אחרת ⇒ `resolve(sa,sb)` (:125).
   - **כל** חריגה ב-specOf/resolve ⇒ נבלעת, נופלים ל-legacy (kill-switch, :126-129).
   - `tradeId=='plumbing'` ⇒ מדלגים על התפר לגמרי ⇒ legacy (:120).
2. **legacy** (`:132-149`): צד ללא-spec (`endsOf==null`) ⇒ `''`. הזוג-הראשון המתאים-ישירות
   (`_directMates`, lvc.dart:38-48) ⇒ תווית לפי `eA.type`. אחרת שיתוף-צינור
   (`_pipeShared`, lvc.dart:50-53) ⇒ `'אום הידוק (compression)'`. אחרת `''`.

## דוגמאות (עוגן install_engine.dart:132-149 + :120-129)
| # | תרחיש | פלט | עוגן |
|---|-------|-----|------|
| 1 | legacy: bspMale 1/2" ↔ bspFemale 1/2" | תבריג + PTFE | :140-141 |
| 2 | legacy: pexPress 20 ↔ pexPress 20 | Press / טבעת כיווץ | :138 |
| 3 | legacy: copperPress 22 ↔ copperPress 22 | Press / O-ring | :139 |
| 4 | legacy: drainOpening 110 ↔ drainOpening 110 | כיסוי ניקוז | :143 |
| 5 | legacy: hdpeCompression 32 ↔ hdpeCompression 32 | אום הידוק (compression) | :146 |
| 6 | legacy: bspMale 1/2" ↔ (אין spec) | '' | :133 |
| 7 | legacy: bspMale 1/2" ↔ bspMale 1/2" (זכר↔זכר) | '' | :149 |
| 8 | trade: tradeId='electrical' · specOf→non-null · resolve→'ריתוך' | ריתוך | :125 |
| 9 | trade: tradeId='electrical' · specOf→null לצד-אחד | '' (לא-legacy) | :124 |
| 10 | trade: tradeId='electrical' · resolve זורק ⇒ נפילה ל-legacy (pex↔pex) | Press / טבעת כיווץ | :126-129 |
| 11 | trade: tradeId='plumbing' + specOf זורק ⇒ מדולג ⇒ legacy (pex↔pex) | Press / טבעת כיווץ | :120 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- 'plumbing' חסין-האצלה: גם עם specOf-זורק התפר מדולג לגמרי, ה-legacy מכריע (#11 — R1-2 KEYSTONE).
- spec-null-בצד ≠ כשל-פותר: הראשון מחזיר '' סופי; השני נבלע ונופל ל-legacy (#9 מול #10).
- חסר-trade ⇒ נתיב legacy ביט-זהה ל-snapshot הישן (#1-#7).
