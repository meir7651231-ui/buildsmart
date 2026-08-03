# מסך · בית-הקבלן (contractor-home) — body
**קובץ:** `app_flutter/lib/screens/smart_home_screen.dart` · **persona:** 👷 קבלן · **מרכיב:** `SmartHomeBody` (`ConsumerWidget`, :116)

> **מודל 3-שכבות:** כל אטום = **עצם** (node · זהות+תוכן) · **חיבורים** (edges · מה מתחבר למה) · **התנהגות** (flows · trigger→verbs→rules→formulas→effect). כל עלה מצביע ל-`shared/floor.md`.

## המרכיב (composer) + שערי-אב
בונה את ה-body מרשימת `HomeSection` — **סדר+הסתרה data-driven** (ה-seam שהכללנו למנוע-האטומים).
- **סדר:** `verb` `screenSections.visibleIds('home', kHomeSectionIds).map(HomeSection.byName)` (:127) → אילו אטומים ובאיזה סדר.
- **מיפוי:** `smartHomeSectionFor(section)→atom` (:102). סדר: `categories→departments · products→smartTree · workPath · promise→quickTools · reorderHistory→recentOrders · installHero→installStudio · favorites · superFinder`.
- **שערי-אב (חשוב — שני אטומים מגודרים כאן, לא בפנים):**
  - `rule` `:141`: `installHero → compatOn ? [_InstallStudioHero] : []` (`compatOn=modOn('compat')`).
  - `rule` `:149`: `superFinder → kAxisDive ? [_SuperFinderOpen] : []` — **החי מרנדר `_SuperFinderOpen`**; `_SuperFinderHero` רק ב-preview.
- **layout:** `ListView(key 'catalog-list')[ space2, ...sections ]` · **אין writes.**

## אטומים (8) → קובץ-פר-אטום
`departments` · `smartTree` · `workPath` · `quickTools` · `recentOrders` · `installStudio` · `favorites` · `superFinder` · יסוד: `shared/primitives.md` · רצפה: `shared/floor.md`

## שלמות-registry (שורת zero-miss)
- **body key `'smart_home_screen'` — 6 leaves · mapped 6/6 ✓** (add_to_cart→smartTree · workpath ×3→workPath · install ×2→installStudio).
- ⚠️ **`home.*` (14, `screen:'home'`) = ה-SHELL** (topbar/תפריטים/newchat/פרופיל) — פירוק-נפרד משותף ל-123. כולל `home.status.smarttree` (shell, לא ה-body).
- ⚠️ **פער-כיסוי:** רוב הטקסטים-הסטטיים (כותרות · empty · תוויות-QuickTools · toast) **לא רשומים** → לא ניתנים לעריכה ב-Studio. מפורט ב-`gaps` בכל אטום.

## מפקד-אינטראקציה (מי בעל התנהגות)
- **אינטראקטיבי:** departments · smartTree · quickTools · installStudio · favorites · superFinder(preview).
- **build-only:** recentOrders (read+empty) · smartTree-row (gate).
- **סטטי טהור:** workPath · _OrderCard · _SuperFinderOpen (הטמעה — האינטראקציה ב-CatalogWheelScreen).
