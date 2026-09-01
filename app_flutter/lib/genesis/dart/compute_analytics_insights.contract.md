# חוזה · `computeAnalyticsInsights` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/ai_hub_logic.dart:346-394`.

**שקעים:** `fMoney(int)`⇒`fMoney` · `aiAlternatives()`⇒`aiAlternatives` (חוק-3).
**הוטבע:** `Insight`(ic/title/sub) ו-`Order`(sum/isOpen) ⇒ records inline.
**הוסק-כשקע:** `kBudgetTotal`/`kBudgetSpent` — ערכם **לא הופיע בטיוטה** ⇒ הומרו לפרמטרים
(חוק-6: קונפיגורציה=הזרקה). במקור היו const וכן `const budgetLeft` — כאן `final`, אותה התנהגות.

## חתימה
```dart
List<({String ic, String title, String sub})> computeAnalyticsInsights(
  List<({int sum, bool isOpen})> orders, {
  required String Function(int) fMoney,
  required List<({int save})> Function() aiAlternatives,
  required int kBudgetTotal,
  required int kBudgetSpent,
})
```

## קלט
- `orders` — ההזמנות (`sum`, `isOpen`).
- `fMoney` — **שקע**: עיצוב-סכום.
- `aiAlternatives` — **שקע**: חלופות, כל אחת עם `save`.
- `kBudgetTotal`/`kBudgetSpent` — תקציב מוזרק.

## פלט / התנהגות (עוגני-שורה)
- `:349-352` — `orderCount`/`totalSpend`(fold sum)/`openCount`(where isOpen)/`deliveredCount`.
- `:354-372` — אם `orderCount>0`: 📦 (ספירה+סה״כ), 💵 (ממוצע=`round(totalSpend/orderCount)`), 🚚 (פתוחות/סופקו).
- `:375-382` — `savings = Σ aiAlternatives().save`; אם `>0` ⇒ 💰.
- `:384-393` — `budgetPctValue = kBudgetTotal>0 ? round(kBudgetSpent/kBudgetTotal*100) : 0`;
  `budgetLeft = kBudgetTotal-kBudgetSpent`; תמיד מוסיף 📊 (ניצול-תקציב).
- **המשבצת 📊 תמיד נוספת** (גם ב-orders ריק). סדר-הפריטים קבוע.

## דוגמאות (‏fMoney(n)=`'₪$n'`)
### דוגמה A — ריק (orders=[], aiAlternatives=[], total=0, spent=0)
פלט (‏1 פריט): `[📊 'ניצול תקציב: 0%' / 'נותרו ₪0 מתוך ₪0']`.

### דוגמה B — orders=[(100,open),(200,delivered)], alts=[(50),(30)], total=1000, spent=250
פלט (‏5 פריטים) לפי-סדר:
1. 📦 `'2 הזמנות · ₪300 סה״כ רכש'`
2. 💵 `'שווי הזמנה ממוצע: ₪150'` (‏avg=round(300/2))
3. 🚚 `'1 הזמנות פתוחות · 1 סופקו'`
4. 💰 `'חיסכון אפשרי: ₪80'` (‏50+30)
5. 📊 `'ניצול תקציב: 25%'` / `'נותרו ₪750 מתוך ₪1000'`

### דוגמה C — orders=[(10,open)], alts=[], total=0, spent=0
פלט (‏4 פריטים): 📦 `'1 הזמנות · ₪10 סה״כ רכש'` · 💵 `'שווי הזמנה ממוצע: ₪10'` ·
🚚 `'1 הזמנות פתוחות · 0 סופקו'` · 📊 `'ניצול תקציב: 0%'` (‏savings=0 ⇒ בלי 💰).

## שקעים
- `fMoney`, `aiAlternatives`, `kBudgetTotal`, `kBudgetSpent` — מוזרקים.

## DoD
```
dart run --enable-asserts new/dart/compute_analytics_insights_test.dart  ⇒ exit 0 + "OK computeAnalyticsInsights: N asserts passed"
```
