# חוזה · plumbingAccessories

> אטום-Dart · קידום-ידני מטיוטת-מחצבה "קשה" (חוק-4 — verbatim מהמקור, Dart-לא-מתורגם).

## מקור
buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:174-198 (ענף claude/align-main)
- טיפוסים: `AccessoryRule` — domain/trade_schema.dart:387-423 · `SmartProduct`/`SmartAcc` — data/smart_tree.dart:116-134 / 98-113 (צורות-מינימום, רק השדות שהמנוע נוגע בהם).

## הכרעת-הקידום (טיוטה-קשה)
🔌 שכן+דאטה ⇒ שקעים: `_smartKeyToId()` (שכן, plumbing_trade_seed.dart:97-100) ⇒ פרמטר `smartKeyToId` · `kSmartProducts` (דאטה, smart_tree.dart:156) ⇒ פרמטר `catalog` · הקבועים `kPlumbingTradeId` (שורה 30) ו-`kUncategorizedCategoryId` (שורה 61) ⇒ פרמטרים בשמם (כמו האטום-האח `category_id.dart`). ⚛️ `AccessoryRule` הוטבע מינימלי-verbatim.

## קלט
- `catalog: List<SmartProduct>` — מוצרים-חכמים; מכל אחד נקראים `key` + `acc[]` (name/emoji/why/must/price/sku).
- `smartKeyToId: Map<String, String>` — פותר `SmartProduct.key` ⇒ מזהה-קטגוריה.
- `kPlumbingTradeId: String` — במקור `'plumbing'`.
- `kUncategorizedCategoryId: String` — יעד-נפילה כשה-key לא בפותר (שלמות-FK, שורה 185).

## פלט
`List<AccessoryRule>` — כלל אחד פר-אביזר, ממוין לפי `id` (השוואת-מחרוזת, שורה 196).

## התנהגות (עוגני-שורה)
1. `id = '$kPlumbingTradeId.acc.${sp.key}.$i'` — `i` = אינדקס-האביזר במוצר (שורה 182).
2. `appliesToCategoryId = smartKeyToId[sp.key] ?? kUncategorizedCategoryId` (שורות 184-185).
3. מיפוי-שדות verbatim: name⇒nameHe · emoji⇒emoji · why⇒whyHe · must⇒mustHave · price⇒price · sku⇒linkSku (שורות 186-191); ‏price/sku יכולים להיות null ונשמרים null.
4. מיון-סופי `a.id.compareTo(b.id)` — **מיון-מחרוזת**: אינדקס 10 ממוין לפני 2 (`.acc.x.10` < `.acc.x.2`) — התנהגות-המקור, לא "משפרים".

## דוגמאות מספריות
- ‏catalog=[{key:'boiler', acc:[{name:'שסתום', emoji:'🔩', why:'חובה-תקן', must:true, price:45, sku:'LP-1'}]}], smartKeyToId={'boiler':'plumbing.cat.b1'}, trade='plumbing', uncat='plumbing.cat._uncategorized' ⇒ כלל-יחיד: id='plumbing.acc.boiler.0' · appliesToCategoryId='plumbing.cat.b1' · nameHe='שסתום' · mustHave=true · price=45 · linkSku='LP-1'.
- אותו קלט עם smartKeyToId={} ⇒ appliesToCategoryId='plumbing.cat._uncategorized'.
- ‏catalog=[] ⇒ [].
- מוצר עם 11 אביזרים ⇒ הרשומה של אינדקס 10 קודמת לזו של אינדקס 2 (מיון-מחרוזת).

## אימות (DoD — נכתב לפני הקוד)
`dart run --enable-asserts new/dart/plumbing_accessories_test.dart` ⇒ exit 0, פלט `OK plumbing_accessories`.
