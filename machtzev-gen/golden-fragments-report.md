# חציבת-הזהב (quarry-golden · G4a)

**9** מודולים · **1668** שברים · **378** שברי-תובנה (≥2 אטומים בשימוש) · **57** עם הצהרת-⊕ · הרכבה-חוזרת ביט-לביט: **✓ 9/9**

| מודול | שורות | שברים | תובנות | אטומים-בשימוש (ייחודיים) |
|---|---|---|---|---|
| schoolos.dart | 885 | 116 | 32 | 47 |
| schoolos_students.dart | 1367 | 221 | 41 | 72 |
| schoolos_attendance.dart | 1283 | 193 | 38 | 61 |
| schoolos_courses.dart | 1732 | 223 | 63 | 74 |
| schoolos_teachers.dart | 1152 | 177 | 34 | 56 |
| schoolos_rooms.dart | 1317 | 190 | 35 | 61 |
| schoolos_fees.dart | 1585 | 203 | 47 | 75 |
| schoolos_parents.dart | 1534 | 202 | 52 | 66 |
| schoolos_dashboard.dart | 1125 | 143 | 36 | 59 |

## דוגמאות-הצהרה (כותרת ⇒ אטומים-מוצהרים ⇒ בשימוש)
- `schoolos#46` איתור (הכרעה 23-ג · תובנה·3) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ n ⇒ [DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch] · בשימוש: DsSearch, smartFilter, smartScore, normSearch
- `schoolos#54` חריגה (הכרעה 23-ג · תובנה·2) = FilterChipPill ⊕ finderMatches ⇒ [FilterChipPill ⊕ finderMatches] · בשימוש: FilterChipPill, finderMatches
- `schoolos#57` ייצוא (הכרעה 23-ג · תובנה) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAl ⇒ [SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed] · בשימוש: SoftButton, toCsv, csvEscape, exportAllowed
- `schoolos#65` הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedA ⇒ [roleOf ⊕ canGrantedAction] · בשימוש: roleOf, canGrantedAction, label
- `schoolos#69` אוטומציות פרואקטיביות (הכרעה 23-ג · תובנה) = AlertBanner ⊕ expiringInt ⇒ [AlertBanner ⊕ expiringIntakes ⊕ warehouseValue] · בשימוש: AlertBanner, expiringIntakes, warehouseValue
- `schoolos#75` מחזור-חיים · מצב-מיוחד "פריט-לא-פעיל" (23-ב · דגל=עובדה) = StatusChip  ⇒ [StatusChip ⊕ SoftButton] · בשימוש: StatusChip, SoftButton
- `schoolos#102` ייצוא (23-ג · תובנה) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed  ⇒ [SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ GlassCard] · בשימוש: SoftButton, toCsv, csvEscape, exportAllowed, GlassCard, MediaRow, AlertBanner, TimelineItem
- `schoolos_students#124` איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch  ⇒ [DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch ⊕ normPhone] · בשימוש: DsSearch, smartFilter, smartScore, normSearch, normPhone, norm
- `schoolos_students#130` חריגה/פילטרים (הכרעה 23-ג) = FilterChipPill⊕DsEnumField ⊕ finderMatche ⇒ [FilterChipPill ⊕ DsEnumField ⊕ finderMatches ⊕ numMatch] · בשימוש: FilterChipPill, DsEnumField, finderMatches, numMatch
- `schoolos_students#139` הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedA ⇒ [roleOf ⊕ canGrantedAction] · בשימוש: roleOf, canGrantedAction, label
- `schoolos_attendance#92` הרשאות-פר-תפקיד (חוק-6 · הכרעה 23-ג) = roleOf ⊕ canGrantedAction — 6 ת ⇒ [roleOf ⊕ canGrantedAction] · בשימוש: roleOf, canGrantedAction
- `schoolos_attendance#109` איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch  ⇒ [DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch] · בשימוש: DsSearch, smartFilter, smartScore, normSearch
- `schoolos_attendance#117` חריגה (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches — 10 צירי-נעילה (ה ⇒ [FilterChipPill ⊕ finderMatches] · בשימוש: FilterChipPill, finderMatches, label
- `schoolos_attendance#120` ייצוא (23-ג) = toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport — שורות ⇒ [toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport] · בשימוש: toCsv, csvEscape, exportAllowed, guardExport, label
- `schoolos_attendance#187` ייצוא (23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardE ⇒ [SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport ⊕ GlassCard] · בשימוש: SoftButton, toCsv, csvEscape, exportAllowed, guardExport, GlassCard, fmtDate
- `schoolos_courses#40` זיהוי-חריגה · התנגשויות (מורה/חדר = הרכבת sessionsOf⊕timeToMin · תלמיד ⇒ [scheduleClashText] · בשימוש: sessionsOf, timeToMin, scheduleClashText
- `schoolos_courses#58` גריד-שבועי: שעות = טווח מפגשי-החוגים-החיים (timeToMin), צעד 60; תוויות ⇒ [minToHM] · בשימוש: timeToMin, minToHM
- `schoolos_courses#114` איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch  ⇒ [DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch] · בשימוש: DsSearch, smartFilter, smartScore, normSearch
- `schoolos_courses#122` חריגה/סינון (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches — 13 צירים · ⇒ [FilterChipPill ⊕ finderMatches] · בשימוש: FilterChipPill, finderMatches, SegmentedSwitch, DsSearch, sessionsOf, timeToMin
- `schoolos_courses#127` הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedA ⇒ [roleOf ⊕ canGrantedAction ⊕ teacherIdOf] · בשימוש: roleOf, canGrantedAction, teacherIdOf, label
