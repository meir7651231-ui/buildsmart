# מפת-הפערים — איפה עוד יש פערים (שני סוגים, מאומת)

יש **שני סוגי-פערים שונים**. אל תבלבל ביניהם.

---

## A. פערי-כיסוי (מתוך `empire-coverage.mjs` שלו) — "מה עוד לא נחצב לאטום"
מאור: **1024 פונקציות-מקור · 663 נחצבו (65%) · 117 פער-לוגיקה-אמיתי** (כיסוי-לוגיקה-טהורה 85%).
= פונקציות-lib טהורות שקיימות במאור אבל **טרם הועברו** לשכבת-האטומים שלו.

**היכן הפערים הגדולים (קובץ · כמה חסרים):**
| קובץ | # | דוגמאות |
|---|---|---|
| `home/homeData.ts` | 20 | courseActiveOn · todaySessions · homeStats · monthlySeries · careCounts |
| `calendar/calLib.ts` | 16 | fmtD · hpOf · roomClashError · buildGregorianGrid · icsWindowEvents |
| `timer/cashLib.ts` | 9 | changeBreakdown · denomTint · expectedDrawer · cashSuggestions |
| `courses/ops.ts` | 6 | coursesToday · debtors · dropoutRisk · opsKpis |
| `public/portal.ts` | 6 | portalValid · portalChannels · portalChatLine · parsePortalChat |
| `types/domain.ts` | 6 | pushDelLog · mergeDelLogs · pushAudit · emptyDb |
| `builder/wizardLib.ts` | 5 | wizardDiff · diffCount · groupFeatures |
| `courses/teacher.ts` | 5 | teacherCourses · teacherAgenda · teacherKpis |
| `wall/wallData.ts` | 5 | buildPodium · buildWeek · buildWallData |
| ... + ~20 קבצים | 1–4 כ"א | handoff · collection · segments · dashboard · parent · retention · morningBrief · timemachine · universe3d ... |

→ **המשמעות:** אלה יכולות-מאור שעדיין רק ב-TS החי, לא כאטומים-מפורטים-עם-חוזה-וטסט. זה "מה עוד להביא פנימה".

---

## B. פערי-נכונות (מתוך `--deepfiles` שלי) — "איפה הקוד עלול להיות שגוי"
**86 קבצים עם סיכון · 5 🔴 קריטיים** (מתוך 302 קבצים).

⚠️ **כנות:** רוב ה-🟡 **אינם באגים** — ‏`a.f || b.f` על phone/email/city = מילוי-מכוון של שדה-ריק. הגלאי מזהה **צורה**; רק זהות/כסף (🔴) הם קריטיים.

**ה-🔴 הקריטיים (בליעה-שקטה של זהות/כסף):**
| קובץ:שורה | שדה | סטטוס |
|---|---|---|
| `dedup.ts:356` | `idNum` (ת"ז) | ✅ **תוקן** — נשמר בהערות |
| `dedup.ts:360` | `hok` (הוראת-קבע) | ✅ **תוקן** — נשמר בהערות |
| `dedup.ts:385` | `extId` (מזהה-חיצוני) | ⬜ **פתוח** — מועמד-תיקון הבא |
| + 2 קבצים נוספים | — | לבדיקה פרטנית |

**סוגי-הסיכון שהגלאי מחפש:** בליעה-שקטה · תאריך-UTC (תוקן ב-3 קבצים) · חשבון-כסף-בצפים · רצף-מונה · JSON.parse-לא-מוגן.

---

## ההבדל בין השניים (חשוב)
- **פער-כיסוי (A)** = "יכולת קיימת שלא הובאה לאטום" — פער-**רוחב** (שלו).
- **פער-נכונות (B)** = "קוד קיים שעלול להיות שגוי" — פער-**עומק/איכות** (שלי).

מנוע-אחד לא מכסה את השני: הוא מודד כמה הבאנו, אני מודד מה שבור. **שני הצירים ביחד = המפה המלאה.**

## הפער-הפתוח היחיד המומלץ-לפעולה
`dedup.ts:385 · extId` — בליעה-שקטה של מזהה-חיצוני (ToremId נדרים) במיזוג-כפילות. אותה משפחת-תיקון כמו idNum/hok שכבר תוקנו. דורש אישור-בעלים (גבול-תפקיד: האם 2 מזהים = 2 אנשים).
