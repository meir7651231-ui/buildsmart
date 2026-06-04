# POLISH-BRIEF — משימות מוכנות לסוכן ליטוש

> **לסוכן ליטוש** (presentation + Phase B–K). בצע **בתוך `POLISH_PROTOCOL`** שלך: before→after→gate · **token-binding = safe** (אפס שינוי ויזואלי) · L5 visual-screenshot ל-`POLISH_LOG`.
> ⚠️ **אל תיגע בקבצים-בתעופה של הקבלן** (`home_shell.dart` + מסכי-T1–T9 ש-מקבץ בונה כעת — PLAYBOOK no-collision). עבוד רק על הקבצים-הבטוחים המסומנים.
> אומת מהקוד v6.05. בצע לפי הסדר (בטוח→גדול).

---

## P-4 · הסרת `go_router` (P1, הכי-נקי) — ⏱️ ~30 דק'
🎯 dependency-מת: `go_router ^14.6` ב-`pubspec.yaml`, **0 שימושים** ב-`lib/`.
- צעדים: ודא `grep -rn "go_router" lib/` = 0 → הסר מ-`pubspec.yaml` → `flutter pub get` → analyze+test.
- ✅ DoD: pubspec בלי go_router · 0 imports · test ירוק.

## P-3 · typography pass (Phase C) — ⏱️ ~1ש'
🎯 font-sizes קסם → `BsTokens`. (מסומן כבר ב-`POLISH_LOG` Backlog.)
- קבצים-בטוחים: `widgets/toast.dart` (14) · `widgets/chain_diagram.dart` (8/9/22).
- צעד: הוסף tokens (`BsTokens.fontXs/Sm/...` אם אין) → החלף. **token-equal** = אפס שינוי ויזואלי.
- ✅ DoD: 0 font-size קסם בקבצים אלה · screenshot before/after זהה.

## P-2 · a11y / Semantics (P1) — ⏱️ ~2ש'
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
🎯 **1,028 `Color(0x` קשיחים** ב-lib → `BsTokens`. **token-binding = safe.**
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
