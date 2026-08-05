# Ring‑DIVE — תוכנית שני‑שלבים + חוזה‑החיבור הקפוא

> נכתב 6/7 (החלטת‑בעלים): **שלב 1 — Claude‑Design** בונה את גלגל‑הטבעות כרכיב עצמאי עם דאטה‑דמו · **שלב 2 — סוכן‑חיווט** מחבר אותו למנוע‑הצלילה האמיתי.
> משלים את `SPEC-ring-dive.md` (העיצוב/אינטראקציה המלאים). **הקובץ הזה = החוזה שמאפשר לשני השלבים להתברג בלי שכתוב.**

---

## עיקרון: הרכיב עיוור לדאטה
הרכיב הוא **תצוגה טהורה**: לא מסנן, לא מחשב, לא מחזיק דאטה. הוא מקבל "מצב" ומדווח "נגיעות". כל הצמצום קורה בחוץ — בדמו: מעטפת‑דמו מזויפת; באפליקציה: מנוע‑הצלילה הקיים. **אסור למעצב להמציא עץ‑דאטה/לוגיקת‑חיפוש** — זה בדיוק מה שהופך את שלב‑2 לחיבור‑לגו במקום שכתוב.

## החוזה (API קפוא — אסור לשנות בלי אישור‑בעלים)
```dart
/// מקטע על הטבעת הפעילה. id אטום — מוחזר כמו-שהוא ב-onSelect.
class RingSegment {
  final String id;          // אטום (בשלב-2: ה-payload של המנוע)
  final String label;       // תווית מלאה בעברית (מוצגת במרכז כשבפוקוס)
  final String shortLabel;  // תווית קצרה לקשת (או emoji)
  final String? emoji;
}

/// טבעת פנימית נעולה (בחירה שכבר בוצעה).
class LockedRing {
  final String axisLabel;   // למשל 'גודל'
  final String valueLabel;  // למשל '½"'
  final String? emoji;
}

/// פריט ברצועת-התוצאות החיה.
class RingProduct {
  final String id;          // אטום (בשלב-2: sku)
  final String label;       // תווית-תצוגה ייחודית
}

/// המצב המלא שהרכיב מצייר. הרכיב לא משנה אותו — רק מצייר.
class RingDiveState {
  final List<LockedRing> locked;   // מהפנימית לחיצונית, לפי סדר-הצלילה
  final String activeAxisLabel;    // הציר של הטבעת הפעילה, למשל 'חומר'
  final List<RingSegment> active;  // מקטעי הטבעת הפעילה (עד 10; מעבר → הרכיב מציג 'עוד ›')
  final List<RingProduct> results; // הבריכה הנוכחית, עד 12
  final bool isEmpty;              // בריכה ריקה → slot מצב-ריק
}

/// הרכיב. תצוגה טהורה + callbacks. אפס גישה ל-state/מנוע של האפליקציה.
class RingDiveWheel extends StatefulWidget {
  final RingDiveState state;
  final ValueChanged<String> onSelect;     // נבחר מקטע (id)
  final ValueChanged<int>    onBackTo;     // נגיעה בטבעת-נעולה index → חזרה לעומק ההוא
  final ValueChanged<String> onProductTap; // נגיעה במוצר ברצועה/במרכז (id)
  final VoidCallback?        onRestart;    // פעולת מצב-ריק
}
```
- **State פנימי מותר לרכיב:** זווית‑סיבוב/אנימציות/פוקוס בלבד. שום דבר עסקי.
- **בשלב‑2:** `RingDiveState` נבנה מפלט תור‑הצלילה (`mergedKeys`) · `onSelect` → `_pushStep` (payload‑מטיפוס) · `onBackTo` → pop‑stack · `onProductTap` → `lipskey_product_sheet` · `onRestart` → `_restart`.

## שלב 1 — הוראה ל‑Claude‑Design (רכיב+דמו, מבודד)
- לבנות מודול עצמאי: `lib/features/ring_dive/` — `ring_dive_wheel.dart` (הרכיב, לפי החוזה למעלה, מילה‑במילה) + `ring_dive_demo_screen.dart` (מעטפת‑דמו).
- **בידוד מוחלט:** אפס imports מ‑state/מנוע/מסכים קיימים · אפס עריכה של קבצים קיימים · הדמו רץ standalone.
- **דאטה‑דמו** בטעם‑אינסטלציה (עברית RTL אמיתית): מילים: ברז/מחסום/צינור/ברך · גדלים: ½"/¾"/DN40 · חומרים: נחושת/PPR/HDPE · צבעים: לבן/שחור · ~20 "מוצרים". מעטפת‑הדמו מזייפת צמצום (כל בחירה מקטינה את הרשימות) — **בתוך המעטפת, לא בתוך הרכיב.**
- **עיצוב/אינטראקציה:** לפי `SPEC-ring-dive.md` §2–§4 במלואם — פוקוס 12:00 · קריאת‑מרכז לתווית המלאה · גרירה‑סיבובית atan2 + detent‑snap + `HapticFeedback.selectionClick()` · בחירה: כיווץ 1→0.8 (300ms easeOutCubic) + טבעת‑חדשה fade+scale 0.9→1 · נעולות מוקטנות עם הערך · 'עוד ›' מעל 10 · שפת‑העיצוב הקיימת (BsTokens: כתום מותג, פינות, כהה/בהיר).
- **נגישות (חובה):** כל מקטע `Semantics(button, 'ציר: ערך')` הניתן להקשה ישירה בלי סיבוב · ≥48dp · `liveRegion` "נשארו N מוצרים" · `reduceMotion` → בלי אנימציות · `textScaler` · RTL מלא.
- **ביצועים:** `RepaintBoundary` פר‑טבעת · סיבוב=transform בלבד · rebuild רצועה רק ב‑detent.
- **מסירה (DoD שלב‑1):** analyze‑0 · widget‑tests (בחירה מפעילה onSelect עם ה‑id הנכון · onBackTo · empty‑state · Semantics · reduceMotion) · הדמו רץ · **החוזה לא שונה.**

## שלב 2 — הוראה לסוכן‑החיווט (אחרי אישור‑feel של הבעלים על הדמו)
- לקחת את הרכיב **כמו‑שהוא** (אסור לשנות את החוזה) ולחבר: adapter יחיד `ring_dive_adapter.dart` שממפה תור‑צלילה→`RingDiveState` ו‑callbacks→handlers הקיימים (`_pushStep`/pop/`lipskey_product_sheet`/`_restart`).
- גידור `kRingDive` (env `RING_DIVE`) default OFF = byte‑identical · A/B pill "צלילת‑טבעות" לצד "מקלדת חכמה" · אסור לגעת בהתנהגות word_finder/card_keyboard החיים.
- בדיקות: הסוויטות הקיימות ירוקות · טסט‑אינטגרציה (בחירה בגלגל → הבריכה באמת מצטמצמת — מקביל לטסט‑ההקשה של המקלדת) · goldens.
- DoD: analyze‑0 · הכל ירוק · APK + web‑preview עם `RING_DIVE=true` ל‑feel‑test · בלי הדלקה‑חיה בלי אישור‑בעלים.

## למה ככה
המעצב חופשי לגמרי על ה‑ויזואליה (שלב‑1 לא נוגע באפליקציה בכלל) · המחווט לא צריך להבין עיצוב (שלב‑2 = adapter אחד) · והחוזה‑הקפוא באמצע מבטיח שהלגו מתברג. אם מישהו משנה את החוזה — שני השלבים נשברים; לכן שינוי‑חוזה = אישור‑בעלים בלבד.
