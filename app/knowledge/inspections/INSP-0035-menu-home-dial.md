# INSP-0035 — Menu FAB tab בית → Dial (final menu wiring)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
The LAST unwired menu FAB tab. `בית` previously called `closeMenu()`.
Now drills into 4 home-unique leaves verbatim from view-home.

## Leaves (verbatim — emoji + label in the same legacy DOM string)
| emoji | title | legacy source |
|---|---|---|
| 🤖 | בינה מלאכותית ואוטומציה | `<span class="fin-hub-ic">🤖</span><span class="fin-hub-t">בינה מלאכותית ואוטומציה</span>` @ :4436-4438 |
| 📐 | סרוק תוכנית עבודה | `<div class="pt">📐 סרוק תוכנית עבודה</div>` @ :4474 |
| 📦 | המלאי שלי | `<div class="pt">📦 המלאי שלי</div>` @ :4493 |
| 📋 | משימות העבודה | `<div class="pt">📋 משימות העבודה</div>` @ :4503 |

## Why these 4 (and not the categories)
The home view in legacy also has 8 category shortcut tiles (🔧 כלי
עבודה · 🚿 אינסטלציה · ⚡ חשמל · …). These are excluded from the home
dial because they duplicate the `קטלוג` tab (each `onclick="go('catalog')"`).
The 4 leaves here are the home-unique tools.

## Changes
- **`submenu-settings.tsx`** — `HOME_LEAVES` array + `HomeSubmenu`
  component. Pattern matches `CatalogSubmenu` / `ProjectsSubmenu`.
- **`menu-speed-dial.tsx`** — `TAB_HAS_SUBMENU.home = true`; render
  `<HomeSubmenu />` when `active === 'home'`.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0023..0034.

## Menu FAB — all 5 tabs wired
| Tab | Submenu |
|---|---|
| **בית** | ✅ 4 home-unique tools (INSP-0035) |
| קטלוג | ✅ 11 categories (INSP-0033) |
| הפרויקטים | ✅ 3 projects |
| רכש | ✅ 2 + 6 sub-services (INSP-0034) |
| הגדרות | ✅ profile tree + 10 settings categories |
