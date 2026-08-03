# מסך · בית-הקבלן (contractor-home) — body
**קובץ:** `app_flutter/lib/screens/smart_home_screen.dart` · **persona:** 👷 קבלן · **מרכיב:** `SmartHomeBody` (`ConsumerWidget`, :116)

## המרכיב (composer)
בונה את ה-body מרשימת `HomeSection` — **סדר + הסתרה data-driven** (זה ה-seam שהכללנו למנוע-האטומים).
- **סדר:** `screenSectionsProvider` → `visibleIds('home', kHomeSectionIds)` → `HomeSection[]` (:126-131). ריק ⇒ ברירת-מחדל (byte-identical).
- **מיפוי:** `smartHomeSectionFor(section)→atom` (:102). סדר-ברירת-מחדל: `categories→departments · products→smartTree · workPath · promise→quickTools · reorderHistory→recentOrders · installHero→installStudio · favorites · superFinder`.
- **override חי** (:140): `installHero` רק אם `compatOn` · `superFinder` מרנדר **`_SuperFinderOpen`** (gated `kAxisDive`) לא `_SuperFinderHero` · ברירת-מחדל: atom + רווח `space4`.
- **reads:** `screenSectionsProvider` (watch) · `compatOn = modOn('compat')`. **אין writes.**
- **layout:** `ListView(key 'catalog-list', padding bottom space6)[ space2, ...sections ]`.

## אטומים (8) → קובץ-פר-אטום
`departments` · `smartTree` · `workPath` · `quickTools` · `recentOrders` · `installStudio` · `favorites` · `superFinder`
אטומי-יסוד משותפים: `shared/primitives.md`.

## שלמות-registry (שורת zero-miss)
- **screen key ל-body: `'smart_home_screen'` — 6 leaves רשומים** (כולם `wired`, `kImmutable:false`, `kRoleFloor:'contractor'`).
- **mapped: 6/6 ✓** → `add_to_cart`→smartTree · `workpath_badge/title/sub`→workPath · `install_title/sub`→installStudio.
- ⚠️ **`home.*` (14 leaves, `screen:'home'`) = ה-SHELL** (topbar/תפריטים/newchat/כרטיס-פרופיל) — **לא שייך ל-body הזה**. שייך לפירוק-shell נפרד (משותף ל-123 מסכים). כולל את `home.status.smarttree` שנשמע כמו עץ-חכם אבל הוא shell.
- ⚠️ **פער-כיסוי:** רוב האלמנטים-הסטטיים של ה-body (כותרות-סקציה · empty-states · תוויות-QuickTools · toast) **לא רשומים ב-registry** → לא ניתנים לעריכה ב-Studio. מפורט בשדה `gaps` בכל אטום.
