# Prototype & Target — app_flutter (היעד מול האב-טיפוס)

What we're building toward, and how it relates to the prototype. This is the
"why/where-to" that `SPEC.md` (the "what is") points back to.

## The three layers
| Layer | Path | Role |
|---|---|---|
| **Prototype** (האב-טיפוס) | `/index.html` (root, ~1.4 MB) | the **spec for *what*** — every screen, leaf, and Hebrew string, verbatim. Source of truth for content. |
| **Reference** | `app/` (Preact + Vite PWA) | **live in production** on GitHub Pages. Translates the prototype into the dial pattern. Bug-fixes only until Flutter stabilizes. `app/RULES.md` = the spec for *how* (R1–R9). |
| **Target** | `app_flutter/` (Flutter) | **this app** — the native iOS + Android + Web build meant for **store launch**. |

> `app/RULES.md`: "האב-טיפוס `index.html` הוא ה-spec ל**מה**; החוקים מספקים את ה**איך**.
> בכל קונפליקט — האב-טיפוס מספק את התוכן." Content comes from the prototype; the
> rules provide the wrapper.

## The target (definition of done)
1. **Verbatim feature-parity** with the prototype — ~270 leaves, every Hebrew
   string copied verbatim (R6/R8: no invention; strings come from `index.html`).
2. **Translated to the dial pattern**, never full-screen windows (R2 absolute):
   "כשהאב-טיפוס פותח חלון מלא — אנחנו מתרגמים אותו ל-dial." The 5 FABs (R1) and
   the 4 bottom tabs are the shell; features are dials/leaves, not new windows.
3. **Cutover**: once Flutter is stable it replaces the Preact reference in
   production; the prototype/Preact stay as content reference.
4. **Launch** in the iOS / Android / Web stores.

## Parity status (current) — measured map in `PARITY.md` + `port/COVERAGE.md`
- **Label parity high; functional parity partial.** ~200+ verbatim dial leaves
  exist (`sections.dart`/`menu_trees.dart`/`settings_tree.dart`), but most are
  placeholder toasts ("בבנייה"), and the **menu + search dials are built yet not
  wired to any trigger** — only the BS dial opens (AppBar wordmark). Shell is a
  4-tab bottom-nav + cart-FAB, not the 5-FAB row of R1 (see `spec/shell-and-dials.md` §7).
- **Flutter goes *deeper* than the prototype** on two axes: the real ~935-SKU
  Lipskey catalog, and the install-studio + BOM/compatibility engine (no prototype
  equivalent).
- **Absent / stub (the ~85% to port — see `PARITY.md`)**: contractor card / ranks /
  rewards; projects / sites / budget / finance / tasks; the B2B flows (RFQ / RMA /
  rental / deposits / MSDS / gov-XML / signature); the 4 persona apps (dial labels
  only); onboarding / RBAC. Some media/telephony buttons are ⛔ (device APIs).

## Where Flutter intentionally goes *beyond* the prototype
These are wrapper/quality improvements, not content changes — content stays verbatim:
- full **light-mode** theme (prototype/Preact were dark-leaning);
- real **product grid** + cart stepper, settings **wired to real effects**;
- a **regression + mutation-tested** logic core and this **knowledge protocol**.

## How to use this when building
- Need to know **what** a screen/leaf should contain or say → the **prototype**
  (`index.html`) / the Preact `app/` reference. Copy Hebrew verbatim (R6).
- Need to know **how** to present it → `app/RULES.md` (R1–R9) + `CONVENTIONS.md`.
- Need to know **what already exists in Flutter** → `SPEC.md` + `../WIRING.md`.
- New string added to `app/`? Mirror it verbatim into `app_flutter/` (CLAUDE.md rule 3).
