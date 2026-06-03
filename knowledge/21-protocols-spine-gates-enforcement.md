# עולם-הפרוטוקולים (1) — השדרה · 116 השערים · 4 שכבות-האכיפה
> ⚠️ **פרוטוקול-R בוטל (הוראת-משתמש, 2026-06).** אזכורי R1–R9 להלן = תיעוד-היסטורי בלבד, לא חוק פעיל.

> **עולם בפני עצמו.** מנגנון-הממשל של פרויקט ה-**Flutter** (`app_flutter/`, ענף `whats-happening`) — ~3,100 שורות אכיפה + ~5,200 שורות מסמכי-פרוטוקול. נלכד מ-`app_flutter/knowledge/` + `.githooks/` + `.github/workflows/` + `scripts/` + `.claude/hooks/`.
> ⚠️ **מקביל-אך-נפרד** מה-Inspector של Preact/legacy (דוח 18, FND/FRM/WIR/FIN/OPS + 43 INSP). לכל פרויקט שכבת-אכיפה משלו.

## A. למה הפרוטוקול קיים
ציטוט-יסוד: **"הכשלים באו מחוסר-תהליך, לא מחוסר-ידע."** 3 ריברטים מתועדים — קוד שעבר typecheck+tests אך **הפר כלל-עיצוב ב-runtime**. הדוקטרינה: **הפרת-חוק נתפסת רק ב-checklist אנושי, לא בקומפיילר.** 2 פרויקטים מקבילים: `app_flutter/` (פעיל לפיתוח) · `app/` (Preact, frozen, bug-fix). ענף-עבודה יחיד: `claude/whats-happening-LyY9G`.

## B. `MASTER_PROTOCOL.md` (1,628ש׳) = החוק

### שכבת-הכללים הממוספרת — **בוטלה**
> ⚠️ שכבת-הכללים הממוספרת של MASTER_PROTOCOL **בוטלה** (הוראת-משתמש, 2026-06). **סגנון-הבנייה היחיד = האפליקציה הסופית עצמה** (`app_flutter/`, v5.96) — מסכים + bottom-sheets + dials כפי שהם בקוד.
> מה שנשאר **פעיל** מהדוח הזה: שערי-האכיפה (Group A–D למטה) · 4 שכבות-האכיפה · scripts/CI. שאר המסמך = תיעוד-תהליך (לא חוקי-עיצוב).

### Build-loop (10 צעדים, לפני כל עבודה משמעותית)
דרישה+acceptance → מקורות-נתונים → בדיקת-חפיפת-דפוס → design → **כתיבת-בדיקות-תחילה (RED)** → מימוש (GREEN) → `flutter analyze`=0 → wiring (RTL-safe) → suite כל ~5 צעדים → ROADMAP+version+commit-מקומי (בלי push).

### 5 שלבי-Checklist (רק שלבים שה-diff נגע בהם; OPS תמיד אחרון)
- **FND** (יסודות, 8): analyze=0 (CRIT) · אין-SKU-כפול (CRIT) · provider ב-providers.dart · StateNotifier עם initial-state · LS-key `bs.{thing}.v{N}` · helper-טהור→test (CRIT) · אין-לוגיקה-ב-build().
- **FRM** (מסגרת, 9 = R1–R5+R7): כמפורט בטבלה.
- **WIR** (חיווט, 7): אין `ref.watch` ב-callback · אין-mutation-ב-build · **אינווריאנט עגלה `cartCount==Σqty`** (CRIT) · button חדש→WIRING.md · state-machine→test · אין-`Future.delayed`-להמתנה (השתמש `ref.listen`).
- **VRB** (verbatim, 5 = R6/R8 — ההפרה הנפוצה ביותר): ציטוט-`[L#]` · אין-שינוי-סדר-מילים · אין-פיצ׳ר-מומצא · emoji-verbatim · חדש-ב-app→מועתק-ל-app_flutter.
- **OPS** (always-last, 7): `flutter analyze`=0 (CRIT) · `build web --release` (CRIT) · `flutter test` ≤ known-failing (CRIT) · version-bump · WIRING-update · commit מצטט `@rule/@legacy/@adr` · **loop-check OPS-07** (אותו finding לא ב-2/3 דוחות אחרונים).

### מנגנונים נוספים ב-MASTER
- **stuck-loop P-01:** אותו finding-ID ב-2 מתוך 3 דוחות → **STOP** · `VERDICT: NO-GO (stuck-loop)` · לשאול את הבעלים (לא ניסיון-3).
- **דוחות-INSP** ב-`inspections/INSP-NNNN-*.md` (immutable — תיקון=דוח-חדש).
- **helper-first** (כל לוגיקה→helper-טהור+test לפני UI; regression_gate: כל helper-ציבורי חייב ≥1 test) · **build-order inviolable** (data→helper→test→provider→UI→smoke→trigger→WIRING→OPS→commit).
- **⛔ כן-משמעותי:** leaf חסום מציג snackbar עם **הסיבה** (backend/geo/pricing), **לא** toast "בבנייה" שמסתיר חוב.
- **push: literal-word-only** (ראה דוח 22 §PLAYBOOK).

## C. `GATE_REGISTRY.md` = מספור עד 116 (הבא=117) · **~66 שערים פעילים ב-pre-commit**
> סמכות-המספור — מונע התנגשות. כל שער חדש נרשם כאן + ב-`.githooks/pre-commit`.
> ✅ **אומת-עצמי מול `.githooks/pre-commit`:** המספר הגבוה ביותר = **116** (תואם "הבא=117"). אבל בפועל **66 שערים נפרדים פעילים** (78 call-sites של `err "N"`); מספרים חסרים בטווח 1–116 = **שערים שפרשו או הועברו** (למשל שער 34 build-web→pre-push · שער 59 version disabled→auto). כלומר "116" = תקרת-המספור, לא ספירת-הפעילים.

- **Group A — יסודות (1–20):** ענף · 11 קבצי-knowledge קיימים · WIRING.md · pubspec · hooks-קיימים · GitHub-Actions · **11/12 version.g.dart קיים+מסונכרן ל-STATUS** · hooksPath=.githooks.
- **Group B — בטיחות-קוד (24–80):** 24 WIRING-update · 25 shared-state-frozen · **31 analyze=0 · 32 test-baseline · 33 build-web** (CRIT) · 41 אין-`greaterThan(0)` · 42 helper→test · 46 אין-dark-surface(0xFF111111) · 48 אין-print · 52/53 אין-secrets/.env · **59 version (disabled→auto)** · 62/63/65 RTL · 64 אין-emoji-לא-מהלגאסי · 70 gitignore-secrets · 73 LS-key-format · 74 אין-manual-ProviderContainer · 78 אין-binaries · 86 SKU-unique · 88 MASTER-edit-guard · 89/90 אין-מחיקת-test/state.
- **Group C — שלמות-Hooks (81–100):** 81 hook-synced(.githooks↔.git/hooks) · 83 hooksPath · 94 knowledge_protocol_test · 99 4-שכבות-קיימות · 100 summary.
- **Group D — ידע-ופרוטוקול (101–116):** 101 stuck_log קיים · **102 retry→stuck_log-entry-חדש** · **103 אנטי-דפוסים-לא-חוזרים** · 104 stuck_regression-מתעדכן · 107/116 UI→visual_log · 108 CARRY_FORWARD · 111 ANTIPATTERN-count=test-count · 112 stubs-deprecated · **114 `kLipskeyCatalog` אסור ב-screens/state/logic** (השתמש `kCatalogProducts`) · 115 hot-file-claims (advisory).

## D. `PROTOCOL_ENFORCEMENT.md` (154ש׳) = 4 שכבות-אכיפה
1. **Git-hooks** (`.githooks/`): `pre-commit` (925ש׳ ✓אומת — **~66 שערים פעילים** מתוך מספור-עד-116, **tiered**: docs-only=5ש׳ / קוד=3–5דק׳) · `commit-msg` (≥15 תווים, חוסם wip/test/asdf/tmp) · `pre-push` (חוסם main ללא `.allow_push_main` · חוסם force-push · `flutter build web` fast-gate).
2. **Claude-hooks** (`.claude/hooks/`): `pre-tool.sh` (186ש׳ — חוסם 10 וקטורי-עקיפה: `--no-verify` · `-c core.hooksPath=` · force-push · rm/mv/find-delete על hooks · edit על protected-paths) · `session-start.sh` (70ש׳ — משחזר hooksPath + `gen_version` + סיכום-פרוטוקול).
3. **Auto-restoration** (`session-start.sh` בכל פתיחת-סשן).
4. **GitHub-Actions** (`protocol-enforce.yml`, 8 שערים — לא-ניתן-לעקיפה-מקומית) + branch-protection ב-GitHub-UI.

**עקיפה-מאושרת (מתועדת):** `.allow_protocol_edit` (TTL 24ש׳, 30+ תווים) · `.emergency_token`/`BUILDSMART_EMERGENCY_DISABLE` (16+ תווים) · `.allow_master_protocol_edit` · `.allow_push_main`. **כולם ב-`.gitignore` + gate-blocked.** audit→`.git/protocol_audit.log` · retry-detection→`.git/stuck_fingerprints.txt` (fingerprint=sha256-של-שמות-staged + `head=$SHA`, חלון-5-שעות).

## E. Scripts (האכיפה בקוד)
- **`catalog_qa.py` (623ש׳):** מנוע-QA לקטלוג — **100+ כללים** (ERROR=block / WARN / INFO). parse-Dart paren-balanced. commands: `audit [--json]` · `selftest` (מוכיח שכל כלל יורה) · `fix [--apply]` (נרמול-שמות) · `export csv` · `truthcheck` (מול `source_truth.json`) · `crosscheck PDF` (OCR↔קטלוג) · `pdfmap`/`verify`. **תקרת-WARN ≤80** (סף-חוב). schema: `product.schema.json` (sku/nameHe/categoryHe חובה; brands enum).
- **`mutation_test.py` + `mutation_hard_test.py`:** 40 מוטציות מוזרקות ל-helpers — מוכיח שכל מוטציה **נתפסת** (אחרת ה-suite חלול).
- **`gen_version.sh` (37ש׳):** מייצר `lib/version.g.dart` (gitignored) מ-`git rev-list --count` + `STATUS.md` + short-SHA. **idempotent, פותר את conflict-magnet** (לקח #72). נקרא ב-hook + 4 workflows + session-start.
- **`new_feature.sh` (113ש׳):** scaffold עם isolation (model/helper/widget/test, "ADD-only").
- **`preflight.sh` (102ש׳):** בדיקות-מהירות (30ש׳, בלי Flutter) לפני commit.

## F. CI Workflows (4)
- **`android-package.yml`** — build APK+AAB (Flutter 3.44, Java 17, keystore-from-secrets-או-debug) + analyze+test gates.
- **`catalog-qa.yml`** — `catalog_qa.py selftest+audit` (WARN≤80) + analyze + catalog-regression.
- **`deploy.yml`** — **שתי האפליקציות** ל-gh-pages: Preact→`/buildsmart/` · Flutter-web→`/buildsmart/flutter/`.
- **`protocol-enforce.yml`** — 8 שערים (analyze · test · build-web · version-sync · אין-dark · hooks-intact · claude-settings · android-build), על **כל** הענפים.

---
**שורה תחתונה:** ~3,100 שורות אכיפה · **מספור-שערים עד 116** (תקרת-GATE_REGISTRY; ~66 פעילים ב-pre-commit + 8 CI + ~8 pre-push-checks + 1 commit-msg — אומת-עצמי) · 100+ כללי-קטלוג · כל-עוקף-חסום-ומבוקר. זו מכונת-הממשל; דוח 22 = עולם-הסוכנים, ה-PLAYBOOK, סולם-הבדיקות, וה-protocols הייעודיים.
