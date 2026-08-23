# Handoff לבנצי — Huliot SmartLock P10 (R2 upload)

> **קטלגן → בנצי**, 2026-06-02. הקטלוג + כל הלוגיקה של חוליות סגורים 100%.
> נשאר רק upload של 172 קבצים שאני לא יכול לבצע בלי credentials.

---

## TL;DR

חוליות בקוד = ✅ 100% parity עם Polyroll (11/11 + smart-tree 170/170 + P11 installKit).
חוליות ב-deploy = 🔴 כרטיסי-מוצר מציגים עמוד-קטלוג מלא במקום crop ייעודי —
כי **172 קבצי-תמונה לא הועלו ל-Cloudflare R2**. ה-fallback אקטיבי דרך 2 flags
זמניים כדי שהכרטיסים לא יתרוקנו ב-web/release (אבחנה שלך, hotfix v5.80).

---

## הבעיה ב-30 שניות

| תרחיש | תוצאה |
|---|---|
| Web/release, IMAGE_BASE_URL מוגדר ל-R2 | `CachedNetworkImage` מנסה למשוך `huliot_smartlock/products/sml_pNN_X.jpg` → CDN מחזיר 404 → flutter_cache_manager זורק חריגה → build fails → כרטיס ריק. |
| Web/release, אחרי v5.80 hotfix (פעיל עכשיו) | כרטיס מציג את `page_NN.jpg` של עמוד-הקטלוג המלא (כבר ב-R2) — תקין אבל לא יפה, אין crop ייעודי. |
| Debug/test מקומי | תקין (1041/1041) — קורא מהדיסק, לא דרך CDN. |

**הוכחת ה-404 שלך (קבצים שאני צריך):**
```
huliot_smartlock/products/sml_p25_a.jpg     ❌ 404
huliot_smartlock/products/spec_sml_p25_a.jpg ❌ 404
huliot_smartlock/pages/page_25.jpg          ✅ 200  ← זה למה fallback עובד
```

---

## מה אני צריך ממך

### צעד 1 — העלאה ל-R2

**מקור (172 קבצים, 1.1 MB סה"כ):**
```
app_flutter/assets/huliot_smartlock/products/sml_p*.jpg       (89 photo crops)
app_flutter/assets/huliot_smartlock/products/spec_sml_p*.jpg  (83 spec crops)
```

**יעד ב-bucket R2:**
```
huliot_smartlock/products/sml_p*.jpg
huliot_smartlock/products/spec_sml_p*.jpg
```

הנתיב הוא 1:1 מהמקור (נטרל את `assets/`). זה אותו mapping שעבד עבור
`huliot_smartlock/pages/page_*.jpg` שאתה כבר העלית בסשן הקודם.

**פקודה אפשרית (wrangler):**
```bash
cd app_flutter/assets/huliot_smartlock/products
wrangler r2 object put <bucket>/huliot_smartlock/products/<filename> --file <filename>
```
(או דרך `upload-images-to-r2.ps1` המתועד ב-`LAUNCH_PACKAGE/image-cdn-setup.md`.)

### צעד 2 — flip 2 flags בקוד

קובץ: `lib/data/huliot_smartlock_catalog.dart`

```dart
// ב-_huliotImageFor (סביב שורה 49):
const _routeCropDisabled = false;   // היה true → flip ל-false

// ב-_huliotSpecFor (סביב שורה 173):
const _specCropDisabled = false;    // היה true → flip ל-false
```

זה החלק היחיד בקוד. אין שינוי בלוגיקה — הרוטינג הקנוני נשמר ב-
`_huliotImageForCrop` המוכן ומחכה.

### צעד 3 — וידוא + הקשחת guards (אופציונלי)

קובץ: `test/spec_assets_test.dart`

```dart
// §17.1-Huliot — להחזיר את הבדיקה ל"is a real crop" (לא רק "exists"):
// כיום קוראים "every product front image exists"
// להחזיר ל-"every product front image exists + is a real crop"
// + להוסיף את ה-pageFallback check שהיה.
```

זה לא חובה — אם תפעיל את ה-flags ב-false, ה-§17.1 הנוכחי עדיין יעבור (page_
לא יוחזרו → לא יהיו רוטינגים כאלה). אבל בשלב 3 אתה מהדק שאי-אפשר לחזור אחורה
בלי שערים יידלקו.

---

## מה כבר מוכן בשבילך

| | |
|--|--|
| 172 קבצים מוכנים, נקראים מתוך `assets/huliot_smartlock/products/` | ✅ ב-repo |
| crop_huliot.py — re-generate בכל זמן (`python3 scripts/crop_huliot.py`) | ✅ |
| `_huliotImageForCrop` (הרוטינג הקנוני) שמור ופעיל ב-flip של flag | ✅ |
| §17.2-Huliot guard (כל מוצר עם specImageFile → קובץ קיים) | ✅ קוד-קודם |
| §17.1.b-Huliot orphan-guard (כל crop מקושר לרוטינג) | ✅ |
| stuck_log תיעוד מלא של הבאג + ANTIPATTERN + RULE | ✅ |
| HULIOT_TODO P10 instructions | ✅ |

---

## אחרי שתסיים

מצב סופי:
- 1041 tests pass ✅
- כל כרטיס Huliot ב-web/release מציג crop ייעודי 238×170 (לא עמוד מלא)
- ה-flip של flip side מציג דיאגרמת-חתך 238×~80 (לא עמוד מלא)
- ה-CDN מחזיק 172 קבצים נוספים (1.1 MB) — תוספת זניחה לבנדל
- ה-fallback ב-`_huliotImageFor`/`_huliotSpecFor` נשאר כ-safety-net לעתיד

ההתנהגות זהה לחלוטין למה ש-Polyroll מקבל מ-CDN — **100% parity אמיתי**.

---

## איש קשר

קטלגן (claude/whats-happening-LyY9G) · HULIOT_TODO.md sec P10 · stuck_log
"2026-06-02 — כרטיסי Huliot ריקים ב-web/release".
