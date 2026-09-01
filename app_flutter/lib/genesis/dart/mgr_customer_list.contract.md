# חוזה · `mgrCustomerList` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/manager_dashboard.dart:279-302`
(‏`mgrCustomerList`). אגרגציית-קונים לדשבורד-המנהל: רשומה פר-קונה, ממוינת יורד לפי מחזור.

## הטבעה/שקעים
- `ManagerCustomer` — data-class-אח, **הוטבע verbatim** (שדות/בנאי/copyWith).
- `ManagerOrder` — טיפוס-שכן; המקור אינו בריפו (grep ⇒ ריק). האטום קורא רק
  `.who` (String) ו-`.sum` (int) ⇒ **הוטבע data-class מינימלי מוסק** (חוק-8).
- `kManagerOrderSeed` — const-זרע (ברירת-מחדל אופציונלית) ⇒ **הושמט**; `orders`
  הופך ל-חובה (const-קטלוג לא-נגיש). האגרגציה (279-302) ביט-זהה.

## חתימה
```dart
List<ManagerCustomer> mgrCustomerList(List<ManagerOrder> orders)
```

## התנהגות (עוגני-שורה)
- `manager_dashboard.dart:281-297` — קיפול על `who`: קונה-חדש ⇒
  `orderCount:1, totalSpend:o.sum, creditLimit:0`; קיים ⇒ `orderCount+1`,
  `totalSpend+o.sum`, שימור `creditLimit`.
- `:299-300` — `byBuyer.values.toList()..sort((a,b) => b.totalSpend.compareTo(a.totalSpend))`
  (מיון **יורד** לפי מחזור).
- `creditLimit` תמיד `0` בנתיב-הנגזר הזה (‏fake-data-sweep 1א). `ownerId`/`phone` = `''`.

## דוגמאות מספריות
| # | orders (who,sum) | ⇒ (name·count·spend·credit) |
|---|------------------|------------------------------|
| 1 | `[]` | `[]` |
| 2 | `[(A,100)]` | `[A·1·100·0]` |
| 3 | `[(A,100),(A,30)]` | `[A·2·130·0]` (קיפול) |
| 4 | `[(A,100),(B,50)]` | `[A·1·100·0, B·1·50·0]` (מיון יורד) |
| 5 | `[(B,50),(A,100)]` | `[A·1·100·0, B·1·50·0]` (מיון בלתי-תלוי-קלט) |
| 6 | `[(A,20),(B,50),(A,40)]` | `[A·2·60·0, B·1·50·0]` |

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/mgr_customer_list_test.dart  ⇒ exit 0 + "OK mgrCustomerList: N asserts passed"
```
