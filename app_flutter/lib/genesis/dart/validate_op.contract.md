# חוזה · `validateOp` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:171-214`
(‏`_validateOp`, ענף `claude/align-main` — הקובץ אינו בענף-העבודה של buildsmart).
תשע קריאות-השכן הפכו לשקעים (חוק-3); משפחת-ה-`ConfigOp` הסגורה + `CfgAction`
הוטבעו מינימלי-verbatim (הכרעה-2 של הקידום); `CfgStyle` **לא** הוטבע — ה-style
עובר אטוּם (`Object?`) דרך שקע-`resolveStyle` (חוק-5: האטום לא קורא אף שדה שלו).

## חתימה
```dart
ConfigOp? validateOp(Object? entry, {
  required ConfigOp? Function(Map<String, dynamic> m) opFromJson,
  required String? Function(String id) matchElementId,
  required String? Function(String target, String axis) matchPropKey,
  required String Function(ConfigOp op) axisOf,
  required bool Function(String target, String prop, String? value) freeValueOk,
  required ({bool ok, Object? style}) Function(String target, Object? style) resolveStyle,
  required String? Function(Map<String, dynamic> m) actionIdOf,
  required String? Function(String target, String id) matchActionId,
  required String? Function(String id) matchCatalogActionId,
})
```

## קלט
- `entry` — איבר-מערך גולמי אחד (Object?; מפה או כל דבר אחר).
- 9 שקעים — במקור: `configOpFromJson(m)` · `matchElementId(reg, id)` ·
  `matchPropKey(reg, target, axis)` · `_axisOf(shape)` · `_freeValueOk(reg, target, prop, value)` ·
  `_resolveStyle(reg, target, style)` · `_actionIdOf(m)` · `matchActionId(reg, target, id)` ·
  `matchCatalogActionId(id)`. ה-`RegistryView` מוזרק-מראש (curry) בקופסה — האטום לא מכיר אותו.

## פלט / התנהגות (עוגני-שורה, הכול-או-כלום — פספוס בכל שדה ⇒ null)
- `edit_intent.dart:172` — `entry is! Map` ⇒ `null` (איבר-זר; אף שקע לא נקרא).
- `:173` — נרמול-מפתחות: `k.toString()` על כל מפתח לפני מסירה ל-`opFromJson`/`actionIdOf`.
- `:177-178` — `opFromJson(m) == null` (תג-לא-מוכר / צורה-רעה / id-ריק) ⇒ `null`.
- `:182-183` — `matchElementId(shape.id) == null` ⇒ `null`; אחרת **ה-RESOLVED נישא הלאה**
  (המזהה המוחזר, לא `shape.id` — שיקוף assistant_intent.dart:195).
- `:186` — `matchPropKey(target, axisOf(shape)) == null` ⇒ `null` (הציר אינו עריך על האלמנט).
- `:190-191` — `SetText`: ‏`freeValueOk(target, 'text', text)` שקר ⇒ `null`; אמת ⇒ `SetText(target, text)`.
- `:193-194` — `SetEmoji`: כנ"ל עם `'emoji'` ⇒ `SetEmoji(target, emoji)`.
- `:196-197` — `SetHidden` ⇒ `SetHidden(target, hidden)` ישירות (bool — אין אוסף-סגור).
- `:198-199` — `SetOrder` ⇒ `SetOrder(target, order)` ישירות (int — אין אוסף-סגור).
- `:200-203` — `SetStyle`: ‏`resolveStyle(target, style)`; ‏`ok:false` ⇒ `null`;
  ‏`ok:true` ⇒ `SetStyle(target, resolved.style)` — **ה-style המוחזר-מהשקע**, לא המקורי.
- `:204-212` — `SetAction`: ה-id מהמפה הגולמית (`actionIdOf(m)`, לא מה-shape); ‏null ⇒ `null`;
  ‏`matchActionId(target, id)` **וגם** `matchCatalogActionId(id)` חייבים שניהם להיפתר;
  ⇒ `SetAction(target, CfgAction(kind: onElement))` — ה-kind הוא **פתרון-על-האלמנט** (onElement).
- ‏TOTAL: לעולם לא זריקה (בהינתן שקעים שאינם זורקים).

## דוגמאות מספריות
| # | entry | שקעים | ⇒ |
|---|-------|--------|---|
| 1 | `'x'` (לא-מפה) | (אף אחד לא נקרא) | null |
| 2 | `{'op':'zap','id':'a'}` | opFromJson⇒null | null (matchElementId לא נקרא) |
| 3 | `{'op':'setText','id':'ghost',…}` | matchElementId⇒null | null (matchPropKey לא נקרא) |
| 4 | `{'op':'setText','id':'hero','text':'שלום'}` | matchElementId⇒'home.hero'; matchPropKey⇒'text'; freeValueOk⇒true | `SetText('home.hero','שלום')` — id RESOLVED |
| 5 | כנ"ל אך freeValueOk⇒false | | null |
| 6 | `{'op':'setHidden','id':'hero','hidden':true}` | ציר-'hidden' עריך | `SetHidden('home.hero',true)`; ‏freeValueOk לא נקרא |
| 7 | `{'op':'setStyle','id':'hero','style':{…}}` | resolveStyle⇒(ok:true,style:S') | `SetStyle('home.hero',S')` — ה-style מהשקע |
| 8 | כנ"ל אך resolveStyle⇒(ok:false,·) | | null |
| 9 | `{'op':'setAction','id':'hero','action':'buy'}` | matchActionId⇒'checkout.buy'; matchCatalogActionId⇒'buy' | `SetAction('home.hero', CfgAction(kind:'checkout.buy'))` |
| 10 | כנ"ל אך matchCatalogActionId⇒null | | null (חוקי-על-האלמנט אך לא-בקטלוג) |
| 11 | `{'op':'setOrder','id':'hero'}` אך matchPropKey⇒null | | null (ציר לא-עריך) |

## שקעים
כל התשעה הזרקת-ריאדרים/בנאים (חוק-3). הבדיקה מזריקה סטאבים עם מוני-קריאה
ומוודאת short-circuit (שקע לא נקרא כשלא-צפוי) ונשיאת-ה-RESOLVED.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/validate_op_test.dart  ⇒ exit 0 + "OK validateOp: N asserts passed"
```
