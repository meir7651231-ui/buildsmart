# atom · superFinder · מאתר-על   [🔵 מטמיע רכיב-משותף גדול]
**class חי:** `_SuperFinderOpen` (:676, **StatelessWidget**) · **class preview:** `_SuperFinderHero` (:716, ConsumerWidget) · **kind:** hero

> ⚠️ שני מימושים: המרכיב מרנדר **`_SuperFinderOpen`** (הגלגל הפתוח, gated `kAxisDive`). `_SuperFinderHero` = **טוקן-preview בלבד** לאשף-הסידור (`smartHomeSectionFor`), לא נראה ב-body החי.

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| 🕸️ מאתר-על (:688 חי · :746 preview) | — לא רשום (plain Text) | text | static |
| גלגל-חיפוש-על — בחר מאיזה ציר… (:753) | — לא רשום (preview בלבד) | text | static |
| (גלגל-הצירים) | — | embed | **דינמי** — `CatalogWheelScreen()` (רכיב-משותף גדול) |

→ **registry: 0 · mapped: 0 · לא-רשום: 1-2** ⚠️

- **state:** Stateless (חי) · אין controllers
- **reads:** `_pal`
- **cross-effects (רק ב-preview `_SuperFinderHero`):** `mainTabProvider.state=0` (:726) · `catalogSectionProvider.state='מאתר-על'` (:727) · `keyboardDiveQueryProvider.state=''` (:728). **החי (`_SuperFinderOpen`) אינו כותב** — הצלילה קורית בתוך `CatalogWheelScreen`.
- **gate:** המרכיב מגדר על const `kAxisDive` (:149) → כבוי מתעלם ב-tree-shake
- **layout (חי):** `_Pad→Column[ Text('🕸️ מאתר-על'), Container(h:560, clip)→CatalogWheelScreen() ]`
- **primitives:** _Pad · **מטמיע:** `CatalogWheelScreen` (אטום-נפרד משלו)
- **חוזה-רכיב:** `extractable: embeds-shared` · **untangle:** `CatalogWheelScreen` = רכיב-משותף גדול → אטום נפרד; כאן רק מעטפת-hero (title + מסגרת + embed)
- **gaps:** הכותרת לא-רשומה · שני מימושים (חי/preview) — לתעד את ההבחנה בקוד
