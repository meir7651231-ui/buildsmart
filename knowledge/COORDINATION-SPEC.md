# COORDINATION-SPEC — מפרט-תיאום לרגע-הפיצול (מי-לוקח-מה · merge-order · אנטי-פיצול)

> 🧭 נקודת-כניסה: `00-START-HERE.md`. משלים את `archive/TASKS-to-full.md`. מטרה: לפצל את 8 ה-tracks לסוכנים **בלי לחזור על הפיצול ל-3 ענפים** שקרה. נשען על PLAYBOOK (`AGENT_PATTERNS`/`AGENT_COORDINATION`) + בעלות-הסוכנים (דוח 24).

## 🔴 חוק-הזהב (הלקח מהפיצול הקודם)
**טרנק אחד = `claude/whats-happening-LyY9G`. כולם ממזגים אליו תכופות.**
- כל סוכן: worktree מבודד · commit מקומי · **merge-back ל-whats-happening כל ≤~10 commits** (לא לתת לענף להתבדר — זה מה שיצר את ה-3 ענפים).
- push = **ff-only + rebase-on-divergence** (`ff-push.sh`). אם diverged → fetch+rebase, לא ענף-חדש.
- **אסור** ענף-feature ארוך-טווח שלא ממזג חזרה. (3 הענפים נוצרו כי לא מיזגו — נפתר ב-v6.12 cutover; לא לחזור על זה.)

## 👥 מי-לוקח-מה (track → סוכן, לפי בעלות)
| Track | סוכן | קבצים | הערה |
|---|---|---|---|
| **B0** תשתית-data | **קטלגן** (data) | `data/*_seeds.dart` | ראשון · חוסם |
| ~~**T10**~~ טריגר | — | — | ❌ **מבוטל** (דיאל הוסר 07-06; גישה נייטיב) |
| **T6** server-ready | **מקבץ-A** (ארכיטקטורה) | `data/repositories/` (קבצים-חדשים) | מוקדם · פאונדציה |
| **T1** פיננסים(10) | **מקבץ-B** | `screens/finance_hub_*` (חדשים) | מקבילי |
| **T2** אתר(10) | **מקבץ-C** | `screens/site_hub_*` (חדשים) | מקבילי |
| **T3** חסרים(9) | **מקבץ-D** (+spawn) | `screens/{tasks,smart_project,...}` | אחד-לכל-feature |
| **T4** היקפי(43) | **מקבץ-E/ליטוש** | chats/camera/settings (קיימים) | ⚠️ partition-לפי-קובץ |
| **T5** דחויים(5) | **מקבץ-F** | store/courier screens (קיימים) | ⚠️ תיאום עם בעלי-T2-פרסונה |
| **ליטוש** P-1–P-5 | **ליטוש** | theme/widgets (יציבים) | רציף · אחרי-feature |
| **פרוטוקול** | **פרוטוקוליסט** | `.githooks/` | hooks בלבד |

## 📐 סדר-ביצוע (sequencing)
```
שלב-0 (serial · חוסם):   B0 (קטלגן) + T6.1 interface (מקבץ-A)   [T10 בוטל — דיאל הוסר 07-06]
        ↓ merge-back לטרנק
שלב-1 (מקבילי · disjoint): T1 ∥ T2 ∥ T3 ∥ T4 ∥ T5  (כל אחד worktree נפרד)
        ↓ merge-back תכוף (≤10 commits)
שלב-2 (רציף):             ליטוש (P-1–P-5) על מה שיציב · בנצי audit-passes
שלב-3:                    deploy-fix · השקה (חשבונות = משתמש)
```

## 🧩 מניעת-התנגשות (collision-avoidance)
1. **קבצים-חדשים-בלבד** היכן שאפשר (T1/T2/T3/T6 = מסכים/repos חדשים → אפס-התנגשות).
2. **קבצים-חמים** (`home_shell`·`role_picker`·`data/menu_trees`·`data/sections`) → **hot-file claim** (gate 115) לפני עריכה · עורך-אחד-בכל-רגע. (`menu_dial_widget`+`bs_dial_widget` **נמחקו** 07-06.)
3. **T4 (43 סטאבים)** = קבצים-קיימים → **partition מפורש**: chats↔camera↔settings↔store = סוכנים-שונים, אף-אחד לא נוגע בקובץ של השני.
4. **claims-log** (`archive/PLAN-contractor-completion.md` §תפיסות) — כל סוכן רושם track+SHA+סטטוס לפני שמתחיל.

## 🧠 תפקיד ה-Supervisor (בכל סבב)
- **ממסגר** כל track ב-10-step · **מוליד** את מקבץ-A..F + ליטוש · מוודא partition-disjoint (`Glob`).
- **central-verify v2** (analyze 0 + test + build **+ conformance** [`assert-manifest.sh` + `buildsmart.conformance.txt`] **+ required-tests** + codegen-לפני-analyze) על כל merge-back · **grep-verify** את הבייטים (לא prose) · **`ckpt.sh`** = checkpoint עמיד (שלב-מאוחר נחסם לפני שקודמו הושלם).
- **fallback:** concurrent → serial → supervisor-direct (אם track נכשל, ל-supervisor יש context).
- **דיווח-מעלה** + עדכון claims-log + status.

## ✅ DoD גלובלי לפיצול
- כל track ב-worktree מבודד · merge-back ≤10 commits · ff-only.
- אפס-התנגשות (partition נאכף) · central-verify ירוק לכל merge.
- claims-log מעודכן · supervisor מאמת.

## 🚦 אות-התחלה
כשהסוכנים מוכנים: **(1)** קטלגן+סדרן+מקבץ-A מתחילים שלב-0 (תשתית/טריגר/repo-interface) → merge. **(2)** ואז מקבץ-B..F + ליטוש נשלחים במקביל (track לכל אחד). **כל זה על whats-happening — אין ענפים-חדשים.**
