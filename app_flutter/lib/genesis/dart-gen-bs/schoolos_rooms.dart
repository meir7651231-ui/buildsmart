// 🏫 SchoolOS · חדרים ויומן-מרחבים (ROOMS) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) לפי
// המפרט knowledge/SPEC-ROOMS-FULL-2026-09-04.md. קובץ יחיד · מחלקה ציבורית אחת: RoomsScreen.
//
// 🎯 המטרה (צעד-1, ליבה): "שכל מרחב ינוצל נכון — אף חדר לא כפול-תפוס, אף שיעור לא בלי-חדר,
//    אף ציוד לא נעלם — ורואים את השבוע של הבניין במבט-אחד."
// 🔺 פעולות-היסוד (צעד-2): איתור (חדר/משבצת) · הערכת-מצב (תפוס-עכשיו · ניצולת) · זיהוי-חריגה
//    (כפל-תפיסה · תקלה · חסימה · לא-מנוצל · ציוד-חסר) · הכרעה (חדר-חלופי · אישור) ·
//    ביצוע (הזמן · העבר · בטל · תקלה · חסימה) · אימות (היסטוריה · אודיט · ייצוא).
// 🔎 צעד-3 · חיפוש-מלא בשני המקורות + האורקל (atom-index-full 1402): מנועי-היומן של מאור
//    (diary/lib.ts ⇒ buildSlots · roomsNow · weeklyRoomSessions · blockReason · inactiveRoomCourses ·
//    roomInfoLabel · scheduleClashText · timeToMin · minToHM · sessionsOf · termOf · hebParts · HOLIDAYS ·
//    upcomingHolidays · buildIcs) + בנייה-חכמה (startOfWeekSunday · daysBetweenDst · סטטוס-אישור של TaskItem).
//    "אין אטום" = "לא-חיפשת": כל "אין" שנבדק התבדה (יומן-חדרים שלם קיים במאור).
// 🧩 צעד-4 · הרכבה תמיד (לעולם לא אטום-יחיד לתובנה) — ראה הערת-הרכבה מעל כל חלקיק.
// 🔌 צעד-5 · חיווט בשקעים: today/now מוזרקים (אפס Date.now במנוע) · זהות=roleDefs (חוק-6) · צבע=הצבה.
// 📷 צעד-6 · אימות-מול-המטרה ברנדר: בדיקת-widget ב-buildsmart (test/genesis_rooms_test.dart).
// ⛔ §20-ג אפס-זיוף: כל שדה בדאטה = מקור-אמת (מאור Room/Course/OrgEvent · בנייה-חכמה TaskItem-defect);
//    חסר-מקור ⇒ מקום-שמור בחוזה-הדאטה (חוק-7), לעולם לא ערך-מומצא.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/bare_stat.dart'; // עובדה-אטומית: ערך+תווית (KPI, פיגמנט מוזרק)
import '../dart-ui-bs/premium/surfaces/gradient_card.dart'; // מיכל-KPI
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // הערך-הבולט (המטרה: התנגשויות=0)
import '../dart-ui-bs/premium/feedback/alert_banner.dart'; // התראה/מצב-שגיאה
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // מצב "אין-חדרים"/"אין-תוצאות"
import '../dart-maor/rooms-now.dart'; // הערכת-מצב: תפוס/פנוי-עכשיו (מדף מאור, יומן-חדרים)
import '../dart-maor/weekly-room-sessions.dart'; // הערכת-מצב: מפגשים-שבועיים פר-חדר (ניצולת)
import '../dart-maor/build-slots.dart'; // יומן: משבצות-היום של חדר (חוג/אירוע/חסום/ניקיון/פנוי)
import '../dart-maor/time-to-min.dart'; // "HH:MM"⇒דקות (שקע ל-buildSlots)
import '../dart-maor/min-to-hm.dart'; // דקות⇒"HH:MM" (שקע ל-buildSlots)
import '../dart-maor/pad2.dart'; // ריפוד-2 (שקע ל-minToHM)
import '../dart-maor/sessions-of.dart'; // מפגשי-חוג בפועל (sessions או weekday/time)
import '../dart-maor/term-of.dart'; // מונח-פר-ארגון (שקע ל-buildSlots)
import '../dart-maor/block-reason.dart'; // חריגה: חסימת-יום (שבת/שישי/חג/צום-נדחה/חוה"מ)
import '../dart-maor/heb-parts.dart'; // לוח-עברי: תאריך⇒{day,month,year}
import '../dart-maor/holidays.dart'; // מפת-חגים "חודש יום"⇒שם
import '../dart-maor/iso-local.dart'; // DateTime⇒'YYYY-MM-DD'
import '../dart-maor/count-by.dart'; // ספירה-לפי-מפתח (קיבוץ)
import '../dart-maor/inactive-room-courses.dart'; // חריגה: שיעור בלי-חדר-פעיל
import '../dart-data-maor/block-reason-strings.dart'; // BLOCK_REASON_T (מחרוזות-החסימה, אטום-דאטה)
import '../dart-data-maor/block-reason-data.dart'; // FULL_HOLIDAYS (חגים ללא-פעילות, אטום-דאטה)
import '../dart-data-maor/build-slots-strings.dart'; // BUILD_SLOTS_T (תוויות-המשבצות, אטום-דאטה)
import '../dart-data-maor/inactive-room-courses-strings.dart'; // INACTIVE_ROOM_COURSES_T
import '../dart/start_of_week_sunday.dart'; // בנייה-חכמה: תחילת-שבוע (ראשון)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════ דאטה-אמת + מנוע-טהור (אפס-DOM · אפס Date.now · today/now מוזרקים) ═══════════
// 🔴 סכמת-חדר = רק שדות עם מקור-אמת (§20-ג):
//   Room (מאור schema-fields.dart:928-996): id·name·active·slot·cap·location·rate·from·to·access·notes·eq{k:bool}
//   Course (מאור :364-594): id·name·teacherId·roomId·start·end·weekday·time·sessions[{day,time,label}]·maxStudents·cat
//   OrgEvent (מאור :1000-1074): id·title·date·time·type·roomId·priority·done·notes
//   Fault = TaskItem kind='defect' (בנייה-חכמה state/tasks_engine.dart:70-112 + defects_sheet.dart:57):
//     id·name·detail·status(pending·active·review·done·rejected·proposed)·severity(חמור·בינוני·קל)·createdBy·days
//   סטטוס-אישור-הזמנה = אוצר-המילים של TaskItem.status (proposed=ממתין-אישור · pending=מאושר · rejected=נדחה)
//   קלט-תכנון (כמו target/rate/lead במלאי): needsEq (ציוד-נדרש-לשיעור) · utilFloor (סף-ניצולת) · policy (מדיניות-הזמנה)
//   ⛔ ללא-מקור ⇒ מקום-שמור (חוק-7), לא בדאטה: type·floor·owner·lastCheck·updatedAt·photo·floorMap·sensor·smartLock
class _RoomsData {
  static const today = '2026-09-03'; // יום חמישי — תאריך-הזרקה דטרמיניסטי (אפס Date.now במנוע)
  static final DateTime now = DateTime(2026, 9, 3, 10, 15); // "עכשיו" מוזרק ל-roomsNow
  static const int utilFloor = 30; // סף-ניצולת (%) — מתחתיו "חדר-לא-מנוצל" (קלט-תכנון)
  static const int activeDays = 6; // ימי-פעילות ראשון–שישי (dayNames של מאור = 6)

  // ── חדרים (מאור Room) ──
  static const rooms = <Map<String, dynamic>>[
    {'id': 'r1', 'name': 'כיתה 101', 'active': true, 'slot': 60, 'cap': 32, 'location': 'בניין א׳ · קומה 1', 'from': '08:00', 'to': '15:00', 'access': true, 'notes': '', 'eq': {'מקרן': true, 'לוח-חכם': true, 'מזגן': true}},
    {'id': 'r2', 'name': 'מעבדת מדעים', 'active': true, 'slot': 60, 'cap': 24, 'location': 'בניין ב׳ · קומה 2', 'from': '08:00', 'to': '16:00', 'access': false, 'notes': 'כיור-חירום בכניסה', 'eq': {'מקרן': true, 'מזגן': true, 'כיורים': true}},
    {'id': 'r3', 'name': 'חדר מחשבים', 'active': true, 'slot': 60, 'cap': 28, 'location': 'בניין א׳ · קומה 2', 'from': '08:00', 'to': '16:00', 'access': true, 'notes': '', 'eq': {'מחשבים': true, 'מקרן': true, 'מזגן': false}},
    {'id': 'r4', 'name': 'אולם ספורט', 'active': true, 'slot': 60, 'cap': 120, 'location': 'בניין ג׳ · קרקע', 'from': '08:00', 'to': '17:00', 'access': true, 'notes': '', 'eq': {'מזרנים': true, 'מגבר': true}},
    {'id': 'r5', 'name': 'כיתה 204', 'active': true, 'slot': 60, 'cap': 30, 'location': 'בניין ב׳ · קומה 2', 'from': '08:00', 'to': '15:00', 'access': true, 'notes': '', 'eq': {'מקרן': false, 'מזגן': true}},
    {'id': 'r6', 'name': 'חדר מורים', 'active': true, 'slot': 60, 'cap': 16, 'location': 'בניין א׳ · קומה 1', 'from': '08:00', 'to': '16:00', 'access': true, 'notes': '', 'eq': {'מדפסת': true, 'מזגן': true}},
    {'id': 'r7', 'name': 'אודיטוריום', 'active': false, 'slot': 60, 'cap': 220, 'location': 'בניין ג׳ · קומה 1', 'from': '08:00', 'to': '20:00', 'access': true, 'notes': 'בשיפוץ עד סוף אוקטובר', 'eq': {'מקרן': true, 'מגבר': true}},
  ];

  // ── חוגים/שיעורים (מאור Course) — תפיסות-חוזרות (שבועיות) · sessions=[{day(0=ראשון),time}] ──
  static const courses = <Map<String, dynamic>>[
    // כיתה 101 (r1) — 17 מפגשים/שבוע מתוך 42 ⇒ 40%
    {'id': 'c1', 'name': 'מתמטיקה י׳-1', 'teacherId': 't1', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'מדעים', 'sessions': [{'day': 0, 'time': '08:00', 'label': ''}, {'day': 2, 'time': '10:00', 'label': ''}, {'day': 4, 'time': '09:00', 'label': ''}]},
    {'id': 'c9', 'name': 'אנגלית י׳-1', 'teacherId': 't6', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'שפות', 'sessions': [{'day': 0, 'time': '09:00', 'label': ''}, {'day': 1, 'time': '10:00', 'label': ''}, {'day': 3, 'time': '08:00', 'label': ''}, {'day': 4, 'time': '12:00', 'label': ''}]},
    {'id': 'c10', 'name': 'תנ״ך י׳-1', 'teacherId': 't3', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 1, 'time': '08:00', 'label': ''}, {'day': 2, 'time': '11:00', 'label': ''}, {'day': 3, 'time': '13:00', 'label': ''}]},
    {'id': 'c11', 'name': 'לשון י׳-1', 'teacherId': 't6', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'שפות', 'sessions': [{'day': 0, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '08:00', 'label': ''}, {'day': 3, 'time': '10:00', 'label': ''}]},
    {'id': 'c12', 'name': 'אזרחות י׳-1', 'teacherId': 't3', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 1, 'time': '12:00', 'label': ''}, {'day': 2, 'time': '12:00', 'label': ''}]},
    {'id': 'c13', 'name': 'פיזיקה י׳', 'teacherId': 't2', 'roomId': 'r1', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 28, 'cat': 'מדעים', 'needsEq': ['מקרן'], 'sessions': [{'day': 0, 'time': '13:00', 'label': ''}, {'day': 3, 'time': '11:00', 'label': ''}]},
    // מעבדת מדעים (r2) — 17/48 ⇒ 35% · c2⊕c3 ביום חמישי 10:00 = כפל-תפיסה (התנגשות-אמת)
    {'id': 'c2', 'name': 'כימיה יא׳', 'teacherId': 't2', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 22, 'cat': 'מדעים', 'needsEq': ['כיורים', 'מקרן'], 'sessions': [{'day': 1, 'time': '09:00', 'label': ''}, {'day': 4, 'time': '10:00', 'label': ''}]},
    {'id': 'c3', 'name': 'ביולוגיה יב׳', 'teacherId': 't3', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 26, 'cat': 'מדעים', 'needsEq': ['מקרן'], 'sessions': [{'day': 4, 'time': '10:00', 'label': ''}, {'day': 3, 'time': '12:00', 'label': ''}]},
    {'id': 'c14', 'name': 'פיזיקה-מעבדה יב׳', 'teacherId': 't2', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 20, 'cat': 'מדעים', 'sessions': [{'day': 0, 'time': '09:00', 'label': ''}, {'day': 2, 'time': '09:00', 'label': ''}, {'day': 3, 'time': '08:00', 'label': ''}]},
    {'id': 'c15', 'name': 'כימיה יב׳', 'teacherId': 't2', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 22, 'cat': 'מדעים', 'needsEq': ['כיורים'], 'sessions': [{'day': 1, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '13:00', 'label': ''}, {'day': 4, 'time': '08:00', 'label': ''}]},
    {'id': 'c16', 'name': 'מדעים ז׳', 'teacherId': 't3', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 24, 'cat': 'מדעים', 'sessions': [{'day': 0, 'time': '12:00', 'label': ''}, {'day': 1, 'time': '13:00', 'label': ''}, {'day': 3, 'time': '10:00', 'label': ''}, {'day': 4, 'time': '13:00', 'label': ''}]},
    {'id': 'c17', 'name': 'ביולוגיה י׳', 'teacherId': 't3', 'roomId': 'r2', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 24, 'cat': 'מדעים', 'sessions': [{'day': 0, 'time': '14:00', 'label': ''}, {'day': 2, 'time': '11:00', 'label': ''}, {'day': 3, 'time': '14:00', 'label': ''}]},
    // חדר מחשבים (r3) — 15/48 ⇒ 31%
    {'id': 'c4', 'name': 'תכנות ט׳', 'teacherId': 't4', 'roomId': 'r3', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 28, 'cat': 'טכנולוגיה', 'needsEq': ['מחשבים', 'מקרן'], 'sessions': [{'day': 0, 'time': '10:00', 'label': ''}, {'day': 4, 'time': '13:00', 'label': ''}]},
    {'id': 'c18', 'name': 'סייבר יא׳', 'teacherId': 't4', 'roomId': 'r3', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 24, 'cat': 'טכנולוגיה', 'needsEq': ['מחשבים'], 'sessions': [{'day': 1, 'time': '09:00', 'label': ''}, {'day': 2, 'time': '10:00', 'label': ''}, {'day': 3, 'time': '09:00', 'label': ''}, {'day': 4, 'time': '09:00', 'label': ''}]},
    {'id': 'c19', 'name': 'מחשבים ז׳', 'teacherId': 't4', 'roomId': 'r3', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 28, 'cat': 'טכנולוגיה', 'needsEq': ['מחשבים'], 'sessions': [{'day': 0, 'time': '08:00', 'label': ''}, {'day': 1, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '12:00', 'label': ''}, {'day': 3, 'time': '13:00', 'label': ''}]},
    {'id': 'c20', 'name': 'עריכת-וידאו', 'teacherId': 't4', 'roomId': 'r3', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 16, 'cat': 'אמנויות', 'needsEq': ['מחשבים'], 'sessions': [{'day': 2, 'time': '14:00', 'label': ''}, {'day': 4, 'time': '11:00', 'label': ''}]},
    {'id': 'c21', 'name': 'רובוטיקה ט׳', 'teacherId': 't4', 'roomId': 'r3', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 20, 'cat': 'טכנולוגיה', 'needsEq': ['מחשבים'], 'sessions': [{'day': 0, 'time': '12:00', 'label': ''}, {'day': 1, 'time': '13:00', 'label': ''}, {'day': 3, 'time': '11:00', 'label': ''}]},
    // אולם ספורט (r4) — 7/54 ⇒ 13% (לא-מנוצל)
    {'id': 'c5', 'name': 'חינוך גופני ח׳', 'teacherId': 't5', 'roomId': 'r4', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 60, 'cat': 'ספורט', 'sessions': [{'day': 1, 'time': '08:00', 'label': ''}, {'day': 4, 'time': '08:00', 'label': ''}]},
    {'id': 'c22', 'name': 'חינוך גופני ז׳', 'teacherId': 't5', 'roomId': 'r4', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 60, 'cat': 'ספורט', 'sessions': [{'day': 0, 'time': '09:00', 'label': ''}, {'day': 2, 'time': '09:00', 'label': ''}, {'day': 3, 'time': '09:00', 'label': ''}]},
    {'id': 'c23', 'name': 'נבחרת כדורסל', 'teacherId': 't5', 'roomId': 'r4', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 15, 'cat': 'ספורט', 'sessions': [{'day': 1, 'time': '14:00', 'label': ''}, {'day': 3, 'time': '14:00', 'label': ''}]},
    // כיתה 204 (r5) — 20/42 ⇒ 48% · המקרן שרוף (תקלה-חמורה) ⇒ ציוד-נדרש חסר לשיעורי-מקרן
    {'id': 'c6', 'name': 'היסטוריה י׳-2', 'teacherId': 't6', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 34, 'cat': 'רוח', 'needsEq': ['מקרן'], 'sessions': [{'day': 4, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '13:00', 'label': ''}]},
    {'id': 'c24', 'name': 'גיאוגרפיה י׳-2', 'teacherId': 't3', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 0, 'time': '08:00', 'label': ''}, {'day': 1, 'time': '09:00', 'label': ''}, {'day': 3, 'time': '10:00', 'label': ''}]},
    {'id': 'c25', 'name': 'אנגלית י׳-2', 'teacherId': 't6', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'שפות', 'sessions': [{'day': 0, 'time': '09:00', 'label': ''}, {'day': 1, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '08:00', 'label': ''}, {'day': 4, 'time': '08:00', 'label': ''}]},
    {'id': 'c26', 'name': 'היסטוריה יא׳', 'teacherId': 't6', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 0, 'time': '11:00', 'label': ''}, {'day': 2, 'time': '10:00', 'label': ''}, {'day': 3, 'time': '12:00', 'label': ''}]},
    {'id': 'c27', 'name': 'ספרות י׳-2', 'teacherId': 't6', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 1, 'time': '13:00', 'label': ''}, {'day': 3, 'time': '08:00', 'label': ''}, {'day': 4, 'time': '13:00', 'label': ''}]},
    {'id': 'c28', 'name': 'תנ״ך י׳-2', 'teacherId': 't3', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'רוח', 'sessions': [{'day': 0, 'time': '13:00', 'label': ''}, {'day': 2, 'time': '11:00', 'label': ''}, {'day': 4, 'time': '09:00', 'label': ''}]},
    {'id': 'c29', 'name': 'חשבון ז׳', 'teacherId': 't1', 'roomId': 'r5', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 30, 'cat': 'מדעים', 'sessions': [{'day': 1, 'time': '08:00', 'label': ''}, {'day': 3, 'time': '13:00', 'label': ''}]},
    // שיעור-בלי-חדר-פעיל (r7 בשיפוץ) · שיעור-בלי-חדר (roomId ריק) — חריגות-אמת ל-inactiveRoomCourses
    {'id': 'c7', 'name': 'סדנת רובוטיקה', 'teacherId': 't4', 'roomId': 'r7', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 20, 'cat': 'טכנולוגיה', 'needsEq': ['מחשבים'], 'sessions': [{'day': 4, 'time': '14:00', 'label': ''}]},
    {'id': 'c8', 'name': 'ספרות יא׳', 'teacherId': 't6', 'roomId': '', 'start': '2026-09-01', 'end': '2027-06-20', 'maxStudents': 28, 'cat': 'רוח', 'sessions': [{'day': 4, 'time': '12:00', 'label': ''}]},
  ];

  // ── אירועים/הזמנות חד-פעמיות (מאור OrgEvent ⊕ סטטוס-אישור מבנייה-חכמה) ──
  static const events = <Map<String, dynamic>>[
    {'id': 'e1', 'title': 'ישיבת-צוות מדעים', 'date': '2026-09-03', 'time': '12:00', 'type': 'meeting', 'roomId': 'r6', 'priority': 'green', 'done': false, 'notes': '', 'status': 'pending', 'requestedBy': 't2', 'attendees': 12},
    {'id': 'e2', 'title': 'הרצאת-אורח בטיחות', 'date': '2026-09-03', 'time': '11:00', 'type': 'lecture', 'roomId': 'r1', 'priority': 'orange', 'done': false, 'notes': 'דורש מקרן', 'status': 'proposed', 'requestedBy': 't1', 'attendees': 30},
    {'id': 'e3', 'title': 'מבחן-מתכונת מתמטיקה', 'date': '2026-09-03', 'time': '09:00', 'type': 'exam', 'roomId': 'r1', 'priority': 'red', 'done': false, 'notes': '', 'status': 'pending', 'requestedBy': 't1', 'attendees': 30},
    {'id': 'e4', 'title': 'אסיפת-הורים ט׳', 'date': '2026-09-06', 'time': '18:00', 'type': 'meeting', 'roomId': 'r4', 'priority': 'green', 'done': false, 'notes': '', 'status': 'proposed', 'requestedBy': 's1', 'attendees': 150},
    {'id': 'e5', 'title': 'חוג-שחמט (חיצוני)', 'date': '2026-09-03', 'time': '14:00', 'type': 'other', 'roomId': 'r5', 'priority': 'green', 'done': false, 'notes': '', 'status': 'rejected', 'requestedBy': 's1', 'attendees': 14},
  ];

  // ── תקלות (בנייה-חכמה TaskItem kind='defect' · roomId=מיקום) ──
  static const faults = <Map<String, dynamic>>[
    {'id': 'f1', 'roomId': 'r3', 'name': 'מזגן לא מקרר', 'detail': 'מזגן', 'status': 'active', 'severity': 'בינוני', 'createdBy': 't4', 'days': 3, 'date': '2026-08-31'},
    {'id': 'f2', 'roomId': 'r5', 'name': 'מקרן שרוף', 'detail': 'מקרן', 'status': 'pending', 'severity': 'חמור', 'createdBy': 't6', 'days': 1, 'date': '2026-09-02'},
    {'id': 'f3', 'roomId': 'r7', 'name': 'שיפוץ במה + חשמל', 'detail': '', 'status': 'active', 'severity': 'חמור', 'createdBy': 'm1', 'days': 45, 'date': '2026-08-01'},
    {'id': 'f4', 'roomId': 'r2', 'name': 'ברז דולף', 'detail': 'כיורים', 'status': 'done', 'severity': 'קל', 'createdBy': 't2', 'days': 2, 'date': '2026-08-20'},
  ];

  // ── מורים (מאור Teacher: id·name) — לתווית "מי-מזמין"/"מי-משתמש" ──
  static const teachers = <Map<String, dynamic>>[
    {'id': 't1', 'name': 'דנה כהן'}, {'id': 't2', 'name': 'יוסי לוי'}, {'id': 't3', 'name': 'מירב שלו'},
    {'id': 't4', 'name': 'אורי בן-דוד'}, {'id': 't5', 'name': 'רוני אזולאי'}, {'id': 't6', 'name': 'נועה פרץ'},
    {'id': 's1', 'name': 'מזכירות'}, {'id': 'm1', 'name': 'אחזקה'},
  ];
  static String teacherName(dynamic id) {
    for (final t in teachers) {
      if (t['id'] == id) return t['name'] as String;
    }
    return '—';
  }

  // db בצורת-הקלט של מנועי-מאור (rooms·courses·events)
  static Map<String, dynamic> get db => {'rooms': rooms, 'courses': courses, 'events': events};
  static const config = <String, dynamic>{'terms': {'entity.course': 'שיעור', 'entity.room': 'חדר'}}; // termOf

  // ── שקעים (חוק-1: השכנים מוזרקים, לא מיובאים ע"י האטומים) ──
  static num _t2m(dynamic t) => timeToMin(t) as num;
  static String _m2hm(dynamic m) => minToHM((m as num).toInt(), pad2);
  static List<dynamic> _sess(dynamic c) => sessionsOf(c) as List;
  static String _term(dynamic cfg, dynamic k, dynamic fb) => '${termOf(cfg, k, fb)}';
  static bool _onDate(dynamic c, dynamic iso) { // חוג פעיל בתאריך: start≤iso≤end (השוואת-ISO)
    final cm = c as Map;
    final s = '${cm['start'] ?? ''}', e = '${cm['end'] ?? ''}';
    return (s.isEmpty || '$iso'.compareTo(s) >= 0) && (e.isEmpty || '$iso'.compareTo(e) <= 0);
  }
  static ({int day, String month, int year}) _hp(DateTime d) {
    final p = hebParts(d);
    return (day: p['day'] as int, month: p['month'] as String, year: p['year'] as int);
  }
  static Map<String, dynamic> _room(String id) => rooms.firstWhere((r) => r['id'] == id, orElse: () => const {'id': '', 'name': '—'});

  // ═══ תאריכים · שבוע-הבניין = startOfWeekSunday(בנייה-חכמה) ⊕ isoLocal(מאור) × 6 ימי-פעילות ═══
  static DateTime get todayDt => DateTime.parse('${today}T12:00:00');
  static List<String> get weekIsos {
    final s = startOfWeekSunday(todayDt);
    return [for (var i = 0; i < activeDays; i++) isoLocal(DateTime(s.year, s.month, s.day + i))];
  }
  static int dow(String iso) => DateTime.parse('${iso}T12:00:00').weekday % 7; // 0=ראשון

  // ═══ חריגה · חסימת-יום = blockReason(מאור) ⊕ hebParts ⊕ HOLIDAYS ⊕ FULL_HOLIDAYS (סנכרון-לוח: חג/צום-נדחה/חוה"מ) ═══
  static String? blockOf(String iso) => blockReason(DateTime.parse('${iso}T12:00:00'), _hp, HOLIDAYS, FULL_HOLIDAYS, BLOCK_REASON_T);
  static String? holidayNameOf(DateTime d) {
    final p = hebParts(d);
    return HOLIDAYS['${p['month']} ${p['day']}'];
  }

  // ═══ יומן · משבצות-היום של חדר = buildSlots(מאור) — חוג/אירוע/חסום/ניקיון/פנוי, קדימות-המקור ═══
  static final Map<String, List<Map<String, dynamic>>> _slotCache = {};
  static void invalidate() => _slotCache.clear();
  static List<Map<String, dynamic>> slotsOf(Map<String, dynamic> room, String iso) =>
      _slotCache['${room['id']}|$iso'] ??= buildSlots(liveDb, room, iso, blockOf(iso), config, _t2m, _m2hm, _sess, _onDate, _term, BUILD_SLOTS_T);

  // ═══ פנקס-שינויים (פעולות=state · חוק-1 מצב=חיווט): הבסיס const + Σשינויים ⇒ מסך-אמת ═══
  static final List<Map<String, dynamic>> extraEvents = []; // הזמנות חדשות
  static final Map<String, String> eventStatus = {}; // שינויי-סטטוס (approve/reject/cancel)
  static final Map<String, String> eventRoom = {}; // העברת-תפיסה לחדר-אחר
  static final Map<String, String> courseRoom = {}; // העברת-שיעור לחדר-אחר
  static final Map<String, bool> roomActive = {}; // סמן-לא-זמין/שיפוץ
  static final Map<String, String> faultStatus = {}; // סגור-תקלה
  static final List<Map<String, dynamic>> extraFaults = []; // דיווח-תקלה
  static final Map<String, Map<String, bool>> eqAdj = {}; // הוסף-ציוד / דווח-חסר
  static final Set<String> blockedDates = {}; // חסום-תאריך (ידני)
  static final List<Map<String, dynamic>> audit = []; // אודיט: {when, who, what, target}
  static void log(String who, String what, String target) => audit.insert(0, {'when': today, 'who': who, 'what': what, 'target': target});

  static bool activeOf(Map<String, dynamic> r) => roomActive[r['id']] ?? (r['active'] as bool? ?? true);
  static Map<String, bool> eqOf(Map<String, dynamic> r) => {...((r['eq'] as Map?)?.cast<String, bool>() ?? const {}), ...(eqAdj[r['id']] ?? const {})};
  static String statusOfEvent(Map<String, dynamic> e) => eventStatus[e['id']] ?? '${e['status'] ?? 'pending'}';
  static String statusOfFault(Map<String, dynamic> f) => faultStatus[f['id']] ?? '${f['status']}';
  static String roomOfEvent(Map<String, dynamic> e) => eventRoom[e['id']] ?? '${e['roomId'] ?? ''}';
  static String roomOfCourse(Map<String, dynamic> c) => courseRoom[c['id']] ?? '${c['roomId'] ?? ''}';

  // רשומות-חיות (בסיס + פנקס) — בצורת-הקלט של המנועים; אירוע שנדחה/בוטל ⇒ done (buildSlots מדלג)
  static List<Map<String, dynamic>> get liveRooms => [for (final r in rooms) {...r, 'active': activeOf(r), 'eq': eqOf(r)}];
  static List<Map<String, dynamic>> get liveCourses => [for (final c in courses) {...c, 'roomId': roomOfCourse(c)}];
  static List<Map<String, dynamic>> get liveEvents => [
        for (final e in [...extraEvents, ...events])
          {...e, 'roomId': roomOfEvent(e), 'status': statusOfEvent(e), 'done': (e['done'] == true) || statusOfEvent(e) == 'rejected' || statusOfEvent(e) == 'cancelled'},
      ];
  static List<Map<String, dynamic>> get liveFaults => [for (final f in [...extraFaults, ...faults]) {...f, 'status': statusOfFault(f)}];
  static Map<String, dynamic> get liveDb => {'rooms': liveRooms, 'courses': liveCourses, 'events': liveEvents};

  // ═══ הערכת-מצב (KPI) · כל מדד = הרכבה של מנועי-מדף/שדות-אמת (אפס StatBlock) ═══
  static List<Map<String, dynamic>> get activeRooms => liveRooms.where(activeOf).toList();
  // תפוס-עכשיו = roomsNow(מאור): חדר-פעיל × מפגש שחל עכשיו ⇒ busyWith
  static List<Map<String, dynamic>> get nowRows => roomsNow(liveDb, now, _sess).cast<Map<String, dynamic>>();
  static Map<String, dynamic>? busyNow(Map<String, dynamic> r) {
    for (final row in nowRows) {
      if ((row['room'] as Map)['id'] == r['id']) return row['busyWith'] as Map<String, dynamic>?;
    }
    return null;
  }
  static int get busyNowN => nowRows.where((x) => x['busyWith'] != null).length;
  static int get freeNowN => nowRows.length - busyNowN;

  // ניצולת-שבועית% = weeklyRoomSessions(מאור) ÷ קיבולת-משבצות-שבועית ((to−from)/slot × ימים) — יחס מפורק
  static int weeklyCap(Map<String, dynamic> r) {
    final from = _t2m(r['from']), to = _t2m(r['to']);
    final slot = (r['slot'] is num && (r['slot'] as num) > 0) ? r['slot'] as num : 60;
    final f = from.isNaN ? 8 * 60 : from, t = to.isNaN ? 20 * 60 : to;
    return (((t - f) / slot).floor() * activeDays).clamp(1, 1 << 20);
  }
  static int weeklyUsed(Map<String, dynamic> r) => weeklyRoomSessions(liveDb, r['id'], today, _sess).toInt();
  static int utilPct(Map<String, dynamic> r) => (100 * weeklyUsed(r) / weeklyCap(r)).round().clamp(0, 100);
  static int get utilAvgPct {
    final rs = activeRooms;
    if (rs.isEmpty) return 0;
    var sum = 0;
    for (final r in rs) {
      sum += utilPct(r);
    }
    return (sum / rs.length).round();
  }
  static bool underused(Map<String, dynamic> r) => activeOf(r) && utilPct(r) < utilFloor;

  // תקלות
  static List<Map<String, dynamic>> faultsOf(Map<String, dynamic> r, {bool openOnly = true}) =>
      liveFaults.where((f) => f['roomId'] == r['id'] && (!openOnly || f['status'] != 'done')).toList();
  static List<Map<String, dynamic>> get openFaults => liveFaults.where((f) => f['status'] != 'done').toList();
  static bool faulty(Map<String, dynamic> r) => faultsOf(r).any((f) => f['severity'] == 'חמור');
  // חדר-לא-זמין = לא-פעיל (שיפוץ/סגור) או תקלה-חמורה-פתוחה
  static bool unavailable(Map<String, dynamic> r) => !activeOf(r) || faulty(r);
  static int get unavailableN => liveRooms.where(unavailable).length;

  // הזמנות-ממתינות-אישור = סטטוס proposed (אוצר-מילים של TaskItem)
  static List<Map<String, dynamic>> get pendingApprovals => liveEvents.where((e) => e['status'] == 'proposed').toList();

  // ציוד-חסר/תקול = ציוד-נדרש-לשיעור (needsEq) שאינו ב-eq של החדר, או ציוד שעליו תקלה-פתוחה (fault.detail)
  static List<String> missingEqFor(Map<String, dynamic> c) {
    final rid = roomOfCourse(c);
    if (rid.isEmpty) return const [];
    final r = liveRooms.firstWhere((x) => x['id'] == rid, orElse: () => const {'id': '', 'eq': <String, bool>{}});
    final eq = (r['eq'] as Map).cast<String, bool>();
    final broken = {for (final f in faultsOf(r)) if ('${f['detail']}'.isNotEmpty) '${f['detail']}'};
    return [for (final k in (c['needsEq'] as List? ?? const [])) if (eq['$k'] != true || broken.contains('$k')) '$k'];
  }
  static List<Map<String, dynamic>> get coursesMissingEq => liveCourses.where((c) => missingEqFor(c).isNotEmpty).toList();
  static int get brokenEqN {
    var n = 0;
    for (final r in liveRooms) {
      n += faultsOf(r).where((f) => '${f['detail']}'.isNotEmpty).length;
    }
    return n + coursesMissingEq.length;
  }

  // ═══ חריגה · כפל-תפיסה (התנגשות) = הרכבת פעולות-יסוד: לולאה(חדר×יום) ⊕ מרווח[t,t+slot) ⊕ השוואת-חפיפה ═══
  //   buildSlots מסתיר אירוע-מול-חוג (קדימות) ולכן ההתנגשות נגזרת מהמרווחים עצמם: חוג⊕חוג · חוג⊕אירוע · אירוע⊕אירוע.
  static List<Map<String, dynamic>> _intervals(Map<String, dynamic> r, String iso) {
    final slot = (r['slot'] is num && (r['slot'] as num) > 0) ? (r['slot'] as num) : 60;
    final d = dow(iso);
    final out = <Map<String, dynamic>>[];
    for (final c in liveCourses) {
      if (c['roomId'] != r['id'] || !_onDate(c, iso)) continue;
      for (final s in _sess(c)) {
        final t = _t2m((s as Map)['time']);
        if (s['day'] == d && !t.isNaN) out.add({'kind': 'course', 'id': c['id'], 'name': c['name'], 'who': teacherName(c['teacherId']), 'start': t, 'end': t + slot});
      }
    }
    for (final e in liveEvents) {
      if (e['roomId'] != r['id'] || e['date'] != iso || e['done'] == true) continue;
      final t = _t2m(e['time']);
      if (!t.isNaN) out.add({'kind': 'event', 'id': e['id'], 'name': e['title'], 'who': teacherName(e['requestedBy']), 'start': t, 'end': t + slot, 'status': e['status']});
    }
    return out;
  }
  static List<Map<String, dynamic>> conflictsOf(Map<String, dynamic> r, String iso) {
    final iv = _intervals(r, iso);
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < iv.length; i++) {
      for (var j = i + 1; j < iv.length; j++) {
        final a = iv[i], b = iv[j];
        if ((a['start'] as num) < (b['end'] as num) && (b['start'] as num) < (a['end'] as num)) {
          out.add({'room': r, 'iso': iso, 'a': a, 'b': b, 'time': _m2hm((a['start'] as num) > (b['start'] as num) ? a['start'] : b['start'])});
        }
      }
    }
    return out;
  }
  static List<Map<String, dynamic>> get weekConflicts => [for (final r in activeRooms) for (final iso in weekIsos) ...conflictsOf(r, iso)];

  // שיעור-בלי-חדר = inactiveRoomCourses(מאור): roomId ריק/לא-קיים/חדר-לא-פעיל
  static List<Map<String, dynamic>> get orphanCourses => [
        ...inactiveRoomCourses(liveDb, today, config, (cfg, k, fb) => '${termOf(cfg, k, fb)}', INACTIVE_ROOM_COURSES_T),
        for (final c in liveCourses) if (roomOfCourse(c).isEmpty) {'course': c, 'roomName': '— (ללא-חדר)'},
      ];

  // קיבוץ (countBy מאור) — לפי בניין (location) · לפי סטטוס
  static List<List<Object>> get byBuilding => countBy(liveRooms, (r) => '${(r as Map)['location']}'.split(' · ').first);
  static String statusOf(Map<String, dynamic> r) {
    if (!activeOf(r)) return faultsOf(r).isNotEmpty ? 'שיפוץ' : 'סגור';
    if (faulty(r)) return 'תקול';
    if (blockOf(today) != null || blockedDates.contains(today)) return 'חסום';
    return busyNow(r) != null ? 'תפוס' : 'זמין';
  }
}

// ═══════════ המסך · RoomsScreen (const · ללא main) ═══════════
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  bool _loading = false; // מצב-מסך שמור: טעינה
  String? _error; // מצב-מסך שמור: שגיאה (null בזרימה-התקינה)

  @override
  Widget build(BuildContext context) {
    final rooms = _RoomsData.liveRooms;
    final active = _RoomsData.activeRooms;
    final conflicts = _RoomsData.weekConflicts;
    final openFaults = _RoomsData.openFaults;
    final underN = active.where(_RoomsData.underused).length;
    return DsScaffold(
      title: 'חדרים ויומן-מרחבים',
      subtitle: '${rooms.length} חדרים · ${_RoomsData.byBuilding.length} בניינים · שבוע ${_RoomsData.weekIsos.first}',
      icon: '🏫',
      children: [
        // KPI-10 (המפרט): hero=התנגשויות (המטרה: אפס) + 10 מדדי-מצב BareStat — כולם מנועי-מדף/שדות-אמת
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: '${conflicts.length}', label: 'התנגשויות-תפיסה השבוע'),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${rooms.length}', label: '🏫 חדרים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_RoomsData.busyNowN}', label: '🔴 תפוסים-עכשיו', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_RoomsData.freeNowN}', label: '🟢 פנויים-עכשיו', inkColor: _ok, mutedColor: _muted),
              BareStat(value: '${_RoomsData.utilAvgPct}%', label: '📊 ניצולת-שבוע', inkColor: _acc, mutedColor: _muted),
              BareStat(value: '${conflicts.length}', label: '⚠️ התנגשויות', inkColor: conflicts.isEmpty ? _ok : _danger, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: '${openFaults.length}', label: '🔧 תקלות-פתוחות', inkColor: openFaults.isEmpty ? _ok : _warning, mutedColor: _muted),
              BareStat(value: '${_RoomsData.unavailableN}', label: '⛔ לא-זמינים', inkColor: _RoomsData.unavailableN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_RoomsData.pendingApprovals.length}', label: '⏳ ממתינות-אישור', inkColor: _warning, mutedColor: _muted),
              BareStat(value: '${_RoomsData.brokenEqN}', label: '🧰 ציוד-חסר/תקול', inkColor: _RoomsData.brokenEqN > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '$underN', label: '🪑 לא-מנוצלים', inkColor: underN > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (rooms.isEmpty)
          const EmptyState(glyph: '🏫', message: 'אין חדרים — הוסף חדר ראשון')
        else
          DsSection(title: '🏫 חדרים · ${rooms.length}', children: [
            for (final r in rooms)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${r['name']} · ${r['location']} · ${_RoomsData.statusOf(r)} · ניצולת ${_RoomsData.utilPct(r)}%', style: const TextStyle(color: _ink, fontSize: 13)),
              ),
          ]),
      ],
    );
  }

  // מצב-טעינה שמור (מחוון-מסגרת סטנדרטי; אפס ShimmerSkeleton מזייף) — Column ולא Center (גובה-חסום ברשימה)
  Widget _loadingView() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          SizedBox(height: 14),
          Text('טוען חדרים…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );
}
