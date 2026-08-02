# 01 · מסך-הבית של הקבלן — פירוק לאטומים

**קובץ:** `app_flutter/lib/screens/smart_home_screen.dart` · **persona:** 👷 קבלן
**מטרה:** בלוּפְּרינט-פירוק — כל רכיב, מה הוא צריך, והאם ניתן לחלץ אותו כאטום עצמאי.

---

## המרכיב (composer)
**`SmartHomeBody`** — בונה את המסך מ-8 סקציות דרך `smartHomeSectionFor(HomeSection)`.
תלות: `catalogSettingsProvider` (הגדרות-תצוגה) · `screenSectionsProvider` (סדר+הסתרה).
👉 האטומים למטה **מורכבים על-ידו**; כל אחד עצמאי בקוד (מחלקה נפרדת).

## האטומים (8 סקציות)
| # | אטום (מחלקה) | תפקיד | אלמנטים | דאטה שהוא קורא | פעולות | מטמיע | ניתן-לחילוץ? |
|---|---|---|---|---|---|---|---|
| 1 | `_Departments` | אריחי-מחלקות | (מחלקות דינמיות) | `homeDepartmentProvider` | בחירה→`mainTabProvider=1` (לשונית מחלקות) | `_SectionTitle` · `_MiniTile` | 🔵 צריך: דאטת-מחלקות + ניווט-לשונית |
| 2 | `_SmartTreeRow` → `_SmartTreeCard` | שורת-מוצרים→כרטיס | **"הוסף לסל"** | דאטת-מוצרים | `smartCartProvider.add` (לסל) | `_SectionTitle` · `_Pad` | 🔵 צריך: קטלוג-מוצרים + עגלה |
| 3 | `_WorkPath` | מסלול-עבודה שלב-שלב | "🛁 חדש" · "גמר אמבטיה" · "4 שלבים…" | דאטת-מסלולים | פתיחת-מסלול | `_SectionTitle` | 🔵 צריך: דאטת-מסלולים |
| 4 | `_QuickTools` | קיצורים | "המלאי שלי" · "משימות העבודה" | — | `Navigator.push(StockScreen)` + משימות | `_SectionTitle` · `_MiniTile` | ✅ **עצמאי** — תלוי רק בניווט |
| 5 | `_RecentOrders` → `_OrderCard`/`_EmptyCard` | הזמנות-אתר אחרונות | (הזמנות + מצב-ריק) | providers-הזמנות | פתיחת-הזמנה | `_OrderCard` · `_EmptyCard` | 🔵 צריך: דאטת-הזמנות |
| 6 | `_InstallStudioHero` | תכנון-חיבור (hero) | "תכנון חיבור" · "בחר מה לחבר…" | — (gate `compatOn`) | `Navigator.push` → מנוע-תאימות | — | 🔵 צריך: מנוע-החיבורים |
| 7 | `_Favorites` | מוצרים מסומנים ★ | (מועדפים + מצב-ריק) | provider-מועדפים | הסרה/פתיחה | — | 🔵 צריך: דאטת-מועדפים |
| 8 | `_SuperFinderHero` → `_SuperFinderOpen` | גלגל-מאתר-על פתוח | (גלגל-צירים) | — (gate `kAxisDive`) | `mainTabProvider=0` + מטמיע `CatalogWheelScreen` | `CatalogWheelScreen` | 🔵 מטמיע רכיב-משותף גדול |

## אטומי-יסוד משותפים (חוזרים בכל הסקציות → לחלץ פעם-אחת)
| אטום | תפקיד |
|---|---|
| `_Metrics` | חישובי-גודל מ-`catalogSettingsProvider` |
| `_Pad` | ריפוד |
| `_SectionTitle` | כותרת-סקציה |
| `_MiniTile` | אריח-קיצור (עם `onTap`) |

## שכבת-התלויות (מה כל האטומים ביחד צריכים)
`catalogSettingsProvider` (תצוגה) · `screenSectionsProvider` (סדר/הסתרה) · `homeDepartmentProvider` · `mainTabProvider` (ניווט-לשוניות) · `smartCartProvider` (עגלה) · providers-הזמנות/מועדפים · דאטת-מוצרים/מחלקות/מסלולים · `CatalogWheelScreen` · `StockScreen`.

## סיכום-חילוץ (מה מוכן לאטומיזציה)
- ✅ **נקי (עצמאי):** `_QuickTools` (רק ניווט) + 4 אטומי-היסוד.
- 🔵 **צריך ניתוק-תלות:** 6 הסקציות שקוראות providers/דאטה — לחלץ = לחשוף את התלות כ**קלט** (props) במקום גישה-ישירה ל-provider.
- 📦 **המרכיב** `SmartHomeBody` = מגדיר את הפריסה (סדר-הסקציות) — כבר data-driven דרך `screenSectionsProvider`.

---
*אומת מול הקוד: `smart_home_screen.dart` (מחלקות + ref.watch/read + Navigator) · `element_registry.dart` (6 עלים) · `screen_sections.dart`.*
