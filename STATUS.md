# BuildSmart — STATUS

_עודכן: 2026-11-11 · **דוח אחרון: 2026-11-11 02:25 UTC (לילה)** · ענף אחרון שמוזג ל-main: `claude/whats-happening-LyY9G` (PR #58, 2026-08-24)._
_יומן גרסאות מפורט ותווית הגרסה: `app_flutter/knowledge/STATUS.md` (כרגע **v7.02**)._

## מצב נוכחי
| רכיב | מצב | אימות בסשן זה (2026-11-03) |
|---|---|---|
| `app_flutter/` (Flutter, הפעיל) | 🟢 חי ב-buildsmart-il.com · Android AAB/APK ב-CI · iOS טרם נבנה | analyze: **0 errors** (56 warnings, infos) · tests: **6034 ✅ · 0 ✗ · 12 skip** (Flutter 3.44, ~18 דק׳) |
| `app/` (Preact legacy) | 🟡 GitHub Pages, תיקוני באגים בלבד | typecheck ✅ · build ✅ · smoke **21/21** ✅ (בעקיפת נתיב Chromium — ראה בעיה 2) |
| `functions/` | 🟢 me-west1, gen2 | typecheck ✅ · selftest **100/100** ✅ |
| קטלוג (`scripts/catalog_qa.py`) | 🟢 | selftest ✅ · audit: אפס שגיאות חוסמות ✅ |

עבודה אחרונה שנכנסה (אוגוסט 2026): dark-mode waves 1–16 (מסכים theme-aware), server-sync ל"ניהול מסך"
(`SCREEN_SECTIONS_LIVE`, ברירת-מחדל OFF), הכרטיס הפנימי באנדרואיד (v7.02), תיקון אישור-הבעלים (v7.01).

## בעיות פתוחות
1. **Dark mode לא הושלם** — אחרי wave 16 נותרו ~49 אתרי-משטח בהירים קשיחים (atlas 65→49, `tools/atom/decompose/bin/colors.dart`).
2. **`app/smoke-settings.mjs` מקודד נתיב Chromium** (`/opt/pw-browsers/chromium-1194/...`) — נכשל בסביבה הנוכחית (`chromium-1243/chrome-linux64`). צריך fallback/משתנה-סביבה.
3. **פער גרסאות Flutter ב-CI** — `protocol-enforce.yml`/`catalog-qa.yml` על 3.29.3, build/deploy על 3.44.0; `flutter analyze` ב-3.44 מציג 56 warnings (לא חוסם).
4. **הוראות סשן ישנות** — הענף `claude/whats-happening-LyY9G` עדיין מפעיל deploy לפרודקשן בכל push (`web-deploy.yml`, `firebase-hosting.yml`, `firebase-deploy.yml`); מסמכי `orchestrator/`/`knowledge/` עדיין מפנים אליו כענף העבודה.
5. **PRs פתוחים לא מטופלים** — [#59](https://github.com/meir7651231-ui/buildsmart/pull/59) (הצלת נכסי-ענפים ל-`rescue/`) ו-[#5](https://github.com/meir7651231-ui/buildsmart/pull/5) (`.gitignore` ל-`.claude/`) — ממתינים להחלטת מאיר.
6. **השקה בחנויות** — iOS: אין signing/build (דורש Mac/CI); חשבונות Apple/Google + privacy-policy עדיין פתוחים (`app_flutter/knowledge/LAUNCH_READINESS.md`).
7. **Spec מיושן** — `app_flutter/knowledge/spec/shell-and-dials.md` §7 עדיין מתאר dials וטאבים שהוסרו (היום: בית · מחלקות · עדכונים · חנות). לעדכן.

## Next (3–5 משימות הבאות)
1. **לסיים dark mode** — waves 17+ על ~49 האתרים הנותרים, עד atlas=0, עם צילומי light/dark.
2. **לתקן את smoke-settings** — נתיב Chromium דינמי (`PW_CHROMIUM` / חיפוש ב-`/opt/pw-browsers`) + להכניס ל-CI.
3. **ליישר CI ל-Flutter 3.44.0** בכל ה-workflows ולנקות את ה-warnings של analyze (דורש אישור — `protocol-enforce.yml` קובץ מוגן).
4. **החלטה על ענף ה-deploy** — להעביר את הטריגרים של הפרודקשן ל-`main` בלבד (באישור מאיר) ולעדכן את המסמכים.
5. **iOS build ב-CI** (macOS runner) + השלמת P0 של `LAUNCH_READINESS.md` לקראת הגשה לחנויות.


## לילה 2026-11-11

> הבסיס של הקובץ הזה הוא `STATUS.md` מ-PR [#60](https://github.com/meir7651231-ui/buildsmart/pull/60) (טיוטה, לא מוזג). הסעיף הזה נוסף מעליו.

**⛔ החלטות שמחכות למאיר (קודם כל):**
1. **שער `central-verify.sh` אדום גם על main נקי.** 16 הצהרות conformance ב-`orchestrator/manifests/buildsmart.conformance.txt` נכשלות על main (‏`AppBrand.name`, `kVerticalPacks`, `kOrgModules`, `featEnabled(...)` ב-manager_dashboard, `clean-two-links.yml` בנתיב שגוי ועוד). ה-analyze, ה-suite וה-build עצמם ירוקים. צריך להחליט: לעדכן את ה-manifest, או שהקוד איבד פיצ'רים שהיו אמורים להיות שם.
2. **היקף dark-mode אמיתי גדול מה-atlas.** הגלים 1–16 הסבו משטחים אבל השאירו טקסט `inkLight` קשיח, ובכהה הוא בלתי נראה. גל 17 תיקן 17 קבצים. **~89 קבצים** נוספים עם אותו דפוס. ה-atlas (49) לא סופר את זה. להחליט אם להמשיך בגלים לילה-לילה.
3. **smoke ב-CI** (המשך ל-#64): מחייב נגיעה ב-workflow, ו-`protocol-enforce.yml` מוגן.

**✅ הושלם (3 PRs טיוטה):**
- [#64](https://github.com/meir7651231-ui/buildsmart/pull/64): smoke-settings עם נתיב Chromium דינמי. ‏`node --test` ‏5/5 · smoke **21/21** · CI ✅. סיכון נמוך.
- [#65](https://github.com/meir7651231-ui/buildsmart/pull/65): dark-mode גל 17. ‏`bsInk`/`bsMuted` ‏+ 16 מסכים + `AiOffState`. טסט ניגודיות חדש: אדום לפני, ירוק אחרי, mutation-verified. suite **6055 ✅ / 0 ✗ / 12 skip**. screen-review ‏8.4, כל ציר ≥7 אחרי תיקונים. סיכון נמוך-בינוני.
- [#66](https://github.com/meir7651231-ui/buildsmart/pull/66): ‏36 אזהרות analyzer (56 ← 20), בלי שינוי התנהגות. suite **6034 ✅ / 0 ✗**. סיכון נמוך.

**🔄 בתהליך:** CI (Protocol Enforcement) על #65/#66 רץ בזמן הכתיבה.

**הערות סביבה:** בקונטיינר אין Flutter מותקן מראש. הורדתי 3.44.0 ל-`/home/user/flutter`. בנוסף, `lib/version.g.dart` נוצר רק דרך `bash scripts/gen_version.sh` **משורש הריפו**, ובלעדיו analyze מראה 8 errors מדומים.

**▶️ הצעד הבא:**
- גל 18 של dark-mode: מפרידים וגבולות (`bsDivider`), `bsSubtleFill`, ‏`worker_app_screen.dart:160`, והקבצים הבאים מתוך ה-89.
- להרחיב את `dark_ink_screens_test` לגיליונות.
- לקבע את גרסת Flutter ב-CI על 3.44.
