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

## Parity status (current)
- CLAUDE.md records **feature-parity to Preact "completed" (~270 leaves verbatim)**;
  inspections INSP-0009→INSP-0040 all GO.
- Ported & live in Flutter: 4 tabs, 3 FAB dials (BS 5 personas, search 5 tools,
  menu 4 tabs), 6/6 legacy hubs, ~200+ verbatim leaves, settings trees.
- **Deferred / divergent**: contractor persona deep-tree (no verbatim emoji);
  some conversation/media buttons remain 🚧 (need device APIs absent in the
  prototype too).

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
