# חשבון-מלא — כל השדרוגים שלי מול המחצב (7 משפחות · מאומת בחשבון-תוכניות)

מטרה: להכניס את כל שיפורי-gen-max למנועי-המחצב. זהו החשבון-המלא —
כל ~33 תוכניות-היכולת שלי מופו לאחת מ-7 משפחות-השדרוג / מקבילה-שלו / artifact.
**אין משפחת-שדרוג שמינית.**

---

## 7 משפחות-השדרוג (לפורט)

### חסרות אצלו לגמרי (1–5)
1. **גלאי-באגי-נכונות** — `gen-max·deepFindings()` · `purity-data-max`
   בליעה-שקטה · תאריך-UTC · כסף-בצפים · רצף-מונה · JSON.parse-לא-מוגן.
   פער: `deep-purity-scan` = טוהר בלבד. חיבור: עדשה ליד deep-purity-scan.
2. **תיקון קוד-מאור החי (.ts)** — `--fixfile/autofix/fixmagic` · `wire-upgrade` · `upgrade-engine` · `apply-one`
   פער: אפס-כתיבה ל-maor/src ב-146 כליו. חיבור: צעד back-port opt-in.
3. **control-flow→טבלה** — `--switch` · `--restructure`
   פער: purify מרים דאטה, לא זרימה. חיבור: פאזה ב-purify-dart/chisel.
4. **חיפוש-מסלול על גרף-טיפוסים** — `--board/--board-scan` · `super-compose` · `super-monster`
   פער: compose-engine `formula→ops` קבוע, אפס BFS. חיבור: type-graph מעל compose-engine.
5. **קיפול op-שקילות סמנטי** — `gen-merge` · `gen-fold2/3` · `max-best`
   פער: `dedup-deep` סינטקטי (sha1/שם/regex). חיבור: עדשת "opTwins" (op+סוקט+נושא).

### שדרוגי-רוחב/ציר — לו יש בסיס, שלי מרחיב (6–7)
6. **חציבה רחבה פי-60** — `harvest-particles` (90,234 קבצים ⇒ 40,854 חלקיקים)
   מול `op-census` (1,402 אטומים). חיבור: הזן op-census מהסורק שלי.
7. **מפקד-מקסימליות + פסק-כנות** — `--maxall` (fixpoint/effect/idempotent/upgradeable + "pulled-not-wired")
   מול `empire-coverage` (מודד כיסוי, לא מקסימליות; אין פסק-כנות false-MAX). חיבור: ג'וב ליד empire-coverage + coverage-gate.

---

## חשבון-התוכניות (הוכחת-שלמות — כל כלי שלי מופה)
| התוכניות שלי | דלי |
|---|---|
| `--deepfiles` · `purity-data-max` | #1 |
| `--fixfile/autofix` · `wire-upgrade` · `upgrade-engine` · `upgrade-one` · `apply-one` · `super-upgrade` | #2 |
| `--switch` · `--restructure` | #3 |
| `--board/--board-scan` · `super-compose` · `super-monster` · `super-run` · `super-finish` | #4 |
| `gen-merge` · `gen-fold2/3` · `max-best` · `super-upgrade-max` · `phone-monster` | #5 |
| `harvest-particles` · `super-quarry` · `super-carver` · `empire-index` · `maor-opindex` | #6 |
| `--maxall` · `gen-upgrade` · `empireMax` · `cover` | #7 |
| `core-from-shape` · `sentence` · `entity` · `seam-recognize` · `io-contract` · `super-monster2` · `verify` | מקבילה-שלו |
| `*.max/*.fix/*.restr/*.switch/*ListMax/board_*` · `wizard-monster` | artifacts (פלט) |

---

## מה שכפול-אמיתי אצלו (לא לפורט)
`--dedup-scan`(סינטקטי — #5 מכסה) · `--domain`/`--goal`(box-assemble/synth) ·
חוזי-כוונה(1,160 חוזים) · אימות-עצמאי(verify-independent) · schema→core(shape-ops/retarget).

---

## רמת-ודאות (כנות)
- **ברמת משפחות-השדרוג: הרשימה סגורה — 7.** אומת בחשבון-מלא: כל תוכנית שלי נופלת ל-7 / מקבילה / artifact. אין 8.
- **הסייג:** 7 הן משפחות; תת-פרטים דקים ייתכנו. הצד-שלו נבדק בכותרת+grep+קריאת-מנגנון — לא כל שורה ב-146 כליו. אומת מול snapshot ארעי.
- לנעילת-100% פר-משפחה: מעבר שורה-אחר-שורה על 5–7 הקבצים המקבילים שלו (deep-purity-scan · [חיפוש-כתיבה-ל-src] · purify-dart · compose-engine · dedup-deep · op-census · empire-coverage).
