# עולם-הפרוטוקולים (2) — 6 הסוכנים · PLAYBOOK · סולם-הבדיקות · הפרוטוקולים-הייעודיים
> ⚠️ **פרוטוקול-R בוטל (הוראת-משתמש, 2026-06).** אזכורי R1–R9 להלן = תיעוד-היסטורי בלבד, לא חוק פעיל.

> המשך דוח 21. עולם-העבודה האנושי/רב-סוכני של פרויקט ה-Flutter + סולם-הוולידציה + ~10 הפרוטוקולים-הייעודיים + הלוגים. נלכד מ-`app_flutter/knowledge/`.

## A. מערכת 6 הסוכנים (ענף-משותף `whats-happening`)
| סוכן | תפקיד | בעלות (עורך) | אסור |
|---|---|---|---|
| **פרוטוקוליסט** | בונה/מתקן פרוטוקולים | `.githooks/` · `knowledge/` · `test/` | feature-code · UI · data |
| **קטלגן** | קטלוגים | `lib/data/` · `assets/` | פרוטוקולים |
| **סדרן** | עריכה-ויזואלית/מבנה | `lib/ui/` · `lib/widgets/` | פרוטוקולים |
| **מקבץ** | פיצ׳רים חדשים | `lib/features/` · `lib/screens/` | פרוטוקולים |
| **בנצי** | הכנה-להשקה | audit + `LAUNCH_PACKAGE/` | refactor רחב · נ-וויגציה · מחיקה · פרוטוקולים |
| **ליטוש** | ליטוש-UI + ניקוי-knowledge (Phase K) | presentation · `theme/` · `POLISH_LOG`/`KNOWLEDGE_AUDIT` | data · מחיקת-מסמך-ללא-verdict · app/knowledge |

**תיאום:** אסינכרוני דרך קבצים (`AGENT_COORDINATION.md` + `STATUS.md`), **אין צ׳אט-חי**, **המשתמש הוא ה-relay** להחלטות בין-סוכנים. **hot-file-claims** (gate 115 advisory, TTL) לפני עריכת-קובץ-חם. **append-only logs** (stuck_log/mutation_log/POLISH_LOG — keep-both בקונפליקט). **push-sync:** fetch+rebase (לעולם לא `reset --hard` אם ahead>0 — לקח #63) → `cp` hook → push. **קונסנזוס = סימולציית-6-פרסונות** (לא הצבעה), GO סופי מהמשתמש.

## B. PLAYBOOK (נהלי-עבודה)
- **NO-STOPPING:** ממשיכים לבנות/לאמת/לעשות commit מקומי בלי לעצור. מכריזים **WALL** רק כשבאמת חסום (אחרי ~50 ניסיונות) → טבלה (🔴 חומה / ⚪ סיכון / 🟢 אפשרי) + שואלים את המשתמש.
- ⭐ **push = מילה-מילולית בלבד:** `git push` דורש **מילה literal** `תדחוף`/`push`/`approved`/`deploy` ב-**הודעה הנוכחית**. "תמשיך"/"continue"/"תעדכן"/"תראה" **אינם** מאשרים. כל push דורש אישור-משלו. שער-מכני (אפס-שיקול-דעת → אין-drift). interpretation-creep מתועד כאנטי-דפוס.
- **cadence:** suite-מלא כל ~5 צעדים · commit-מקומי באצווה ~20 פעולות · live-demo כל ~10.
- **sub-agents:** עד 3 concurrent · **new-files-only** (disjoint, "ADD-only") · absolute-paths · `_test.dart` (יחיד) · בלי worktree-isolation · fallback (concurrent→serial→supervisor-direct ב-529).
- **hook-bug-loop:** סוכן מדווח על gate false-positive → פרוטוקוליסט מתקן תוך 24ש׳ (`.allow_protocol_edit` + לקח) — **לעולם לא** `--no-verify`.

## C. `VERIFICATION_PROTOCOL.md` — סולם-הבדיקות L0–L7 (מאחד TESTING/CHECKLISTS/BUG_INVESTIGATION)
| רמה | שכבה | תנאי-מעבר |
|---|---|---|
| L0 | static | `flutter analyze`=0 + `dart format` |
| L1 | regression | `flutter test` (129 קבצים / 10 תחומים) ≤ `known_failing.txt` |
| L1c | wiring-contract | כל שורת-WIRING.md → test (`wiring_test`/`gaps_test`) |
| L2 | in-app-harness | `runRegression(ref)` (פאנל-מנהל) ירוק |
| **L3** | **mutation** (לוגיקה — חובה) | red→fix→green (כל שינוי נתפס) |
| L3g | stuck-regression | אנטי-דפוס-חדש = test-חדש |
| L4 | build | `build web --release` |
| **L5** | **visual** (UI) | before/after screenshot ב-`POLISH_LOG` |
| **L6** | **knowledge** (docs) | verdict 4-שדות + `knowledge_protocol_test` |
| L7 | hooks | commit-msg → pre-commit → pre-push |
| L7a | gate-audits | micro-inject — כל שער חוסם באג-מכוון |

- **mutation method:** `scripts/mutation_verify.sh` (backup+restore, **לעולם לא** `git checkout`).
- **bug-investigation 100-צעדים (A–G):** אין-פתרון-לפני-צעד-55 (100% אבחון, לקח #39) · אין-suite-מלא-לפני-86 (isolation) · נכשל-פעמיים→pivot (לקח #37).

## D. session-planning · CARRY_FORWARD · KNOWLEDGE_AUDIT · COACH
- **`SESSION_PLAN_TEMPLATE` (10 חלקים):** Owner+Scope+Style · rules · P-table · solution-shape · **100-צעדים phases A–G** (recon/tests-first/utility/wire/integration+visual/harness+docs/ship-on-hold) · sub-protocols · audit-log · live-log (LL-NN) · closeout · carry-forward. שערים 21/22/106.
- **`CARRY_FORWARD.md` = 74 לקחים** (top-10: fetch-first · `preflight`-חוסך-13דק׳ · re-fetch-לפני-commit · `kCatalogProducts`-לא-`kLipskeyCatalog` · `flutter test`-אחרי-type-change · קובץ-knowledge-חדש=שורת-README · register-gate-לפני-הוספה · contact-sheet-לפני-"done" · פרוטוקוליסט=hooks-only · parallel=new-files-only). שער 110 (לקח-חדש אחרי כל sub-protocol).
- **`KNOWLEDGE_AUDIT.md`:** 76 מסמכים, **Phase-K verdict-first** (4 שדות: למה-נכתב/תפקיד-היום/רלוונטי?/למה) — index-gap תוקן (27→0 יתומים), 3 deprecated-stubs (TESTING/CHECKLISTS/BUG_INVESTIGATION) + 1 deprecate-pending (PROTOCOL.md) + 0 מחיקות.
- **`COACH_MODE.md` (roadmap 99–100):** הכרטיס כמורה (JIT pedagogy) — גרסת-טקסט שמישה כבר היום מ-helpers קיימים; voice/AR/camera = שדרוגי-ערוץ-מסירה, לא ידע.

## E. הפרוטוקולים-הייעודיים
- **`stuck_log.md` (1,220ש׳ ✓אומת) = רישום-אנטי-דפוסים** (**65 רשומות · 52 `ANTIPATTERN:`-regex → 64 בדיקות `stuck_regression_test.dart` auto-gen**; gate-111 שומר count==count · נאכף ב-gate-103. "48" היה ספירה ישנה). פורמט: בעיה/פתרון/`ANTIPATTERN:<regex>`/`RULE:`. אנטי-דפוסים מרכזיים: emoji-grep-ב-hook→bash-builtin · baseline-phantom (known-failing בלי-שמות) · retry-fingerprint+`head=$SHA` · `echo|grep`-non-determinism · `grep -c||echo 0` · `git diff file`-exit-0 · CRLF-Windows · letter-size-ambiguity · switch-fall-through · `kLipskeyCatalog`-ריק-ל-Huliot/PPR. כל `ANTIPATTERN` → `stuck_regression_test.dart` (auto-gen).
- **`SIZE_FILTER_PROTOCOL.md` (545ש׳):** P1–P17 — מיון-נומרי · family-aware · התאמה-מבנית (לא substring) · זוויות=ציר-נפרד · cross-dim=union · pretty-inch-fold · dedup-by-mm · bidi-LTR-isolate. `_size_norm.dart` (`SizeFamily`/`SizeToken`).
- **`CATALOG-CARD-PROTOCOL.md` (1,143ש׳):** כרטיס-מוצר 9 פאנלים (gate 64) · **2 מערכות-chip** (Lipskey-חיצוני vs smart-tree — אסור-לערבב) · brand-wiring-recipe · golden-test-traps · workflow-חילוץ-PDF.
- **`CATALOG_PROTOCOL.md` (root, 243ש׳):** 5 חוקי-ברזל (נקי≠נכון · אין-המצאה · SKU-קדוש · הכל→regression · אותו-פרוטוקול-בקנה-מידה) · היררכיית-4-קבצים · 2 שכבות-QA (syntactic+semantic) · `catalog_qa.py`.
- **`LAUNCH_READINESS_PROTOCOL.md` (231ש׳):** audit 100-צעדים (orientation→architecture→cleanup→tests→performance→a11y/i18n/RTL→platform→security→go/no-go) · P0/P1/P2 · → `LAUNCH_PACKAGE/SEND_TO_GOOGLE.md`.
- **`POLISH_PROTOCOL.md` (319ש׳):** ליטוש-UI (capture→plan→polish, phases B–K) + Phase-K ניקוי-knowledge (verdict-first). safe (token-binding) vs needs-approval (token-value/refactor).
- **`IMPROVEMENTS_PROTOCOL.md` (231ש׳):** I1–I10 שיפורי-finder.

## F. DECISIONS · CONVENTIONS · לוגים
- **`DECISIONS.md` = 15 ADRs (D-001..D-015):** light-theme+count-badges · real-grid+cart-stepper · light-migration · wire-only-real(⛔) · wiring-contract · pure-helpers · 100%-mutation · **knowledge-protocol(Flutter)** · colored-dot · zone-headers · balance-valve · BOM-quality(0-new-SKU) · progressive-dock · generated≠gitignored · proposal-lifecycle.
- **`CONVENTIONS.md`:** light-only (`#F5F6FA`) · white-text-only-on-colored · RTL-verbatim · ExpansionTile-count-badge · **`kCatalogProducts`** (לא kLipskeyCatalog) · ירושת-R1/R2/R6/R8 מ-app/RULES · `pull --no-rebase`.
- **`mutation_log.md` (317ש׳):** 48 פונקציות נבדקו-במוטציה. **`POLISH_LOG.md`:** לוג-סשן (before/after). **`PROPOSAL_version_friction.md` (403ש׳):** תיקון-ה-gen_version (P0/P1/P2) → D-014/D-015.

---
**שורה תחתונה:** עולם-הפרוטוקולים = **6 סוכנים** (אומת ✓) + **PLAYBOOK** (NO-STOPPING + push-מילולי) + **סולם L0–L7** + **~10 פרוטוקולים-ייעודיים** + **15 ADRs** (D-001..D-015 ב-`DECISIONS.md` ✓) + **~74 לקחי-CARRY_FORWARD** + **52 אנטי-דפוסי-regex (65 רשומות)** — כולם נאכפים דרך מספור-שערים-עד-116 (דוח 21). **הלולאה:** בעיה → stuck_log (ANTIPATTERN+RULE) → regression-אוטומטי → הסוכן-הבא נחסם → אין-חזרה.
