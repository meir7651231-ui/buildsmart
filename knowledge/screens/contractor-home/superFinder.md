# atom · superFinder · מאתר-על   [🔵 מטמיע רכיב-משותף גדול]
**חי:** `_SuperFinderOpen` (:676, Stateless) · **preview:** `_SuperFinderHero` (:716, ConsumerWidget) · hero

> ⚠️ המרכיב מרנדר **`_SuperFinderOpen`** (הגלגל הפתוח, gated `kAxisDive`). `_SuperFinderHero` = טוקן-preview לאשף-הסידור בלבד, לא נראה ב-body החי.

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| 🕸️ מאתר-על (:688 חי · :746 preview) | — לא רשום | text | static |
| גלגל-חיפוש-על — בחר מאיזה ציר… (:753) | — (preview) | text | static |
| (גלגל-הצירים) | — | embed | **דינמי** — `CatalogWheelScreen()` |

→ **registry 0 · mapped 0 · לא-רשום 1-2** · **state:** Stateless (חי)

## 2 · חיבורים (edges)
```
superFinder —קרא→   _pal
superFinder —כתוב→  (רק preview) mainTab=0 · catalogSection='מאתר-על' · keyboardDiveQuery=''   (SFH-2)
superFinder —מטמיע→ CatalogWheelScreen   (אטום-נפרד גדול)
superFinder —משתמש→ _Pad · cfgRadius
superFinder —מגודר→ kAxisDive  ← ב-SmartHomeBody (:149)
```

## 3 · התנהגות (flows)
**SFO-1 · build (החי) = הטמעה-סטטית טהורה:**
title `Text('🕸️ מאתר-על')` + `Container(h:560)` → `CatalogWheelScreen()`. **אין onTap/reads כאן** — כל האינטראקציה (צלילת-ציר, tap→גיליון) **נדחית ל-`CatalogWheelScreen`**.

**SFH-2 · onTap (רק preview `_SuperFinderHero`):**
`verb write` `mainTab=0` → `verb write` `catalogSection='מאתר-על'` → `verb write` `keyboardDiveQuery=''` → **effect:** מעבר לקטלוג/מאתר-על + ניקוי-שאילתה

## חוזה-רכיב + gaps
`extractable: embeds-shared` · **untangle:** `CatalogWheelScreen` = רכיב-משותף גדול → אטום-נפרד; כאן רק מעטפת-hero (title + מסגרת + embed)
**gaps:** הכותרת לא-רשומה · שני מימושים (חי/preview) — התנהגות-הכתיבה רק ב-preview
