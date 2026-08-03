# 🔒 משמעת-עבודה מחייבת (self-binding) — נגזר מהפרוטוקול של הידען

> **זה חוזה-עבודה שאני כפוף לו.** לא ידע-לעיון — **checklist שמבוצע.** נטען בכל סשן דרך SessionStart hook.
> מקור: `MASTER_PROTOCOL` · `VERIFICATION_PROTOCOL` · `AGENT_COORDINATION` · `CARRY_FORWARD` · `DECISIONS` (ענף `whats-happening-LyY9G`).
> אם אני עומד לעבוד על BuildSmart — **אני חייב לגעת בקובץ הזה ולעבור עליו לפני הקוד.**

## ① פתיחת-סשן (חובה, לפני כל עבודה)
- [ ] `git fetch origin <branch>` → `git rev-list --left-right --count origin/<branch>...HEAD` → בדוק ahead/behind. **"קובץ חסר" = בדוק ענף, לא working-tree** (T1/#60).
- [ ] אל תיגע ב-git אם `.git/index.lock` קיים (commit רץ) (#63).
- [ ] יישור-ענף = `merge --ff-only` אחרי בדיקת-ahead. **לעולם לא `reset --hard` עיוור** (#63/#66).

## ② לפני שכותבים קוד (לכל פיצ׳ר/שלב)
- [ ] **שאלת-פתיחה §ג.1:** מה · מקור (proto L#/preact file:line) · תרגום-ל-dial · helper (signature) · verbatim · ⛔חסום.
- [ ] אם התרגום כולל "מסך/דף/view/dashboard" → **עצור** (R2 — הכל dial).
- [ ] **10-step:** דרישה→deps→patterns קיימים→signature→**tests-first (red)**→green→analyze 0→wire→suite→ROADMAP+bump+local-commit.

## ③ לוגיקה = Helper-First
- [ ] לוגיקה טהורה (בלי BuildContext/ref/side-effects) **לפני** UI.
- [ ] boundary-tests לכל תנאי-קצה · **golden מול המקור** (למשל `pure_engine.py`).
- [ ] הוסף שם ה-helper ל-`_kRequiredHelpers` (regression_gate), אחרת ה-suite נופל.
- [ ] **`kCatalogProducts` לרוחב ה-UI, לעולם לא `kLipskeyCatalog`** (שער 114 · T4/#69) — אחרת חוליות/PPR = כרטיס-לבן.

## ④ לפני commit — סולם L0–L7
- [ ] **L0** `flutter analyze` 0 + `dart format` נקי · **L1** `flutter test`.
- [ ] **L3 מוטציה — חובה לכל שינוי-לוגיקה** (`mutation_verify.sh`: אדום→שחזור→ירוק→`mutation_log`). ‏analyze לבד לא תופס (T5).
- [ ] **L6** לשינוי-ידע: verdict-4-שדות + `knowledge_protocol_test` + אין הפניות-שבורות.
- [ ] **L7** hooks — **לא לעקוף.** שגיאת-שער → דווח לפרוטוקוליסט, המתן (אל תעקוף).
- [ ] commit message: קידומת עברית + `@rule/@legacy/@adr` היכן שרלוונטי.

## ⑤ דגלים · שערים · מסמכים
- [ ] פיצ׳ר חדש = דגל-קומפילציה **default-OFF** (byte-identical כבוי · D-017) + **רישום ב-`GATE_REGISTRY.md` אותו commit** (T7).
- [ ] מסמך-ידע חדש = **שורה ב-`README.md` + status-header** (draft→…) אותו commit (T6/D-015). חפש קיים-לעדכון לפני יצירה.
- [ ] keystone: אינסטלציה **byte-identical** — רק `putIfAbsent`, לא דורסים.

## ⑥ push רב-סוכני
- [ ] `git fetch` → ahead/behind → `rebase` (או `ff-only`) מעל origin החדש. "אותו HEAD" = הנחה מסוכנת (T3/#5).
- [ ] התנגשות: מסמכי-תיאום keep-both · `lib/**` ידני + הסלמה לפרוטוקוליסט.

## ⑦ התנהגות (הכי חשוב — תיקוני-עבר שלי)
- [ ] **P-01 לולאה-תקועה:** אותו כשל-שורש **פעמיים** → **עצור · אל תנסה שלישית · שאל את הבעלים.** (רצפת ~1.3 מ״מ = דוגמה — לתעד, לא "לנצח".)
- [ ] **#71 feedback מעורפל → שאלה-ממוקדת אחת, לא קוד.** "לא נקי"/"בעייתי" בלי specifics = טריגר-לאבחון, לא ל-commit. אבחן 100% לפני פתרון (#39).
- [ ] עבודה חוצת-זונה (data=קטלגן · features=מקבץ · knowledge=פרוטוקוליסט) = **תיאום דרך הבעלים**, לא drop.

## ⑧ סוף-סשן
- [ ] **דוח-ביצוע 6-שדות** (בוצע+מספרים · לא-בוצע+למה · כיסוי-פרוטוקול · אימות L0–L7 · חסמים · commit-SHA). "דוח חסר = סשן לא סגור."
