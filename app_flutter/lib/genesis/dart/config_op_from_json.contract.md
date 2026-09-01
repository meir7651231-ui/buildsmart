# חוזה · configOpFromJson

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/studio/config_op.dart:77-107`
**אטום:** `new/dart/config_op_from_json.dart` — `T? configOpFromJson<T>(Object? raw, {setText, setEmoji, setHidden, setOrder, setStyle, setAction})`

## קלט
- `raw` — `Object?`: ה-JSON הגולמי (במקור מגיע מ-`op.toJson()` המשוחזר). כל דבר שאינו `Map` ⇒ `null`.
- שֵש שקעי-בנייה (`required`) — כל אחד בונה את וריאנט-האטום המתאים מן המשפחה-הסגורה (config_store.dart). מייצגים את בנאי-השכן `SetText`/`SetEmoji`/`SetHidden`/`SetOrder`/`SetStyle`/`SetAction`. סוג-ההחזרה `ConfigOp?` במקור ⇒ גנרי `T?`.
  - `setStyle`/`setAction` מקבלים `Map<String,dynamic>?` (המפה המנורמלת דרך `_strMap`, config_op.dart:100,103,143-144), או `null` כשהשדה אינו `Map`. הרכבת `CfgStyle.fromJson`/`CfgAction.fromJson` (config_node.dart) חיה בתוך-השקע.

## פלט
`T?` — האטום שנבנה (`ConfigOp` במקור), או `null`. **TOTAL — לעולם לא זורק** (config_op.dart:72-76,105).

## התנהגות (עוגני-שורה למקור)
1. `raw is! Map` ⇒ `null` (config_op.dart:78).
2. נרמול-מפתחות: `j = raw.map((k,v)=>MapEntry(k.toString(),v))` (config_op.dart:79) — מפתחות לא-String מתועתקים ל-String.
3. `rawId = j['id']`; אם אינו `String` או ריק ⇒ `null` (fail-closed on identity, config_op.dart:81-82).
4. `switch (j['op'])` (config_op.dart:85):
   - `'setText'` ⇒ `setText(id, text is String ? text : null)` (:86-88).
   - `'setEmoji'` ⇒ `setEmoji(id, emoji is String ? emoji : null)` (:89-91).
   - `'setHidden'` ⇒ `setHidden(id, hidden is bool ? hidden : null)` (:92-94).
   - `'setOrder'` ⇒ `setOrder(id, order is num ? order.toInt() : null)` (:95-97) — `toInt()` **מקצץ לכיוון-אפס** (3.9→3, -2.9→-2).
   - `'setStyle'` ⇒ `setStyle(id, style is Map ? _strMap(style) : null)` (:98-100).
   - `'setAction'` ⇒ `setAction(id, action is Map ? _strMap(action) : null)` (:101-103).
   - `default` (תג לא-מוכר/חסר, כולל `addComponent`/`addRule` שאין להם וריאנט) ⇒ `null` (:104-105).

## דוגמאות מספריות (מוכחות ב-config_op_from_json_test.dart)
הרתמה מדמה את המשפחה-הסגורה: כל שקע מחזיר record `(tag, id, val)`.

| # | קלט raw | פלט | עוגן |
|---|--------|-----|------|
| 1 | `null` | `null` | :78 (אינו Map) |
| 2 | `'hi'` (String) | `null` | :78 |
| 3 | `{}` (מפה ריקה) | `null` | :82 (id חסר) |
| 4 | `{'id':'', 'op':'setText'}` | `null` | :82 (id ריק) |
| 5 | `{'id':5, 'op':'setText'}` | `null` | :82 (id אינו String) |
| 6 | `{'id':'a', 'op':'setText', 'text':'hi'}` | `setText('a','hi')` | :86-88 |
| 7 | `{'id':'a', 'op':'setText'}` | `setText('a', null)` | :88 (text חסר ⇒ null) |
| 8 | `{'id':'a', 'op':'setText', 'text':5}` | `setText('a', null)` | :88 (5 אינו String) |
| 9 | `{'id':'a', 'op':'setEmoji', 'emoji':'🔥'}` | `setEmoji('a','🔥')` | :89-91 |
| 10 | `{'id':'a', 'op':'setHidden', 'hidden':true}` | `setHidden('a', true)` | :92-94 |
| 11 | `{'id':'a', 'op':'setHidden', 'hidden':'yes'}` | `setHidden('a', null)` | :94 ('yes' אינו bool) |
| 12 | `{'id':'a', 'op':'setOrder', 'order':3}` | `setOrder('a', 3)` | :95-97 |
| 13 | `{'id':'a', 'op':'setOrder', 'order':3.9}` | `setOrder('a', 3)` | :97 (קיצוץ לכיוון-אפס) |
| 14 | `{'id':'a', 'op':'setOrder', 'order':-2.9}` | `setOrder('a', -2)` | :97 (שלילי מקצץ ל--2) |
| 15 | `{'id':'a', 'op':'setOrder', 'order':'3'}` | `setOrder('a', null)` | :97 ('3' אינו num) |
| 16 | `{'id':'a', 'op':'setStyle', 'style':{'c':1}}` | `setStyle('a', {'c':1})` | :98-100 |
| 17 | `{'id':'a', 'op':'setStyle', 'style':{7:'x'}}` | `setStyle('a', {'7':'x'})` | :100,143 (מפתח מנורמל) |
| 18 | `{'id':'a', 'op':'setStyle'}` | `setStyle('a', null)` | :100 (style חסר) |
| 19 | `{'id':'a', 'op':'setAction', 'action':{'k':'v'}}` | `setAction('a', {'k':'v'})` | :101-103 |
| 20 | `{'id':'a', 'op':'unknown'}` | `null` | :104-105 (תג לא-מוכר) |
| 21 | `{'id':'a'}` | `null` | :105 (op חסר ⇒ default) |
| 22 | `{'id':'a', 'op':'addComponent'}` | `null` | :105 (תג-משפחה-נושנת ⇒ drop) |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- **id חסר/ריק/לא-String** גובר על הכל (fail-closed) ⇒ `null` בטרם ה-switch (#3-5, :82).
- **שדה שגוי-טיפוס** (text=5, hidden='yes', order='3') ⇒ הוריאנט נבנה עם `null` בשדה, לא זריקה (#8,11,15) — כל קריאה `is`-guarded (:88,94,97).
- **`order` שברי/שלילי** ⇒ `toInt()` מקצץ לכיוון-אפס בדיוק כמו המקור (3.9→3, -2.9→-2; #13-14, :97) — לא עיגול.
- **מפתחות-מפה לא-String** (עליון או מקונן) ⇒ מתועתקים ל-String (:79,143); לכן id תחת מפתח לא-String לא-יימצא (fail-closed), ומפה-מקוננת `{7:'x'}` הופכת `{'7':'x'}` (#17).
- **תג לא-מוכר/חסר/נושן** (`unknown`/חסר/`addComponent`/`addRule`) ⇒ `null` (drop), לעולם לא op-חצי-בנוי (#20-22, :104-105).
