# POLISH_LOG — יומן ליטוש (סוכן: ליטוש)

> תוצר פאזה A צעד 9. **before → after → gate → ref** לכל שינוי-UI (כלל-זהב §1).
> ענף `claude/whats-happening-LyY9G` · push רק ב"תדחוף".

## פאזה A — קו-בסיס (בוצע · 2026-06-01)
- **סביבה:** Flutter 3.29.3 · `analyze` 0 errors · `test` 986 ✅ · `build web` ✅.
- **tokens** (`lib/theme/tokens.dart`): מערכת מסודרת — spacing (`space1–6` = 4..32), radii
  (pill/card16/circle24), dial dims (circle48 · icon22 · emoji20 · fab56), timing
  (`dialIn` 280ms · `ssubIn` 240ms · `dialCurve` Cubic) · צבעים light/dark · shadows.
  **מקור-אמת יחיד למידה/צבע/תנועה.**
- **widgets משותפים:** `dial.dart` (`DialRow`+`DialColumn`+`_StaggerIn`) · `chain_diagram.dart` · `toast.dart`.
- **dials:** `bs/menu/search_dial_widget.dart` — כולם מרכיבים את `DialRow`.
- **ממצא-על:** ה-UI **כבר מלוטש היטב** — token-based, `DialRow` כולל `Semantics(label,button:true)`
  ומבנה RTL-מודע. ההזדמנויות קטנות/מדויקות (כמו פאזה K — בריא מהחשש שבפרוטוקול).

## ⛔ בלוקר — מנגנון before/after (steps 4–6 · 10–11 · 93–94)
אין `display`/chrome, ואין `golden-tests`/`integration_test` בריפו. כלל-הזהב אוסר שינוי-UI
בלי before/after מתועד. → **ה-apply של פאזות B–F חסום** עד שייבנה מנגנון-לכידה headless
(golden tests / Playwright על `build web` / display). **דרושה החלטה.**

## Backlog (B–J) — מעוגן-מקור, מתועדף

### ✅ מכוסה כבר (אין מה לעשות)
- **G · נגישות:** `DialRow` מספק Semantics; כל 3 ה-dials מרכיבים אותו (bs 4 · menu 9 · search 6).
  כיסוי-בסיס תקין. (P2: audit-עומק ל-labels דינמיים — pending capture.)

### 🟢 ready-to-apply — safe, token-equal, אפס שינוי ויזואלי
- ✅ **בוצע** (ראה "שינויים שבוצעו"): `dial.dart` `vertical:4` → `BsTokens.space1`.

### 🟡 needs token-decision / larger pass
- ✅ stagger `28ms` → `BsTokens.dialStaggerStep` (#3) · toast `2s` → `BsTokens.toastDuration` (#4).
- `dial.dart:69` `vertical: 6` — אין token (scale 4,8,12); ערך/token decision.
- **typography pass (Phase C):** font-sizes magic ב-`toast.dart`(14) · `chain_diagram.dart`(8/9/22) +
  `chain_diagram` לא מייבא tokens — pass נפרד, דורש type-scale (החלטת-design).

### 🔵 H · microcopy verbatim — audit בוצע (2026-06-01)
- **15/16 label-ים עליונים verbatim ✅** מול `app/src/` Preact (menu 4 + search 11 תואמים מילה-במילה).
- ✅ **drift 1 תוקן** (באישור-משתמש): `search_dial_widget.dart:94` — `'פתח מצלמה'` → **`'הפעל מצלמה'`**
  (verbatim מ-`app/src/components/search/submenu-barcode.tsx`, R6/R8). ראה "שינויים שבוצעו" #2.
- היקף: audit עליון בלבד (menu+search top-level). ~200+ leaves נותרו ל-audit מלא (סבב המשך).

### 🔴 חסום על capture (דורש שיפוט ויזואלי + before/after)
- **B** layout/spacing · **C** color/contrast · **D** motion-feel · **E** states (empty/loading/error) · **F** RTL-render.

## תיאום (בעלות — AGENT_COORDINATION)
- `dial.dart`/`tokens.dart` = `lib/widgets`/`theme` → **נתיב ליטוש** ✅.
- `*_dial_widget.dart` = `lib/screens` → תיאום מקבץ/סדרן לפני נגיעה.

## שינויים שבוצעו
| # | קובץ | before → after | gate | ref |
|---|------|----------------|------|-----|
| 1 | `lib/widgets/dial.dart` | `DialRow` padding `vertical: 4` → `BsTokens.space1` (token-equal, 4==4, אפס שינוי-render) | analyze 0 · test 986 ✅ | non-visual (literal→token) |
| 2 | `lib/screens/search_dial_widget.dart` | label `'פתח מצלמה'` → `'הפעל מצלמה'` (verbatim מ-Preact `submenu-barcode.tsx`) | gate analyze+test+build | H · R6/R8 · באישור-משתמש |
| 3 | `lib/theme/tokens.dart` · `lib/widgets/dial.dart` | stagger `28ms` → `BsTokens.dialStaggerStep` (motion token; zero-visual) | gate analyze+test+build | D |
| 4 | `lib/theme/tokens.dart` · `lib/widgets/toast.dart` | toast `2s` → `BsTokens.toastDuration` (zero-visual) | gate | D |
