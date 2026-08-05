# POLISH-BRIEF — משימות מוכנות לסוכן ליטוש

> **לסוכן ליטוש** (presentation + Phase B–K). בצע **בתוך `POLISH_PROTOCOL`** שלך: before→after→gate · **token-binding = safe** (אפס שינוי ויזואלי) · L5 visual-screenshot ל-`POLISH_LOG`.
> ⚠️ **אל תיגע בקבצים-בתעופה של הקבלן** (`home_shell.dart` + מסכי-T1–T9 ש-מקבץ בונה כעת — PLAYBOOK no-collision). עבוד רק על הקבצים-הבטוחים המסומנים.
> אומת מהקוד 2026-06-09 (tip `536486d`). **עדכון-סטטוס:** P-4 ✅ · P-3 ✅ · **P-2 (a11y) ✅** (Semantics בכל-המסכים) · P-1 🔲 (~1,200 — מטרה-נעה) · P-5 🔲. **הצי בגלי-ליטוש+UX:** theme · a11y · **floating-cart (#47)** · async-race guards · honesty (#29–#55).

---

## P-4 · הסרת `go_router` — ✅ **בוצע** (אומת 2026-06-05: 0 `go_router` ב-pubspec)
🎯 [✅ בוצע] היה dependency-מת `go_router ^14.6` ב-`pubspec.yaml` (0 שימושים) → **הוסר.**
- צעדים-שבוצעו: grep=0 → הוסר מ-`pubspec.yaml` → pub get → analyze+test ירוק.
- ✅ DoD: pubspec בלי go_router · 0 imports · test ירוק.

## P-3 · typography pass — ✅ **בוצע** (אומת: `toast.dart`+`chain_diagram.dart` משתמשים ב-`BsTokens.font*`)
🎯 font-sizes קסם → `BsTokens`. (מסומן כבר ב-`POLISH_LOG` Backlog.)
- קבצים-בטוחים: `widgets/toast.dart` (14) · `widgets/chain_diagram.dart` (8/9/22).
- צעד: הוסף tokens (`BsTokens.fontXs/Sm/...` אם אין) → החלף. **token-equal** = אפס שינוי ויזואלי.
- ✅ DoD: 0 font-size קסם בקבצים אלה · screenshot before/after זהה.

## P-2 · a11y / Semantics — ✅ **בוצע** (06-09: Semantics/Tooltip בכל-המסכים · high-contrast · Dynamic-Type · screen-reader · RTL)
🎯 פער-נגישות: רק **3 קבצים** ב-lib עם `Semantics`.
- קבצים-בטוחים: `widgets/dial.dart` (`DialRow` → `Semantics(button:true, label:...)`) · כפתורי-AppBar · `widgets/toast.dart`.
- touch-targets ≥44×44 · `Semantics` לאלמנטים-אינטראקטיביים.
- ✅ DoD: אלמנטים-אינטראקטיביים מרכזיים עם Semantics · אין רגרסיה ויזואלית.

## P-5 · ניקוי-knowledge (Phase K — תחומך הבלעדי) — ⏱️ ~2ש'
🎯 סגירת מחיקת-פרוטוקול-R + audit.
- ודא 0 שאריות-R (`grep -rnE "\bR[1-9]\b" knowledge/` = רק Cloudflare-R2/RBAC/RTL).
- `KNOWLEDGE_AUDIT.md` verdict-pass (4-שדות) למסמכים החדשים (PLAN-*, 24-governance).
- ✅ DoD: 0 R-שיורי · audit-verdict לכל מסמך-חדש.

## P-1 · צבעים-קשיחים → `BsTokens` (הכי-בעל-ערך, גדול — לפצל) — ⏱️ ~יום+
🎯 **1,187 `Color(0x` קשיחים** ב-lib → `BsTokens` (07-08 — *גדל* 1,028→1,115→1,187; **מטרה-נעה:** פיצ'רים-חדשים מוסיפים צבעים מהר-יותר-מהטוקניזציה. "גמור" ידרוש הקפאת-פיצ'רים). **token-binding = safe.**
- **גל-1 (בטוח, התחל פה):** `theme/` · `widgets/` · מסכים-יציבים (`install_studio_screen` · 4 מסכי-settings · `departments_screen`).
- **גל-2 (מאוחר):** מסכי-הקבלן (`home_shell` + T1–T9) — **רק אחרי** ש-מקבץ סוגר אותם (אחרת התנגשות).
- צעד: צבע-קשיח → token קיים ב-`BsTokens`; אם חסר token — הצע ב-`POLISH_LOG` (needs-approval), אל תמציא ערך.
- ✅ DoD: 0 `Color(0x` בקבצי-גל-1 · screenshot זהה · גוף-2 חסום עד שהקבלן יציב.

---

## סדר-ביצוע מומלץ
**P-4** (נקי, 30 דק') → **P-3** (typography) → **P-2** (a11y) → **P-5** (knowledge) → **P-1 גל-1** (צבעים יציבים). P-1 גל-2 = אחרי שלב-א של הקבלן.

## מסגרת-עבודה (חובה)
- ענף `claude/whats-happening-LyY9G` · `git fetch` לפני התחלה · push רק על מילה מפורשת.
- כל שינוי: before/after ל-`POLISH_LOG` · gate L5 · `analyze`=0 + `test` ירוק.
- **safe** (token-binding) = ללא-אישור · **token-value/refactor** = needs-approval (הצע, אל תבצע).
