# MASTER_PROTOCOL — פרוטוקול אב מאוחד (BuildSmart Flutter)

> **מסמך-חוק יחיד.** מאחד את כל הפרוטוקולים הקיימים ללא השלה:
> PROTOCOL · PLAYBOOK · CATALOG-CARD-PROTOCOL · SMARTPRODUCT_ROADMAP ·
> AGENT_PATTERNS · SCHEMA · STATE_OVERVIEW · TESTS_OVERVIEW · HELPER_INDEX ·
> CARD_FLOW · PROJECTS_GUIDE · COACH_MODE · BUNDLE_SPLIT · DECISIONS · CONVENTIONS.
>
> **הכללים כאן נכתבו בדם ויזע.** כל שורה מגיעה מכשלון ממשי שתועד.
> אין לדלג. אין לקצר. אין "תיקון מהיר" לפני gate.
>
> **MASTER_PROTOCOL.md** = source of truth לתהליך.
> **SMARTPRODUCT_ROADMAP.md** = source of truth לתוכן.

---

# חלק א — עיקרונות יסוד

## א.1 · למה צריך פרוטוקול

*"הכשלות לא הגיעו ממחסור בידע — הגיעו ממחסור בתהליך."*
— לקח מ-INSP-0025, אחרי הרברט השלישי.

בלי פרוטוקול: קוד נכתב → נראה נכון → עובר לייצור → נמצאת הפרת R2 → revert → מחדש.
עם פרוטוקול: הפרת R2 נתפסת **לפני** שהקוד אפילו נכתב, בשלב התרגום.

## א.2 · שני פרויקטים מקבילים

| תיקייה | סטאק | מצב |
|---|---|---|
| `app_flutter/` | Flutter 3.29 + Dart 3.7 + Riverpod | **🟢 פעיל לפיתוח חדש** |
| `app/` | Preact + TypeScript + Vite + PWA | 🟡 **חי בפרודקשן** (GitHub Pages). תיקוני באגים בלבד |

כל פיצ׳ר חדש = `app_flutter/` בלבד.
אם נוסף string ב-`app/` — להעתיק verbatim ל-`app_flutter/`.

## א.3 · ענף עבודה ו-PUSH POLICY (כלל אבסולוטי)

- ענף: `claude/whats-happening-LyY9G` — **כל עבודה על ענף זה**.
- **אין push ל-main ללא אישור מפורש מהמשתמש.**
- **"NO STOPPING" אינו היתר לדחיפה.** build/test/commit מקומי בחופשיות — push רק כש-
  המשתמש אומר "תדחוף" / "push" / "approved". checkpoint נקי = הצע — לא בצע.
- כל commit קטן; `git pull --no-rebase` לפני push (sessions מקבילים).
- Bump גרסה ב-`home_shell.dart` בכל שינוי גלוי למשתמש (פורמט: `vX.YY · DD.M.YY · <note>`).
- גרסה ב-`home_shell.dart` ו-`knowledge/STATUS.md` **חייבים להיות זהים** בכל commit
  (`knowledge_protocol_test` יכשל אחרת).

---

# חלק ב — כלל R2 (הכלל המוחלט)

## ב.1 · אין חלון, נקודה

**"Flutter FRM-02 (R2):" אסור להופיע בקוד חדש:**

| אסור | סיבה |
|---|---|
| `showDialog(...)` | מסך מלא |
| `showModalBottomSheet(...)` | מסך חדש |
| `Navigator.push(...)` | מסך חדש |
| `Scaffold(...)` חדש שלא היה | מסך חדש |
| `Stack` עם `Positioned.fill` כ"מסך" חדש | מסך מלא |

**כל פיצ׳ר חדש = dial-drill בלבד.**

## ב.2 · תרגום מהפרוטוטייפ

הפרוטוטייפ (`/index.html`) תמיד פותח חלון מלא (`position:fixed; inset:0`).
כל תרגום ל-Flutter חייב להיות **dial-drill**.

| פרוטוטייפ פתח... | Flutter מממש... |
|---|---|
| `renderBudget()` — מסך תקציב | dial עם 5 שורות קטגוריה + total leaf |
| `renderProjects()` — רשימה | dial-drill: פרויקט → sub-dial עם אתרים |
| `openFinanceHub()` — panel | dial-drill עם 10 עלים |
| persona dashboard מלא | ❌ אסור — dial-drill דרך BS tile בלבד |

## ב.3 · היתרים קיימים (לא לשנות, לא להוסיף)

- `LipskeyProductSheet` — גיליון מוצר (bottom sheet, קיים ומאושר)
- `InstallStudioScreen` — מסך install studio (קיים ומאושר, R2 exception)
- `RegressionPanelScreen` — panel בדיקות (קיים ומאושר)

## ב.4 · למה R2 לא נתפס ע"י compiler

בכל 3 הרברטים — קיים קוד שנראה הגיוני, עובר typecheck, ואפילו passes tests — ועדיין הפר R2.

| רברט | סיבה | הכלל שנוסף |
|---|---|---|
| INSP-0016/0017 — `SitesView` + `ProfileView` | נבנו כ-`position:fixed; inset:0` views | FRM-02 CRITICAL |
| INSP-0022/0023 — persona dashboards | `AppView` enum + view-routing | FRM-02 + FRM-03 CRITICAL |
| INSP-0018 revert | `currentView` state ב-shell | לא `Navigator.push`, לא enum-view ב-shell |

**R2 נתפס רק ע"י checklist — לא ע"י compiler.**

---

# חלק ג — לפני שגורעים שורת קוד

## ג.1 · שאלת-הפתיחה החובה

לכל פיצ׳ר/עלה/מסך — לענות בכתב לפני כל קוד:

```
מה: [שם הפיצ׳ר]
מקור: proto [L####] / preact [file:line]
תרגום ל-dial: "dial עם X עלים: [עלה1, עלה2, ...]"
helper נדרש: [שם, signature, מה מחזיר]
מחרוזות verbatim: ["מחרוזת" מ-L####, ...]
חסום (⛔): [מה תלוי-backend/נתון ואי-אפשר לממש]
```

**אסור לפתוח קובץ dart לכתיבה לפני שהתרגום-ל-dial ברור.**
אם ה"תרגום" כולל את המילה "מסך" / "דף" / "view" / "dashboard" — עצור. שאל שוב.

## ג.2 · 10-step decomposition לכל פעולה

לפני כל פעולה משמעותית (roadmap step / תיקון), פרק ל-~10 שלבים ספציפיים:

1. דרישה + acceptance criteria
2. מקורות נתונים / dependencies
3. בדיקת patterns קיימים / overlap
4. עיצוב (signature + התנהגות)
5. כתוב tests קודם (red)
6. מממש (green)
7. `flutter analyze` → 0 errors
8. wire UI (מינימלי, RTL-safe)
9. Scoped tests ירוקים + full suite כל ~5 שלבים
10. עדכן ROADMAP + bump גרסה + local commit (ללא push)

אסור לדלג בשקט — להתאים לכל שלב.

---

# חלק ד — לולאת הבנייה (Build Loop)

לכל יחידת עבודה (פיצ׳ר / עלה / helper / תיקון-באג):

```
[1] READ    → קרא מקור [L#] + knowledge/port/
[2] PLAN    → כתוב תרגום-ל-dial (§ג.1) + helper signature
[3] HELPER  → כתוב helper טהור (ללא UI) + unit test
[4] TEST    → flutter test → כל הבדיקות ירוקות
[5] WIDGET  → כתוב dial widget + smoke test (נפתח, עלים קיימים)
[6] WIRE    → חבר trigger + עדכן WIRING.md
[7] GATE    → הרץ checklist (חלק ה) — כל CRITICAL חייב לעבור
[8] COMMIT  → גרסה bump + commit עם @rule/@legacy/@adr
```

**אסור לדלג.** skip שלב [3] = helper ללא בדיקה = bug שמגיע אחר כך.
skip שלב [7] = commit ללא gate = revert שמגיע אחר כך.

---

# חלק ה — Checklist שלבי-ביקורת

רק השלבים שה-diff נגע בהם נבדקים. **OPS תמיד, אחרון.**

## FND — יסודות (Data · Models · Providers)

| מזהה | בדיקה | חומרה |
|---|---|---|
| FND-01 | `flutter analyze` — 0 errors | CRITICAL |
| FND-02 | אין ID כפול ב-`kCatalogProducts` | CRITICAL |
| FND-03 | כל `ProductVariant` ממפה למוצר קיים | MAJOR |
| FND-04 | כל provider חדש מוגדר ב-`providers.dart` | MAJOR |
| FND-05 | כל `StateNotifier` מוגדר עם initial state מפורש | MAJOR |
| FND-06 | מפתחות `SharedPreferences` פורמט `bs.{thing}.v{N}` | MINOR |
| FND-07 | helper טהור חדש → unit test ב-`test/` | CRITICAL |
| FND-08 | אין logic ב-`build()` (חישוב = helper, לא inline) | MAJOR |

## FRM — מסגרת (Layout · Dial · R1–R5)

| מזהה | בדיקה (R) | חומרה |
|---|---|---|
| FRM-01 (R1) | FABs קיימים לא זזים — layout ב-`home_shell.dart` לא השתנה | CRITICAL |
| FRM-02 (R2) | אין `showDialog`/`showModalBottomSheet`/`Navigator.push`/`Scaffold` חדש | CRITICAL |
| FRM-03 (R2) | אין `Positioned.fill` / `SizedBox.expand` כ"מסך" חדש | CRITICAL |
| FRM-04 (R3) | כלים נפתחים כ-dial — לא drawer/sheet/modal חדש | CRITICAL |
| FRM-05 (R4) | כל שורת dial = שני widgets נפרדים: circle-icon + label pill | MAJOR |
| FRM-06 (R4) | gap בין circle לפיל ≥ 8px, לא container אחד | MAJOR |
| FRM-07 (R2) | overlay backdrop `opacity ≤ 0.45` + `blur ≤ 3px` | MAJOR |
| FRM-08 | RTL — כל padding/margin/alignment משתמש ב-`start`/`end`, לא `left`/`right` | MAJOR |
| FRM-09 | touch target ≥ 44×44 px לכל כפתור אינטרקטיבי | MAJOR |

## WIR — חיווט (State · Effects · Riverpod)

| מזהה | בדיקה | חומרה |
|---|---|---|
| WIR-01 | אין `ref.watch` בתוך callback / initState / dispose | CRITICAL |
| WIR-02 | אין mutation ב-`build()` — setter רק ב-callback | CRITICAL |
| WIR-03 | invariant עגלה: `cartCount == sum(cart.items.qty)` | CRITICAL |
| WIR-04 | כל כפתור חדש רשום ב-`WIRING.md` עם status ✅/🚧/⛔ | MAJOR |
| WIR-05 | state machine חדש → unit test לכל מעבר | CRITICAL |
| WIR-06 | persist חדש → `SharedPreferences` key מתועד ב-WIRING.md | MINOR |
| WIR-07 | אין `Future.delayed` כ"המתנה לstate" — השתמש ב-`ref.listen` | MAJOR |

## VRB — Verbatim (R6/R8 — הכי נפוץ להפרה)

| מזהה | בדיקה | חומרה |
|---|---|---|
| VRB-01 (R6) | כל מחרוזת עברית חדשה — מצוין מקור [L#] בפרוטוטייפ | CRITICAL |
| VRB-02 (R6) | אין שינוי סדר מילים ממקור | CRITICAL |
| VRB-03 (R8) | אין מחרוזת/פיצ׳ר שלא קיים בפרוטוטייפ | CRITICAL |
| VRB-04 | emoji verbatim מהפרוטוטייפ — לא מוחלף/מוסר | MAJOR |
| VRB-05 | חדש ב-`app/` → מועתק verbatim ל-`app_flutter/` | MAJOR |

**אימות VRB-01:** `grep -n "המחרוזת" /home/user/buildsmart/index.html`
אם לא נמצאת — לא להוסיף. אם נמצאת — לרשום [L#] בתגובה.

## OPS — אופרציות (תמיד מריץ, אחרון)

| מזהה | בדיקה | חומרה |
|---|---|---|
| OPS-01 | `flutter analyze` — `No issues found!` | CRITICAL |
| OPS-02 | `flutter build web --release` — מצליח | CRITICAL |
| OPS-03 | `flutter test` — 0 failures | CRITICAL |
| OPS-04 | גרסה bumped ב-`pubspec.yaml` (version: X.Y.Z+N) | MAJOR |
| OPS-05 | WIRING.md מעודכן לכל שינוי-התנהגות | MAJOR |
| OPS-06 | commit message מציין `@rule R2`/`@legacy L#`/`@adr ADR-NNN` | MINOR |
| OPS-07 | **בדיקת-לולאה:** אותו finding ID לא הופיע ב-2+ מ-3 הדוחות האחרונים | CRITICAL |

---

# חלק ו — מנגנון לולאה-תקועה (Stuck-Loop P-01)

**הגדרה:** אם אותו finding (אותו ID שורש) הופיע ב-2 מתוך 3 ביקורות אחרונות:

1. **עצור** — אל תנסה תיקון שלישי.
2. **הצג:** `"⛔ לולאה-תקועה: [finding-ID] חוזר — נדרשת התערבות הבעלים."`
3. **אל תוסיף עוד ממצאים** — הדוח מסתיים כאן עם `VERDICT: NO-GO (stuck-loop)`.
4. **שאל את המשתמש** במפורש מה ה-approach הנכון.

**מה ש-P-01 מונע:** 3 ניסיונות לפתרון שגוי שכל אחד מהם גורם לרברט חדש.

---

# חלק ז — מבנה דוח ביקורת

לכל commit משמעותי — דוח מספרי ב:
`app_flutter/knowledge/inspections/INSP-NNNN-[תיאור].md`

```markdown
# INSP-NNNN — [כותרת]

**תאריך:** YYYY-MM-DD
**שלב:** [FND/FRM/WIR/VRB/OPS]
**diff-scope:** [קבצים שהשתנו]

## ממצאים

| מזהה | תיאור | חומרה | סטטוס |
|---|---|---|---|
| [ID] | [מה נמצא] | CRITICAL/MAJOR/MINOR | FIXED/ACCEPTED/⛔ |

## בדיקת-לולאה
[3 דוחות אחרונים — האם finding-ID חוזר?]

## VERDICT: GO / NO-GO
```

**דוחות הם בלתי-ניתנים-לשינוי.** תיקון → דוח חדש, לא עריכת הישן.

---

# חלק ח — Helper-First Discipline

**כל לוגיקה שאפשר לבדוק → helper טהור לפני UI.**

## התבנית:

```dart
// lib/logic/[domain]_helper.dart
/// [שם] — [מה עושה בשורה אחת]
/// מקור: proto [L####]
[ReturnType] helperName(params) {
  // logic בלבד — אין BuildContext, אין ref, אין side-effects
}
```

```dart
// test/[domain]_helper_test.dart
void main() {
  group('[שם helper]', () {
    test('[תנאי גבול 1]', () {
      expect(helperName(input), expected);
    });
    test('[תנאי גבול 2]', () { ... });
  });
}
```

## דוגמאות מחייבות (תנאי-גבול לבדיקה):

| helper | תנאי-גבול |
|---|---|
| `currentRank(orders)` | 0, 2, 3, 7, 8, 14, 15 הזמנות |
| `orderTransition(order, action, role)` | כל 6×5 = 30 צירופי מצב×role |
| `buildGovXml(order)` | מבנה XML תקין, DocumentType=305 |
| `rentalCost(tool, days)` | 0 ימים, 1 יום, שבוע, חודש |
| `kpiSnapshot(orders)` | רשימה ריקה, הזמנה אחת, N הזמנות |

## Regression gate

`regression_gate_test` סורק את `test/` לשמות helpers; helper ציבורי בקוד השימוש
(מ-`catalog_screen.dart` / `lipskey_product_sheet.dart`) שאין לו test → fail.
הוסף helper חדש → הוסף שמו ל-`_kRequiredHelpers` ב-`regression_gate_test.dart`.

---

# חלק ט — Verbatim Discipline (R6/R8)

## שיטת-עבודה:

```bash
# לפני כל מחרוזת עברית חדשה:
grep -n "המחרוזת" /home/user/buildsmart/index.html
# → מחזיר [L#]? → להשתמש verbatim + לרשום בתגובה
# → לא מחזיר? → לא להוסיף (R8)
```

## כשלים נפוצים (מ-INSP-0006):

```dart
// ❌ שגוי — סדר מילים שונה
'ברירת מחדל — משלוח אקספרס'
// ✅ נכון — verbatim מ-L6842
'מצב ניגודיות גבוהה (לשמש)'

// ❌ אסור — emoji שונה
'📋 ניהול אתר'
// ✅ נכון — verbatim מהמקור
'🏗️ ניהול אתר'
```

---

# חלק י — State Machine Discipline

כל state machine (הזמנות / משימות / persona transitions) חייב:

### 1. הגדרה מפורשת (enum + sealed class):
```dart
enum OrderStage { newOrder, confirmed, picked, shipped, delivered, closed }

class OrderTransitionResult {
  final OrderStage next;
  final String? error; // null = הצליח
}
```

### 2. פונקציית-מעבר טהורה:
```dart
OrderTransitionResult transition(Order order, OrderAction action, UserRole role) {
  // pure — אין side-effects, אין BuildContext
}
```

### 3. Unit test לכל תא בטבלה (מקור: proto [L#]):
```dart
test('store can confirm new order', () {
  final result = transition(mockOrder(OrderStage.newOrder), OrderAction.confirm, UserRole.store);
  expect(result.next, OrderStage.confirmed);
  expect(result.error, isNull);
});
test('courier cannot confirm new order', () {
  final result = transition(mockOrder(OrderStage.newOrder), OrderAction.confirm, UserRole.courier);
  expect(result.error, isNotNull);
});
```

---

# חלק יא — WIRING.md — חוזה חי

כל שורה ב-WIRING.md היא **חוזה שהבדיקות מאמתות**:

```markdown
| כפתור/הגדרה | התנהגות | מקור [L#] | Status |
|---|---|---|---|
| currentRank dial leaf | מציג דרגה נוכחית | [L6499] | ✅ |
| orderTransition confirm | store → new→confirmed | [L11970] | ✅ |
| buildGovXml export | XML מבנה 1.31 | [L19298] | 🚧 |
| AI hub — 9 tools | — | [L21123] | ⛔ |
```

**כלל:** הוספת שורה ל-WIRING.md **= התחייבות לבדיקה** ב-`wiring_test.dart`.
אם אין בדיקה — status = 🚧 (לא ✅).

**⛔ ב-WIRING.md:** חייבת לרשום **מה החסמה** (backend/geo/מחירים/telephony).

---

# חלק יב — סדר-הבנייה הנכון

```
data model / enum
    ↓
helper טהור
    ↓
unit test לhelper
    ↓
Riverpod provider (אם נדרש)
    ↓
dial widget (UI)
    ↓
smoke test (widget נפתח + עלים מוצגים)
    ↓
trigger (FAB / tile)
    ↓
WIRING.md מעודכן
    ↓
OPS checklist → flutter analyze + test
    ↓
commit
```

**לעולם לא להפוך את הסדר.** UI לפני helper = bug שמחכה.

---

# חלק יג — מה ש-⛔ הוא ⛔

```dart
// ✅ נכון — ⛔ ביושר
DialLeaf(
  label: '📊 מחשבון ROI', // [L19487] verbatim
  onTap: () => showInfoSnack(context, '⛔ דורש נתוני עלויות מהשרת'),
)

// ❌ אסור — toast "בבנייה" מסתיר חוב
DialLeaf(
  label: '📊 מחשבון ROI',
  onTap: () => showToast('בבנייה'), // ← לא מודיע שיש חסמה אמיתית
)
```

---

# חלק יד — Versioning

```yaml
# pubspec.yaml
version: X.Y.Z+N
# X = major (שינוי ארכיטקטורה)
# Y = minor (פיצ׳ר חדש)
# Z = patch (תיקון / tweaks)
# N = build number (מונוטוני)
```

- כל commit שמוסיף feature = bump Y.
- כל commit שמתקן באג = bump Z.
- לא לדלג על bump — הגרסה היא החתימה של כל שלב ב-ROADMAP.
- `home_shell.dart` ו-`knowledge/STATUS.md` חייבים להיות **זהים** (`knowledge_protocol_test`).

---

# חלק טו — ADR (Architecture Decision Records)

נדרש ADR כשיש:
- שינוי / הוספת כלל R1–R9
- pattern שסותר את האלטרנטיבה הברורה
- החלטה טכנית עמוקה
- **הפרה ידועה ומקובלת** (exception עם נימוק)

```markdown
# ADR-NNN — [כותרת]
**Status:** Accepted / Superseded by ADR-XXX
**Date:** YYYY-MM-DD
**Related:** R[N], `file.dart:line`

## Context / Decision / Rationale / Alternatives rejected / Consequences / Verification
```

ADRs קיימים: `adr/001-no-window.md`, `adr/002-dial-pattern.md`.

---

# חלק טז — PLAYBOOK: מצב עבודה ו-Cadence

## מצב-עבודה: NO STOPPING

- צעד שנראה "חסום" **אינו** עצור — נסה עשרות גישות שונות: stubs מקומיים, נתונים סינתטיים,
  heuristics, ספריות חלופיות, placeholders, workarounds, re-framings.
- הצהר על "קיר" רק כשהוא **באמת בלתי-עביר** (שרת חיצוני, חומרת מכשיר, third-party בתשלום).
- כשמגיעים לקיר — תעד + המשך לדבר הבא.

## Cadence

| פעולה | תדירות |
|---|---|
| Full test suite | כל ~5 שלבים (ground truth לפני כל checkpoint) |
| Local commit | כל ~20 operations ומעלה (אחרי 0/0 נקי) |
| Live demo | כל ~10 operations ומעלה (web server port 8090) |

"operation" = פעולת build משמעותית (helper מחובר, UI block, תיקון) — לא לחיצת מקש.

---

# חלק יז — PLAYBOOK: Git על ענף מהיר

## Push נקי כשהענף זז תחתיך

```bash
# שלב 1: commit קוד הפיצ׳ר בלבד (ללא bump גרסה)
# שלב 2:
git fetch
comm -12 <(git diff --name-only $BASE @{u}|sort) <(git diff --name-only $BASE HEAD|sort)
git -c core.editor=true rebase origin/<branch>
# שלב 3: bump גרסה בcommit נפרד אחרי rebase
# שלב 4:
git push
git rev-list --left-right --count HEAD...@{u}  # → 0 0
```

## כשהחפיפה היחידה היא שורת-גרסה — `-X theirs`

```bash
# בדוק שהשינוי remote הוא רק שורת גרסה:
git diff $BASE @{u} -- home_shell.dart
# אם נכון:
git -c core.editor=true rebase -X theirs origin/<branch>
# ואז: analyze + full suite לפני push
```

`-X theirs` בrebase = "העדף את ה-commits שמשוחזרים (שלי)".
**אל תשתמש בזה עיוורות כשיש overlap של לוגיקה אמיתית.**

## Version label drift

```bash
# bump שניהם באותו commit:
home_shell.dart + knowledge/STATUS.md
# בהתנגשות: לך גבוה יותר (מונוטוני)
```

## כשה-session האחר מגרה את שכבת-הנתונים

אחרי rebase שנגע בקובץ משותף:
```bash
git diff <base> origin/<branch> -- <file>
```
ואז יישר לrequester canonical החדש. `kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]`
הוא source of truth — `kLipskeyCatalog` לבדו מצומצם.

## אמות של rebase

```bash
git merge-base --is-ancestor <my-commit> origin/<branch>
# confirms my commit is in the cloud history (nothing lost)
```

---

# חלק יח — PLAYBOOK: Dart / Test Pitfalls

## `Set == {literal}` הוא identity, לא value

```dart
// ❌ תמיד שקר
kVerifiedSpecs[sku]?.endSystems == {WaterSystem.drainage}
// ✅ נכון
s.endSystems.length == 1 && s.endSystems.contains(WaterSystem.drainage)
```

## שם קובץ test חייב להיות singular

`_test.dart` (singular) — `*_tests.dart` (plural) נדלג בשקט ע"י `flutter test`.
**אחרי הוספת test file — אמת שהcount עלה** בfull suite.

## Mutation tests: אסור לאמת `count > 0`

```dart
// ❌ שגוי — נכשל כשאין נתונים (valid)
expect(checked, greaterThan(0));
// ✅ נכון — vacuously true על נתונים ריקים; boundary tests נמצאים בtest ייעודי
// הtest יעבור על כל sample שנמצא ויאמת invariant
```

## `grep -c` מחזיר exit 1 על 0 תוצאות

```bash
# ❌ שורשר את &&
grep -c X file && echo next
# ✅ נכון
grep -c X file || true
```

## Stale assertions אחרי refactor

כשמשנה widget gesture mechanism → grep tests לסוג הישן:
```bash
grep -rn 'InkWell' test/product_sheet_strips_test.dart
```

---

# חלק יט — PLAYBOOK: Engine / Domain Insights

## `plan.items` הוא BOM, לא flow sequence

items הם deduped (first-appearance) — לא adjacency פיזי.
לשאלות adjacency: `findShortestPath(a, b)`, לא `plan.items`.

## Fitting↔fitting בלי pipe = missing component

`materializeChain` מכניס pipe בין שני fittings, coupling בין שני pipes.
pipe↔fitting = ישיר (לא צריך הכנסה).

## Drainage ≠ supply לcompliance

`lineIsSupply(items)` (via `endSystems`) מגן על שסתומים לא להיכנס לקו ניקוז.

## בדוק data distribution לפני הרחבת כלל

```bash
# לפני שמרחיב גלבאני לברז+פלדה — בדוק:
grep -c 'steel' lib/data/lipskey_verified_connections.dart
```
הרחבה שנדחתה: brass↔steel רגרסה (steel PRV ליד ברז = דיאלקטרי שגוי).

## ΔP לא כולל side branches

`_kOffLineSkus` (sampling/air-vent/expansion-tank) לא חלק מהflow הראשי.

## Synthetic specs לא דולפים לcarousel

`materializeChain` רושם `PIPE-*` ל-`kVerifiedSpecs`, אבל `compatibleProductsFor`
מסנן על `kLipskeyCatalog` → synthetic SKUs לא מופיעים בcarousel.

---

# חלק כ — PLAYBOOK: Refactor / Deletion Safety

## Build "alongside" ללא נגיעה במקור

```dart
// בנה על helpers ציבוריים של card A בלבד:
// engineeringSpecFor / compatibleProductsFor / connectionExplainHe / ...
// אמת שA לא השתנה:
git diff --quiet <A-file>
```

## מחיקת class block

```bash
# בדוק boundaries לפני:
awk '/^class _X /{skip=1} /^<keep-marker>/{skip=0} !skip{print}' file.dart
```
אסור לסמוך על line numbers — classes לא תמיד רציפות.

## מחיקת widget

1. הסר render site יחיד
2. הסר class(es)
3. הסר helpers שרק הוא שמש (`grep -rn`)
4. `flutter analyze` (0 errors)
5. full suite

---

# חלק כא — PLAYBOOK: Persistence (Flutter)

## Pattern להimplementation:

```dart
// mirror: lib/state/product_favorites.dart
class MyStateNotifier extends StateNotifier<Set<String>> {
  MyStateNotifier() : super({}) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bs.<feature>.v1') ?? [];
    state = Set.from(list);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bs.<feature>.v1', state.toList());
  }

  void toggle(String key) {
    state = {...state}..add(key);
    _persist();
  }
}
```

## Test pattern:

```dart
test('persists across restart', () async {
  SharedPreferences.setMockInitialValues({});
  final n1 = MyStateNotifier();
  n1.toggle('x');
  final n2 = MyStateNotifier();
  await Future.delayed(Duration.zero); // allow _load()
  expect(n2.state, contains('x'));
});
```

## Key migration

כשמעלה key ל-`.v2` — שמור `.v1` לreleases אחד כדי שusers ישנים לא יאבדו נתונים.

---

# חלק כב — PLAYBOOK: UI / Flutter-web Automation

## Canvas taps לא אמינים

Flutter web מרנדר לcanvas אחד; קואורדינטות מחטיאות.
- מתגים וchips קרובים לראש ה-sheet = אמינים יותר.
- `showDialog` buttons = הכי לא אמינים.
- **Prefer code verification** (tests + grep) כground truth.

## A11y tree ריק בFlutter web

הdisability tree לא exposed ב-default. Enable accessibility manually לפי צורך.

## אסטרטגיה לdemo

```bash
# Start web server
flutter run -d web-server --web-port 8090 --web-hostname 127.0.0.1
# Wait:
until grep -q "is being served at" /tmp/fweb.log; do sleep 3; done
```

---

# חלק כג — PLAYBOOK: Synthetic Catalog Products

מוצרים שאין בקטלוג האמיתי (hot-water gear, cut-to-length pipes):

```dart
// בונה ב-lipskey_hotwater.dart::_hw(...)
final p = LipskeyCatalogProduct(
  sku: 'HW-PUMP-40',
  nameHe: 'משאבה 40 ליטר', // productType → "משאבה" via kLipskeyTypes
  // ...
);
// רושם spec:
kVerifiedSpecs.putIfAbsent('HW-PUMP-40', () => VerifiedSpec(...));
// לא מופיע בcarousel — שמסנן על kLipskeyCatalog
```

---

# חלק כד — Sub-Agent Patterns (AGENT_PATTERNS)

## TL;DR

- **Disjoint NEW files only** — כל agent כותב ל-paths חדשים שאף agent אחר לא נוגע.
- **Absolute paths** — harness מאפס cwd בין Bash calls; relative paths לא עובדים.
- **Max 3 concurrent** — ה-ceiling המוכח לפני 529.
- **No `isolation: "worktree"`** — ייכשל בharness הזה (cwd לא git root).

## Pre-flight checklist לפני כל batch:

- [ ] `git ls-files` / `ls` — אמת שכל deliverable הוא **path חדש**
- [ ] כל agent briefed עם absolute paths לrepo
- [ ] כלול verbatim: *"ADD only — never modify existing files. No git commit or push."*
- [ ] כלול 10-step decomposition + `_test.dart` (singular) naming
- [ ] point לmirror reference file לconsistency
- [ ] Cap 3 agents בcall אחד
- [ ] אחרי batch: `flutter analyze` + full suite + **אמת שcount עלה**

## Fallback chain:

1. **Concurrent (3 agents)** — default כשAPI responsive + disjoint files
2. **Serial (agent אחד בפעם)** — first response ל-529
3. **Supervisor-direct (`Write` + `Bash`)** — אם single-agent גם 529; יש לך context מלא

## כשלים נפוצים:

- **Agent כותב לcwd הלא נכון** → Include בkick-off: *"Step 1: run `pwd && ls`. If NOT inside the project path, STOP and report."*
- **Agent מקבץ content** → אם write נדחה — אל תנסה "elsewhere"; report denial ו-stop.
- **Supervisor**: אחרי agent return, `ls <absolute-path>` לאמת landing.
- **מעולם לא להעתיק doc של agent לproject ללא אימות** — שמות fabricated slip in.

## 529 clusters

אם 3-agent batch כולו 529 → **דלג על serial retry** → ישירות supervisor-direct.
Pattern: כש-capacity גלובלית נמוך, serial retry תגם כ-200s נוספות ותחזיר 529.

---

# חלק כה — Conventions (CONVENTIONS.md)

## Theme / colors (light mode — כל האפליקציה)

| Token | ערך | שימוש |
|---|---|---|
| scaffold/page bg | `0xFFF5F6FA` | רקע כל מסך |
| cards/sheets/appbar | `0xFFFFFFFF` | כרטיסים ו-sheets |
| primary text/ink | `0xFF1A1A1A` | טקסט ראשי |
| secondary/muted | `0xFF888888` / `black54` | טקסט משני |
| dividers | `0xFFEEEEEE` / `0xFFE5E5E5` | מפרידים |
| brand orange | `BsTokens.brand` (`0xFFFF7A18`) | כפתורים ראשיים |
| light-orange chip bg | `0xFFFFE8D6` | chips |

**⚠️ טקסט לבן מותר רק על surface צבעונית** (כפתור/badge brand/orange/green/red,
  או active selection pill). בכל מקום אחר — טקסט לבן = bug.
AppBars: `foregroundColor: 0xFF1A1A1A`.

## RTL

האפליקציה RTL. כל מחרוזות UI = עברית, מגובות בproduct/legacy.
Emoji מוצגים במכשיר/דפדפן — מוצגים כ-□ בscreenshots headless (לא bug).

## Settings sections

`ExpansionTile` headers: **count badge במקום chevron** (כתום, `_activeCount` = שורות פונקציונליות,
ללא placeholders). כשcount==0 — chevron נשאר.

## Commit / branch / version

- Branch `claude/whats-happening-LyY9G`; אין push ל-main ללא אישור.
- `pull --no-rebase` לפני push (sessions מקבילים).
- Bump גרסה ב-`home_shell.dart` על שינויים גלויים.
- **אסור לכלול model identifier בcommit messages, PR titles, code comments.**

---

# חלק כו — Architectural Decisions (DECISIONS.md)

## D-013 · Progressive dock UX (3-state)

Install Studio dock: State A (empty) = full-width CTA; State B (1 item) = glow;
State C (2+ items) = ghost+glow split. Loop toggle = רק כש-`tempC > 20`.

## D-012 · BOM quality upgrade — zero new SKUs

Upgrade engine + UI בלבד (constraint: אין SKUs חדשים):
1. TMTV auto-per-branch כש-`tempC ≥ 60` + manifold בtrunk.
2. Zone tagging — `InstallationPlan.zones: Map<String, List<String>>`.
3. Severity on LineCheck — `CheckSeverity {critical, warning, info}`.
4. Compliance checks — Legionella bypass / sampling port / balancing valve.
5. Auto-compliance — `_autoAddCompliance(items, qty, tempC)`.
6. Gap hints — `_gapHint(InstallationGap)`.
7. Temperature pill — color-coded by temp range.

## D-011 · Balance valve auto-add per branch with pump

כש-`HW-PUMP-40` בtrunk, `buildTreeInstallation` מוסיף `HW-BALANCE-20` לכל branch.

## D-010 · BOM zone headers in UI

`_zoneHeader(label, {count})` = cyan bar + Hebrew zone name + chip + divider.

## D-009 · `_NodeRow` colored dot

8px dot לפי `systemType` לפני numbered circle.

## D-008 · Knowledge protocol for Flutter

`app_flutter/knowledge/` הוקם כי `app/knowledge/` Inspector הוא Preact-only (frozen INSP-0044).
Flutter: code-first discipline: `WIRING.md` + `flutter test` + mutation testing.

## D-007 · 100% mutation coverage of domain logic

חולץ embedded logic לpure helpers וpinned equivalence mutant עם adversarial input.
50/50 mutation coverage.

## D-006 · Extract widget logic into pure helpers

VAT/checkout math, notification filter/grouping, payment/delivery mapping,
date-group detection, index tokenizer → lifted לpure functions. סגר 27 mutation gaps.

## D-005 · Wiring contract enforced by tests

WIRING.md + `gaps_test.dart` / `wiring_test.dart` evolve together.

## D-004 · Wire only what has data; mark the rest honestly

settings מחוברים לeffects רק כשdata/behavior קיים מקומית.
כל דבר שצריך prices/ratings/geo/notification engine/telephony/server = ⛔.

## D-003 · Full light-mode migration

כל מסך הומר מdark לlight (scaffold `0xFFF5F6FA`, dark ink).
Bug נפוץ: white text על white surface — נתקן בכל settings screens, store, notifications.

## D-002 · Real product grid + cart stepper

`viewMode`/`gridColumns` → grid card (image, name, "מחיר לפי ספק", `+ לעגלה` / `− qty +`).

## D-001 · Light-themed settings with count badges

Settings screens משתפים `_SectionTile` עם `ExpansionTile` + orange active-count badge.

---

# חלק כז — Data Schema (SCHEMA.md)

## שלושה עמודות קנוניות

### 1. `kCatalogProducts` — מה קיים

```dart
// lib/data/polyroll_catalog.dart
final List<LipskeyCatalogProduct> kCatalogProducts =
    [...kLipskeyCatalog, ...kPolyrollCatalog];
```

**source of truth יחיד** לאיזה מוצרים קיימים. Polyroll משתמש באותה class; `brand` מבדיל.

#### `LipskeyCatalogProduct` — שדות ליבה

| שדה | סוג | משמעות |
|---|---|---|
| `sku` | `String` | מק"ט ספק — המפתח הגלובלי. ייחודי ברשימה המאוחדת |
| `nameHe` / `nameEn` | `String` | שם תצוגה (עברית קנונית) |
| `brand` | `String` | `'ליפסקי'` או `'פולירול'` — בוחר `assets/<dir>/` |
| `categoryHe/En/Emoji` | `String` | קטגוריה — gate לconnector coverage |
| `page` | `int` | עמוד PDF; default asset = `assets/<dir>/pages/page_NN.jpg` |
| `dims` | `Map<String, dynamic>?` | ממדים גולמיים. source fallback ל-DN |
| `imageFile` / `specImageFile` / `specImageFiles` | `String?` / `List<String>?` | תמונת מוצר + diagrams |
| `productType` (getter) | `String?` | מgetter מ-`nameHe` via `kLipskeyTypes` |
| `connectionSizes` (getter) | `List<String>` | DN ends: override → name → dims → category default |
| `connectionGender` / `connectionMethod` | `String?` | name-parsed זכר/נקבה ותבריג/הדבקה |

#### Lookup

```dart
// O(1), works for both brands:
catalogProductForSku('217861')
// Memoised in related_info.dart (_skuIndex)
```

### 2. `kVerifiedSpecs` — מפרטים פיזיים

```dart
// lib/data/lipskey_verified_connections.dart
final Map<String, VerifiedSpec> kVerifiedSpecs = { '<sku>': VerifiedSpec(...), ... };
```

`compat_coverage_test`: כל catalog product עם `needsConnectionSpec(p)==true` חייב לקבל VerifiedSpec.
Synthetic specs (HW-*, PIPE-*) → `putIfAbsent` בruntime → לא מופיעים בcarousel.

#### `VerifiedSpec` — שדות

- `sku` — חייב להתאים ל-`LipskeyCatalogProduct.sku`.
- `ends: List<ConnectorEnd>` — ports פיזיים.
- `material` — `'HDPE'`, `'PEX'`, `'נחושת'`, `'פליז'`, `'PVC'`, `'PP'`, `'רב-שכבתי'`, etc.
- `pressureRating: String?` — `'PN16'`, `'PN10'`, etc.
- `maxTempC: double` — default `40` (HDPE cap).
- `systemOverride: WaterSystem?` — override כשgeometry מנוגד לתפקיד.

#### Enums

- `EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }`
  — `hdpeCompression` overloaded: כל push-fit/socket compression (HDPE/PEX/PVC/PP/etc.)
- `WaterSystem { supply, drainage }` — pressure supply vs gravity drainage.
- `ConnectorEnd(type, size)` — `directMatesWith`, `pipeSharedWith`, `system` getter.

### 3. `kSmartProducts` — SmartTree

```dart
// lib/data/smart_tree.dart
const List<SmartProduct> kSmartProducts = [ ... ];
```

~81 מוצרים curated (smart card each). SmartProduct = concept ("ברז לכיור") עם brand options ואביזרים.

#### `SmartProduct`

- `key` — stable id לstate (`cardSelectionProvider`, `stageProgressProvider`, ...).
- `brands: List<SmartBrand>` — אפשרויות SKU.
- `acc: List<SmartAcc>` — אביזרים מומלצים.
- `stages: List<SmartStage>` — שלבי התקנה עם `match[]` לcross-highlight accessories.

#### `SmartBrand` — **כאן יושב ה-SKU**

- `sku: String?` — הlink היחיד ל-`kCatalogProducts`. יכול להיות null.
- `rec: bool` — true בדיוק לaption מומלצת.
- `price: int?` — null = "מחיר לפי ספק".

### 4. Bridge — SKU הוא הFK היחיד

```dart
// Forward (catalog ← smart):
LipskeyCatalogProduct? catalogProductForSku(String? sku);
LipskeyCatalogProduct? catalogProductForBrand(SmartBrand brand);
LipskeyCatalogProduct? catalogProductForSmart(SmartProduct sp);

// Reverse (smart ← catalog):
SmartProduct? smartProductForSku(String sku);
```

Round-trip guard: `smartproduct_contract_test`.

### 5. Data Flow

```
SmartProduct sheet → catalogProductForBrand(b)
                   → _skuIndex[b.sku] (built once from kCatalogProducts)
                   → LipskeyCatalogProduct prod

                   ┌──────────────────────────────┐
                   │ kVerifiedSpecs[prod.sku]      │
                   │ priceFor(prod)                │
                   │ compatibleProductsFor(prod)   │
                   └──────────────────────────────┘
```

### 6. Invariants בבדיקות

- `compat_coverage_test` — כל connector product → VerifiedSpec.
- `smartproduct_contract_test` — כל SmartBrand.sku קיים בcatalog.
- `regression_gate_test` — כל curated helper ≥1 test file.

---

# חלק כח — Card Architecture (CATALOG-CARD-PROTOCOL)

## קבצי-ליבה

| קובץ | תפקיד |
|---|---|
| `lib/data/lipskey_catalog.dart` | מודל `LipskeyCatalogProduct` + getters |
| `lib/data/polyroll_catalog.dart` | קטלוג PPR + `kCatalogProducts` |
| `lib/screens/lipskey_products_screen.dart` | כרטיס חיצוני — chips (`AttrKind`, siblings) |
| `lib/screens/lipskey_product_sheet.dart` | כרטיס פנימי — 9 strips, interactive chips |
| `lib/data/related_info.dart` | כל הfunctions הנתוניות |
| `lib/logic/install_kit.dart` | `recommendedKitForProduct` |
| `lib/data/variant_families.dart` | `productCanonicalKey`, `variantValue`, `kindOf` |

## dims — המפתחות בשימוש (סדר = סדר תצוגה)

| מפתח | דוגמה |
|---|---|
| `שם מלא` | כותרת הכרטיס הפנימי |
| `תיאור` | כותרת הכרטיס החיצוני |
| `יצרן` / `מק"ט יצרן` | chip יצרן + טבלה |
| `PN` / `SDR` | שורה תחתונה + מפרט הנדסי |
| `חומר` | מפרט + chip חומר |
| `dn נומינלי` | חתימה + ריתוך + מפרט |
| `de/e/di` | טבלה + מפרט |
| `תקנים` | טבלה + תקינות |
| `לחץ עבודה (50 שנה)` | מפרט הנדסי |
| `אורך` | chip אורך אפור |

## הכרטיס החיצוני — `_ProductRow`

- **כותרת:** `dims['תיאור']` (לא `nameHe`).
- **chips (מ-`nameHe`):** כל מילה → `AttrKind`. **כתום** = siblings אמיתיים (פותח בורר); **אפור** = ערך יחיד.
  - `AttrKind = { size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }`.
  - `maker` = chip סינתטי מ-`dims['יצרן']`, לא מ-`nameHe`.
- **שורה תחתונה:** `brand · #sku · PN.. · SDR..`.

## מנגנון siblings (מה הופך chip לכתום)

- `findAttrSiblings` — בmותג (`kCatalogProducts` where `brand==kPolyrollBrand`) בתוך `_getCompoundType`.
- chip **כתום** רק אם ≥2 ערכים שונים.
- `maker` chip: `_makerSignature(p) = category|compoundType|nominalBore|PN|SDR`.
- chip אורך = אפור-תמיד (informative).

## הכרטיס הפנימי — `LipskeyProductSheet`

1. **`_FlipImage`:** מוצר ↔ מפרט (diagram חתוך).
2. **כותרת:** `dims['שם מלא'] ?? nameHe`. תת-כותרת = `nameEn`.
3. **`_InteractiveChips`:** `parsedName` + `variantValue`: `סוג · תת-סוג · גודל · צבע · אורך`.
   - גודל עטוף ב-LTR isolate כדי שלא יתהפך.
4. **רצועת 9 כרטיסים (`_StripKind`)** — מוצג רק אם function מחזיר content:

| כרטיס | gate |
|---|---|
| נמצא ב | `finderGroupFor` |
| מוצרים תואמים | `compatibleProductsCount` |
| ערכת התקנה | `installKitFor` + `recommendedKitForProduct` |
| דומים | `variantSiblingsCountFor` (מ-`kCatalogProducts`) |
| תקינות | `complianceTriggersFor` |
| מפרט הנדסי | `engineeringSpecFor` |
| מחיר משוער | `priceFor` |
| מידע כללי | `_buildInfo` (brand-gated) |
| חיטוי וניקוי | `_buildHygiene` (brand-gated) |

## להוספת brand חדש

הוסף **ענף `if (p.brand == '<מותג>')`** בכל function רלוונטית ב-related_info.dart.
`variantSiblingsCountFor`/`Of` → `kCatalogProducts` (לא `kLipskeyCatalog`).

## עיקרון-על R8 לכרטיסים

**אין המצאה.** כל טקסט/מספר בכרטיס — verbatim מהקטלוג.
אם לא מצאת בקטלוג — אל תכתוב. תחפש (טקסט + תמונות-עמודים), ורק אז תכתוב.

---

# חלק כט — SmartProduct Card Flow (CARD_FLOW)

סדר רנדור top-to-bottom בpump ה-SmartProduct card:

## Header & diagram

1. Sheet handle + product title + emoji + category
2. `_DiagramFlow` (renders `p.stages`) — stage chips עם pop-in animation
3. Explode chips — כשstage active, accessories שname מatches `p.stages[i].match`
4. Install progress tracker — `stageProgressProvider` (**Step 31**)

## Selectors

5. בחר מותג — collapsible brand list עם "🌡 מים חמים בלבד" filter (**Step 65**)
6. בחר סוג / בחר מידה — filters

## 📦 נתוני קטלוג

Header row: title · **score badge** · ☆ שמור · 📋 הצעה · מצב מורחב ▾

7. Score badge — `cardReadinessScore(prod)` (**Step 30**)
8. Save toggle ☆/★ — `savedConfigsProvider.toggle()` (**Step 47**)
9. Copy-quote 📋 — `Clipboard.setData(quoteTextFor(p, _selectedBrand))` (**Step 48+68**)
10. Mode toggle — `cardDetailModeProvider.toggle()` (**Step 95**)
11. One-line summary — `smartCardSummaryHe(p, brand)` (**Step 59**)
12. Discovery tags — `discoveryTagsFor(p, brand)` (**Step 67**)
13. System safety note — `systemSafetyNoteHe(prod)` (**Step 24**)
14. Physical-connection warning — `connectionWarningHe(prod)` (**Step 29**)
15. "בקו שלך" — `lineFitFor(prod, lineProducts)` + `adapterSuggestionFor` (**Steps 28+27**)
16. Hot-water suitability — `hotWaterSuitabilityFor(p)` (expert only) (**Step 26**)

### Spec rows (מ-`engineeringSpecFor(prod)`) — step 11

17. חומר · לחץ · טמפ׳ · מערכת · קצוות(expert) · קוטר(expert) · עמידות★(expert) ·
    מאתר(expert) · ערכת(expert) · התקנה(expert) · וריאנטים(expert) · יצרן(expert) · מחיר

### Price & line economics

18. Cheaper alternative — `cheaperAlternativeBrand(p, _selectedBrand)` (**Step 45**)
19. Line cost estimate — `lineCostEstimateFor(p, _selectedBrand)` (**Step 42**)

### Compat & engine

20. 🔗 מתחבר ל-N מוצרים — `compatibleProductsFor(prod)` (**Step 21**)
21. Frequently paired types (expert) — `frequentlyPairedTypesFor(prod)` (**Step 56**)
22. Inline chain — `buildInstallation` + `chainArrowText` (**Step 23**)
23. 🔧 בנה לי קו (BOM) button (**Step 22**)
24. 🛡 ערכת בטיחות (auto) — `safetyKitItems` (**Step 25**)
25. 🛒 + בטיחות לסל — `buildSafetyAccessories` (**Step 46**)

### Project actions

26. ➕ הוסף לפרויקט (**Step 71**)
27. ×3 חדרים (**Step 72**)
28. 🧩 תבניות — `projectTemplates()` (**Step 80**)
29. Project counter (**Step 74**)
30. 📋 BOM פרויקט מלא (**Step 74**)
31. 📋 הצעת מחיר לפרויקט (**Step 75**)

### Compliance & detail (expert)

32. תקינות נדרשת — `complianceTriggersFor(prod)` + `complianceWhyHe` (**Steps 19+58**)
33. מה הקו צריך — `connectionNeedsHe(prod)` (**Step 73**)
34. בדיקת קבלה — `acceptanceChecklistFor(prod)` (**Step 38**)
35. תקן ישראלי — `israeliStandardsFor(prod)` (**Step 12**)
36. כלי עבודה — `installToolsFor(prod)` (**Step 33**)
37. טעויות ותיפים — `installTipsFor(prod)` (**Step 35**)
38. גרסאות נוספות — `variantSiblingsOf(prod)` (**Step 63**)
39. 💾 שמור גרסה — `cardVersionsProvider.save(...)` (**Step 76**)
40. מתי לבחור איזה מותג — `brandDecisionGuide(p)` (**Step 16**)
41. נצפו לאחרונה — `recentlyViewedProvider.touch(sku)` (**Step 66**)

## Footer

42. פריטי חובה ⚡ — `p.acc.where((a)=>a.must)` checkboxes + qty
43. פריטים אופציונליים 💡 — `p.acc.where((a)=>!a.must)`
44. הוסף לסל ₪total

## Cross-cutting state

- `_selectedBrand` = `cardSelectionProvider` if prev saved, else `recBrand`.
- Recently-viewed touched once per card open (post-frame callback).
- Mode toggle + save toggle wrapped ב-`Semantics` (**Step 85**).

---

# חלק ל — Helper Index (HELPER_INDEX)

`lib/data/related_info.dart` — data-layer hub: ~45 public top-level helpers.

## טבלה אלפביתית

| שם | מחזיר | Step |
|---|---|---|
| `acceptanceChecklistFor` | `List<String>` | 38 |
| `adapterSuggestionFor` | `LipskeyCatalogProduct?` | 27 |
| `brandDecisionGuide` | `List<({String brand, String advice})>` | 16 |
| `brandSuitableForHot` | `bool` | 65 |
| `cardReadinessScore` | `({int score, String label})` | 30 |
| `catalogProductForBrand` | `LipskeyCatalogProduct?` | 3 |
| `catalogProductForSku` | `LipskeyCatalogProduct?` | 3 |
| `catalogProductForSmart` | `LipskeyCatalogProduct?` | 3 |
| `chainArrowText` | `String` | 23 |
| `chainEdgeLabelHe` | `String` | — |
| `cheaperAlternativeBrand` | `({String name, int price})?` | 45 |
| `compatibleProductsCount` | `int` | — |
| `compatibleProductsFor` | `List<LipskeyCatalogProduct>` | — |
| `complianceTriggersFor` | `List<({String label, String reason})>` | — |
| `complianceWhyHe` | `String?` | 58 |
| `connectionExplainHe` | `String` | — |
| `connectionJoint` | `({EndType type, String size})?` | — |
| `connectionNeedsHe` | `List<String>` | 73 |
| `connectionWarningHe` | `String?` | 29 |
| `deepLinkFor` | `String` | 68 |
| `discoveryTagsFor` | `List<String>` | 67 |
| `durabilityRatingFor` | `({int stars, String reason})?` | 15 |
| `engineeringSpecFor` | `({String material, …})?` | — |
| `finderGroupFor` | `({String emoji, String label})?` | — |
| `frequentlyPairedTypesFor` | `List<String>` | 56 |
| `gapAdviceHe` | `String` | — |
| `hotWaterSuitabilityFor` | `({int suitable, int total, int tempC})` | 26 |
| `installEffortFor` | `({int minutes, String difficulty})?` | 34 |
| `installKitFor` | `({int must, int optional, int tools})?` | — |
| `installTipsFor` | `List<String>` | 35 |
| `installToolsFor` | `List<String>` | 33 |
| `israeliStandardsFor` | `List<({String code, String scope})>` | 12 |
| `jointLabelHe` | `String` | — |
| `lineCostEstimateFor` | `({int product, int accessories, int labour, int total})?` | 42 |
| `lineFitFor` | `({int connects, List<String> names})` | 28 |
| `lineStructureText` | `String` | — |
| `manufacturerInfoFor` | `({String manufacturer, String partNumber})?` | 20 |
| `needsConnectionSpec` | `bool` | — |
| `priceFor` | `int?` | — |
| `quoteTextFor` | `String` | 48 |
| `safetyKitItems` | `List<LipskeyCatalogProduct>` | 25 |
| `smartCardSummaryHe` | `String` | 59 |
| `systemSafetyNoteHe` | `String?` | 24 |
| `variantSiblingsCountFor` | `int` | — |
| `variantSiblingsOf` | `List<LipskeyCatalogProduct>` | — |

## Regression gate list (`_kRequiredHelpers`)

`compatibleProductsFor`, `compatibleProductsCount`, `connectionExplainHe`,
`connectionJoint`, `jointLabelHe`, `chainEdgeLabelHe`, `connectionNeedsHe`,
`connectionWarningHe`, `lineFitFor`, `adapterSuggestionFor`, `safetyKitItems`,
`chainArrowText`, `engineeringSpecFor`, `cardReadinessScore`,
`durabilityRatingFor`, `discoveryTagsFor`, `frequentlyPairedTypesFor`,
`manufacturerInfoFor`, `finderGroupFor`, `israeliStandardsFor`,
`systemSafetyNoteHe`, `hotWaterSuitabilityFor`, `brandSuitableForHot`,
`installToolsFor`, `installTipsFor`, `installEffortFor`, `installKitFor`,
`acceptanceChecklistFor`, `priceFor`, `lineCostEstimateFor`,
`cheaperAlternativeBrand`, `quoteTextFor`, `deepLinkFor`, `smartCardSummaryHe`,
`complianceTriggersFor`, `complianceWhyHe`, `variantSiblingsOf`,
`variantSiblingsCountFor`, `brandDecisionGuide`, `catalogProductForBrand`,
`catalogProductForSku`, `catalogProductForSmart`.

לא בgate כרגע: `needsConnectionSpec`, `lineStructureText`, `gapAdviceHe`.

---

# חלק לא — State Files Inventory (STATE_OVERVIEW)

## מלאי (אלפביתי)

| קובץ | סוג | שומר? | מפתח | Step | מטרה |
|---|---|---|---|---|---|
| `ab_experiments.dart` | `Map<String, String>` | ✓ JSON | `bs.ab-experiments.v1` | 92 | A/B variant assignment |
| `analytics_log.dart` | `List<AnalyticsEvent>` | — memory | — | 91 | bounded analytics log |
| `app_settings.dart` | `AppSettings` record | ✓ Preact-shared | (legacy) | — | App settings (R1 R2 R6 contract) |
| `brand_history.dart` | `Map<key, Map<brand, int>>` | ✓ JSON | `bs.brand-history.v1` | 51 | brand-pick frequency |
| `card_detail_mode.dart` | enum `simple`/`expert` | ✓ string | `bs.card-detail-mode.v1` | 95 | card depth toggle |
| `card_projects.dart` | `List<ProjectItem>` | ✓ JSON | `bs.card-projects.v1` | 71 72 74 75 80 | project assignment |
| `card_selection.dart` | `Map<key, brandName>` | ✓ JSON | `bs.card-brand-selection.v1` | 7 | last brand per product |
| `card_versions.dart` | `List<ConfigVersion>` | ✓ JSON | `bs.card-versions.v1` | 76 | named snapshots |
| `cart_lists_state.dart` | `Map<id, CartList>` | ✓ JSON | (own key) | — | saved cart lists |
| `cart_safety.dart` | (pure helpers) | — | — | 46 | engine safety SKUs → SmartCartAcc |
| `catalog_settings.dart` | `CatalogSettings` | ✓ Preact-shared | (legacy) | — | view prefs |
| `chat_settings.dart` | `ChatSettings` | ✓ Preact-shared | (legacy) | — | chat settings |
| `comparison_set.dart` | `Set<String>` cap 4 | ✓ stringList | `bs.comparison-set.v1` | 76-adj | comparison queue |
| `crash_log.dart` | `List<CrashEntry>` | — memory | — | 90 | error log (not persisted) |
| `dial_state.dart` | enum `OpenDial` | — memory | — | R1 | which FAB dial open |
| `draft_quote.dart` | `List<DraftQuote>` | ✓ JSON | `bs.draft-quotes.v1` | 48-adj | quote text drafts |
| `feature_flags.dart` | `Set<String>` | ✓ stringList | `bs.feature-flags.v1` | 10 | enabled flag names |
| `hidden_catalog_sections.dart` | `Set<String>` | ✓ stringList | `bs.hidden-catalog-sections.v1` | — | hidden sections |
| `menu_state.dart` | per-tab drill lists | — memory | — | R1 | menu drill paths |
| `notif_settings.dart` | `NotifSettings` | ✓ Preact-shared | (legacy) | — | notifications settings |
| `offline_cache.dart` | `Map<key, CacheEntry>` | ✓ JSON | `bs.offline-cache.v1` | 83 | TTL'd cache |
| `product_favorites.dart` | `Set<String>` | ✓ stringList | (own key) | — | heart-toggled SKUs |
| `recent_searches.dart` | `List<String>` cap 8 | ✓ stringList | (own key) | 62 | recent queries |
| `recently_viewed.dart` | `List<String>` cap 20 | ✓ stringList | `bs.recently-viewed.v1` | 66 | recently opened SKUs |
| `saved_configs.dart` | `Set<String>` | ✓ stringList | `bs.saved-configs.v1` | 47 | favourite configs |
| `saved_projects.dart` | `List<SavedProject>` | ✓ JSON | (own key) | — | Install Studio plans |
| `smart_cart.dart` | `List<SmartCartLine>` | ✓ JSON | (own key) | — | smart-tree cart |
| `stage_progress.dart` | `Set<String>` | ✓ stringList | `bs.stage-progress.v1` | 31 | install stages done |
| `store_settings.dart` | `StoreSettings` | ✓ Preact-shared | (legacy) | — | store settings |

## Preact-shared files — ⚠️ לא לשנות

`app_settings` · `catalog_settings` · `chat_settings` · `notif_settings` · `store_settings`.
**נגיעה בהם = סיכון contract drift עם הpreact app (R6).**

## Template לstate files חדשים

Mirror: `card_selection.dart` / `recently_viewed.dart` — הformat הcanonical.

## Persistence keys index (כל `bs.*.v1` בשימוש)

`bs.ab-experiments.v1` · `bs.brand-history.v1` · `bs.card-brand-selection.v1` ·
`bs.card-detail-mode.v1` · `bs.card-projects.v1` · `bs.card-versions.v1` ·
`bs.comparison-set.v1` · `bs.draft-quotes.v1` · `bs.feature-flags.v1` ·
`bs.hidden-catalog-sections.v1` · `bs.offline-cache.v1` · `bs.recently-viewed.v1` ·
`bs.saved-configs.v1` · `bs.stage-progress.v1`

---

# חלק לב — Test Suite Map (TESTS_OVERVIEW)

**102 test files, 700+ tests.** Suite = ground truth לפני כל checkpoint.

## כלל naming: `_test.dart` (singular בלבד)

`*_tests.dart` (plural) = דלוג שקט ע"י `flutter test`. אמת שהcount עלה אחרי הוספה.

## 10 domains

### 1. SmartProduct card data & rendering

| קובץ | Step | מטרה |
|---|---|---|
| `smartproduct_contract_test.dart` | 5 | כל SmartBrand.sku → real catalog SKU |
| `smart_card_data_test.dart` | 81 | כל product × brand: summary/standards/tools/compat coherent |
| `product_journey_test.dart` | 81 | HARD end-to-end: 935 sheets × cart + checkout |
| `card_score_test.dart` | 30 | `cardReadinessScore` 0..100 + label |
| `card_detail_mode_test.dart` | 95 | persisted expert/simple toggle |
| `smart_card_strings_test.dart` | 86 | 28 labels non-empty, unique, grounded |
| `accessibility_test.dart` | 85 | 6 key actions expose `Semantics(button, label)` |
| `widget_test.dart` | — | boot smoke test |

### 2. Compat engine & coverage

`compat_50_samples_test` · `compat_coverage_test` · `compat_explain_test` ·
`connection_joint_test` · `chain_arrow_test` · `adapter_suggestion_test` ·
`paired_warning_test` · `line_fit_test` · `compat_brass_nipple_check`

### 3. Install / engine / studio

`engine_harness_test` · `install_builder_test` · `install_effort_test` ·
`install_kit_test` · `build_line_bom_test` · `safety_kit_test` ·
`acceptance_stage_test` · `pressure_drop_test` (+ `_advanced` / `_offline`) · `hard_tests`

### 4. Card helpers (pure data)

`core_helpers_test` · `brand_guide_test` · `brand_hot_filter_test` ·
`hot_water_suitability_test` · `durability_test` · `manufacturer_info_test` ·
`standards_tools_test` · `discovery_tags_test` · `compliance_why_test` ·
`summary_alt_test` · `line_cost_test`

### 5. Persisted state

Pattern: `SharedPreferences.setMockInitialValues({})`, mutate, fresh notifier, assert.

`card_selection_test` · `brand_history_test` · `card_versions_test` ·
`card_projects_test` · `recently_viewed_test` · `recent_searches_test` ·
`feature_flags_test` · `ab_experiments_test` · `quote_saved_test` ·
`offline_cache_test` · `persistence_roundtrip_test` · `crash_log_test` ·
`analytics_log_test`

### 6. Cart, projects & commerce

`cart_safety_test` · `cart_bulk_order_test` · `cart_stress_test` ·
`draft_quote_test` · `store_notif_widget_test` · `deep_link_test`

### 7. Mutation / regression gates

| קובץ | מטרה |
|---|---|
| `regression_gate_test.dart` | **META**: 47 helpers ≥1 test reference |
| `mutation_test.dart` | 6 invariants: price/selection/score/effort/kit/tag |
| `catalog_regression_test.dart` | catalog structural invariants |
| `knowledge_protocol_test.dart` | version label home_shell == STATUS.md |
| `dedup_test.dart` | no SKU duplicates |
| `no_duplicate_specs_test.dart` | kVerifiedSpecs no duplicates |

### 8. Audits, scans & catalog health

`audit40_test` · `deep_audit_test` · `full_compliance_audit_test` · `ten_scenarios_audit_test` ·
`catalog_bfs_test` · `bfs_demo_test` · `pathfinder_test` · `long_chain_test` · `loop_test` ·
`catalog_health_test` · `category_scan_test` · `coverage_scan_test` · `gaps_test` ·
`gap_advice_test` · `dn_pipe_gaps_test` · `find_all_four_test` · `alt_paths_test` ·
`auto_compliance_test` · `drainage_no_supply_test` · `temp_suitability_test` ·
`zone_tmtv_test` · `manifold_test` · `materialize_test` · `hidden_sections_test` ·
`connection_joint_test` · `ppr_infra_test` · `wiring_test` · `system_examples_test` ·
`comparison_set_test` · `chip_structure_test` · `line_structure_test` ·
`layer3_quality_test` · `twenty_products_test` · `spec_assets_test`

### 9. Cards: interactions, robustness & edge cases

`card_interactions_test` · `robustness_test` · `edge_cases_test` ·
`state_deep_test` · `product_sheet_strips_test`

### 10. Infra helpers (`test/helpers/`)

`dial_test_helper` · `wiring_contract_helper` · `state_machine_fixture` ·
`feature_isolation_test_base` · `isolation_validator` ·
`infra_extreme_test` · `infra_gap_test` · `infra_hard_test` · `infra_stress_test`

## הוספת helper חדש — איפה הtest שלו?

1. **Focused unit test** — `test/<my_helper>_test.dart` (singular!): empty, happy path, boundaries.
2. **Regression gate** — אם helper ציבורי בcard: הוסף שמו ל-`_kRequiredHelpers`.
3. **Persisted state?** Mirror `card_selection_test`.
4. **נוגע ב-`_SmartProductSheet` rendering?** הסתמך על `product_journey_test` + `smart_card_data_test`.
5. **אמת שהcount עלה.**

---

# חלק לג — Projects Guide (PROJECTS_GUIDE)

## מה זה "projects" בcard

`ProjectItem = (project, location, product, brand, sku, qty)` — persisted across launches.
**נפרד** מ-`smartCart` (working cart). Cart = short-lived; Project = long-lived planning.
Key: `bs.card-projects.v1`.

## 5 features ש-shipped (Phase 8)

### Step 71 · הוסף לפרויקט

`CardProjectsNotifier.add(ProjectItem)` → `projectItemsAfterAdd` (merges by id, sums qty).

### Step 72 · ×3 חדרים

`addToLocations(template, List<String> locations)` → fan-out. Calling twice → bumps qty (לא double-insert).

### Step 74 · counter + BOM dialog

Counter: `totalUnits` + `projects`. BOM: resolves every `ProjectItem.sku` → `catalogProductForSku` →
`buildInstallation(autoCompliance:true, 60°C)` → dialog.

### Step 75 · הצעת מחיר

`projectQuoteText(project, items)` → Hebrew plain-text with total + "נוצר ב-BuildSmart".
Unit prices: `priceFor` (null prices = zero, no throws).

### Step 80 · Templates

`_kProjectTemplates` = אמבטיה סטנדרטית + מטבח סטנדרטי.
`projectTemplates()` → resolves keywords → exactly one `SmartProduct` per keyword (first match).
`applyTemplate(project, location, products)` → inserts at `recBrand`.

## ה-id formula (frozen interface)

```dart
'$project|$location|$productKey|$brandName'
```

לא לשנות — שובר dedupe בcross sessions. רוצה field חדש? → key `.v2` + migration.

## ⬜ Wall-blocked

| Step | Capability | Wall |
|---|---|---|
| 77 | Team sharing | needs backend + auth + sync |
| 78 | Gantt/tasks sync | needs project-management API |
| 79 | Unified procurement PDF | needs `pdf` + `printing` packages |

## Pattern להוספת project feature

1. Extend `ProjectItem` רק אם צריך persisted field (rare).
2. Method ב-`CardProjectsNotifier` → delegate לpure helper → `_persist()`.
3. Test first: `test/card_projects_test.dart` + SharedPreferences mock.
4. Wire בcard. אסור לגעת ב-`catalog_screen.dart` בparallel run — sequence עם supervisor.
5. Mark ✅ ב-ROADMAP + bump version + local commit.

---

# חלק לד — SmartProduct Roadmap Handoff

## מצב נוכחי (~46%: 32 ✅ + 14 🟦)

**Group A — buildable locally, do next:**
76 config-versioning · 25 auto safety-kit · 46 add-whole-line-to-cart ·
74 full project BOM dialog · 89 regression-gate meta-test · 82 mutation tests ·
85 accessibility (Semantics) · 57 profession-aware depth.

**Group B — finish 🟦 partials:**
2, 7, 9, 15, 20, 24, 26, 29, 30, 48, 56, 65, 68.

**Group C — needs infra/pkg/backend (user decision):**
13, 17, 18, 32, 36, 37, 39, 40, 41, 43, 44, 49, 50, 53, 54, 55, 60, 69, 70, 79, 83, 84, 86, 88, 90, 91, 92, 93, 94, 96, 97, 98.

**Group D — risky/shared/big refactor:**
1 (merge sheets — user said don't touch catalog card), 10 (A/B flag),
61 (search index), 64 (modal→tab nav), 99/100 (meta).

**Cadence reminder:** full suite ~5 steps · local commit ~20 ops · demo ~10 ops · **no push w/o approval**.

**חשוב:** Prototype (`/index.html`) **לא מכיל** features אלה (רק base leaves).
SmartProduct "brain" הוא Flutter-only evolution; content מgounded ב-`kSmartProducts`/`kCatalogProducts`.
רק UI labels חדשים.

---

# חלק לה — Bundle Split Strategy (BUNDLE_SPLIT)

## Top-10 קבצים לפי גודל

| קובץ | שורות |
|---|---|
| `lib/screens/catalog_screen.dart` | 7668 |
| `lib/data/lipskey_catalog.dart` | 6822 |
| `lib/screens/install_studio_screen.dart` | 3184 |
| `lib/screens/store_screen.dart` | 2993 |
| `lib/screens/lipskey_product_sheet.dart` | 2890 |
| `lib/data/smart_tree.dart` | 2343 |
| `lib/screens/lipskey_products_screen.dart` | 1822 |
| `lib/data/lipskey_verified_connections.dart` | 1727 |
| `lib/logic/install_engine.dart` | 1390 |
| `lib/screens/chats_screen.dart` | 1436 |

_SmartProductSheet_ (`catalog_screen.dart` lines 4325-6102) = ~1777 lines — loaded ב-first paint למרות שנפתח רק אחרי tap.

## אסטרטגיה (cheapest-first)

| Step | תיאור | Effort | Risk | Impact |
|---|---|---|---|---|
| 1 | Extract `_SmartProductSheet` → `lib/screens/smart_product_sheet.dart` | S | low | none* |
| 2 | Defer install engine (`deferred as`) | S | low | medium |
| 3 | Defer verified-spec map | M | med | medium |
| 5 | Defer secondary tab screens | M | low | high |
| 4 | Per-category catalog code-split | L | med | high |

\* Step 1 = prerequisite לstep 2, bundle-neutral בפני עצמו.

## מדידה

```bash
flutter build web --release --analyze-size
# → build/web/analyze-size.json + stdout summary
```

Target: **25-40% reduction** לinitial main.dart.js אחרי steps 1-3+5.

---

# חלק לו — Coach Mode Vision (COACH_MODE)

## Step 99 — Vision

Coach mode = הcard מלמד את המשתמש תוך כדי. **אין לcreate data חדש** — כל coach line
היא function call על helper שכבר shipped.

## Just-in-time hints

| Context | Hint |
|---|---|
| פתח card | `smartCardSummaryHe` — one-liner |
| בחר brand | `complianceWhyHe` — first trigger reason |
| צופה בstages | `installTipsFor` — one tip per stage |
| לפני הוספה לסל | `connectionWarningHe` — אם אין direct mate |
| סימן stage done | `acceptanceChecklistFor` — next check |
| עומד לעזוב | אם `safetyKitItems` לא בסל — interrupt |
| pair בסל | `connectionNeedsHe` — מה חסר |

## Next-best-action priority queue

| Context | CTA |
|---|---|
| `lineFitFor.matches == 0` + adapter exists | "🔌 הוסף מתאם מומלץ" |
| `lineFitFor.matches > 0` + no warning | "🛒 + בטיחות לסל" |
| `safetyKitItems` non-empty, missing from cart | "🛡 הוסף ערכת בטיחות" |
| Stages < 100% | "✅ סמן שלב הבא" |
| All resolved | "📋 צור הצעת מחיר" |

## Progressive disclosure

- Simple + coach: coachmark bubble אחת בפעם, ללא vocabulary טכני.
- Expert + coach: bubbles inline כannotations.
- Coach off: התנהגות של היום.

## מה חסר לcoach mode מלא

| Dependency | Gap |
|---|---|
| TTS / read-aloud | step 40 — needs TTS package + permissions |
| In-card AI assistant | step 53 — needs LLM endpoint |
| Camera barcode | step 55 — needs permissions + barcode library |
| AR overlay | step 36 — ARCore/ARKit, not available in Flutter web |
| Profession-aware (3-way) | step 57 — step 95 = 2-way only |

Coach mode כtext-only (in-card) יכול לship כבר עם helpers הנוכחיים.
Voice/AR/Camera = upgrades ל-delivery channel, לא לknowledge.

## Step 100 — The Convergence

| Sub-claim | Status |
|---|---|
| **what** | ✅ `smartCardSummaryHe`, `engineeringSpecFor`, `manufacturerInfoFor`, `israeliStandardsFor` |
| **why** | ✅ `complianceTriggersFor` + `complianceWhyHe` |
| **connects** | ✅ `compatibleProductsFor`, `connectionExplainHe`, `adapterSuggestionFor`, `lineFitFor` |
| **install** | 🟦 tools/effort/tips/checklist/safety — חסר: video(32), AR(36), exploded view(37), PDF(39), voice(40) |
| **cost** | ✅ `priceFor`, `lineCostEstimateFor`, `cheaperAlternativeBrand` |
| **supplier** | ⬜ stock/ETA(17), multi-supplier(41), distance(44), order/payment(50) — כולם backend |

---

# חלק לז — פקודות-ריצה סטנדרטיות

```bash
export PATH="/home/user/flutter/bin:$PATH"
cd /home/user/buildsmart/app_flutter

# OPS לפני כל commit
flutter analyze                    # OPS-01: אפס issues
flutter test                       # OPS-03: אפס failures
flutter build web --release        # OPS-02: build נקי

# VRB — אימות מחרוזת
grep -n "המחרוזת" /home/user/buildsmart/index.html

# FND-07 — הרצת test ספציפי
flutter test test/[domain]_helper_test.dart -v

# web server לdemo
flutter run -d web-server --web-port 8090 --web-hostname 127.0.0.1

# PATH issue:
export PATH="$PATH:/home/user/flutter/bin:/home/user/flutter/bin/cache/dart-sdk/bin"

# git clean-push (מerge conflicts בשורת גרסה בלבד):
git -c core.editor=true rebase -X theirs origin/claude/whats-happening-LyY9G
# אז: flutter analyze + flutter test → push
```

---

> **זכור: הפרוטוקול הזה הוא תוצר של 43+ ביקורות ו-3 רברטים.**
> **כל כלל עלה ביוקר. לא לדלג. לא לקצר. לא ל"תיקון מהיר" לפני gate.**
