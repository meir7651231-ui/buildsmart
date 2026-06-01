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
- **B/C:** `dial.dart:41` — `EdgeInsets.symmetric(vertical: 4)` → `BsTokens.space1` (4==4,
  token-consistency, ללא שינוי-render). gate: `flutter test` ירוק (before/after = literal→token).

### 🟡 needs token-decision (ערך לא בסקאלה)
- `dial.dart:69` — `vertical: 6` (אין token; scale=4,8,12...). או token חדש, או 6→8 (`space2`,
  **שינוי ויזואלי** → דורש before/after).
- `dial.dart:109` — stagger `28ms` literal — לשקול `BsTokens.dialStagger`.

### 🔵 feasible ללא צילום (טקסט בלבד)
- **H · microcopy verbatim:** label-ים ב-dials הם literals עבריים inline (`'בית'`,`'הפרויקטים'`,
  `'רכש'`,`'הגדרות'`...). לוודא verbatim מול `app/` Preact + `port/proto/`. (`lib/screens` —
  תיאום מקבץ/סדרן לפני נגיעה.)

### 🔴 חסום על capture (דורש שיפוט ויזואלי + before/after)
- **B** layout/spacing · **C** color/contrast · **D** motion-feel · **E** states (empty/loading/error) · **F** RTL-render.

## תיאום (בעלות — AGENT_COORDINATION)
- `dial.dart`/`tokens.dart` = `lib/widgets`/`theme` → **נתיב ליטוש** ✅.
- `*_dial_widget.dart` = `lib/screens` → תיאום מקבץ/סדרן לפני נגיעה.

## שינויים שבוצעו
| # | קובץ | before → after | gate | ref |
|---|------|----------------|------|-----|
| — | — | (pass ראשון = Plan בלבד. apply ימתין למנגנון-capture/החלטה.) | — | — |
