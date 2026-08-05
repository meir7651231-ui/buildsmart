# ארכיטקטורת-הממשל הרב-סוכנית — פרוטוקול → Supervisor → 6 סוכנים

> מה שנבנה כאן הוא **מפעל-תוכנה אוטונומי**: סוכנים בונים את BuildSmart לבד, נשלטים ע"י פרוטוקול-אכיף-עצמי, תחת פיקוח סוכן-על, עם המשתמש כסמכות-עליונה. נלכד מ-`AGENT_PATTERNS.md` · `AGENT_COORDINATION.md` · ענף-הפרוטוקול `agent-network-proto-build` (V2–V10).

## A. ההיררכיה (אומת מ-`AGENT_COORDINATION.md:544` + `AGENT_PATTERNS.md`)
```
   הפרוטוקול (116 שערים + מנוע חסין-זיוף) — החוק העליון, אכיפה אוטומטית על כל commit
                          │
   פרוטוקוליסט — הסוכן העליון ("מעל כולם"); בעלות על .githooks/knowledge/test בלבד
                          │
   🧠 Supervisor (סוכן-העל) — ממסגר · מוליד sub-agents · מפקח · fallback-direct
                          │
   קטלגן · סדרן · מקבץ · בנצי · ליטוש — תת-הסוכנים, כל אחד עם בעלות-תחום
                          │
   👤 המשתמש — מעניק-סמכות · GO סופי · אישור-push מילולי
```

## B. ה-Supervisor (סוכן-העל) — `AGENT_PATTERNS.md`
התפקיד שפספסתי בתחילה; קיים מפורש:
1. **ממסגר כל משימה** ב-10-step decomposition סטנדרטי.
2. **מוליד (spawns)** את תת-הסוכנים המקבילים (עד 3) · מוודא אי-התנגשות (`Glob` mutual-exclusion).
3. **מחזיק context מלא** של כל המתרחש.
4. **Fallback chain:** concurrent → serial → **supervisor-direct** (אם sub-agent נכשל/529, ה-supervisor כבר עם context → עושה ישירות).
5. **מקבל דוחות** מכל תת-סוכן (סשן בלי-דוח = לא-סגור).

## C. 6 תת-הסוכנים (בעלות · אסור)
| סוכן | בונה | אסור |
|---|---|---|
| **פרוטוקוליסט** | `.githooks/` · knowledge · test | feature/UI/data |
| **קטלגן** | `lib/data/` · assets (קטלוגים) | פרוטוקולים |
| **סדרן** | `lib/ui/` · widgets (ויזואל/מבנה) | פרוטוקולים |
| **מקבץ** | `lib/features/` · screens (פיצ'רים) | פרוטוקולים |
| **בנצי** | audit + `LAUNCH_PACKAGE/` (השקה) | refactor-רחב · ניווט · מחיקה |
| **ליטוש** | presentation · `theme/` · ניקוי-knowledge | data · מחיקת-מסמך-ללא-verdict |

## D. הפרוטוקול = המפקח-הצמוד (אוטומטי, חסין-זיוף)
לא אדם ולא סוכן-יחיד — **מערכת-כללים שאוכפת את עצמה.** ענף `agent-network-proto-build` הקשיח אותה ל-10 גרסאות מול red-team רב-סוכני:
- **registry-as-source-of-truth** (`protocol/gates.tsv`) — כל השערים בקובץ-נתונים אחד.
- **ran-ledger (K3):** הרץ פולט `ran <id>` אחרי כל בדיקה → הוכחה שכל שער **באמת רץ** (מחקת שער → parity נכשל).
- **content-hash pinning (K4):** המנוע/hooks/workflows ננעלים ב-SHA → אי-אפשר לשנות אכיפה בשקט.
- **חסינות-התקפה:** נסגרו base64-laundering · slash-laundering · whole-tree-skip · ReDoS (V2→V10).
- **ה-WALL** (נשאר למשתמש): branch-protection · CODEOWNERS · deployment.

## E. התיאום (איך עובדים יחד)
- **אסינכרוני דרך קבצים** — `AGENT_COORDINATION.md` · claims-log · `STATUS.md`. **אין צ'אט-חי.** המשתמש = relay להחלטות-בין-סוכנים.
- **hot-file claims** (gate 115) לפני עריכת-קובץ-חם.
- **PLAYBOOK:** **NO-STOPPING** (בונים בלי לעצור · WALL רק אחרי ~50 ניסיונות) · **push = מילה-מילולית בלבד** (`תדחוף`/`push`) · cadence (suite/~5 · commit/~20 · demo/~10) · **new-files-only** למקביליות.
- **קונצנזוס** = סימולציית-6-פרסונות (ביקורות-הדדיות), לא הצבעה; **GO סופי מהמשתמש.**

## F. הוכחה-חיה (2026-06-04)
המערכת מבצעת בפועל את `PLAN-contractor-completion.md`: **שלב-א של הקבלן הושלם** (T0–T9 ✅; T8 stub-מכוון) + **המנהל בנוי ומאוחד** (v6.12) + הקשחת v6.13–v6.16 (**1,539 טסטים**) — נבנה אוטונומית ע"י הסוכנים, מתואם ע"י ה-supervisor, נאכף ע"י הפרוטוקול, עם הסוכנים **מעדכנים סטטוס בתוך התוכנית עצמה**. v5.92→v6.16 · אפס-תקיעות.

## G. ה-orchestrator-kit v2 (2026-06-05) — תמצית-ההתנהגות כ-config-טעין
מעבר לסוכני-התחום, נלכדה **ערכת-orchestrator לשימוש-חוזר** (`orchestrator/` בענף whats-happening): `PLAYBOOK.md` (v2) + agents (auditor/validator/fixer/supervisor) + scripts. עיקרי-v2:
- **ה-gate (`central-verify.sh`) הוקשח:** analyze+test+build **+ conformance** (byte-assertions מול manifest) **+ required-tests** (נוכחות-flows) + codegen-לפני-analyze. מכריז בעצמו "NOT enforced this run" כשלא מועבר manifest (כנות-floor).
- **`ckpt.sh`** = checkpoint עמיד + phase-order guard · **`grep-verify.sh`** = אימות-בייטים · **`ff-push.sh`** = push ff-only.
- **red-team עצמי:** 9 designs נבדקו, כולם NEEDS-WORK, נשלח רק האחד ("structural absence"). **`perfect-agent/`** = self-spec 9-ממדי שמתכנס (bootstrap→v6).
- **תקרה (מתועדת ביושר):** הכל on-host = floor; ה"חובה" האמיתי = off-host CI.

---
**השורה:** לא רק אפליקציה נבנית כאן — נבנתה **מכונת-בנייה אוטונומית עם ממשל-עצמי אכיף**. הסוכן-המפקח "מעל" העובדים הוא ה-Supervisor; מעליו רק הפרוטוקול (פרוטוקוליסט) והמשתמש.
