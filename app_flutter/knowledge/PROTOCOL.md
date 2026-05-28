# PROTOCOL — פרוטוקול בנייה מתקדם (Flutter)

> **מסמך-חוק.** כל commit לאפליקציית Flutter עובר דרך פרוטוקול זה — ללא יוצא מן הכלל.
> מבוסס על 43 ביקורות ו-3 רברטים מהפרויקט הקודם (Preact). כל כלל כאן נובע מכשלון
> ממשי שתועד. **PROTOCOL.md הוא ה-source of truth לתהליך; ROADMAP.md הוא ה-source of
> truth לתוכן.**

---

## עיקרון-הבסיס (למה צריך פרוטוקול)

> *"הכשלות לא הגיעו ממחסור בידע — הגיעו ממחסור בתהליך."*
> — לקח מ-INSP-0025, אחרי הרברט השלישי.

בלי פרוטוקול: קוד נכתב → נראה נכון → עובר לייצור → נמצאת הפרת R2 → revert → מתחילים מחדש.
עם פרוטוקול: הפרת R2 נתפסת **לפני** שהקוד אפילו נכתב, בשלב התרגום.

---

# חלק 1 — לפני שגורעים שורת קוד

## 1.1 · שאלת-הפתיחה החובה

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

## 1.2 · כלל R2 — תרגום חובה מהפרוטוטייפ

הפרוטוטייפ (`/index.html`) תמיד פותח **חלון מלא** (`position:fixed; inset:0`).
כל תרגום ל-Flutter חייב להיות **dial-drill** בלבד.

| פרוטוטייפ פתח... | Flutter מממש... |
|---|---|
| `renderBudget()` — מסך תקציב | dial עם 5 שורות קטגוריה + total leaf |
| `renderProjects()` — רשימת פרויקטים | dial-drill: פרויקט → sub-dial עם אתרים |
| `openFinanceHub()` — panel 10 כלים | dial-drill עם 10 עלים (כמו BS dial היום) |
| `renderSmartProject()` — timeline | dial עם משימות + status chip בכל עלה |
| persona dashboard מלא | ❌ אסור — dial-drill דרך BS tile בלבד |

**Flutter "FRM-02" (R2 — מקביל ל-Preact):** אסור להופיע בקוד חדש:
`showDialog` · `showModalBottomSheet` · `Navigator.push` (עמוד חדש) · `Scaffold` חדש · `Stack` עם `Positioned.fill` שמשמש כמסך. כל אחד מאלה = CRITICAL.

**היתרים קיימים (לא לשנות, לא להוסיף):**
- `LipskeyProductSheet` — גיליון מוצר (bottom sheet, קיים ומאושר)
- `InstallStudioScreen` — מסך install studio (קיים ומאושר, R2 exception)
- `RegressionPanelScreen` — panel בדיקות (קיים ומאושר)

---

# חלק 2 — לולאת-הבנייה (Build Loop)

לכל יחידת עבודה (פיצ׳ר / עלה / helper / תיקון-באג):

```
[1] READ    → קרא מקור [L#] + knowledge/port/
[2] PLAN    → כתוב תרגום-ל-dial (§1.1) + helper signature
[3] HELPER  → כתוב helper טהור (ללא UI) + unit test
[4] TEST    → flutter test → כל הבדיקות ירוקות
[5] WIDGET  → כתוב dial widget + smoke test (נפתח, עלים קיימים)
[6] WIRE    → חבר trigger + עדכן WIRING.md
[7] GATE    → הרץ checklist (חלק 3) — כל CRITICAL חייב לעבור
[8] COMMIT  → גרסה bump + commit עם @rule/@legacy/@adr
```

**אסור לדלג.** skip שלב [3] = helper ללא בדיקה = bug שמגיע אחר כך.
skip שלב [7] = commit ללא gate = revert שמגיע אחר כך.

---

# חלק 3 — Checklist (שלבי-ביקורת)

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
| FRM-02 (R2) | אין `showDialog`/`showModalBottomSheet`/`Navigator.push`/`Scaffold` חדש שלא היה | CRITICAL |
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
| VRB-02 (R6) | אין שינוי סדר מילים ממקור (דוגמה: `'ברירת מחדל — משלוח'` ≠ `'משלוח — ברירת מחדל'`) | CRITICAL |
| VRB-03 (R8) | אין מחרוזת/פיצ׳ר שלא קיים בפרוטוטייפ ב-Preact | CRITICAL |
| VRB-04 | emoji verbatim מהפרוטוטייפ — לא מוחלף/מוסר | MAJOR |
| VRB-05 | חדש ב-`app/` → מועתק verbatim ל-`app_flutter/` | MAJOR |

**שיטת אימות VRB-01:** לכל מחרוזת חדשה: `grep -n "המחרוזת" /home/user/buildsmart/index.html`.
אם לא נמצאת — לא להוסיף. אם נמצאת — לרשום [L#] בתגובה בקוד.

## OPS — אופרציות (תמיד מריץ, אחרון)

| מזהה | בדיקה | חומרה |
|---|---|---|
| OPS-01 | `flutter analyze` — `No issues found!` | CRITICAL |
| OPS-02 | `flutter build web --release` — מצליח | CRITICAL |
| OPS-03 | `flutter test` — 0 failures | CRITICAL |
| OPS-04 | גרסה bumped ב-`pubspec.yaml` (version: X.Y.Z+N) | MAJOR |
| OPS-05 | WIRING.md מעודכן לכל שינוי-התנהגות | MAJOR |
| OPS-06 | commit message מציין `@rule R2`/`@legacy L#`/`@adr ADR-NNN` כשרלוונטי | MINOR |
| OPS-07 | **בדיקת-לולאה:** אותו finding ID לא הופיע ב-2+ מ-3 הדוחות האחרונים | CRITICAL |

---

# חלק 4 — מנגנון לולאה-תקועה (Stuck-Loop P-01)

**הגדרה:** אם אותו finding (אותו ID שורש) הופיע ב-2 מתוך 3 ביקורות אחרונות:

1. **עצור** — אל תנסה תיקון שלישי.
2. **הצג:** `"⛔ לולאה-תקועה: [finding-ID] חוזר — נדרשת התערבות הבעלים."`
3. **אל תוסיף עוד ממצאים** — הדוח מסתיים כאן עם `VERDICT: NO-GO (stuck-loop)`.
4. **שאל את המשתמש** במפורש מה ה-approach הנכון.

**מה ש-P-01 מונע:** 3 ניסיונות לפתרון שגוי שכל אחד מהם גורם לרברט חדש.

---

# חלק 5 — מבנה דוח ביקורת

לכל commit משמעותי (פיצ׳ר חדש, שינוי-ארכיטקטורה) — דוח מספרי ב:
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

# חלק 6 — Helper-First Discipline

**כל לוגיקה שאפשר לבדוק → helper טהור לפני UI.**

### התבנית:

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
    // כל ערך-גבול מהפרוטוטייפ נבדק
  });
}
```

### דוגמאות מחייבות:

| helper | תנאי-גבול לבדיקה |
|---|---|
| `currentRank(orders)` | 0, 2, 3, 7, 8, 14, 15 הזמנות |
| `orderTransition(order, action, role)` | כל 6×5 = 30 צירופי מצב×role |
| `buildGovXml(order)` | מבנה XML תקין, DocumentType=305 |
| `rentalCost(tool, days)` | 0 ימים, 1 יום, שבוע, חודש |
| `kpiSnapshot(orders)` | רשימה ריקה, הזמנה אחת, N הזמנות |

---

# חלק 7 — Verbatim Discipline (R6/R8)

### שיטת-עבודה:

```bash
# לפני כתיבת כל מחרוזת עברית חדשה:
grep -n "המחרוזת" /home/user/buildsmart/index.html
# → מחזיר [L#]? → להשתמש verbatim + לרשום בתגובה
# → לא מחזיר? → לא להוסיף (R8)
```

### כשל נפוץ (מ-INSP-0006):
```dart
// ❌ שגוי — סדר מילים שונה
'ברירת מחדל — משלוח אקספרס'
// ✅ נכון — verbatim מ-L6842
'מצב ניגודיות גבוהה (לשמש)'
```

### emoji — verbatim תמיד:
```dart
// ❌ אסור — emoji שונה
'📋 ניהול אתר'
// ✅ נכון — verbatim מהמקור
'🏗️ ניהול אתר'
```

### כשנוסף string ב-`app/` (Preact):
חובה להעתיק verbatim ל-`app_flutter/` עם אותה שורה (CLAUDE.md כלל 3).

---

# חלק 8 — ADR (Architecture Decision Records)

נדרש ADR כשיש:
- שינוי / הוספת כלל R1–R9
- pattern שסותר את האלטרנטיבה הברורה (למה dial ולא drawer)
- החלטה טכנית עמוקה (למה Riverpod ולא BLoC)
- **הפרה ידועה ומקובלת** (יוצא-מן-הכלל עם נימוק) — לא לתקן

**תבנית:**
```markdown
# ADR-NNN — [כותרת]
**Status:** Accepted / Superseded by ADR-XXX
**Date:** YYYY-MM-DD
**Related:** R[N], `file.dart:line`

## Context
[למה נדרשת החלטה]

## Decision
[מה הוחלט — קונקרטי]

## Rationale
[למה זה, ולא האלטרנטיבה]

## Alternatives rejected
[מה נדחה ולמה]

## Consequences
- ✅ [יתרון]
- ⚠️ [מגבלה]

## Verification
[איזה check ב-checklist מוודא]
```

**ADRs קיימים:** ראה `adr/001-no-window.md`, `adr/002-dial-pattern.md`.

---

# חלק 9 — State Machine Discipline

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

### 3. Unit test לכל תא בטבלה:
```dart
// מקור: proto SYS_ORDERS [L11970]
test('store can confirm new order', () {
  final result = transition(mockOrder(OrderStage.newOrder), OrderAction.confirm, UserRole.store);
  expect(result.next, OrderStage.confirmed);
  expect(result.error, isNull);
});
test('courier cannot confirm new order', () {
  final result = transition(mockOrder(OrderStage.newOrder), OrderAction.confirm, UserRole.courier);
  expect(result.error, isNotNull); // לא מורשה
});
```

---

# חלק 10 — WIRING.md — חוזה חי

כל שורה ב-WIRING.md היא **חוזה שהבדיקות מאמתות**:

```markdown
| כפתור/הגדרה | התנהגות | מקור [L#] | Status |
|---|---|---|---|
| currentRank dial leaf | מציג דרגה נוכחית לפי מספר הזמנות | [L6499] | ✅ |
| orderTransition confirm | store מאשר → new→confirmed | [L11970] | ✅ |
| buildGovXml export | מחזיר XML מבנה 1.31 | [L19298] | 🚧 |
| AI hub — 9 tools | — | [L21123] | ⛔ |
```

**כלל:** הוספת שורה ל-WIRING.md **= התחייבות לבדיקה** ב-`wiring_test.dart`.
אם אין בדיקה — status = 🚧 (לא ✅).

---

# חלק 11 — סדר-הבנייה הנכון (מה לפני מה)

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

# חלק 12 — מה ש-⛔ הוא ⛔

כשפיצ׳ר תלוי-backend / תלוי-נתון שאין לנו:

```dart
// ✅ נכון — ⛔ ביושר
DialLeaf(
  label: '📊 מחשבון ROI', // [L19487] verbatim
  onTap: () => showInfoSnack(context, '⛔ דורש נתוני עלויות מהשרת'),
)
```

```dart
// ❌ אסור — toast "בבנייה" מסתיר חוב
DialLeaf(
  label: '📊 מחשבון ROI',
  onTap: () => showToast('בבנייה'), // ← לא מודיע שיש חסמה אמיתית
)
```

**ב-WIRING.md:** שורה עם ⛔ חייבת לרשום **מה החסמה** (backend/geo/מחירים/telephony).

---

# חלק 13 — כיצד מייצרים גרסה (Versioning)

```yaml
# pubspec.yaml
version: X.Y.Z+N
# X = major (שינוי ארכיטקטורה)
# Y = minor (פיצ׳ר חדש)
# Z = patch (תיקון / tweaks)
# N = build number (מונוטוני)
```

**כל commit שמוסיף feature = bump Y.**
**כל commit שמתקן באג = bump Z.**
**לא לדלג על bump — הגרסה היא החתימה של כל שלב ב-ROADMAP.**

---

# חלק 14 — מה נלמד מ-3 הרברטים (הסיכום הקונקרטי)

| רברט | סיבה | הכלל שנוסף |
|---|---|---|
| INSP-0016/0017 — `SitesView` + `ProfileView` | נבנו כ-`position:fixed; inset:0` views | FRM-02 CRITICAL |
| INSP-0022/0023 — persona dashboards | `AppView` enum + view-routing | FRM-02 + FRM-03 CRITICAL |
| INSP-0018 revert | `currentView` state ב-shell | לא `Navigator.push`, לא enum-view ב-shell |

**המכנה המשותף:** בכל 3 המקרים — קיים קוד שנראה הגיוני, עובר typecheck, ואפילו passes tests — ועדיין הפר R2. **R2 לא נתפס ע"י compiler. נתפס רק ע"י checklist.**

---

## נספח: פקודות-הריצה הסטנדרטיות

```bash
# OPS — לפני כל commit
export PATH="/home/user/flutter/bin:$PATH"
cd /home/user/buildsmart/app_flutter

flutter analyze                    # OPS-01: אפס issues
flutter test                       # OPS-03: אפס failures
flutter build web --release        # OPS-02: build נקי

# VRB — לאימות מחרוזת
grep -n "המחרוזת" /home/user/buildsmart/index.html

# FND-07 — הרצת בדיקה ספציפית
flutter test test/[domain]_helper_test.dart -v
```

---

> **זכור:** הפרוטוקול הזה הוא תוצר של 43 ביקורות ו-3 רברטים. כל כלל עלה ביוקר.
> לא לדלג. לא לקצר. לא ל"תיקון מהיר" לפני gate.
