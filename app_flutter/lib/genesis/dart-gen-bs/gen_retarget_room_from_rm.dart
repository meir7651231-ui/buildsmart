// 🎯 RoomScreen — retarget של schoolos_rooms.dart לישות Room (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_rooms.dart --entity Room
//   זרע-ראשי: rooms (מועמדים: rooms(11/11) events(11/12) faults(8/9) teachers(2/2)) · מיפוי שם 11 · ערוץ 0 · טיפוס-יחיד 0 · מקום-שמור 0 · חוזה-מנוע (לא משתנה) 0
//   id⇒id(name) · name⇒name(name) · active⇒active(name) · slot⇒slot(name) · cap⇒cap(name) · location⇒location(name) · from⇒from(name) · to⇒to(name) · access⇒access(name) · notes⇒notes(name) · eq⇒eq(name)
//   תפר-עובדות (G9b): RoomFacts · count=rooms.length (static-const) · מדדים 5 · hero=unavailableN · שורות-מדד (G10a) busyNowN/unavailableN · תפר-כניסה initialPanelId · תפר-סינון-מדד initialMetric · תפר-הזרקה ∅
//   שדות-Room בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): rate · תוויות: מונחי room (חדר/חדרים) ⇒ Room (חדר/חדרים) · 0 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של Room
// 🏫 SchoolOS · חדרים ויומן-מרחבים (ROOMS) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) לפי
// המפרט knowledge/SPEC-ROOMS-FULL-2026-09-04.md. קובץ יחיד · מחלקה ציבורית אחת: RoomScreen.
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
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // ארגון: בורר יום/שבוע/רשימה + בורר-יום (מבוקר)
import '../dart-ui-bs/screens__manager_dashboard_screen/tinted_tag.dart'; // תא-יומן: תג בשטיפת-צבע (פיגמנט מוזרק)
import '../dart-ui-bs/ds/ds_field.dart'; // שדה-קלט מבוקר (כותרת-הזמנה/תיאור-תקלה)
import '../dart-ui-bs/ds/ds_table.dart'; // רשימה: טבלה-אמיתית (labels+rows, מיון-בלחיצה) — לא DataGrid המזייף
import '../dart-maor/day-names.dart'; // שמות-ימי-הפעילות (0=ראשון…5=שישי)
import '../dart-maor/room-info-label.dart'; // זהות-חדר: משבצות·קיבולת·נגישות·ציוד (שורת-מידע של יומן-מאור)
import '../dart-data-maor/room-info-label-strings.dart'; // ROOM_INFO_LABEL_T (אטום-דאטה)
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל-החדר (child שרירותי)
import '../dart-ui-bs/premium/lists/media_row.dart'; // כותרת-חדר (glyph·title·subtitle)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס: ניצולת מול קיבולת-משבצות (בר-מילוי)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט-ציר-זמן (title/time/body) — היום/תפיסות/תקלות/היסטוריה/אודיט
import '../dart-ui-bs/premium/feedback/status_chip.dart'; // עובדה-אטומית: תג-מצב (ציוד/סטטוס)
import '../dart-ui-bs/premium/actions/soft_button.dart'; // פעולה (label·onTap·tone)
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // חריגה: צ׳יפ-סינון מבוקר (פיגמנטים מוזרקים)
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (סופיות⇒רגילות, אטום-דאטה)
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND על נעילות (מדף)
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff (מדף)
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח (מדף)
import '../dart-maor/upcoming-holidays.dart'; // אוטומציה: חגים קרובים ⇒ חסימות-אוטו (מדף)
import '../dart-maor/intel-day-diff.dart'; // אוטומציה: ימים-מאז (בדיקה-תקופתית) (מדף)
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // ניצולת-להנהלה: עמודות-ערך אמיתיות (values מוזרקים)
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM (מדף)
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) (מדף)
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע (מדף)
import '../dart-maor/guard-export.dart'; // ייצוא: שער חוסם+מודיע (מדף)
import '../dart-maor/build-ics.dart'; // ייצוא iCal: VCALENDAR מ-occurrences (מדף מאור)
import '../dart-maor/ics-escape.dart'; // ייצוא iCal: escaping לפי RFC5545 (מדף)
import '../dart-maor/fold-ics-line.dart'; // ייצוא iCal: קיפול-שורות 75 בייט (מדף)
import '../dart-maor/day-letters.dart'; // אותיות-הימים (א׳…ו׳) — בורר-יום קומפקטי
import '../dart-data-maor/day-letters-terms.dart' as day_letters_terms; // שקע-המונחים של dayLetters (אטום-דאטה)

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
class _RoomData {
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
  static void log(String who, String what, String target, {String? roomId}) => audit.insert(0, {'when': today, 'who': who, 'what': what, 'target': target, 'roomId': roomId});

  static bool activeOf(Map<String, dynamic> r) => roomActive[r['id']] ?? (r['active'] as bool? ?? true);
  static Map<String, bool> eqOf(Map<String, dynamic> r) => {...((r['eq'] as Map?)?.cast<String, bool>() ?? const {}), ...(eqAdj[r['id']] ?? const {})};
  static String statusOfEvent(Map<String, dynamic> e) => eventStatus[e['id']] ?? '${e['status'] ?? 'pending'}';
  static String statusOfFault(Map<String, dynamic> f) => faultStatus[f['id']] ?? '${f['status']}';
  static String roomOfEvent(Map<String, dynamic> e) => eventRoom[e['id']] ?? '${e['roomId'] ?? ''}';
  static String roomOfCourse(Map<String, dynamic> c) => courseRoom[c['id']] ?? '${c['roomId'] ?? ''}';

  // רשומות-חיות (בסיס + פנקס) — בצורת-הקלט של המנועים; אירוע שנדחה/בוטל ⇒ done (buildSlots מדלג)
  static List<Map<String, dynamic>> get liveRooms => [for (final r in rooms) {...r, 'active': activeOf(r), 'eq': eqOf(r)}];
  static List<Map<String, dynamic>> get liveCourses => [for (final c in [...extraCourses, ...courses]) {...c, 'roomId': roomOfCourse(c)}];
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
  static List<Map<String, dynamic>> get rowsOf_busyNowN => nowRows.where((x) => x['busyWith'] != null).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד busyNowN (מהצורה של ה-getter, לא מילון)
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
  static List<Map<String, dynamic>> get rowsOf_unavailableN => liveRooms.where(unavailable).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד unavailableN (מהצורה של ה-getter, לא מילון)

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

  // ═══ יומן · גריד חדרים×שעות = SegmentedSwitch(יום) ⊕ buildSlots(פר-חדר) ⊕ TintedTag(תא)×רשת ⊕ conflictsOf(⚠) ═══
  //   עמודות = איחוד זמני-המשבצות של כל החדרים-הנראים (חדרים עם שעות שונות מתיישרים על ציר-אחד).
  static List<String> gridHours(List<Map<String, dynamic>> rs, String iso) {
    final set = <String>{};
    for (final r in rs) {
      for (final sl in slotsOf(r, iso)) {
        if (sl['outOfHours'] != true) set.add('${sl['time']}'.substring(0, 2) + ':00');
      }
    }
    final l = set.toList()..sort();
    return l;
  }
  // תא = המשבצות של החדר שמתחילות בשעה (≥1 חוג באותה-שעה ⇒ כפל-תפיסה)
  static List<Map<String, dynamic>> cellSlots(Map<String, dynamic> r, String iso, String hh) =>
      slotsOf(r, iso).where((sl) => sl['outOfHours'] != true && '${sl['time']}'.substring(0, 2) == hh.substring(0, 2)).toList();
  static bool cellConflict(Map<String, dynamic> r, String iso, String hh) =>
      conflictsOf(r, iso).any((c) => '${c['time']}'.substring(0, 2) == hh.substring(0, 2));
  // התפיסה-הבאה היום (אחרי "עכשיו") = buildSlots ⊕ השוואת-זמן — לעמודת "הבאה"
  static String nextOf(Map<String, dynamic> r) {
    final nowMin = now.hour * 60 + now.minute;
    for (final sl in slotsOf(r, today)) {
      if (sl['kind'] != 'course' && sl['kind'] != 'event') continue;
      final t = _t2m(sl['time']);
      if (!t.isNaN && t > nowMin) return '${sl['time']} ${sl['label']}';
    }
    return '—';
  }
  static String busyLabel(Map<String, dynamic> r) {
    final b = busyNow(r);
    return b == null ? '—' : '${b['name']} · ${teacherName(b['teacherId'])}';
  }
  // תא-שבוע (חדר×יום) = ספירת-משבצות-תפוסות ÷ סך-משבצות ⊕ התנגשויות ⊕ חסימה — הרכבה של 3 אותות
  static Map<String, dynamic> dayCell(Map<String, dynamic> r, String iso) {
    final sl = slotsOf(r, iso).where((x) => x['outOfHours'] != true).toList();
    final used = sl.where((x) => x['kind'] == 'course' || x['kind'] == 'event').length;
    return {'used': used, 'total': sl.length, 'conflicts': conflictsOf(r, iso).length, 'blocked': blockOf(iso) ?? (blockedDates.contains(iso) ? 'חסימה-ידנית' : null)};
  }
  // ═══ הכרעה · חדר-חלופי = הרכבה: קיבולת≥נדרש ⊕ ציוד⊇נדרש ⊕ פנוי-במשבצת (אפס-חפיפה) ⊕ קרבה (אותו-בניין) ⇒ דירוג ═══
  static bool freeAt(Map<String, dynamic> r, String iso, num start, {String? exceptId}) {
    final slot = (r['slot'] is num && (r['slot'] as num) > 0) ? (r['slot'] as num) : 60;
    final end = start + slot;
    if (blockOf(iso) != null || blockedDates.contains(iso)) return false;
    for (final iv in _intervals(r, iso)) {
      if (iv['id'] == exceptId) continue;
      if ((iv['start'] as num) < end && start < (iv['end'] as num)) return false;
    }
    return true;
  }
  static String buildingOf(Map<String, dynamic> r) => '${r['location']}'.split(' · ').first;
  static List<Map<String, dynamic>> altRooms({required String iso, required String time, int need = 0, List<String> needsEq = const [], String? nearId, String? exceptId, String? excludeRoomId}) {
    final t = _t2m(time);
    if (t.isNaN) return const [];
    final near = nearId == null ? null : _room(nearId);
    final out = <Map<String, dynamic>>[];
    for (final r in liveRooms) {
      if (r['id'] == excludeRoomId || !activeOf(r) || faulty(r)) continue;
      if (((r['cap'] as num?) ?? 0) < need) continue;
      final eq = (r['eq'] as Map).cast<String, bool>();
      if (needsEq.any((k) => eq[k] != true)) continue;
      if (!freeAt(r, iso, t, exceptId: exceptId)) continue;
      final sameB = near != null && buildingOf(r) == buildingOf(near);
      out.add({...r, 'sameBuilding': sameB, 'spare': ((r['cap'] as num?) ?? 0) - need});
    }
    // דירוג: אותו-בניין קודם, אחר-כך הקיבולת הקרובה-ביותר לנדרש (מינימום-בזבוז)
    out.sort((a, b) {
      final sb = (b['sameBuilding'] == true ? 1 : 0) - (a['sameBuilding'] == true ? 1 : 0);
      if (sb != 0) return sb;
      return (a['spare'] as num).compareTo(b['spare'] as num);
    });
    return out;
  }

  // ═══ ביצוע · פעולות (state=פנקס · כל פעולה רושמת אודיט) ═══
  static final List<Map<String, dynamic>> extraCourses = []; // הזמנה-חוזרת (שבועית) = Course חדש עם sessions
  static int _seq = 0;
  static String _newId(String p) => '$p-new-${++_seq}';
  static void book(String who, Map<String, dynamic> r, String iso, String time, String title, {int attendees = 0, bool approved = false}) {
    extraEvents.insert(0, {'id': _newId('e'), 'title': title, 'date': iso, 'time': time, 'type': 'other', 'roomId': r['id'], 'priority': 'green', 'done': false, 'notes': '', 'status': approved ? 'pending' : 'proposed', 'requestedBy': who, 'attendees': attendees});
    log(who, approved ? 'הזמנת-חדר (אושרה-אוטו)' : 'הזמנת-חדר (ממתינה-אישור)', '${r['name']} · $iso $time · $title', roomId: r['id'] as String);
    invalidate();
  }
  static void bookWeekly(String who, Map<String, dynamic> r, int day, String time, String title) {
    extraCourses.insert(0, {'id': _newId('c'), 'name': title, 'teacherId': who, 'roomId': r['id'], 'start': today, 'end': '2027-06-20', 'maxStudents': 0, 'cat': 'הזמנה-חוזרת', 'sessions': [{'day': day, 'time': time, 'label': ''}]});
    log(who, 'הזמנה-חוזרת (שבועית)', '${r['name']} · ${dayNames()[day]} $time · $title', roomId: r['id'] as String);
    invalidate();
  }
  static void setEventStatus(String who, Map<String, dynamic> e, String st) { eventStatus[e['id'] as String] = st; log(who, st == 'pending' ? 'אישור-הזמנה' : st == 'rejected' ? 'דחיית-הזמנה' : 'ביטול-תפיסה', '${e['title']} · ${e['date']} ${e['time']}', roomId: roomOfEvent(e)); invalidate(); }
  static void moveEvent(String who, Map<String, dynamic> e, Map<String, dynamic> to) { eventRoom[e['id'] as String] = to['id'] as String; log(who, 'העברת-תפיסה', '${e['title']} ⇒ ${to['name']}', roomId: to['id'] as String); invalidate(); }
  static void moveCourse(String who, Map<String, dynamic> c, Map<String, dynamic> to) { courseRoom[c['id'] as String] = to['id'] as String; log(who, 'העברת-שיעור', '${c['name']} ⇒ ${to['name']}', roomId: to['id'] as String); invalidate(); }
  static void reportFault(String who, Map<String, dynamic> r, String name, String severity, {String detail = ''}) {
    extraFaults.insert(0, {'id': _newId('f'), 'roomId': r['id'], 'name': name, 'detail': detail, 'status': 'pending', 'severity': severity, 'createdBy': who, 'days': 0, 'date': today});
    log(who, 'דיווח-תקלה ($severity)', '${r['name']} · $name', roomId: r['id'] as String); invalidate();
  }
  static void closeFault(String who, Map<String, dynamic> f) { faultStatus[f['id'] as String] = 'done'; log(who, 'סגירת-תקלה', '${_room('${f['roomId']}')['name']} · ${f['name']}', roomId: '${f['roomId']}'); invalidate(); }
  static void setActive(String who, Map<String, dynamic> r, bool v) { roomActive[r['id'] as String] = v; log(who, v ? 'החזרה-לזמינות' : 'סימון לא-זמין/שיפוץ', '${r['name']}', roomId: r['id'] as String); invalidate(); }
  static void setEq(String who, Map<String, dynamic> r, String key, bool present) { (eqAdj[r['id'] as String] ??= {})[key] = present; log(who, present ? 'הוספת-ציוד' : 'דיווח ציוד-חסר', '${r['name']} · $key', roomId: r['id'] as String); invalidate(); }
  static void blockDate(String who, String iso) { blockedDates.add(iso); log(who, 'חסימת-תאריך', iso); invalidate(); }
  static void unblockDate(String who, String iso) { blockedDates.remove(iso); log(who, 'ביטול-חסימת-תאריך', iso); invalidate(); }
  static final List<Map<String, dynamic>> outbox = []; // הודעות-למשתמשי-החדר (שקע-שליחה = הצבה; כאן תיבת-יוצא)
  static List<String> usersOf(Map<String, dynamic> r) { // מי-משתמש-בחדר = מורי-השיעורים ⊕ מזמיני-האירועים (השבוע)
    final ids = <String>{};
    for (final c in liveCourses) { if (c['roomId'] == r['id']) ids.add('${c['teacherId']}'); }
    for (final e in liveEvents) { if (e['roomId'] == r['id'] && e['done'] != true) ids.add('${e['requestedBy']}'); }
    return ids.toList();
  }
  static void notifyUsers(String who, Map<String, dynamic> r, String text) {
    final to = usersOf(r);
    outbox.insert(0, {'when': today, 'from': who, 'room': r['name'], 'to': to, 'text': text});
    log(who, 'הודעה למשתמשי-החדר (${to.length})', '${r['name']} · $text', roomId: r['id'] as String);
  }
  // מי-משתמש-הכי-הרבה = countBy(מאור) על מפגשי-השבוע לפי-מורה
  static List<List<Object>> topUsers(Map<String, dynamic> r) => countBy([
        for (final c in liveCourses) if (c['roomId'] == r['id']) for (final _ in _sess(c)) c['teacherId'],
      ], (id) => teacherName(id));
  // תפיסות-השבוע של חדר (מרווחים ממוינים לפי יום+שעה) — לטאב "תפיסות"
  static List<Map<String, dynamic>> weekOccupancies(Map<String, dynamic> r) => [
        for (var i = 0; i < weekIsos.length; i++)
          for (final iv in (_intervals(r, weekIsos[i])..sort((a, b) => (a['start'] as num).compareTo(b['start'] as num)))) {...iv, 'iso': weekIsos[i], 'dayIdx': i},
      ];
  static Map<String, dynamic>? eventById(dynamic id) { for (final e in liveEvents) { if (e['id'] == id) return e; } return null; }
  static Map<String, dynamic>? courseById(dynamic id) { for (final c in liveCourses) { if (c['id'] == id) return c; } return null; }
  static String roomInfo(Map<String, dynamic> r) => roomInfoLabel({...r, 'eq': eqOf(r)}, ROOM_INFO_LABEL_T);

  // ═══ איתור (23-ג · תובנה) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — לא `.contains` שטוח ═══
  //   נרמול-עברי (סופיות/ניקוד) + ניקוד רב-מילתי AND + סינון-ציון-0 + מיון-לפי-רלוונטיות. מונחי-חדר: שם·מיקום·ציוד·שיעורים-בחדר.
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> termsOf(Map<String, dynamic> r) => [
        '${r['name']}', '${r['location']}', ...eqOf(r).keys,
        for (final c in liveCourses) if (c['roomId'] == r['id']) '${c['name']}',
        for (final e in liveEvents) if (e['roomId'] == r['id'] && e['done'] != true) '${e['title']}',
      ];
  static List<Map<String, dynamic>> searchRooms(List<Map<String, dynamic>> rs, String q) =>
      (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה/סינון (23-ג) = FilterChipPill ⊕ finderMatches — 11 צירי-המפרט כנעילות AND ═══
  //   בניין · קומה · סוג(מקום-שמור) · קיבולת≥N · ציוד · פנוי-במשבצת · תפוס · תקלה-פתוחה · ניצולת<סף · נגיש · (טקסט=searchRooms)
  static String floorOf(Map<String, dynamic> r) { final parts = '${r['location']}'.split(' · '); return parts.length > 1 ? parts[1] : ''; }
  static List<String> get buildings => [for (final b in byBuilding) '${b[0]}'];
  static List<String> get floors => {for (final r in liveRooms) if (floorOf(r).isNotEmpty) floorOf(r)}.toList()..sort();
  static List<String> get eqKeys => {for (final r in liveRooms) ...eqOf(r).keys}.toList()..sort();
  static List<String> get types => {for (final r in liveRooms) if (r['type'] != null) '${r['type']}'}.toList()..sort(); // מקום-שמור: ריק עד שיגיע נתון
  static const capSteps = [30, 60, 100];
  static String axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) { // שקע-finderAxisValue
    final r = f as Map<String, dynamic>;
    final a = '$axis';
    if (a == 'building') return buildingOf(r);
    if (a == 'floor') return floorOf(r);
    if (a == 'type') return '${r['type'] ?? ''}';
    if (a.startsWith('cap')) return ((r['cap'] as num?) ?? 0) >= int.parse(a.substring(3)) ? '1' : '0';
    if (a.startsWith('eq:')) return eqOf(r)[a.substring(3)] == true ? '1' : '0';
    if (a.startsWith('freeAt:')) { final p = a.substring(7).split('@'); return activeOf(r) && !faulty(r) && freeAt(r, p[0], _t2m(p[1])) ? '1' : '0'; }
    if (a == 'busy') return busyNow(r) != null ? '1' : '0';
    if (a == 'fault') return faultsOf(r).isNotEmpty ? '1' : '0';
    if (a == 'under') return underused(r) ? '1' : '0';
    if (a == 'access') return r['access'] == true ? '1' : '0';
    return '';
  }
  static List<Map<String, dynamic>> filterRooms(List<Map<String, dynamic>> rs, Map<String, String> locks) =>
      finderMatches({'families': rs}, locks, axisValue).cast<Map<String, dynamic>>();

  // ═══ הרשאות-פר-תפקיד (חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction — 6 תפקידי-המפרט ═══
  //   admin(roleOf)=הנהלה ⇒ הכל · teacher(roles.teachers)=מורה · staff+features=רכז/אחזקה/מזכירות · staff ריק=צפייה-בלבד
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '🗂 רכז/ת', 'email': 'coord@school', 'config': {'features': {'rooms.book': true, 'rooms.bookWeekly': true, 'rooms.move': true, 'rooms.cancel': true, 'rooms.approve': true, 'rooms.block': true, 'rooms.notify': true, 'rooms.export': true, 'rooms.print': true, 'rooms.autoApprove': true}}},
    {'label': '🔧 אחזקה', 'email': 'maint@school', 'config': {'features': {'rooms.fault': true, 'rooms.faultClose': true, 'rooms.eq': true, 'rooms.availability': true, 'rooms.print': true, 'rooms.notify': true}}},
    {'label': '🎓 מורה', 'email': 't1@school', 'config': {'roles': {'teachers': {'t1@school': true}}, 'features': {'rooms.book': true, 'rooms.fault': true}}},
    {'label': '👑 הנהלה', 'email': 'mgr@school', 'config': {'adminEmails': ['mgr@school']}},
    {'label': '🗓 מזכירות', 'email': 'sec@school', 'config': {'features': {'rooms.book': true, 'rooms.cancel': true, 'rooms.notify': true, 'rooms.export': true, 'rooms.print': true, 'rooms.autoApprove': true}}},
    {'label': '👁 צפייה', 'email': 'view@school', 'config': <String, dynamic>{}},
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static String roleName(int role) => roleOf((roleDefs[role]['config'] as Map).cast<String, dynamic>(), roleDefs[role]['email'] as String);
  static String whoOf(int role) => roleDefs[role]['label'] as String;

  // ═══ אוטומציות (23-ג · פרואקטיבי) — המערכת מתריעה ומציעה לפני שדבר נשמט ═══
  // 3 · סנכרון-לוח: חגים ב-45 הימים הקרובים = upcomingHolidays(מאור) על HOLIDAYS⊕hebParts ⇒ הימים חסומים-אוטו (blockReason)
  static List<Map<String, dynamic>> get upcoming => upcomingHolidays(today, holidayNameOf, isoLocal);
  // 5 · בדיקה-תקופתית (מזגן/כיבוי-אש): lastCheck = מקום-שמור; יש-נתון ⇒ dayDiff(מאור) > checkEveryDays ⇒ תזכורת; אין-נתון ⇒ "אין נתון"
  static const int checkEveryDays = 180;
  static bool checkUnknown(Map<String, dynamic> r) => r['lastCheck'] == null;
  static bool checkDue(Map<String, dynamic> r) => !checkUnknown(r) && dayDiff('${r['lastCheck']}', today) > checkEveryDays;
  // 4 · תקלה ⇒ העברת-שיעורים-אוטו + הודעה: לכל תפיסת-השבוע בחדר-תקול ⇒ altRooms (קיבולת⊕ציוד⊕פנוי⊕קרבה) ⇒ העברה ⇒ הודעה למשתמשים
  static List<Map<String, dynamic>> affectedByFault(Map<String, dynamic> r) => weekOccupancies(r);
  static int autoRelocate(String who, Map<String, dynamic> r) {
    var moved = 0;
    final seenCourses = <String>{};
    for (final o in weekOccupancies(r)) {
      if (o['kind'] == 'course') {
        final c = courseById(o['id']);
        if (c == null || !seenCourses.add('${c['id']}')) continue;
        // חדר שפנוי בכל מפגשי-השבוע של השיעור (AND על המפגשים) — בחירה אחת לשיעור, לא פר-מפגש
        Map<String, dynamic>? pick;
        for (final a in altRooms(iso: '${o['iso']}', time: _m2hm(o['start']), need: (c['maxStudents'] as int?) ?? 0, needsEq: [for (final k in (c['needsEq'] as List? ?? const [])) '$k'], nearId: r['id'] as String, exceptId: '${c['id']}', excludeRoomId: r['id'] as String)) {
          final ok = weekOccupancies(r).where((x) => x['id'] == c['id']).every((x) => freeAt(a, '${x['iso']}', x['start'] as num, exceptId: '${c['id']}'));
          if (ok) { pick = a; break; }
        }
        if (pick != null) { moveCourse(who, c, pick); moved++; }
      } else {
        final e = eventById(o['id']);
        if (e == null) continue;
        final alts = altRooms(iso: '${o['iso']}', time: _m2hm(o['start']), need: (e['attendees'] as int?) ?? 0, nearId: r['id'] as String, exceptId: '${e['id']}', excludeRoomId: r['id'] as String);
        if (alts.isNotEmpty) { moveEvent(who, e, alts.first); moved++; }
      }
    }
    if (moved > 0) notifyUsers(who, r, 'החדר ${r['name']} לא-זמין (תקלה) — $moved תפיסות הועברו לחדרים חלופיים, בדקו את היומן');
    return moved;
  }
  // 9 · אישור-אוטו בתוך-מדיניות: תפקיד עם rooms.autoApprove (רכז/מזכירות) או הנהלה ⇒ מאושר; אחרת ⇒ ממתין-אישור
  static bool autoApprove(int role) => can(role, 'rooms.autoApprove') || roleName(role) == 'admin';
  // 8 · ניצולת-שבועית-להנהלה: ערכים אמיתיים (utilPct) ל-NeonBars — ממוין יורד
  static List<Map<String, dynamic>> get utilRanked => [...activeRooms]..sort((a, b) => utilPct(b).compareTo(utilPct(a)));
  // מרכז-דורש-פעולה: ספירת פריטים פתוחים (התנגשויות · אישורים · ציוד-חסר · שיעור-בלי-חדר · תקולים · לא-מנוצלים)
  static int get actionItems => weekConflicts.length + pendingApprovals.length + coursesMissingEq.length + orphanCourses.length + liveRooms.where(faulty).length;

  // ═══ מקום-שמור (חוק-7 · מבחן-הקונכייה) · חוזה-שדות-מתקדמים — שקע לכל שדה חסר-נתון, מאיר לבד כשיגיע ═══
  //   כמו columnDefs: שדה שהחדר נושא ⇒ שבב; חסר ⇒ נרשם בחוזה כ"מקום-שמור" (לא מזויף, לא מושמט).
  static const reservedFields = <Map<String, String>>[
    {'key': 'type', 'label': 'סוג', 'glyph': '🏷'},                 // כיתה/מעבדה/אולם/ספורט/מחשבים/חדר-מורים
    {'key': 'owner', 'label': 'אחראי', 'glyph': '👤'},
    {'key': 'lastCheck', 'label': 'בדיקה אחרונה', 'glyph': '🗓'},   // מזגן/כיבוי-אש
    {'key': 'updatedAt', 'label': 'עדכון', 'glyph': '🕒'},
    {'key': 'features', 'label': 'תכונות (חלונות/הצללה)', 'glyph': '🪟'},
    {'key': 'eqStock', 'label': 'ציוד-מפורט (כמות ממלאי)', 'glyph': '📦'}, // ⇐ מודול-מלאי
    {'key': 'photo', 'label': 'תמונת-חדר', 'glyph': '🖼'},
    {'key': 'floorMap', 'label': 'מפת-קומה', 'glyph': '🗺'},
    {'key': 'sensor', 'label': 'חיישן-תפוסה', 'glyph': '📡'},
    {'key': 'smartLock', 'label': 'נעילה-חכמה', 'glyph': '🔐'},
  ];
  static List<Map<String, String>> presentFields(Map<String, dynamic> r) => [for (final f in reservedFields) if (r[f['key']] != null && '${r[f['key']]}'.isNotEmpty) f];
  static List<Map<String, String>> missingFields(Map<String, dynamic> r) => [for (final f in reservedFields) if (r[f['key']] == null || '${r[f['key']]}'.isEmpty) f];

  // ═══ ייצוא (23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport — רשימת-החדרים הנראית ═══
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'rooms.export');
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> rs) {
    final cols = [for (final c in columnDefs) if (colShown(c, rs)) c];
    return [
      [for (final c in cols) c['label']],
      for (final r in rs) [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(r) : (r[c['key']] ?? '')],
    ];
  }
  static String csvOf(List<Map<String, dynamic>> rs) => toCsv(csvRows(rs), csvEscape) as String;
  // ═══ ייצוא iCal = buildIcs(מאור) ⊕ icsEscape ⊕ foldIcsLine — כל תפיסות-השבוע של החדרים-הנראים (uid=תפיסה·תאריך) ═══
  static String icsOf(List<Map<String, dynamic>> rs) {
    final occ = <Map<String, String?>>[
      for (final r in rs)
        for (final o in weekOccupancies(r))
          {'uid': '${o['id']}@${o['iso']}@rooms', 'title': '${o['name']} · ${o['who']}', 'date': '${o['iso']}', 'time': _m2hm(o['start']), 'location': '${r['name']} · ${r['location']}', 'notes': o['kind'] == 'event' ? 'הזמנה · ${o['status']}' : 'שיעור שבועי'},
    ];
    return buildIcs(occ, 'SchoolOS · יומן-חדרים · שבוע ${weekIsos.first}', DateTime.parse('${today}T12:00:00'), icsEscape, foldIcsLine);
  }

  static String eqLabel(Map<String, dynamic> r) => [for (final e in eqOf(r).entries) if (e.value) e.key].join(' · ');

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7) — 16 עמודות-המפרט כשקעי-דאטה ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key)=מוארת רק כשחדר נושא ערך; חסר ⇒ שקט (type/owner/lastCheck/updatedAt = מקום-שמור).
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    // ═══ חוזה-העמודות של Room (G5h · חוק-7): 1 שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══
    {'key': 'rate', 'label': 'rate'}, // G5h · מקום-שמור: שדה-Room מהסכמה (number) — מאיר כשהנתון מוזרם
    {'label': 'שם/מספר', 'get': (Map<String, dynamic> r) => '${r['name']}'},
    {'key': 'location', 'label': 'בניין/קומה'},
    {'key': 'type', 'label': 'סוג'},                           // מקום-שמור (כיתה/מעבדה/אולם/ספורט/מחשבים/חדר-מורים)
    {'label': 'קיבולת', 'get': (Map<String, dynamic> r) => '${r['cap'] ?? '—'}'},
    {'label': 'תפוס-עכשיו?', 'get': (Map<String, dynamic> r) => busyNow(r) != null ? 'כן' : 'לא'},
    {'label': 'תפיסה-נוכחית', 'get': busyLabel},
    {'label': 'הבאה', 'get': nextOf},
    {'label': 'ניצולת%-שבוע', 'get': (Map<String, dynamic> r) => '${utilPct(r)}'},
    {'label': 'ציוד-קבוע', 'get': eqLabel},
    {'label': 'תקלות-פתוחות', 'get': (Map<String, dynamic> r) => '${faultsOf(r).length}'},
    {'label': 'סטטוס', 'get': statusOf},
    {'label': 'נגישות', 'get': (Map<String, dynamic> r) => r['access'] == true ? '♿ נגיש' : '—'},
    {'key': 'owner', 'label': 'אחראי'},                        // מקום-שמור
    {'key': 'lastCheck', 'label': 'תאריך-בדיקה-אחרונה'},       // מקום-שמור
    {'key': 'notes', 'label': 'הערה'},
    {'key': 'updatedAt', 'label': 'עדכון'},                    // מקום-שמור
  ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((r) => r[c['key']] != null && '${r[c['key']]}'.trim().isNotEmpty);
}

// ═══════════ המסך · RoomScreen (const · ללא main) ═══════════
class RoomScreen extends StatefulWidget {
  const RoomScreen({this.initialMetric, this.initialPanelId, super.key});
  final String? initialMetric; // G10b · תפר-סינון: מפתח-מדד (RoomFacts.metricDefs) ⇒ הטבלה מסוננת לשורות-המדד; null ⇒ ביט-זהה
  final String? initialPanelId; // G10a · תפר-כניסה: מזהה-רשומה שכרטיסה נפתח אחרי הפריים-הראשון (צורת initialPanel של זהב-המורים; הרכזת קופצת לרשומת-ה-hero)
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

  String? _metric; // G10b · המדד הנעול (null = ללא סינון-מדד)
class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    _metric = widget.initialMetric != null && RoomFacts.heroRows(widget.initialMetric!).isNotEmpty ? widget.initialMetric : null; // G10b · מדד בלי שורות ⇒ אין סינון (לא טבלה-ריקה בשקט)
    final p0 = widget.initialPanelId == null ? null : RoomFacts.byId(widget.initialPanelId!); // G10a
    if (p0 != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _openPanel(p0); });
  }
  int _view = 0; // 0=📅 יום (גריד חדרים×שעות) · 1=🗓 שבוע (חדרים×ימים) · 2=📋 רשימה (DsTable) — SegmentedSwitch
  int _dayIdx = _RoomData.dow(_RoomData.today); // היום-הנבחר בשבוע (0=ראשון) — בורר-יום
  bool _loading = false; // מצב-מסך שמור: טעינה
  String? _error; // מצב-מסך שמור: שגיאה (null בזרימה-התקינה)
  String _q = ''; // חיפוש-איתור (DsSearch → searchRooms)
  final Map<String, String> _locks = {}; // נעילות-סינון (FilterChipPill → finderMatches, AND)
  String _slotHour = '10:00'; // המשבצת לצ׳יפ "פנוי-במשבצת" (ביום-הנבחר)

  String get _iso => _RoomData.weekIsos[_dayIdx];

  // צ׳יפ-סינון מבוקר (חוק-6 הזרקת-פיגמנטים) — נעילה=ציר→ערך; לחיצה-חוזרת משחררת
  Widget _fchip(String axis, String value, String label) => FilterChipPill(
        label: label, selected: _locks[axis] == value,
        onTap: () => setState(() => _locks[axis] == value ? _locks.remove(axis) : _locks[axis] = value),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink,
        outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );
  // ציר-בוליאני: נעילה '1' (בלי ערך-מתנגש)
  Widget _bchip(String axis, String label) => _fchip(axis, '1', label);
  // ציר קיבולת/פנוי: ערך יחיד בכל רגע — נעילת cap30/cap60/cap100 מוצגת כקבוצה
  void _setCap(int? n) => setState(() { _locks.removeWhere((k, v) => k.startsWith('cap')); if (n != null) _locks['cap$n'] = '1'; });
  void _setFreeAt(bool on) => setState(() { _locks.removeWhere((k, v) => k.startsWith('freeAt:')); if (on) _locks['freeAt:$_iso@$_slotHour'] = '1'; });
  bool get _freeAtOn => _locks.keys.any((k) => k.startsWith('freeAt:'));

  // תא-יומן: TintedTag בפיגמנט-לפי-מצב (חוק-6 צבע=הצבה) · רוחב-קבוע ⇒ עמודות מיושרות · FittedBox מצמצם תווית-ארוכה
  static const double _cellW = 112;
  Widget _cell(String label, Color c, {double alpha = 0.16, FontWeight w = FontWeight.w700}) => SizedBox(
        width: _cellW,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: TintedTag(label: label, color: c, fillAlpha: alpha, radius: 8, fontSize: 11.5, fontWeight: w, horizontalPadding: 8, verticalPadding: 5),
          ),
        ),
      );
  Color _kindColor(String kind) => switch (kind) { 'course' => _acc, 'event' => DsTokens.cyan, 'blocked' => _danger, 'cleaning' => _muted, _ => _ok };
  String _kindGlyph(String kind) => switch (kind) { 'course' => '🎓', 'event' => '📌', 'blocked' => '⛔', 'cleaning' => '🧹', _ => '·' };

  @override
  Widget build(BuildContext context) {
    final rooms = _RoomData.liveRooms;
    final active = _RoomData.activeRooms;
    final conflicts = _RoomData.weekConflicts;
    final openFaults = _RoomData.openFaults;
    final underN = active.where(_RoomData.underused).length;
    final names = dayNames();
    final letters = dayLetters(term: (k) => day_letters_terms.kTerms[k]!); // א׳…ו׳ (dayLetters ⊕ אטום-דאטה)
    final blocked = _RoomData.blockOf(_iso);
    // איתור⊕חריגה: searchRooms=DsSearch⊕smartFilter⊕smartScore⊕normSearch · filterRooms=finderMatches (AND על נעילות)
    if (_freeAtOn) { _locks.removeWhere((k, v) => k.startsWith('freeAt:')); _locks['freeAt:$_iso@$_slotHour'] = '1'; } // הציר עוקב אחרי היום-הנבחר
    final visibleAll = _RoomData.filterRooms(_RoomData.searchRooms(rooms, _q), _locks);
    final visible = _metric == null ? visibleAll : visibleAll.where((r) => RoomFacts.heroRows(_metric!).any((h) => '${h[RoomFacts.idKey] ?? h['id']}' == '${r[RoomFacts.idKey] ?? r['id']}')).toList(); // G10b · סינון-לפי-מדד (זהות לפי מזהה — שורות-המדד וטבלת-המסך אותו סוג-רשומה, L66)
    final hoursAll = _RoomData.gridHours(rooms, _iso);
    return DsScaffold(
      title: 'חדרים ויומן-מרחבים',
      subtitle: '${rooms.length} חדרים · ${_RoomData.byBuilding.length} בניינים · שבוע ${_RoomData.weekIsos.first}',
      icon: '🏫',
      children: [
        // ═══ סינון-לפי-מדד (G10b): הרכזת שלחה מדד ⇒ הטבלה מוגבלת לשורותיו; הבאנר = עובדת-הסינון, הכפתור מסיר ═══
        if (_metric != null) AlertBanner(glyph: '🎯', tone: 1, message: 'מסונן למדד: ${RoomFacts.metricDefs.firstWhere((d) => d['key'] == _metric, orElse: () => const {'label': ''})['label']} · ${visible.length} מתוך ${visibleAll.length}'),
        if (_metric != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: SoftButton(label: '✖ בטל סינון-מדד', tone: 2, onTap: () => setState(() => _metric = null))),
        // KPI-10 (המפרט): hero=התנגשויות (המטרה: אפס) + 10 מדדי-מצב BareStat — כולם מנועי-מדף/שדות-אמת
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: '${conflicts.length}', label: 'התנגשויות-תפיסה השבוע'),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${rooms.length}', label: '🏫 חדרים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_RoomData.busyNowN}', label: '🔴 תפוסים-עכשיו', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_RoomData.freeNowN}', label: '🟢 פנויים-עכשיו', inkColor: _ok, mutedColor: _muted),
              BareStat(value: '${_RoomData.utilAvgPct}%', label: '📊 ניצולת-שבוע', inkColor: _acc, mutedColor: _muted),
              BareStat(value: '${conflicts.length}', label: '⚠️ התנגשויות', inkColor: conflicts.isEmpty ? _ok : _danger, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: '${openFaults.length}', label: '🔧 תקלות-פתוחות', inkColor: openFaults.isEmpty ? _ok : _warning, mutedColor: _muted),
              BareStat(value: '${_RoomData.unavailableN}', label: '⛔ לא-זמינים', inkColor: _RoomData.unavailableN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_RoomData.pendingApprovals.length}', label: '⏳ ממתינות-אישור', inkColor: _warning, mutedColor: _muted),
              BareStat(value: '${_RoomData.brokenEqN}', label: '🧰 ציוד-חסר/תקול', inkColor: _RoomData.brokenEqN > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '$underN', label: '🪑 לא-מנוצלים', inkColor: underN > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות פר-תפקיד (roleOf⊕canGrantedAction)
        Align(
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SegmentedSwitch(items: [for (final r in _RoomData.roleDefs) r['label'] as String], selected: _role, onSelect: (i) => setState(() => _role = i))),
        ),
        const SizedBox(height: 10),
        // 🚨 מרכז-דורש-פעולה (אוטומציות 1·3·5·6·7·9) — המערכת מתריעה ומציעה; כל שורה = מנוע-מדף ⊕ AlertBanner/SoftButton
        ..._automationCenter(),
        // פס-עליון · חיפוש (DsSearch) + הזמנת-חדר + דיווח-תקלה (בחירת-חדר ⇒ הזרימה של הפאנל)
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔄', tone: 0, onTap: _refresh)),
          const SizedBox(width: 6),
          if (_can('rooms.book')) Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '📌 הזמן-חדר', tone: 1, onTap: () => _pickRoom(visible, (r) => _openBook(context, r, (f) { f(); setState(() {}); })))),
          if (_can('rooms.fault')) ...[const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔧 דווח-תקלה', tone: 2, onTap: () => _pickRoom(visible, (r) => _openFault(context, r, (f) { f(); setState(() {}); }))))],
          if (_RoomData.exportOk(_role)) ...[
            const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '⬇ CSV', tone: 0, onTap: () => _openExport(visible, ical: false))),
            const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '📆 iCal', tone: 0, onTap: () => _openExport(visible, ical: true))),
          ],
        ]),
        // צ׳יפי-סינון (FilterChipPill ⊕ finderMatches) — 11 צירי-המפרט; סוג = מקום-שמור (מואר כשיגיע נתון)
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (final b in _RoomData.buildings) _fchip('building', b, '🏢 $b'),
          for (final f in _RoomData.floors) _fchip('floor', f, '🪜 $f'),
          for (final t in _RoomData.types) _fchip('type', t, '🏷 $t'),
          for (final n in _RoomData.capSteps) FilterChipPill(label: '👥 ≥$n', selected: _locks['cap$n'] == '1', onTap: () => _setCap(_locks['cap$n'] == '1' ? null : n), activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999),
          for (final k in _RoomData.eqKeys) _bchip('eq:$k', '🧰 יש $k'),
          FilterChipPill(label: '🟢 פנוי-במשבצת $_slotHour', selected: _freeAtOn, onTap: () => _setFreeAt(!_freeAtOn), activeFillColor: _ok, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999),
          _bchip('busy', '🔴 תפוס-עכשיו'),
          _bchip('fault', '🔧 תקלה-פתוחה'),
          _bchip('under', '🪑 ניצולת<${_RoomData.utilFloor}%'),
          _bchip('access', '♿ נגיש'),
          if (_locks.isNotEmpty || _q.isNotEmpty) SoftButton(label: '✖ נקה (${visible.length}/${rooms.length})', tone: 2, onTap: () => setState(() { _locks.clear(); _q = ''; })),
        ]),
        if (_freeAtOn && hoursAll.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerRight, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SegmentedSwitch(items: hoursAll, selected: hoursAll.indexOf(_slotHour).clamp(0, hoursAll.length - 1), onSelect: (i) => setState(() => _slotHour = hoursAll[i])))),
        ],
        const SizedBox(height: 10),
        // פס-עליון · בורר-מבט (ארגון = פעולת-יסוד עם אטום משלה: SegmentedSwitch מבוקר)
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['📅 יום', '🗓 שבוע', '📋 רשימה'], selected: _view, onSelect: (i) => setState(() => _view = i)),
        ),
        if (_view == 0) ...[
          const SizedBox(height: 8),
          // בורר-יום (dayNames של מאור) — היום-הנבחר מזין את buildSlots
          Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedSwitch(items: [for (var i = 0; i < letters.length; i++) '${letters[i]} ${_RoomData.weekIsos[i].substring(8)}'], selected: _dayIdx, onSelect: (i) => setState(() => _dayIdx = i)),
            ),
          ),
        ],
        const SizedBox(height: 10),
        // מצבי-מסך שמורים (מקום-שמור): טעינה + שגיאה מאירים במצב-אמת; אחרת התוכן.
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (rooms.isEmpty)
          const EmptyState(glyph: '🏫', message: 'אין חדרים — הוסף חדר ראשון')
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '🔍', message: 'אין חדרים תואמים לחיפוש/סינון'))
        else if (_view == 2)
          DsSection(title: '📋 רשימת-חדרים · ${visible.length}', children: [_table(visible)])
        else if (_view == 1)
          DsSection(title: '🗓 שבוע-הבניין · ${_RoomData.weekIsos.first} → ${_RoomData.weekIsos.last}', children: [_weekGrid(visible, names)])
        else ...[
          // מצב-מיוחד: יום-חסום (שבת/שישי/חג/צום-נדחה/חוה"מ) — blockReason מסנכרן-לוח ⇒ כל המשבצות הפנויות חסומות
          if (blocked != null) ...[
            AlertBanner(glyph: '⛔', tone: 2, message: 'יום חסום לתפיסה — $blocked'),
            const SizedBox(height: 8),
          ],
          DsSection(title: '📅 יומן-חדרים · ${names[_dayIdx]} $_iso · ${visible.length} חדרים', tone: blocked != null ? 2 : 0, children: [_dayGrid(visible)]),
        ],
      ],
    );
  }

  // 📅 גריד-יום: כותרת-שעות + שורה-פר-חדר (שם + תא-פר-שעה מ-buildSlots · ⚠ = כפל-תפיסה מ-conflictsOf)
  Widget _dayGrid(List<Map<String, dynamic>> rooms) {
    final hours = _RoomData.gridHours(rooms, _iso);
    if (hours.isEmpty) return const EmptyState(glyph: '📅', message: 'אין משבצות ביום זה');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _cell('חדר', _muted, alpha: 0.0, w: FontWeight.w800),
          for (final h in hours) _cell(h, _ink, alpha: 0.08, w: FontWeight.w800),
        ]),
        for (final r in rooms)
          Row(children: [
            InkWell(onTap: () => _openPanel(r), child: _cell('${r['name']}${_RoomData.activeOf(r) ? '' : ' ⛔'} ›', _RoomData.activeOf(r) ? _ink : _danger, alpha: 0.06, w: FontWeight.w800)),
            for (final h in hours)
              () {
                final sl = _RoomData.cellSlots(r, _iso, h);
                if (!_RoomData.activeOf(r)) return _cell('לא-זמין', _danger, alpha: 0.10);
                if (sl.isEmpty) return _cell('—', _muted, alpha: 0.04);
                final clash = _RoomData.cellConflict(r, _iso, h) || sl.where((x) => x['kind'] == 'course' || x['kind'] == 'event').length > 1;
                final k = '${sl.first['kind']}';
                final lbl = k == 'course' || k == 'event' ? '${sl.first['label']}'.replaceFirst(RegExp(r'^[^:]*: '), '') : k == 'blocked' ? 'חסום' : k == 'cleaning' ? 'ניקיון' : 'פנוי';
                return _cell(clash ? '⚠ כפל-תפיסה' : '${_kindGlyph(k)} $lbl', clash ? _danger : _kindColor(k), alpha: clash ? 0.30 : k == 'free' ? 0.10 : 0.18);
              }(),
          ]),
      ]),
    );
  }

  // 🗓 גריד-שבוע: חדרים×ימים · תא = תפוס/סך ⊕ ⚠התנגשויות ⊕ ⛔חסימה (dayCell) — "השבוע של הבניין במבט-אחד"
  Widget _weekGrid(List<Map<String, dynamic>> rooms, List<String> names) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _cell('חדר', _muted, alpha: 0.0, w: FontWeight.w800),
            for (var i = 0; i < names.length; i++) _cell('${names[i]} ${_RoomData.weekIsos[i].substring(5)}', _ink, alpha: 0.08, w: FontWeight.w800),
          ]),
          for (final r in rooms)
            Row(children: [
              InkWell(onTap: () => _openPanel(r), child: _cell('${r['name']} · ${_RoomData.utilPct(r)}% ›', _RoomData.underused(r) ? _warning : _ink, alpha: 0.06, w: FontWeight.w800)),
              for (final iso in _RoomData.weekIsos)
                () {
                  final c = _RoomData.dayCell(r, iso);
                  if (!_RoomData.activeOf(r)) return _cell('לא-זמין', _danger, alpha: 0.10);
                  if (c['blocked'] != null) return _cell('⛔ ${c['blocked']}', _danger, alpha: 0.14);
                  final used = c['used'] as int, total = c['total'] as int, conf = c['conflicts'] as int;
                  final frac = total == 0 ? 0.0 : used / total;
                  return _cell('${conf > 0 ? '⚠$conf · ' : ''}$used/$total', conf > 0 ? _danger : frac >= 0.5 ? _acc : frac > 0 ? _ok : _muted, alpha: conf > 0 ? 0.30 : 0.10 + frac * 0.2);
                }(),
            ]),
        ]),
      );

  // 📋 רשימה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid (מזייף int rows).
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _RoomData.columnDefs) if (_RoomData.colShown(c, rows)) c];
    final labels = [for (final c in cols) c['label'] as String];
    final data = <List<String>>[
      for (final r in rows)
        [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(r) : '${r[c['key']] ?? '—'}'],
    ];
    return DsTable(labels: labels, rows: data);
  }

  int _role = 0; // 0=רכז/ת · 1=אחזקה · 2=מורה · 3=הנהלה · 4=מזכירות · 5=צפייה (חוק-6 זהות-מוזרקת; בורר-תפקיד מדגים גידור)
  String get _who => _RoomData.whoOf(_role);
  bool _can(String k) => _RoomData.can(_role, k);
  Widget _gap([double h = 10]) => SizedBox(height: h);
  Widget _h(String t) => Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text(t, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)));
  Widget _wrap(List<Widget> kids) => Wrap(spacing: 8, runSpacing: 8, children: kids);

  // ═══ פאנל חדר-נבחר · GlassCard(child) · זהות(roomInfoLabel) ⊕ מצב(BareStat×4 ⊕ StatRow) ⊕ 8 טאבים(SegmentedSwitch) ⊕ פעולות(SoftButton) ═══
  void _openPanel(Map<String, dynamic> room) {
    var tab = 0;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final r = _RoomData.liveRooms.firstWhere((x) => x['id'] == room['id']);
        void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
        final faults = _RoomData.faultsOf(r);
        final conf = [for (final iso in _RoomData.weekIsos) ..._RoomData.conflictsOf(r, iso)];
        final used = _RoomData.weeklyUsed(r), cap = _RoomData.weeklyCap(r);
        return DraggableScrollableSheet(
          initialChildSize: 0.78, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                MediaRow(glyph: _RoomData.activeOf(r) ? '🏫' : '⛔', title: '${r['name']}', subtitle: '${r['location']} · ${_RoomData.roomInfo(r)}'),
                _gap(8),
                _wrap([
                  StatusChip(label: _RoomData.statusOf(r), tone: switch (_RoomData.statusOf(r)) { 'זמין' => 1, 'תפוס' => 0, 'חסום' => 3, _ => 2 }),
                  if (r['access'] == true) const StatusChip(label: '♿ נגיש', tone: 1),
                  if ('${r['notes']}'.isNotEmpty) StatusChip(label: '📝 ${r['notes']}', tone: 0),
                  if (_RoomData.underused(r)) StatusChip(label: '🪑 לא-מנוצל (<${_RoomData.utilFloor}%)', tone: 3),
                ]),
                _gap(12),
                Row(children: [
                  BareStat(value: '${r['cap']}', label: 'קיבולת', inkColor: _ink, mutedColor: _muted),
                  BareStat(value: '${_RoomData.utilPct(r)}%', label: 'ניצולת-שבוע', inkColor: _acc, mutedColor: _muted),
                  BareStat(value: '${faults.length}', label: 'תקלות-פתוחות', inkColor: faults.isEmpty ? _ok : _warning, mutedColor: _muted),
                  BareStat(value: '${conf.length}', label: 'התנגשויות', inkColor: conf.isEmpty ? _ok : _danger, mutedColor: _muted),
                ]),
                _gap(10),
                StatRow(label: 'תפיסות-שבוע מול קיבולת-משבצות', value: '$used מתוך $cap', fraction: cap == 0 ? 0 : used / cap),
                // שדות-מתקדמים · מקום-שמור (חוק-7): נוכח ⇒ שבב · חסר ⇒ נרשם בחוזה (מאיר כשיגיע נתון, אפס-שינוי-קוד)
                _gap(8),
                _wrap([for (final f in _RoomData.presentFields(r)) StatusChip(label: '${f['glyph']} ${f['label']}: ${r[f['key']]}', tone: 1)]),
                if (_RoomData.missingFields(r).isNotEmpty) ...[
                  _gap(6),
                  Text('מקום-שמור (${_RoomData.missingFields(r).length}): ${_RoomData.missingFields(r).map((f) => '${f['glyph']} ${f['label']}').join(' · ')}', style: const TextStyle(color: _muted, fontSize: 11.5)),
                ],
                // התנגשויות (אדום) — חוסם: כפל-תפיסה בחדר זה
                for (final c in conf) ...[
                  _gap(8),
                  AlertBanner(glyph: '⚠️', tone: 2, message: 'כפל-תפיסה ${c['iso']} ${c['time']}: ${(c['a'] as Map)['name']} ⊕ ${(c['b'] as Map)['name']}'),
                ],
                _gap(12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedSwitch(items: const ['היום', 'שבוע', 'תפיסות', 'ציוד', 'תקלות', 'אחזקה', 'היסטוריה', 'אודיט'], selected: tab, onSelect: (i) => setSheet(() => tab = i)),
                ),
                _gap(10),
                ..._tabBody(ctx, r, tab, act),
                _h('פעולות'),
                _wrap(_actions(ctx, r, act)),
                _gap(8),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // 8 טאבים פנימיים (המפרט) — כל אחד הרכבה של מנוע-מדף ⊕ אטום-תצוגה
  List<Widget> _tabBody(BuildContext ctx, Map<String, dynamic> r, int tab, void Function(void Function()) act) {
    switch (tab) {
      case 0: // היום · ציר-שעות (buildSlots ⊕ TimelineItem) — תפוס/פנוי/חסום/ניקיון
        final sl = _RoomData.slotsOf(r, _iso);
        if (sl.isEmpty) return [const EmptyState(glyph: '📅', message: 'אין משבצות')];
        return [
          _h('ציר-שעות · ${dayNames()[_dayIdx]} $_iso'),
          for (final x in sl)
            TimelineItem(title: '${_kindGlyph('${x['kind']}')} ${x['label']}', time: '${x['time']}', body: x['kind'] == 'course' ? '${_RoomData.teacherName((x['course'] as Map)['teacherId'])}' : x['kind'] == 'event' ? '${_RoomData.teacherName((x['event'] as Map)['requestedBy'])} · ${(x['event'] as Map)['status'] == 'proposed' ? 'ממתין-אישור' : 'מאושר'}' : null),
        ];
      case 1: // שבוע · מיני-גריד (dayCell × 6)
        final names = dayNames();
        return [
          _h('השבוע · תפוס/סך פר-יום'),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (var i = 0; i < names.length; i++)
              () {
                final c = _RoomData.dayCell(r, _RoomData.weekIsos[i]);
                final blocked = c['blocked'] != null;
                return _cell(blocked ? '${names[i]} ⛔' : '${names[i]} ${c['used']}/${c['total']}${(c['conflicts'] as int) > 0 ? ' ⚠' : ''}', blocked ? _danger : (c['conflicts'] as int) > 0 ? _danger : _acc, alpha: 0.14);
              }(),
          ])),
          _h('מי משתמש הכי-הרבה (מפגשים/שבוע)'),
          _wrap([for (final u in _RoomData.topUsers(r)) StatusChip(label: '${u[0]}: ${u[1]}', tone: 0)]),
        ];
      case 2: // תפיסות · כל תפיסות-השבוע + פעולות פר-תפיסה (בטל · העבר · אשר/דחה)
        final occ = _RoomData.weekOccupancies(r);
        if (occ.isEmpty) return [const EmptyState(glyph: '📭', message: 'אין תפיסות השבוע')];
        return [
          _h('תפיסות-השבוע · ${occ.length}'),
          for (final o in occ) _occRow(ctx, r, o, act),
        ];
      case 3: // ציוד · eq (מאור Room.eq) ⊕ תקלות-על-ציוד ⊕ פעולות · מקום-שמור: כמות/פריטי-מלאי (eqStock)
        final eq = _RoomData.eqOf(r);
        final broken = {for (final f in _RoomData.faultsOf(r)) if ('${f['detail']}'.isNotEmpty) '${f['detail']}'};
        return [
          _h('ציוד-קבוע'),
          _wrap([for (final e in eq.entries) StatusChip(label: '${e.key}${broken.contains(e.key) ? ' · תקול' : e.value ? '' : ' · חסר'}', tone: broken.contains(e.key) ? 2 : e.value ? 1 : 3)]),
          if (r['eqStock'] == null) ...[
            _gap(8),
            const AlertBanner(glyph: '📦', tone: 0, message: 'מקום-שמור: כמות-ציוד מפריטי-המלאי (eqStock ⇐ מודול-מלאי) — יאיר כשיגיע נתון'),
          ],
        ];
      case 4: // תקלות · פתוחות (TimelineItem) + סגור-תקלה
        final fs = _RoomData.faultsOf(r);
        if (fs.isEmpty) return [const EmptyState(glyph: '✅', message: 'אין תקלות פתוחות')];
        return [
          _h('תקלות פתוחות · ${fs.length}'),
          for (final f in fs)
            Row(children: [
              Expanded(child: TimelineItem(title: '🔧 ${f['name']} · ${f['severity']}', time: '${f['date']}', body: '${f['status']} · דווח: ${_RoomData.teacherName(f['createdBy'])}${'${f['detail']}'.isNotEmpty ? ' · ציוד: ${f['detail']}' : ''}')),
              if (_can('rooms.faultClose')) SoftButton(label: '✔ סגור', tone: 1, onTap: () => act(() => _RoomData.closeFault(_who, f))),
            ]),
        ];
      case 5: // אחזקה · זמינות (שיפוץ/סגור) · בדיקה-תקופתית (lastCheck = מקום-שמור) · חסימות-תאריך
        return [
          _h('אחזקה'),
          _wrap([
            StatusChip(label: _RoomData.activeOf(r) ? 'זמין לתפיסה' : 'לא-זמין / שיפוץ', tone: _RoomData.activeOf(r) ? 1 : 2),
            StatusChip(label: r['lastCheck'] == null ? 'בדיקה-תקופתית: אין נתון (מקום-שמור)' : 'בדיקה אחרונה: ${r['lastCheck']}', tone: r['lastCheck'] == null ? 3 : 1),
          ]),
          if (_RoomData.blockedDates.isNotEmpty) ...[
            _h('חסימות-תאריך ידניות'),
            _wrap([for (final d in _RoomData.blockedDates) SoftButton(label: '⛔ $d · בטל', tone: 2, onTap: () => act(() => _RoomData.unblockDate(_who, d)))]),
          ],
        ];
      case 6: // היסטוריה · תקלות-שנסגרו ⊕ אירועים-שבוצעו/נדחו (TimelineItem)
        final hist = <Widget>[
          for (final f in _RoomData.faultsOf(r, openOnly: false)) if (f['status'] == 'done') TimelineItem(title: '✔ תקלה נסגרה · ${f['name']}', time: '${f['date']}', body: '${f['severity']}'),
          for (final e in _RoomData.liveEvents) if (e['roomId'] == r['id'] && e['done'] == true) TimelineItem(title: '${e['status'] == 'rejected' ? '✖ נדחה' : e['status'] == 'cancelled' ? '↩ בוטל' : '✔ בוצע'} · ${e['title']}', time: '${e['date']} ${e['time']}', body: '${_RoomData.teacherName(e['requestedBy'])}'),
        ];
        return hist.isEmpty ? [const EmptyState(glyph: '📜', message: 'אין היסטוריה')] : [_h('היסטוריה · ${hist.length}'), ...hist];
      default: // אודיט · פנקס-הפעולות של החדר (מי · מה · מתי)
        final au = _RoomData.audit.where((a) => a['roomId'] == r['id']).toList();
        return au.isEmpty ? [const EmptyState(glyph: '🧾', message: 'אין רשומות-אודיט לחדר')] : [_h('אודיט · ${au.length}'), for (final a in au) TimelineItem(title: '${a['what']}', time: '${a['when']}', body: '${a['who']} · ${a['target']}')];
    }
  }

  // שורת-תפיסה בטאב "תפיסות": מי/מה/מתי + פעולות-פר-תפיסה (בטל · העבר-לחדר-אחר · אשר/דחה)
  Widget _occRow(BuildContext ctx, Map<String, dynamic> r, Map<String, dynamic> o, void Function(void Function()) act) {
    final isEv = o['kind'] == 'event';
    final st = isEv ? '${o['status']}' : 'שבועי';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TimelineItem(title: '${isEv ? '📌' : '🎓'} ${o['name']}', time: '${dayNames()[o['dayIdx'] as int]} ${o['iso']} ${_RoomData._m2hm(o['start'])}', body: '${o['who']} · ${st == 'proposed' ? 'ממתין-אישור' : st == 'pending' ? 'מאושר' : st}'),
      _wrap([
        if (isEv && st == 'proposed' && _can('rooms.approve')) ...[
          SoftButton(label: '✔ אשר', tone: 1, onTap: () => act(() => _RoomData.setEventStatus(_who, _RoomData.eventById(o['id'])!, 'pending'))),
          SoftButton(label: '✖ דחה', tone: 2, onTap: () => act(() => _RoomData.setEventStatus(_who, _RoomData.eventById(o['id'])!, 'rejected'))),
        ],
        if (isEv && _can('rooms.cancel')) SoftButton(label: '↩ בטל-תפיסה', tone: 2, onTap: () => act(() => _RoomData.setEventStatus(_who, _RoomData.eventById(o['id'])!, 'cancelled'))),
        if (_can('rooms.move')) SoftButton(label: '➡ העבר לחדר-אחר', tone: 0, onTap: () => _openMove(ctx, r, o, act)),
      ]),
      _gap(8),
    ]);
  }

  // העבר-תפיסה: הצעת-חדר-חלופי (altRooms: קיבולת⊕ציוד⊕פנוי⊕קרבה) — הכרעה, לא ניחוש
  void _openMove(BuildContext ctx, Map<String, dynamic> from, Map<String, dynamic> o, void Function(void Function()) act) {
    final isEv = o['kind'] == 'event';
    final ev = isEv ? _RoomData.eventById(o['id']) : null;
    final c = isEv ? null : _RoomData.courseById(o['id']);
    final need = isEv ? ((ev?['attendees'] as int?) ?? 0) : ((c?['maxStudents'] as int?) ?? 0);
    final needsEq = isEv ? const <String>[] : [for (final k in (c?['needsEq'] as List? ?? const [])) '$k'];
    final alts = _RoomData.altRooms(iso: '${o['iso']}', time: _RoomData._m2hm(o['start']), need: need, needsEq: needsEq, nearId: from['id'] as String, exceptId: '${o['id']}', excludeRoomId: from['id'] as String);
    showModalBottomSheet<void>(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (c2) => Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
          MediaRow(glyph: '➡', title: 'העבר: ${o['name']}', subtitle: '${o['iso']} ${_RoomData._m2hm(o['start'])} · נדרש ≥$need${needsEq.isNotEmpty ? ' · ציוד: ${needsEq.join(', ')}' : ''}'),
          _gap(8),
          if (alts.isEmpty)
            const EmptyState(glyph: '🚫', message: 'אין חדר חלופי פנוי שמקיים קיבולת+ציוד במשבצת')
          else
            for (final a in alts)
              Row(children: [
                Expanded(child: MediaRow(glyph: a['sameBuilding'] == true ? '📍' : '🏫', title: '${a['name']}', subtitle: '${a['location']} · קיבולת ${a['cap']} (+${a['spare']})${a['sameBuilding'] == true ? ' · אותו בניין' : ''}')),
                SoftButton(label: 'בחר', tone: 1, onTap: () { act(() => isEv ? _RoomData.moveEvent(_who, ev!, a) : _RoomData.moveCourse(_who, c!, a)); Navigator.of(c2).pop(); }),
              ]),
        ])),
      ),
    );
  }

  // הזמן-חדר: יום (SegmentedSwitch) ⊕ משבצת-פנויה (SoftButton מ-buildSlots kind=free) ⊕ כותרת (DsField)
  void _openBook(BuildContext ctx, Map<String, dynamic> r, void Function(void Function()) act, {bool weekly = false}) {
    var day = _dayIdx;
    var title = weekly ? 'הזמנה-חוזרת' : 'הזמנת-חדר';
    showModalBottomSheet<void>(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (c2) => StatefulBuilder(builder: (c2, setB) {
        final iso = _RoomData.weekIsos[day];
        final free = _RoomData.slotsOf(r, iso).where((x) => x['kind'] == 'free').toList();
        final blocked = _RoomData.blockOf(iso) ?? (_RoomData.blockedDates.contains(iso) ? 'חסימה-ידנית' : null);
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
            MediaRow(glyph: weekly ? '🔁' : '📌', title: weekly ? 'הזמנה-חוזרת (שבועית) · ${r['name']}' : 'הזמן-חדר · ${r['name']}', subtitle: 'בחר יום ומשבצת פנויה · ${_RoomData.roomInfo(r)}'),
            _gap(8),
            DsField(label: 'כותרת', hint: 'למה החדר נדרש', value: title, onChanged: (v) => title = v),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: SegmentedSwitch(items: dayNames(), selected: day, onSelect: (i) => setB(() => day = i))),
            _gap(8),
            if (blocked != null)
              AlertBanner(glyph: '⛔', tone: 2, message: 'יום חסום — $blocked')
            else if (free.isEmpty)
              const EmptyState(glyph: '🚫', message: 'אין משבצות פנויות ביום זה')
            else
              _wrap([for (final f in free) SoftButton(label: '🟢 ${f['time']}', tone: 1, onTap: () { act(() => weekly ? _RoomData.bookWeekly(_who, r, day, '${f['time']}', title) : _RoomData.book(_who, r, iso, '${f['time']}', title, approved: _RoomData.autoApprove(_role))); Navigator.of(c2).pop(); })]),
            _gap(8),
          ])),
        );
      }),
    );
  }

  // דווח-תקלה: שם ⊕ חומרה (אוצר-המילים של defects_sheet: חמור·בינוני·קל) ⊕ ציוד-מעורב (מ-eq)
  void _openFault(BuildContext ctx, Map<String, dynamic> r, void Function(void Function()) act) {
    var name = 'תקלה';
    var sev = 1;
    String detail = '';
    const sevs = ['חמור', 'בינוני', 'קל'];
    showModalBottomSheet<void>(
      context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (c2) => StatefulBuilder(builder: (c2, setB) => Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
          MediaRow(glyph: '🔧', title: 'דווח-תקלה · ${r['name']}', subtitle: 'תקלה-חמורה ⇒ החדר לא-זמין + העברת-שיעורים'),
          _gap(8),
          DsField(label: 'תיאור', hint: 'מה התקלה', value: name, onChanged: (v) => name = v),
          SegmentedSwitch(items: sevs, selected: sev, onSelect: (i) => setB(() => sev = i)),
          _h('ציוד מעורב (אופציונלי)'),
          _wrap([for (final k in _RoomData.eqOf(r).keys) SoftButton(label: detail == k ? '✔ $k' : k, tone: detail == k ? 1 : 0, onTap: () => setB(() => detail = detail == k ? '' : k))]),
          _gap(10),
          SoftButton(label: '📨 שלח דיווח', tone: 2, onTap: () { act(() => _RoomData.reportFault(_who, r, name, sevs[sev], detail: detail)); Navigator.of(c2).pop(); }),
          _gap(8),
        ])),
      )),
    );
  }

  // 14 כפתורי-הפעולה (המפרט) — כל אחד מחווט לפנקס (state) ורושם אודיט
  List<Widget> _actions(BuildContext ctx, Map<String, dynamic> r, void Function(void Function()) act) {
    final active = _RoomData.activeOf(r);
    final acts = <Widget>[
      if (active && _can('rooms.book')) SoftButton(label: _RoomData.autoApprove(_role) ? '📌 הזמן-חדר' : '📌 הזמן-חדר (לאישור)', tone: 1, onTap: () => _openBook(ctx, r, act)),
      if (active && _can('rooms.bookWeekly')) SoftButton(label: '🔁 הזמנה-חוזרת', tone: 0, onTap: () => _openBook(ctx, r, act, weekly: true)),
      if (_can('rooms.fault')) SoftButton(label: '🔧 דווח-תקלה', tone: 2, onTap: () => _openFault(ctx, r, act)),
      if (_can('rooms.availability')) SoftButton(label: active ? '⛔ סמן לא-זמין/שיפוץ' : '✅ החזר לזמינות', tone: active ? 2 : 1, onTap: () => act(() => _RoomData.setActive(_who, r, !active))),
      if (_can('rooms.eq')) SoftButton(label: '➕ הוסף-ציוד: מקרן', tone: 0, onTap: () => act(() => _RoomData.setEq(_who, r, 'מקרן', true))),
      if (_can('rooms.eq')) SoftButton(label: '📉 דווח ציוד-חסר: מקרן', tone: 2, onTap: () => act(() => _RoomData.setEq(_who, r, 'מקרן', false))),
      if (_can('rooms.block')) SoftButton(label: '📅 חסום-תאריך: $_iso', tone: 2, onTap: () => act(() => _RoomData.blockDate(_who, _iso))),
      if (_can('rooms.notify')) SoftButton(label: '✉ הודעה למשתמשי-החדר (${_RoomData.usersOf(r).length})', tone: 0, onTap: () => act(() => _RoomData.notifyUsers(_who, r, 'שינוי בחדר ${r['name']} — בדקו את היומן'))),
      if (_can('rooms.print')) SoftButton(label: '🖨 הדפס יומן-יומי', tone: 0, onTap: () => _openPrint(ctx, r)),
      // 4 · תקלה ⇒ העברת-שיעורים-אוטו + הודעה (רק כשהחדר תקול/לא-זמין ויש תפיסות)
      if (!active || _RoomData.faulty(r)) if (_can('rooms.move') && _RoomData.affectedByFault(r).isNotEmpty) SoftButton(label: '🚚 העבר-אוטו ${_RoomData.affectedByFault(r).length} תפיסות + הודעה', tone: 2, onTap: () => act(() => _RoomData.autoRelocate(_who, r))),
    ];
    return acts.isEmpty ? [const AlertBanner(message: 'צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה', glyph: '🔒', tone: 2)] : acts;
  }

  // הדפס-יומן-יומי: תצוגת-הדפסה (טקסט-נקי של buildSlots) — ההדפסה עצמה = שקע-פלטפורמה (הצבה)
  void _openPrint(BuildContext ctx, Map<String, dynamic> r) {
    final lines = [for (final x in _RoomData.slotsOf(r, _iso)) '${x['time']}  ${x['label']}'].join('\n');
    showModalBottomSheet<void>(
      context: ctx, backgroundColor: Colors.transparent,
      builder: (c2) => Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
          MediaRow(glyph: '🖨', title: 'יומן-יומי · ${r['name']}', subtitle: '${dayNames()[_dayIdx]} $_iso'),
          _gap(8),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)), child: SelectableText(lines, style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.7))),
        ])),
      ),
    );
  }

  // ═══ מרכז-אוטומציות (23-ג · פרואקטיבי) — הרכבה: מנוע-מדף ⊕ AlertBanner ⊕ SoftButton(פעולה-מוצעת) ═══
  List<Widget> _automationCenter() {
    final conf = _RoomData.weekConflicts;
    final pend = _RoomData.pendingApprovals;
    final miss = _RoomData.coursesMissingEq;
    final orphan = _RoomData.orphanCourses;
    final faultyRooms = _RoomData.liveRooms.where(_RoomData.faulty).toList();
    final under = _RoomData.activeRooms.where(_RoomData.underused).toList();
    final hol = _RoomData.upcoming;
    final unknownCheck = _RoomData.liveRooms.where(_RoomData.checkUnknown).length;
    final dueCheck = _RoomData.liveRooms.where(_RoomData.checkDue).toList();
    void act(void Function() f) { f(); setState(() {}); }
    return [
      DsSection(title: '🚨 דורש-פעולה · ${_RoomData.actionItems}', tone: _RoomData.actionItems > 0 ? 2 : 1, children: [
        if (_RoomData.actionItems == 0) const EmptyState(glyph: '✅', message: 'אין כפל-תפיסה · אין הזמנות ממתינות · כל שיעור בחדר עם הציוד הנדרש'),
        // 1 · גילוי-כפל-תפיסה בזמן-אמת (חוסם) ⇒ פתור = העברה לחדר-חלופי (altRooms)
        for (final c in conf)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: AlertBanner(glyph: '⚠️', tone: 2, message: 'כפל-תפיסה ${(c['room'] as Map)['name']} · ${c['iso']} ${c['time']}: ${(c['a'] as Map)['name']} ⊕ ${(c['b'] as Map)['name']}')),
            if (_can('rooms.move')) ...[const SizedBox(width: 6), SoftButton(label: '➡ פתור', tone: 2, onTap: () => _openMove(context, c['room'] as Map<String, dynamic>, {...(c['b'] as Map<String, dynamic>), 'iso': c['iso'], 'dayIdx': _RoomData.dow('${c['iso']}')}, act))],
          ])),
        // 9 · הזמנות-ממתינות (מחוץ-למדיניות) ⇒ אשר/דחה (rooms.approve)
        for (final e in pend)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: AlertBanner(glyph: '⏳', tone: 3, message: 'ממתין-אישור: ${e['title']} · ${_RoomData._room('${e['roomId']}')['name']} · ${e['date']} ${e['time']} · ${_RoomData.teacherName(e['requestedBy'])} · ${e['attendees']} משתתפים')),
            if (_can('rooms.approve')) ...[
              const SizedBox(width: 6), SoftButton(label: '✔', tone: 1, onTap: () => act(() => _RoomData.setEventStatus(_who, e, 'pending'))),
              const SizedBox(width: 4), SoftButton(label: '✖', tone: 2, onTap: () => act(() => _RoomData.setEventStatus(_who, e, 'rejected'))),
            ],
          ])),
        // 7 · ציוד-נדרש-לשיעור חסר/תקול בחדר (התרעה) ⇒ העבר לחדר עם הציוד (altRooms needsEq)
        for (final c in miss)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: AlertBanner(glyph: '🧰', tone: 3, message: 'ציוד חסר לשיעור: ${c['name']} ב-${_RoomData._room(_RoomData.roomOfCourse(c))['name']} — ${_RoomData.missingEqFor(c).join(', ')}')),
            if (_can('rooms.move')) ...[const SizedBox(width: 6), SoftButton(label: '➡ העבר', tone: 0, onTap: () {
              final s0 = (_RoomData._sess(c).first as Map);
              final d = s0['day'] as int;
              _openMove(context, _RoomData._room(_RoomData.roomOfCourse(c)), {'kind': 'course', 'id': c['id'], 'name': c['name'], 'who': _RoomData.teacherName(c['teacherId']), 'start': _RoomData._t2m(s0['time']), 'iso': _RoomData.weekIsos[d.clamp(0, 5)], 'dayIdx': d.clamp(0, 5)}, act);
            })],
          ])),
        // שיעור-בלי-חדר (inactiveRoomCourses ⊕ roomId ריק) ⇒ שבץ = חדר-חלופי
        for (final o in orphan)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: AlertBanner(glyph: '🏚', tone: 2, message: 'שיעור בלי חדר-פעיל: ${(o['course'] as Map)['name']} (${o['roomName']})')),
        // 4 · חדר-תקול (תקלה-חמורה פתוחה) ⇒ העברת-שיעורים-אוטו + הודעה
        for (final r in faultyRooms)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: AlertBanner(glyph: '🔧', tone: 2, message: 'חדר תקול (תקלה חמורה): ${r['name']} — ${_RoomData.affectedByFault(r).length} תפיסות השבוע מושפעות')),
            if (_can('rooms.move') && _RoomData.affectedByFault(r).isNotEmpty) ...[const SizedBox(width: 6), SoftButton(label: '🚚 העבר-אוטו', tone: 2, onTap: () => act(() => _RoomData.autoRelocate(_who, r)))],
          ])),
      ]),
      // 6 · חדר-לא-מנוצל · 3 · סנכרון-לוח (חגים קרובים ⇒ חסימה-אוטו) · 5 · בדיקה-תקופתית (מקום-שמור)
      if (under.isNotEmpty) ...[AlertBanner(glyph: '🪑', tone: 3, message: '${under.length} חדרים מתחת לסף-ניצולת ${_RoomData.utilFloor}%: ${under.map((r) => '${r['name']} ${_RoomData.utilPct(r)}%').join(' · ')}'), _gap(8)],
      if (hol.isNotEmpty) ...[AlertBanner(glyph: '📆', tone: 0, message: 'סנכרון-לוח · ${hol.length} חגים ב-45 יום ⇒ חסימה-אוטו: ${hol.map((h) => '${h['name']} ${h['iso']}').join(' · ')}'), _gap(8)],
      if (dueCheck.isNotEmpty) ...[AlertBanner(glyph: '🗓', tone: 3, message: 'בדיקה-תקופתית באיחור (>${_RoomData.checkEveryDays} יום): ${dueCheck.map((r) => r['name']).join(' · ')}'), _gap(8)],
      if (unknownCheck > 0) ...[AlertBanner(glyph: '🗓', tone: 0, message: 'תזכורת-בדיקה-תקופתית (מזגן/כיבוי-אש): אין תאריך-בדיקה ל-$unknownCheck חדרים — מקום-שמור (lastCheck), מאיר כשיגיע נתון'), _gap(8)],
      // 8 · ניצולת-שבועית-להנהלה (admin): NeonBars על ערכי-אמת (utilPct) — לא bar_chart המזייף
      if (_RoomData.roleName(_role) == 'admin') ...[
        DsSection(title: '📊 ניצולת-שבועית להנהלה · ממוצע ${_RoomData.utilAvgPct}%', children: [
          NeonBars(labels: [for (final r in _RoomData.utilRanked) '${r['name']}'], values: [for (final r in _RoomData.utilRanked) _RoomData.utilPct(r).toDouble()], tone: 0),
          _gap(6),
          Row(children: [
            BareStat(value: '${_RoomData.utilRanked.isEmpty ? '—' : _RoomData.utilRanked.first['name']}', label: 'הכי-מנוצל', inkColor: _acc, mutedColor: _muted),
            BareStat(value: '${_RoomData.utilRanked.isEmpty ? '—' : _RoomData.utilRanked.last['name']}', label: 'הכי-פחות', inkColor: _warning, mutedColor: _muted),
            BareStat(value: '${_RoomData.outbox.length}', label: 'הודעות שנשלחו', inkColor: _ink, mutedColor: _muted),
          ]),
        ]),
      ],
    ];
  }

  // ═══ ייצוא (23-ג) = SoftButton ⊕ toCsv/buildIcs ⊕ csvEscape/icsEscape ⊕ exportAllowed ⊕ guardExport ⊕ GlassCard-preview ═══
  //   guardExport(מדף) חוסם+מודיע; בסנדבוקס ההורדה חסומה ⇒ תצוגת-הקובץ לבדיקה+העתקה (SelectableText).
  void _openExport(List<Map<String, dynamic>> rs, {required bool ical}) {
    var blockedMsg = '';
    final ok = guardExport(!_RoomData.exportOk(_role), () => blockedMsg = 'ייצוא חסום (שער-הרשאות)');
    final body = !ok ? '' : ical ? _RoomData.icsOf(rs) : _RoomData.csvOf(rs);
    final occN = ical ? [for (final r in rs) ..._RoomData.weekOccupancies(r)].length : 0;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              MediaRow(glyph: ical ? '📆' : '⬇', title: ical ? 'ייצוא iCal (VCALENDAR)' : 'ייצוא CSV', subtitle: ical ? '${rs.length} חדרים · $occN תפיסות השבוע · RFC5545 (buildIcs)' : '${rs.length} חדרים · ${_RoomData.csvRows(rs).first.length} עמודות · BOM + חסימת-הזרקה'),
              _gap(10),
              if (!ok)
                AlertBanner(message: blockedMsg, glyph: '🔒', tone: 2)
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(body, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 11.5, height: 1.6)),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }

  // בורר-חדר לפעולות הפס-העליון (הזמן-חדר / דווח-תקלה): המועמדים = הרשימה-הנראית (אחרי איתור+סינון)
  void _pickRoom(List<Map<String, dynamic>> rs, void Function(Map<String, dynamic>) then) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent,
      builder: (c2) => Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(8), children: [
          const MediaRow(glyph: '🏫', title: 'בחר חדר', subtitle: 'מהרשימה-הנראית (אחרי חיפוש וסינון)'),
          _gap(6),
          if (rs.isEmpty) const EmptyState(glyph: '🔍', message: 'אין חדרים תואמים'),
          for (final r in rs)
            Row(children: [
              Expanded(child: MediaRow(glyph: _RoomData.activeOf(r) ? '🏫' : '⛔', title: '${r['name']}', subtitle: '${r['location']} · ${_RoomData.statusOf(r)}')),
              SoftButton(label: 'בחר', tone: 1, onTap: () { Navigator.of(c2).pop(); then(r); }),
            ]),
        ])),
      ),
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

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): RoomFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class RoomFacts {
  static const String entity = 'Room';
  static const String label = 'חדרים'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => _RoomData.rooms.length; // רשומות הזרע-הראשי "rooms" (static-const)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[{'key': 'busyNowN', 'label': '🔴 תפוסים-עכשיו', 'tone': 'plain'}, {'key': 'freeNowN', 'label': '🟢 פנויים-עכשיו', 'tone': 'plain'}, {'key': 'utilAvgPct', 'label': '📊 ניצולת-שבוע', 'tone': 'plain'}, {'key': 'unavailableN', 'label': '⛔ לא-זמינים', 'tone': 'danger'}, {'key': 'brokenEqN', 'label': '🧰 ציוד-חסר/תקול', 'tone': 'plain'}]; // 5 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי)
  static Map<String, String> get metrics => <String, String>{'busyNowN': '${_RoomData.busyNowN}', 'freeNowN': '${_RoomData.freeNowN}', 'utilAvgPct': '${_RoomData.utilAvgPct}%', 'unavailableN': '${_RoomData.unavailableN}', 'brokenEqN': '${_RoomData.brokenEqN}'};
  static const String heroKey = 'unavailableN'; // המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => '⛔ לא-זמינים';
  static const String idKey = 'id'; // מפתח-המזהה בזרע (אחרי retarget)
  static List<Map<String, dynamic>> get rows => _RoomData.rooms; // כל רשומות הזרע-הראשי (static-const)
  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>['busyNowN', 'unavailableN']) ...heroRows(k), ...rows]) { if ('${r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי
  static List<Map<String, dynamic>> heroRows(String key) { switch (key) { case 'busyNowN': return _RoomData.rowsOf_busyNowN; case 'unavailableN': return _RoomData.rowsOf_unavailableN; default: return const []; } } // G10a · 2 מדדים עם שורות (צורת X.where(P).length)
  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת
}
