# INSP-0018 — Dial-only Restructure (revert ProfileView + SitesView)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0 — verified by Explore subagent, then written)

## Why
INSP-0016 (SitesView) and INSP-0017 (ProfileView) both built **full
window** views — `<section>` swapping the entire main content area.
This was an R2 violation:

> R2 · אין חלון מלא. backdrop קל לסימון מצב פעיל בלבד.

And contradicted the R2 principle:

> כשהאב-טיפוס פותח חלון מלא — אנחנו מתרגמים אותו ל-**dial**.

The user flagged it (`אני פתיחת חלון חסום נקודה`). This commit reverts
both views and rebuilds the same content inside the dial.

## Scope
- **Deleted**: `app/src/views/profile.tsx`, `app/src/views/sites.tsx`.
- **Removed** from `app-store.ts`: `AppView`, `currentView`, `setView`,
  `openSettingsDial`.
- **Added** to `app-store.ts`: `SettingsLevelId`, `settingsLevel`
  signal, `enterAdvancedSettings`, `exitAdvancedSettings`. Resets on
  `setMenuTab` / `toggleMenu` / `closeMenu`.
- **menu-speed-dial.tsx**: `TAB_HAS_SUBMENU.projects = true`,
  `.settings = true`. `handleTabClick` no longer touches view router.
  `active === 'projects'` → `<ProjectsSubmenu />`. `active === 'settings'`
  → `<SettingsLevel />` which:
   - `settingsLevel === 'profile'` → `<ProfileSubmenu />`
   - `'advanced'` → anchor `חזרה מ-הגדרות מתקדמות` + existing tree.
- **submenu-settings.tsx**: appended `ProfileSubmenu` (8 verbatim
  section rows + "הגדרות מתקדמות" drill) and `ProjectsSubmenu` (3
  PROJECTS rows + toast on tap).
- **app.tsx**: `ActiveView` purely persona-based.
- **global.css**: `.sites__*` and `.profile__*` blocks removed.

## Findings (Inspector subagent)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R2** PASS — no page-swap. All menu tab destinations stay in dial.
- **R3** PASS — every tab submenu renders inside `<ul class="dial">`.
- **R4** PASS — every leaf row = circle + label (two elements).
- **R6/R8** PASS — section labels verbatim from index.html:6545-6680
  (refreshIdentity headers) and projects from :6447-6451.
- **R7** PASS — `node smoke-settings.mjs` reports **21/21**.

## Process note
This time the Inspector subagent ran **before** the markdown report
was written, per RULES.md. INSP-0016 and INSP-0017 are not formally
retracted — they record the (flawed) intermediate state and the lesson;
INSP-0018 supersedes both for the current behavior.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014/0015/0016/0017.
