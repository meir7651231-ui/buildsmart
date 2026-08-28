# BUILD-ORDER — חיבור הפירוק לאפליקציה החיה (Atom-Engine → Live)

> **המטרה (בעלים):** "לחבר את הפירוק לאפליקציה — משהו מקצועי — עם דרך שלב-שלב."
> להעביר את מנוע-האטומים מ**הוכחה-מגודרת דורמנטית** (flag off · tree-shaken ·
> byte-identical) ל**יכולת חיה מקצועית**: מסכי האפליקציה **מורכבים מדאטה** — צינור
> אחד `decompose → manifest → engine → מסך-חי`, מסך-אחר-מסך, מאחורי שער-פֶּרֶט.

---

## 0. איפה אנחנו עומדים (baseline מאומת — 2026-08-28)

**שני חצאים שעדיין לא מחוברים:**

| חצי | מה קיים | מצב |
|---|---|---|
| **המפרק** (read-only) `tools/atom/decompose` | פורק את כל גרף-האפליקציה ל-**~2,000 אטומי-ידע** (6 שכבות · לוגיקה 1,872 · דאטה 161 · פרימיטיבים · מסעות 905 · async 310 · backend 20). מייצר `app_flutter/knowledge/`. | ✅ capstone (DECOMP-DEPTH) |
| **המנוע** (חי-דורמנטי) `lib/atoms/` | `AtomEngine.render(schema, resolve)` מרכיב את **contractor-home** מ-10 אטומים לפי מניפסט, byte-identical ל-`FinderScreen`. שער יחיד: `catalog_screen.dart:1747` `kAtomEngine ? AtomHomeScreen() : FinderScreen()`. | ✅ slice-1 מוכח (parity) |

**הפער — הליבה של המשימה:** המניפסט (`atom-engine/manifests/contractor-home.json`
+ const מוטבע ב-`atom_schema.dart`) **נכתב ביד**. פלט-המפרק (`knowledge/screens/…`)
מיוצר **בנפרד** ולא מזין את המנוע. **אין צינור decompose→manifest.** לחבר אותם =
לסגור את הלולאה.

**חוב פתוח יחיד לפני שמתחילים:** 2 גולדני-מפרק מיושנים
(`SmartCartNotifier.state=` אחרי הרפקטור ל-`PersistOnWrite` mixin — הסטר-האינוריאנט
חולץ למקום-אחד, hard-case #6 נפתר). האפליקציה ירוקה מלאה: **analyze 0 · 6,034
טסטים · build web ✓** (central-verify GATE PASS).

---

## שערים חוצי-פאזות (חלים על כל שלב — לא ניתן לעקיפה)

1. 🛡️ **keystone byte-identical** — כל עוד `kAtomEngine=false` (ברירת-מחדל), הצי-החי
   לא זז: המנוע tree-shaken, `main.dart.js` דלתא = רק תווית-הגרסה (LEARNINGS L1).
   כל פאזה מוכיחה זאת מחדש (byte-verify).
2. **golden-first** — כל מצב חדש משחזר golden ידני 1:1 לפני ריצה-רחבה.
3. **toggle-matrix** — analyze+test+build עוברים בשני המצבים (flag off · flag on
   `--dart-define=ATOM_ENGINE=true`).
4. **central-verify ירוק** — `orchestrator/scripts/central-verify.sh app_flutter`:
   analyze 0 · tests green · build web ✓.
5. **document-don't-fix** — חובות שמתגלים = הכרעות-בעלים, לא רפקטור-בעיוור.
6. **נחיל 9×9** — כל פאזה נפתחת בנחיל (‏skill `swarm`); אין קוד בלי השער.
7. **אין push ל-main בלי אישור מפורש** — עבודה על ענף (‏`claude/atom-engine-*`).

---

## שלב 1 · יישור-קו (tie-off · קטן)
**מטרה:** אפס-אדום לפני שבונים. **פלט:** כל הגולדנים ירוקים.

- לעדכן את `tools/atom/decompose/test/logic_golden_test.dart` כך שישקף את המציאות:
  האינוריאנט חי ב-`PersistOnWrite` (‏`state/prefs_persisted.dart`), ו-
  `SmartCartNotifier.add` כותב `state` ישירות — עם הערה שהריצה-הטרנזיטיבית
  חוצת-הקבצים היא **מגבלה-מתועדת** של מפרק per-file (לא באג).
- להוסיף golden חדש: המפרק על `prefs_persisted.dart` מוצא את `state=` setter עם
  `field:_loaded` + `state:state` (האינוריאנט עבר, לא נעלם).

**שער:** `dart test` ב-decompose+testgen → All green · central-verify ירוק.

---

## שלב 2 · הגשר · decompose → manifest **(החיבור עצמו)**
**מטרה:** פלט-המפרק הופך ל-SSOT שמ**ייצר** את המניפסט, במקום כתיבה-ביד.
**פלט:** `dart run tools/atom/genmanifest <screen>` → `manifests/<screen>.json`.

1. **גשר טהור** `tools/atom/genmanifest` (Dart, כמו decompose/testgen): קורא את
   גרף-המסך של המפרק (`knowledge/screens/<screen>/*.json`) → פולט מניפסט-מנוע
   (‏id · type · when · expanded).
2. **הוכחת-שוויון:** המניפסט המיוצר ל-contractor-home **byte-identical** למניפסט
   הכתוב-ביד היום (golden). זהו הוכחת-הגשר.
3. `atom_schema.dart` טוען מהמניפסט-המיוצר (ה-const המוטבע נשאר SSOT-לרינדור-סינכרוני
   — L3 — אבל מקורו עכשיו הגשר, לא היד).

**שער:** golden byte-identical · parity-test עדיין ירוק · keystone byte-verify.
**הכרעת-בעלים:** האם המניפסט נשמר ב-repo (מיוצר-מ-commit) או מיוצר-בזמן-build.

---

## שלב 3 · מסך שני **(הכללה)**
**מטרה:** להוכיח שהצינור מכליל מעבר ל-finder. **פלט:** מסך-שני חי-דורמנטי מהמנוע.

- לבחור מסך עם מבנה-section דקלרטיבי (מועמד: `SmartHomeBody` / מסך-קטלוג פשוט).
- `decompose <screen>` → `genmanifest` → אטומים חדשים ב-`home_atoms`/library →
  `Atom<Screen>Screen` מאחורי אותו `kAtomEngine`.
- **parity-test** חדש: `Atom<Screen>` ≡ המסך-המקורי, פיקסל-פר-פיקסל.

**שער:** 2 מסכים עוברים parity · toggle-matrix · keystone byte-identical.

---

## שלב 4 · המחולל · emit-layer **(מ"מרכיב" ל"מייצר" — מנוף #2)**
**מטרה:** מ-assembler (resolvers כתובים-ביד) ל-generator (פליטה-אוטומטית).
**פלט:** `dart run tools/atom/emit <screen>` → manifest + שלד-resolver + טסטים.

- הגשר (שלב 2) פולט מניפסט; המחולל מרחיב אותו לפליטת **שלד-ה-resolver**
  (‏`when`-predicates + חיווט-props) מתוך גרף-הלוגיקה של המפרק.
- `testgen` (קיים) כבר פולט את הטסטים מהגרף — משתלב כאן כשלב-הפליטה-השלישי.

**שער:** מסך-מיוצר-אוטומטית עובר parity בלי עריכה-ידנית · golden.
**הכרעת-בעלים:** גבול הפליטה-האוטומטית (props מורכבים = ידני מתועד).

---

## שלב 5 · ספריית-אטומים ניידת **(reuse)**
**מטרה:** אטומים חוצי-מסכים/פרסונות. **פלט:** `lib/atoms/library/`.

- לחלץ את האטומים החוזרים (‏`AtomChipBar` · `AtomTypeGrid` · `AtomBreadcrumb`…)
  לספרייה ניידת, נטולת-מצב-מסך, עם props מפורשים בלבד.
- מסכים חדשים = הרכבת-אטומים-קיימים + מעטים-חדשים (יחס-reuse עולה עם כל מסך).

**שער:** אטום = טהור (בלי ambient state) · נבדק-ביחידה · שני מסכים משתמשים באותו אטום.

---

## שלב 6 · הפעלה-הדרגתית חיה **(rollout · הכרעת-בעלים פר-מסך)**
**מטרה:** המסכים הופכים באמת מנוע-מונעים — מסך-אחר-מסך. **פלט:** flag ON פר-מסך.

- לכל מסך שעבר parity: **הכרעת-בעלים** להפוך את השער ל-ON (או flag פר-מסך).
- ה-keystone נשמר: מסך-ה-fallback המקורי נשאר בקוד כ-byte-identical-safety —
  רגרסיה = היפוך-flag = המסך-הישן חוזר מיידית.
- מדד: ‏% המסכים המנוע-מונעים עולה; אפס רגרסיית-פיקסל.

**שער:** parity ירוק פר-מסך-מופעל · e2e-smoke · אישור-בעלים לכל הפעלה.

---

## שלב 7 · מניפסט-פר-ורטיקל **(התמורה · white-label)**
**מטרה:** שינוי-פריסה = עריכת-דאטה. **פלט:** מניפסט פר-org/ורטיקל.

- המניפסט הופך ל-config פר-ארגון (רוכב על `element_registry`/‏OrgConfig הקיימים —
  ראה WIRING §studio-registry-to-wizard-toggles).
- הסטודיו/אשף עורך מניפסטים → פריסות פר-לקוח בלי קוד. סגירת חזון ה-white-label.

**שער:** absent=ברירת-מחדל (זהה-בייטים) · round-trip · ratchet-כיסוי.

---

## מפת-הדרך בתמצית

```
0 baseline ─▶ 1 יישור-קו ─▶ 2 הגשר decompose→manifest ─▶ 3 מסך-שני
                                    │
        4 המחולל (emit) ◀───────────┘
              │
        5 ספריית-אטומים ─▶ 6 הפעלה-הדרגתית ─▶ 7 מניפסט-פר-ורטיקל (white-label)
```

**האינווריאנט לאורך כל הדרך:** אפס-סיכון ללקוח-החי — כל עוד flag off, האפליקציה
byte-identical. כל שלב = נחיל 9×9 · golden-first · central-verify ירוק · הכרעות-בעלים
מתועדות · אין push ל-main בלי אישור.

**נקודת-הכניסה הבאה:** שלב 1 (יישור-קו · תיקון 2 הגולדנים) — קטן, סוגר ל-100% ירוק,
ופותח את הגשר של שלב 2.
