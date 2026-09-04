// 🧬 AttFee — הרכבה חוצת-מודולים (GENMAX·G4b · הכרעה-24): schoolos_attendance.dart ⊕ schoolos_fees.dart · מחולל דטרמיניסטי: render-module.mjs --modules schoolos_attendance.dart,schoolos_fees.dart
//   כל שבר כאן חצוב מהזהב (golden-fragments.json) — לא נכתב; חברי-State שהתנגשו קיבלו סיומת-מודול; אין Date.now במנוע.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/bare_stat.dart'; // עובדה-KPI חשופה (ערך+תווית, פיגמנט מוזרק)
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל-התלמיד (child שרירותי)
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // ההירו = המטרה (דורשי-פעולה)
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-כיתה/שיעור/מבט מבוקר
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/status_dot.dart'; // נקודת-יום צבעונית (ציר-30-יום)
import '../dart-ui-bs/premium/feedback/empty_state.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/lists/avatar_tile.dart'; // זהות-תלמיד בפאנל (ראשי-תיבות+שם+תת)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס (ציון-סיכון · נוכחות%) — בר-מילוי
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט-ציר-זמן (השלמות · היסטוריה · אודיט)
import '../dart-ui-bs/premium/dataviz/progress_ring.dart'; // יחס נוכחות-חודשי (0..1) — תובנת-יחס
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // השוואת-סיבות (countBy) — עמודות-מנורמלות
import '../dart-ui-bs/premium/dataviz/trend_stat.dart'; // מגמה (ערך+דלתא%) — trendFromScan
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows, מיון) — לא DataGrid המזייף
import '../dart-ui-bs/ds/ds_enum_field.dart'; // בורר-סיבה מרשימה-סגורה (absenceReasonChips)
import '../dart-ui-bs/ds/ds_search.dart'; // חיפוש-מבוקר (value+onChanged) — פעולת-יסוד "איתור"
import '../dart-ui-bs/ds/ds_calendar.dart'; // לוח-חודש עם תפר-דאטה אמיתי (ספירת-חיסורים פר-יום) — טאב "חודש"
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר (חריגה)
import '../dart-maor/presents-in-month.dart'; // מנוע-מדף: ספירת-נוכחויות בחודש (presents ISO)
import '../dart-maor/sheet-summary.dart'; // מנוע-מדף: {present,total} לתאריך על roster
import '../dart-maor/sheet-roster.dart'; // מנוע-מדף: roster פר-חוג (active בלבד)
import '../dart-maor/pending-makeups.dart'; // מנוע-מדף: השלמות-ממתינות (לא-מתוזמנות קודם)
import '../dart-maor/makeup-eligibility.dart'; // מנוע-מדף: זכאות-השלמה (noshow לעולם לא · מוצדק כן)
import '../dart-maor/enroll-summary.dart'; // מנוע-מדף: {presents,absences,noshow,...} פר-שיבוץ
import '../dart-maor/count-by.dart'; // מנוע-מדף: קיבוץ+ספירה (סיבות · ימים · שיעורים)
import '../dart-maor/grand-total.dart'; // מנוע-מדף: Σ-לפי-מפתח (דקות-איחור)
import '../dart-maor/clamp-scale.dart'; // מנוע-מדף: הצמדה לגבולות (יחסים 0..1)
import '../dart-maor/intel-day-diff.dart'; // מנוע-מדף: הפרש-ימים בין ISO (רצף/חלון-מורה)
import '../dart-maor/date-in-range.dart'; // מנוע-מדף: ISO בטווח כוללני (היסטוריה/דוח)
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND (מדף)
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM (מדף)
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) (מדף)
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע (מדף)
import '../dart-maor/guard-export.dart'; // ייצוא: שומר-סף עם notify (מדף)
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff (מדף)
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח (מדף)
import '../dart-maor/intel-trend-from-scan.dart'; // מנוע-מדף: מגמה מרשימה-חודשית {dir,pct}
import '../dart-maor/fmt-date.dart'; // מנוע-מדף: ISO ⇒ dd/mm/yyyy
import '../dart-maor/month-key.dart'; // מנוע-מדף: ISO ⇒ YYYY-MM
import '../dart-maor/week-day-names.dart'; // דאטה-מדף: שמות-ימים (ראשון..שבת)
import '../dart-maor/time-to-min.dart'; // מנוע-מדף: 'HH:MM' ⇒ דקות (איחור · שיעור-נוכחי)
import '../dart-maor/holiday-of.dart'; // מנוע-מדף: שם-חג לתאריך (לוח-עברי)
import '../dart-maor/upcoming-holidays.dart'; // מנוע-מדף: חגים-קרובים בחלון-ימים (סנכרון-לוח מקדים)
import '../dart-maor/holidays.dart'; // דאטה-מדף: HOLIDAYS מפת-חגים
import '../dart-maor/heb-parts.dart'; // מנוע-מדף: תאריך ⇒ {day,month(En),year} עברי
import '../dart-data-maor/holiday-of-terms.dart' as hol_t; // מונחי-חגים-נדחים (דאטה)
import '../dart-data-maor/absence-reason-chips-terms.dart' as reason_t; // סיבות-מובנות (דאטה)
import '../dart-maor/absence-reason-chips.dart'; // מנוע-מדף: רשימת-סיבות-מובנות דרך term
import '../dart-ui-bs/ds/ds_bars.dart'; // פירוק-לפי-סוג: פסים-אמיתיים (labels+values) — לא bar_chart
import '../dart-ui-bs/ds/ds_number_field.dart'; // שדה-סכום (טופס חיוב/תשלום)
import '../dart-ui-bs/ds/ds_date_field.dart'; // שדה-תאריך (טופס)
import '../dart-ui-bs/ds/ds_field.dart'; // שדה-טקסט (הערה/סיבת-ביטול)
import '../dart-maor/shekel.dart'; // ₪-פורמט
import '../dart-maor/pay-bal.dart'; // יתרה = totalDue + carryBalance − שולם (≥0)
import '../dart-maor/pay-credit.dart'; // זכות = שולם-יתר
import '../dart-maor/enrollment-paid-status.dart'; // paid/partial/unpaid
import '../dart-maor/max-discount-pct.dart'; // מדיניות-הנחה: הגבוה-מנצח (אחים/סוציו/מלגה)
import '../dart-maor/effective-price.dart'; // מחיר-אחרי-הנחה (עיגול, ≥0)
import '../dart-maor/hok-effectively-active.dart'; // הו״ק פעילה-אפקטיבית (kevaId ⇒ סליקה-חיה תוך 2 חודשים)
import '../dart-maor/hok-recorded-this-month.dart'; // הו״ק נרשמה-החודש
import '../dart-maor/hok-due.dart'; // רשימת-הו״ק-לרישום-חודשי (ממוינת לפי יום-חיוב)
import '../dart-maor/hok-monthly-total.dart'; // צפוי-החודש מהו״ק
import '../dart-maor/hok-method-label.dart'; // תווית-אמצעי-הו״ק
import '../dart-maor/hok-cat.dart'; // קטגוריית-הו״ק (קבוע-מערכת)
import '../dart-maor/sup-score.dart'; // דפוס-תשלום RFM (טריות·תדירות·סכום) 130–1000
import '../dart-maor/sup-last.dart'; // תשלום-אחרון
import '../dart-maor/sup-count.dart'; // מספר-תשלומים
import '../dart-maor/sup-ils.dart'; // Σ₪ ששולם
import '../dart-maor/sup-usd.dart'; // Σ$ (0 כאן — שקע-האטום דורש)
import '../dart-maor/sup-total-ils.dart'; // שווי-כולל ₪
import '../dart-maor/tier-of.dart'; // דרגת-אמינות לפי-ניקוד (titan/lion/pale/red)
import '../dart-maor/segula-reminders.dart'; // תזכורת-מדורגת: תאריך-התחלה+דילוגים ⇒ לוח-תזכורות
import '../dart-maor/wa-payment-text.dart'; // נוסח-תזכורת (תבנית-מוזרקת, סכום מעוצב)
import '../dart-maor/overdue-contact-task-drafts.dart'; // משימות-מעקב למי-שעבר-מועד
import '../dart-maor/charge-dedup-key.dart'; // מפתח-דדופ לחיוב (חיוב-כפול-חשוד)
import '../dart-maor/strong-match-for-charge.dart'; // התאמת-תשלום-נכנס למשפחה (phone/email/idNum)
import '../dart-maor/pay-link.dart'; // קישור-תשלום (שער-חיצוני · מקום-שמור: payUrl ריק ⇒ null)
import '../dart-maor/donation-years.dart'; // שנות-תשלום קיימות
import '../dart-data-maor/hok-effectively-active-sockets.dart' as skHokActive;
import '../dart-data-maor/hok-recorded-this-month-sockets.dart' as skHokRec;
import '../dart-data-maor/hok-method-label-terms.dart' as tdHokMethod;
import '../dart-data-maor/tier-of-terms.dart' as tdTier;
import '../dart-data-maor/overdue-contact-task-drafts-sockets.dart' as skOverdue;
const _acc = DsTokens.accent;
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);
// ═══════════ בלוק-הצבה (חוק-6): זהויות/קשרים מוזרקים — לא אטום, לא דאטה-דומיין ═══════════
class _Placement {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (VERIFY: אין Date.now במנוע)
  static const nowHm = '10:20'; // שעה-מוזרקת (שיעור-נוכחי · תזכורת · נעילה-אוטו)
  static const lateWindowMin = 10; // חלון-איחור (דקות) — מוגדר-מוסד
  static const minAttendancePct = 80; // סף-רגולטורי (זכאות/תעודה)
  static const streakAlert = 3; // התרעת-רצף: N חיסורים רצופים
  static const riskRed = 60, riskOrange = 35; // ספי-סיכון (ציון 0..100)
  static const lockHm = '16:00'; // נעילה-אוטומטית סוף-יום
  static const groupAbsenceMin = 2; // חיסור-קבוצתי: לפחות N חסרים וגם ≥ חצי-כיתה ⇒ אירוע?
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👩‍🏫 מורה', 'id': 't1', 'email': 'teacher1@school', 'classes': ['y1'], 'window': 1, 'config': {'roles': {'teachers': {'teacher1@school': true}}, 'features': {'att.mark': true, 'att.notify': true, 'att.makeup': true, 'att.export': true}}},
    {'label': '🔄 מחליף', 'id': 'sub1', 'email': 'sub@school', 'classes': ['y2'], 'window': 0, 'config': {'features': {'att.mark': true}}},
    {'label': '🧭 רכז/ת', 'id': 'coord', 'email': 'coord@school', 'classes': null, 'window': 365, 'config': {'features': {'att.mark': true, 'att.back': true, 'att.justify': true, 'att.unlock': true, 'att.lock': true, 'att.makeup': true, 'att.notify': true, 'att.export': true, 'att.audit': true}}},
    {'label': '👑 הנהלה', 'id': 'mgmt', 'email': 'mgr@school', 'classes': null, 'window': 365, 'config': {'adminEmails': ['mgr@school']}}, // admin ⇒ הכל
    {'label': '👪 הורה', 'id': 'parent-s1', 'email': 'parent1@home', 'child': 's1', 'window': 0, 'config': {'features': {'att.parentOk': true}}},
    {'label': '👁 צפייה', 'id': 'viewer', 'email': 'view@school', 'classes': null, 'window': 0, 'config': <String, dynamic>{}},
  ];
  // קשרי-הורים (הצבה): studentId ⇒ {name, phone}. חסר ⇒ המקום-השמור שקט.
  static const parents = <String, Map<String, String>>{
    's1': {'name': 'דנה שמעוני', 'phone': '050-555-0101'},
    's2': {'name': 'יוסי אוחיון', 'phone': '052-555-0102'},
    's3': {'name': 'מיכל נחום', 'phone': '054-555-0103'},
    's4': {'name': 'אורית ביטון', 'phone': '050-555-0104'},
    's5': {'name': 'רות לוי', 'phone': '053-555-0105'},
    's6': {'name': 'עמית כהן', 'phone': '058-555-0106'},
    's8': {'name': 'שרון מזרחי', 'phone': '050-555-0108'},
  };
}

// ═══════════ המנוע הטהור: דאטה-אמת + נגזרות (אפס-DOM) ═══════════
// 🔴 סכמת-אמת (§20-ג): שיבוץ-מאור {id, memberId, courseId, status, presents:[ISO], absences:[{date, reason,
//   makeup, makeupDate, noshow}]} (pending-makeups.contract.md · enroll-summary.contract.md) — הבסיס.
//   הרחבת-חיסור (מקור: AttendanceDay/AttendanceEntry של בנייה-חכמה — timeIn/timeOut): lesson · status
//   (absent|late|released) · arrival 'HH:MM' · justified · parentOk · by · at.
//   ⛔ ללא-מקור ⇒ מקום-שמור בלבד: תמונה · אישור-רפואי-קובץ · נוכחות-מקוונת · הסעה · ביומטרי · GPS · ציון-חיצוני.
class _AttData {
  // כיתות (courseId) + מערכת-שיעורים פר-יום-בשבוע (0=ראשון) — מקור "איזה-שיעור-עכשיו" (מודול-חוגים)
  static const classes = <Map<String, dynamic>>[
    {'id': 'y1', 'name': 'י׳-1', 'teacher': 't1'},
    {'id': 'y2', 'name': 'י׳-2', 'teacher': 't2'},
    {'id': 'h2', 'name': 'ח׳-2', 'teacher': 't3'},
  ];
  // שיעור = {n, time, subject}. שבת=אין. שישי=4 שיעורים.
  static const lessonsByDow = <int, List<Map<String, dynamic>>>{
    0: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'לשון'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'היסטוריה'}, {'n': 5, 'time': '11:40', 'subject': 'מדעים'}],
    1: [{'n': 1, 'time': '08:00', 'subject': 'לשון'}, {'n': 2, 'time': '08:50', 'subject': 'מתמטיקה'}, {'n': 3, 'time': '09:50', 'subject': 'ספורט'}, {'n': 4, 'time': '10:40', 'subject': 'אנגלית'}, {'n': 5, 'time': '11:40', 'subject': 'תנ״ך'}],
    2: [{'n': 1, 'time': '08:00', 'subject': 'מדעים'}, {'n': 2, 'time': '08:50', 'subject': 'מתמטיקה'}, {'n': 3, 'time': '09:50', 'subject': 'לשון'}, {'n': 4, 'time': '10:40', 'subject': 'אזרחות'}, {'n': 5, 'time': '11:40', 'subject': 'אנגלית'}],
    3: [{'n': 1, 'time': '08:00', 'subject': 'אנגלית'}, {'n': 2, 'time': '08:50', 'subject': 'היסטוריה'}, {'n': 3, 'time': '09:50', 'subject': 'מתמטיקה'}, {'n': 4, 'time': '10:40', 'subject': 'מדעים'}, {'n': 5, 'time': '11:40', 'subject': 'לשון'}],
    4: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'תנ״ך'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'ספורט'}, {'n': 5, 'time': '11:40', 'subject': 'לשון'}],
    5: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'לשון'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'חינוך'}],
    6: [],
  };
  // תלמידים (members): id · name · cls · num · active. תמונה (photo) = מקום-שמור.
  static const students = <Map<String, dynamic>>[
    {'id': 's1', 'name': 'רון שמעוני', 'cls': 'y1', 'num': 1},
    {'id': 's2', 'name': 'ליאור אוחיון', 'cls': 'y1', 'num': 2},
    {'id': 's3', 'name': 'הדר נחום', 'cls': 'y1', 'num': 3},
    {'id': 's4', 'name': 'מאיה ביטון', 'cls': 'y1', 'num': 4},
    {'id': 's5', 'name': 'נועה לוי', 'cls': 'y1', 'num': 5},
    {'id': 's6', 'name': 'עידו כהן', 'cls': 'y1', 'num': 6},
    {'id': 's7', 'name': 'שירה פרץ', 'cls': 'y1', 'num': 7, 'active': false}, // תלמיד-לא-פעיל (מצב-מיוחד)
    {'id': 's8', 'name': 'טל מזרחי', 'cls': 'y2', 'num': 1},
    {'id': 's9', 'name': 'יובל דהן', 'cls': 'y2', 'num': 2},
    {'id': 's10', 'name': 'אלה ברק', 'cls': 'y2', 'num': 3},
    {'id': 's11', 'name': 'נדב חדד', 'cls': 'h2', 'num': 1},
    {'id': 's12', 'name': 'רוני גל', 'cls': 'h2', 'num': 2},
  ];
  // ─── יומן-חיסורים בסיסי (const · מקור-האמת ההיסטורי · מודל-הפוך: רק מי-שלא-נכח) ───
  //   date · lesson · sid · status(absent|late|released) · reason · justified · makeup · makeupDate ·
  //   arrival('HH:MM' — מקור: AttendanceEntry.timeIn) · parentOk · by(מי-רשם) · at(מתי, אודיט)
  static const baseMarks = <Map<String, dynamic>>[
    // רון — דפוס: יום-קבוע (ראשון) + רצף אחרון ⇒ בסיכון
    {'date': '2026-08-16', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-16T08:07'},
    {'date': '2026-08-23', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-23T08:05'},
    {'date': '2026-08-30', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-30T08:06'},
    {'date': '2026-09-01', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-01T08:04'},
    {'date': '2026-09-02', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-02T08:09'},
    {'date': '2026-09-03', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-03T08:03'},
    // ליאור — מאחר כרוני (שיעור-קבוע 1) + חיסור מוצדק עם השלמה-מתוזמנת
    {'date': '2026-08-24', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:18', 'by': 't1', 'at': '2026-08-24T08:18'},
    {'date': '2026-08-26', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:22', 'by': 't1', 'at': '2026-08-26T08:22'},
    {'date': '2026-08-31', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:15', 'by': 't1', 'at': '2026-08-31T08:15'},
    {'date': '2026-09-02', 'lesson': 3, 'sid': 's2', 'status': 'absent', 'reason': 'חולה', 'justified': true, 'makeup': true, 'makeupDate': '2026-09-08', 'parentOk': true, 'by': 't1', 'at': '2026-09-02T09:55'},
    // הדר — טיול משפחתי מוצדק, השלמה לא-מתוזמנת
    {'date': '2026-08-27', 'lesson': 2, 'sid': 's3', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'makeup': true, 'parentOk': true, 'by': 't1', 'at': '2026-08-27T08:52'},
    {'date': '2026-08-27', 'lesson': 3, 'sid': 's3', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't1', 'at': '2026-08-27T09:52'},
    // מאיה — שחרור-מאושר (יציאה-מוקדמת)
    {'date': '2026-09-01', 'lesson': 5, 'sid': 's4', 'status': 'released', 'reason': 'רפואי', 'justified': true, 'parentOk': true, 'by': 't1', 'at': '2026-09-01T11:30'},
    // עידו — חיסורים לא-מוצדקים ללא-אישור-הורה (החודש) ⇒ הודעה-אוטו
    {'date': '2026-09-01', 'lesson': 2, 'sid': 's6', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-01T08:55'},
    {'date': '2026-09-03', 'lesson': 4, 'sid': 's6', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-03T10:44'},
    // ח׳-2 · 25/8 — כל הכיתה חסרה (2/2) ⇒ זיהוי-חיסור-קבוצתי (אירוע: טיול)
    {'date': '2026-08-25', 'lesson': 1, 'sid': 's11', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't3', 'at': '2026-08-25T08:05'},
    {'date': '2026-08-25', 'lesson': 1, 'sid': 's12', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't3', 'at': '2026-08-25T08:05'},
    // י׳-2 · טל — אבל (מוצדק), יובל — איחור-הסעה
    {'date': '2026-09-02', 'lesson': 1, 'sid': 's8', 'status': 'absent', 'reason': 'אבל', 'justified': true, 'parentOk': true, 'by': 't2', 'at': '2026-09-02T08:03'},
    {'date': '2026-09-03', 'lesson': 1, 'sid': 's9', 'status': 'late', 'arrival': '08:12', 'by': 't2', 'at': '2026-09-03T08:12'},
    // היום (מוזרק): י׳-1 שיעור 1 נרשם — רון חסר (רצף 4!), ליאור מאחר; י׳-2 וח׳-2 טרם נרשמו
    {'date': '2026-09-04', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-04T08:06'},
    {'date': '2026-09-04', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:14', 'by': 't1', 'at': '2026-09-04T08:14'},
  ];
  // כיתה-שיעור-יום שאושר "כולם-נוכחים" (מודל-הפוך: רישום-ריק חייב אישור מפורש כדי להיחשב "נרשם")
  static const baseRecorded = <String>{'2026-09-04|y1|1', '2026-09-03|y1|1', '2026-09-03|y1|2', '2026-09-03|y1|3', '2026-09-03|y1|4', '2026-09-03|y2|1'};

  // ─── פנקס-הפעולות (state): סימונים מעל הבסיס — אידמפוטנטי (מפתח date|lesson|sid) ───
  static final Map<String, Map<String, dynamic>> _overrides = {};
  static final Set<String> _recorded = {...baseRecorded};
  static final List<Map<String, dynamic>> audit = []; // אודיט-רישום {at, by, action, key} (חדש-ראשון)
  static final Map<String, List<String>> notes = {}; // הערות פר-תלמיד
  static int _seq = 0; // מונה-אירועים (סדר-אודיט דטרמיניסטי; השעון מוזרק)
  static String keyOf(String date, int lesson, String sid) => '$date|$lesson|$sid';
  static void _log(String action, String key) {
    _seq++;
    audit.insert(0, {'at': '${_Placement.today}T${_Placement.nowHm}', 'seq': _seq, 'by': _AttData.recorder, 'action': action, 'key': key});
  }

  // כל הסימונים האפקטיביים: בסיס + דריסות (דריסה עם status='present' = ביטול ⇒ נעלם מהמודל-ההפוך)
  static List<Map<String, dynamic>> get marks {
    final m = <String, Map<String, dynamic>>{};
    for (final b in baseMarks) {
      m[keyOf(b['date'] as String, b['lesson'] as int, b['sid'] as String)] = b;
    }
    for (final e in _overrides.entries) {
      m[e.key] = e.value;
    }
    return [for (final v in m.values) if (v['status'] != 'present') v];
  }
  static final Map<String, Map<String, dynamic>> _baseIndex = {
    for (final b in baseMarks) keyOf(b['date'] as String, b['lesson'] as int, b['sid'] as String): b,
  };
  static Map<String, dynamic>? markOf(String date, int lesson, String sid) {
    final k = keyOf(date, lesson, sid);
    final v = _overrides[k] ?? _baseIndex[k];
    return v == null || v['status'] == 'present' ? null : v;
  }

  // ═══ רישום (פעולה-2): אידמפוטנטי — אותו מפתח+אותו מצב ⇒ false (רישום-כפול חסום, לא מוכפל) ═══
  static bool mark(String date, int lesson, String sid, String status, {String? reason, String? arrival}) {
    if (!canMarkOn(date)) return false; // יום-נעול / מחוץ-לחלון / אין-הרשאה ⇒ חסום (המסך מדווח why)
    final cur = markOf(date, lesson, sid);
    if ((cur?['status'] ?? 'present') == status) return false; // כפול ⇒ חסום
    final k = keyOf(date, lesson, sid);
    if (status == 'present') {
      _overrides[k] = {...?cur, 'date': date, 'lesson': lesson, 'sid': sid, 'status': 'present'};
    } else {
      _overrides[k] = {
        ...?cur, 'date': date, 'lesson': lesson, 'sid': sid, 'status': status,
        'reason': reason ?? cur?['reason'] ?? (status == 'absent' ? 'אחר' : null),
        'justified': cur?['justified'] ?? (status == 'released'),
        if (status == 'late') 'arrival': arrival ?? cur?['arrival'] ?? _Placement.nowHm,
        'by': _AttData.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}',
      };
    }
    _recorded.add('$date|${studentById(sid)['cls']}|$lesson');
    _log(status, k);
    return true;
  }
  static const cycleOrder = ['present', 'absent', 'late', 'released']; // טאפ-מחזורי
  static String cycle(String date, int lesson, String sid) {
    final cur = markOf(date, lesson, sid)?['status'] as String? ?? 'present';
    final next = cycleOrder[(cycleOrder.indexOf(cur) + 1) % cycleOrder.length];
    mark(date, lesson, sid, next);
    return next;
  }
  static void patch(String date, int lesson, String sid, Map<String, dynamic> fields) {
    final cur = markOf(date, lesson, sid);
    if (cur == null) return;
    _overrides[keyOf(date, lesson, sid)] = {...cur, ...fields, 'by': _AttData.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}'};
    _log(fields.keys.join('+'), keyOf(date, lesson, sid));
  }
  // כולם-נוכחים (טאפ-אחד): מאפס סימוני-השיעור לנוכח + מסמן "נרשם"
  static Map<String, bool> eligibility(Map<String, dynamic> m) =>
      makeupEligibility(m['justified'] == true ? 'cancel' : 'noshow', m['justified'] == true, m['noticeHrs'] as num?); // noticeHrs = מקום-שמור
  static String nextSchoolDay(String from) {
    var d = shift(from, 1);
    for (var i = 0; i < 30 && !isSchoolDay(d); i++) {
      d = shift(d, 1);
    }
    return d;
  }

  // ─── תלמידים/כיתות (עובדות) ───
  static bool activeOf(Map<String, dynamic> s) => (s['active'] as bool?) ?? true;
  static List<Map<String, dynamic>> studentsOf(String cls) => students.where((s) => s['cls'] == cls && activeOf(s)).toList();
  static Map<String, dynamic> studentById(String sid) => students.firstWhere((s) => s['id'] == sid);
  static String className(String cls) => classes.firstWhere((c) => c['id'] == cls)['name'] as String;
  static String initials(String name) => name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join();
  static int dow(String iso) => DateTime.parse('${iso}T12:00:00').weekday % 7; // 0=ראשון
  static List<Map<String, dynamic>> lessonsOf(String iso) => lessonsByDow[dow(iso)] ?? const [];
  static String iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String shift(String isoDate, int days) {
    final d = DateTime.parse('${isoDate}T12:00:00');
    return iso(DateTime(d.year, d.month, d.day + days));
  }
  // השיעור-הנוכחי (מודול-חוגים): האחרון שהתחיל לפי nowHm (היום) · 1 ביום אחר
  static int currentLesson(String date) {
    final ls = lessonsStarted(date);
    return ls.isEmpty ? (lessonsOf(date).isEmpty ? 1 : lessonsOf(date).first['n'] as int) : ls.last['n'] as int;
  }

  // ─── לוח/חופשים (מודול-יומן): holidayOf ⊕ hebParts ⊕ HOLIDAYS — חג ⇒ לא-נספר אוטומטית ───
  //   scanHebYear (שקע): קבוצת-החודשים-בני-30 סביב התאריך — נגזר מ-hebParts (יום==30), לא מנוחש.
  static Map<String, dynamic> _scanHebYear(DateTime near) {
    final has30 = <String>{};
    for (var i = -70; i <= 70; i++) {
      final p = hebParts(DateTime(near.year, near.month, near.day + i));
      if (p['day'] == 30) has30.add(p['month'] as String);
    }
    return {'has30': has30};
  }
  static final Map<String, String?> _holCache = {};
  static String? holidayName(String isoDate) => _holCache.putIfAbsent(isoDate, () {
        final d = DateTime.parse('${isoDate}T12:00:00');
        return holidayOf(d, (x) => hebParts(x), (_) => _scanHebYear(d), HOLIDAYS, term: (k) => hol_t.kTerms[k] ?? k);
      });
  // יום-לימודים = יש שיעורים בשבוע-הלימודים וגם אין-חג (נספר בנוכחות%; חג/שבת ⇒ לא-נספר)
  static bool isSchoolDay(String isoDate) => lessonsOf(isoDate).isNotEmpty && holidayName(isoDate) == null;
  static List<String> schoolDaysInMonth(String anyIso, {String? upTo}) {
    final mk = monthKey(anyIso);
    final first = DateTime.parse('$mk-01T12:00:00');
    final out = <String>[];
    for (var i = 0; i < 31; i++) {
      final d = DateTime(first.year, first.month, first.day + i);
      if (d.month != first.month) break;
      final s = iso(d);
      if (upTo != null && s.compareTo(upTo) > 0) break;
      if (isSchoolDay(s)) out.add(s);
    }
    return out;
  }
  // N ימי-לימודים אחרונים (עד today כולל) — חלון-הדפוס
  static List<String> lastSchoolDays(int n) {
    final out = <String>[];
    var d = _Placement.today;
    for (var i = 0; i < 90 && out.length < n; i++) {
      if (isSchoolDay(d)) out.add(d);
      d = shift(d, -1);
    }
    return out.reversed.toList();
  }

  // ─── סטטוס-יומי פר-תלמיד (הכרעה מאוחדת על כל שיעורי-היום): absent > late > released > present ───
  static List<Map<String, dynamic>> marksOn(String date, String sid) => marks.where((m) => m['date'] == date && m['sid'] == sid).toList();
  static String dayStatus(String date, String sid) {
    final ms = marksOn(date, sid);
    if (ms.any((m) => m['status'] == 'absent')) return 'absent';
    if (ms.any((m) => m['status'] == 'late')) return 'late';
    if (ms.any((m) => m['status'] == 'released')) return 'released';
    return 'present';
  }
  static bool absentDay(String date, String sid) => marksOn(date, sid).any((m) => m['status'] == 'absent');
  // שעת-הגעה (מקור: arrival) · דקות-איחור = arrival − תחילת-השיעור (timeToMin מהמדף) − חלון-מוסד
  static String? arrivalOf(String date, String sid) {
    for (final m in marksOn(date, sid)) {
      if (m['arrival'] != null) return m['arrival'] as String;
    }
    return null;
  }
  static int lateMinutes(Map<String, dynamic> m) {
    final arr = m['arrival'];
    if (arr == null) return 0;
    final lesson = lessonsOf(m['date'] as String).firstWhere((l) => l['n'] == m['lesson'], orElse: () => const {'time': '08:00'});
    final a = timeToMin(arr), s = timeToMin(lesson['time']);
    if (a is! num || s is! num || a.isNaN || s.isNaN) return 0;
    final d = (a - s).toInt();
    return d < 0 ? 0 : d;
  }
  static int lateMinutesOn(String date, String sid) => grandTotal(marksOn(date, sid).where((m) => m['status'] == 'late').toList(), (m) => lateMinutes(m as Map<String, dynamic>)).toInt();
  static bool isLate(Map<String, dynamic> m) => m['status'] == 'late' && lateMinutes(m) > _Placement.lateWindowMin;
  static bool unjustified(Map<String, dynamic> m) => m['status'] == 'absent' && m['justified'] != true;
  static Map<String, dynamic>? firstMarkOn(String date, String sid) => marksOn(date, sid).isEmpty ? null : marksOn(date, sid).first;

  // ─── מיפוי לצורת-מאור (enrollment) ⇒ מנועי-המדף עובדים על האמת-ההפוכה ───
  //   presents = ימי-לימודים בחודש שהתלמיד לא-חסר בהם (נגזרת מהמודל-ההפוך) · absences = הסימונים
  static Map<String, dynamic> enrollmentOf(Map<String, dynamic> s, {String? month}) {
    final sid = s['id'] as String;
    final days = schoolDaysInMonth(month ?? _Placement.today, upTo: _Placement.today);
    final presents = [for (final d in days) if (!absentDay(d, sid)) d];
    final absences = [
      for (final m in marks)
        if (m['sid'] == sid && m['status'] == 'absent')
          {'date': m['date'], 'reason': m['reason'], 'makeup': m['makeup'] == true, if (m['makeupDate'] != null) 'makeupDate': m['makeupDate'], 'noshow': m['justified'] != true, 'lesson': m['lesson']},
    ];
    return {'id': 'e-$sid', 'memberId': sid, 'courseId': s['cls'], 'status': activeOf(s) ? 'active' : 'ended', 'presents': presents, 'absences': absences};
  }
  static List<Map<String, dynamic>> get enrollments => [for (final s in students) enrollmentOf(s)];
  // ─── הערכת-מצב (פעולה-3): מנועי-מדף ───
  static int presentsThisMonth(Map<String, dynamic> s) => presentsInMonth((enrollmentOf(s)['presents'] as List).cast<Object?>(), _Placement.today);
  static int absencesThisMonth(String sid) => marks.where((m) => m['sid'] == sid && m['status'] == 'absent' && monthKey(m['date'] as String) == monthKey(_Placement.today)).length;
  static int schoolDaysSoFar() => schoolDaysInMonth(_Placement.today, upTo: _Placement.today).length;
  static double attendancePct(Map<String, dynamic> s) {
    final n = schoolDaysSoFar();
    return n == 0 ? 1.0 : presentsThisMonth(s) / n;
  }
  static Map<String, dynamic> summaryOf(Map<String, dynamic> s) => enrollSummary(enrollmentOf(s), (_) => 0, (_) => 0, const {'k1': 'פעיל', 'k2': 'מושהה', 'k3': 'הסתיים', 'k4': 'רשימת-המתנה'});
  // רצף-חיסורים: ימי-לימודים רצופים (אחורה מהיום) שבהם חסר — dayDiff מהמדף מוודא רציפות-לוח
  static int streak(String sid) {
    final days = lastSchoolDays(30);
    var n = 0;
    for (var i = days.length - 1; i >= 0; i--) {
      if (!absentDay(days[i], sid)) break;
      if (i < days.length - 1 && dayDiff(days[i], days[i + 1]) > 4) break; // פער > 4 ימי-לוח (חופשה) שובר רצף
      n++;
    }
    return n;
  }
  // מגמה: חיסורים פר-חודש (3 חודשים) ⇒ trendFromScan {dir,pct}
  static Map<String, dynamic> trend(String sid) {
    final months = [monthKey(shift(_Placement.today, -60)), monthKey(shift(_Placement.today, -30)), monthKey(_Placement.today)];
    final counts = [for (final mk in months) marks.where((m) => m['sid'] == sid && m['status'] == 'absent' && monthKey(m['date'] as String) == mk).length];
    return trendFromScan({'monthly': counts});
  }
  static String trendLabel(String sid) {
    final t = trend(sid);
    return t['dir'] == 'up' ? '↑ ${t['pct']}%' : t['dir'] == 'down' ? '↓ ${t['pct']}%' : '→';
  }
  static List<Map<String, Object?>> get pendingMakeupList => pendingMakeups(enrollments);
  static List<Map<String, Object?>> pendingMakeupsOf(String sid) => pendingMakeupList.where((p) => p['memberId'] == sid).toList();
  static String? scheduledMakeup(String sid) {
    for (final p in pendingMakeupsOf(sid)) {
      if (p['makeupDate'] != null) return p['makeupDate'] as String;
    }
    return null;
  }
  // חיסורים-לפי-סיבה (countBy מהמדף) — 30 ימי-לימודים אחרונים
  static List<Map<String, dynamic>> absencesOf(String sid) => marks.where((m) => m['sid'] == sid && m['status'] == 'absent').toList();
  static List<List<Object>> reasonsOf(String sid) => countBy(absencesOf(sid), (m) => '${(m as Map)['reason'] ?? 'אחר'}');

  // ═══ ניבוי-נשירה (הכרעה 23-ד · חיבור-מודלים): דפוס-היעדרות ⇒ ציון-סיכון 0..100 ═══
  //   4 אותות מנורמלים: שיעור-חיסורים-לא-מוצדקים(40) · רצף(30) · מגמה(20) · דפוס-קבוע(10).
  //   פוקטור-חיצוני (מודול-תלמידים): riskExternal = מקום-שמור — כשיוזרק, מחברים max(פנימי,חיצוני).
  static Map<String, int> patterns(String sid) {
    final abs = absencesOf(sid);
    if (abs.length < 3) return const {};
    final byDow = countBy(abs, (m) => '${dow((m as Map)['date'] as String)}');
    final byLesson = countBy(abs, (m) => '${(m as Map)['lesson']}');
    final afterHoliday = abs.where((m) => holidayName(shift(m['date'] as String, -1)) != null || dow(m['date'] as String) == 0).length;
    final out = <String, int>{};
    if ((byDow.first[1] as int) * 2 >= abs.length) out['יום-קבוע: ${dayNames[int.parse(byDow.first[0] as String)]}'] = byDow.first[1] as int;
    if ((byLesson.first[1] as int) * 2 >= abs.length) out['שיעור-קבוע: ${byLesson.first[0]}'] = byLesson.first[1] as int;
    if (afterHoliday * 2 >= abs.length) out['אחרי-חופשה/סופ״ש'] = afterHoliday;
    return out;
  }
  static Map<String, num> riskParts(String sid) {
    final days = lastSchoolDays(30);
    final unj = days.where((d) => marksOn(d, sid).any(unjustified)).length;
    final rate = clampScale(unj / 6, 0, 1); // 6 חיסורים לא-מוצדקים ב-30 ימי-לימודים = מקסימום
    final st = clampScale(streak(sid) / 4, 0, 1);
    final t = trend(sid);
    final tr = t['dir'] == 'up' ? 1 : t['dir'] == 'flat' && unj > 0 ? 0.4 : 0;
    final pat = patterns(sid).isEmpty ? 0 : 1;
    return {'rate': rate * 40, 'streak': st * 30, 'trend': tr * 20, 'pattern': pat * 10};
  }
  static int risk(String sid) {
    final internal = riskParts(sid).values.fold<num>(0, (a, b) => a + b).round();
    final ext = studentById(sid)['riskExternal'] as int?; // מקום-שמור (מודול-תלמידים)
    return ext == null ? internal : (ext > internal ? ext : internal);
  }
  static String riskWhy(String sid) {
    final p = riskParts(sid);
    final top = p.entries.reduce((a, b) => a.value >= b.value ? a : b);
    const why = {'rate': 'חיסורים לא-מוצדקים', 'streak': 'רצף-חיסורים', 'trend': 'מגמה עולה', 'pattern': 'דפוס-קבוע'};
    return top.value == 0 ? 'אין-אות' : why[top.key]!;
  }
  static int riskBand(String sid) => risk(sid) >= _Placement.riskRed ? 2 : risk(sid) >= _Placement.riskOrange ? 1 : 0;
  static String riskAction(String sid) => riskBand(sid) == 2 ? 'ועדת-שילוב + ביקור-בית' : riskBand(sid) == 1 ? 'שיחת-מחנך + יידוע-הורים' : 'מעקב';

  // ─── סיבות-מובנות: absenceReasonChips (מדף) ⊕ מונחי-דאטה + סיבות-מוסד (חולה/משפחתי/טיול/אבל/אחר) ───
  static List<String> get reasons => [...absenceReasonChips(term: (k) => reason_t.kTerms[k] ?? k), 'חולה', 'טיול', 'אבל', 'רפואי', 'אחר'];

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 16 עמודות-המפרט + 5 שקעים כחוזה-דאטה ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key)=מוארת רק כשתלמיד/סימון נושא ערך, חסר ⇒ שקט. הזרקת photo/medicalDoc/
  //   online/transportLate/cardIn/gpsIn לדאטה ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static List<Map<String, Object?>> columnDefs(String date) => <Map<String, Object?>>[
        {'key': 'photo', 'label': 'תמונה'}, // מקום-שמור
        {'label': 'שם', 'get': (Map<String, dynamic> s) => '${s['name']}'},
        {'label': 'כיתה', 'get': (Map<String, dynamic> s) => className(s['cls'] as String)},
        {'label': 'מס׳', 'get': (Map<String, dynamic> s) => '${s['num']}'},
        {'label': 'סטטוס-היום', 'get': (Map<String, dynamic> s) => statusLabel[dayStatus(date, s['id'] as String)]!},
        {'label': 'שעת-הגעה', 'get': (Map<String, dynamic> s) => arrivalOf(date, s['id'] as String) ?? '—'},
        {'label': 'דקות-איחור', 'get': (Map<String, dynamic> s) => '${lateMinutesOn(date, s['id'] as String)}'},
        {'label': 'סיבה', 'get': (Map<String, dynamic> s) => '${firstMarkOn(date, s['id'] as String)?['reason'] ?? '—'}'},
        {'label': 'מוצדק?', 'get': (Map<String, dynamic> s) => firstMarkOn(date, s['id'] as String) == null ? '—' : firstMarkOn(date, s['id'] as String)!['justified'] == true ? 'כן' : 'לא'},
        {'label': 'אישור-הורה', 'get': (Map<String, dynamic> s) => firstMarkOn(date, s['id'] as String) == null ? '—' : firstMarkOn(date, s['id'] as String)!['parentOk'] == true ? '✓' : '✗'},
        {'label': 'חיסורים-החודש', 'get': (Map<String, dynamic> s) => '${absencesThisMonth(s['id'] as String)}'},
        {'label': 'רצף-חיסורים', 'get': (Map<String, dynamic> s) => '${streak(s['id'] as String)}'},
        {'label': 'נוכחות%', 'get': (Map<String, dynamic> s) => '${(attendancePct(s) * 100).round()}'},
        {'label': 'מגמה', 'get': (Map<String, dynamic> s) => trendLabel(s['id'] as String)},
        {'label': 'ציון-סיכון', 'get': (Map<String, dynamic> s) => '${risk(s['id'] as String)}'},
        {'label': 'השלמה-מתוזמנת', 'get': (Map<String, dynamic> s) => scheduledMakeup(s['id'] as String) ?? (pendingMakeupsOf(s['id'] as String).isEmpty ? '—' : 'ממתין')},
        {'key': 'medicalDoc', 'label': 'אישור-רפואי'}, // מקום-שמור (קובץ)
        {'key': 'online', 'label': 'מקוון'}, // מקום-שמור (היברידי)
        {'key': 'transportLate', 'label': 'איחור-הסעה'}, // מקום-שמור
        {'key': 'cardIn', 'label': 'כרטיס/ביומטרי'}, // מקום-שמור
        {'key': 'gpsIn', 'label': 'GPS-הגעה'}, // מקום-שמור
      ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((s) => s[c['key']] != null && '${s[c['key']]}'.trim().isNotEmpty);
  static const statusLabel = {'present': '✅ נוכח', 'absent': '⛔ חסר', 'late': '⏰ איחור', 'released': '🚪 שחרור'};
  static const statusTone = {'present': 1, 'absent': 2, 'late': 3, 'released': 0};
  // חוזה-עובדות-הפאנל (מקום-שמור כמו metaFields): שדה מוצג רק כשקיים ערך
  static const metaFields = <Map<String, String>>[
    {'key': 'phone', 'prefix': '📞 ', 'suffix': ''},
    {'key': 'name', 'prefix': '👪 ', 'suffix': ''},
    {'key': 'email', 'prefix': '✉️ ', 'suffix': ''}, // מקום-שמור
    {'key': 'lang', 'prefix': '🗣 ', 'suffix': ''}, // מקום-שמור (שפת-הודעה)
  ];

  // ═══ הרשאות-פר-תפקיד (חוק-6 · הכרעה 23-ג) = roleOf ⊕ canGrantedAction — 6 תפקידים ═══
  static int role = 0; // אינדקס-תפקיד נבחר (בורר מדגים גידור)
  static String recorder = 't1'; // זהות-הרושם (אודיט "מי-רשם") — נגזרת מהתפקיד הנבחר
  static Map<String, dynamic> get roleDef => _Placement.roleDefs[role];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(String key) => canGrantedAction((roleDef['config'] as Map).cast<String, dynamic>(), roleDef['email'] as String, false, key, _isAdmin);
  static String get roleName => roleOf((roleDef['config'] as Map).cast<String, dynamic>(), roleDef['email'] as String);
  static void setRole(int i) {
    role = i;
    recorder = roleDef['id'] as String;
  }
  // כיתות-בהיקף: מורה=כיתותיו · מחליף=כיתה-מוקצית · הורה=כיתת-ילדו · רכז/הנהלה/צפייה=הכל
  static List<Map<String, dynamic>> get visibleClasses {
    final child = roleDef['child'] as String?;
    if (child != null) return classes.where((c) => c['id'] == studentById(child)['cls']).toList();
    final cs = roleDef['classes'] as List?;
    return cs == null ? classes : classes.where((c) => cs.contains(c['id'])).toList();
  }
  // תלמידים-בהיקף: הורה רואה רק את ילדו
  static bool inWindow(String date) => dayDiff(date, _Placement.today).abs() <= (roleDef['window'] as int? ?? 0);
  static bool canMarkOn(String date) => can('att.mark') && inWindow(date) && !isLocked(date);
  static String? whyCannot(String date) => !can('att.mark') ? 'אין הרשאת-רישום לתפקיד $roleName' : isLocked(date) ? 'יום-נעול — רק רכז/ת פותח/ת' : !inWindow(date) ? 'מחוץ לחלון-העריכה (היום±${roleDef['window']}) — אין עריכה-לאחור' : null;

  // ═══ נעילת-יום (מצב-מיוחד): ידנית (רכז/הנהלה) · אוטומטית סוף-יום (nowHm ≥ lockHm) ═══
  static final Set<String> _locked = {};
  static final Set<String> _unlocked = {}; // פתיחה-מפורשת של רכז גוברת על נעילה-אוטו
  static bool autoLocked(String date) => date.compareTo(_Placement.today) < 0 || (date == _Placement.today && (timeToMin(_Placement.nowHm) as num) >= (timeToMin(_Placement.lockHm) as num));
  static bool isLocked(String date) => !_unlocked.contains(date) && (_locked.contains(date) || (autoLocked(date) && date != _Placement.today && !can('att.back')));
  // ═══ איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — לא .contains שטוח ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> s) => ['${s['name']}', '${s['num']}', className(s['cls'] as String), '${_Placement.parents[s['id']]?['name'] ?? ''}'];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches — 10 צירי-נעילה (המפרט: סטטוס·מוצדק·בסיכון·רצף·אישור·השלמה·הגעה) ═══
  static const filterDefs = <Map<String, String>>[
    {'axis': '', 'label': 'הכל'},
    {'axis': 'absent', 'label': '⛔ חסרים'},
    {'axis': 'late', 'label': '⏰ מאחרים'},
    {'axis': 'released', 'label': '🚪 שוחררו'},
    {'axis': 'unjust', 'label': '❔ לא-מוצדק'},
    {'axis': 'just', 'label': '✔ מוצדק'},
    {'axis': 'risk', 'label': '🚨 בסיכון'},
    {'axis': 'streak', 'label': '🔗 רצף≥${_Placement.streakAlert}'},
    {'axis': 'noParent', 'label': '👪 ללא-אישור'},
    {'axis': 'makeup', 'label': '🔁 השלמה-ממתינה'},
    {'axis': 'lateArr', 'label': '🕒 הגעה>${_Placement.lateWindowMin}׳'},
  ];
  static String _axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final s = f as Map<String, dynamic>;
    final sid = s['id'] as String, date = db['date'] as String;
    final ms = marksOn(date, sid);
    switch (axis) {
      case 'absent': case 'late': case 'released': return dayStatus(date, sid) == axis ? '1' : '0';
      case 'unjust': return ms.any(unjustified) ? '1' : '0';
      case 'just': return ms.any((m) => m['status'] == 'absent' && m['justified'] == true) ? '1' : '0';
      case 'risk': return riskBand(sid) > 0 ? '1' : '0';
      case 'streak': return streak(sid) >= _Placement.streakAlert ? '1' : '0';
      case 'noParent': return ms.any((m) => unjustified(m) && m['parentOk'] != true) ? '1' : '0';
      case 'makeup': return pendingMakeupsOf(sid).isNotEmpty ? '1' : '0';
      case 'lateArr': return ms.any(isLate) ? '1' : '0';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> items, String date, int chip) {
    final axis = filterDefs[chip]['axis']!;
    final locks = axis.isEmpty ? <dynamic, dynamic>{} : <dynamic, dynamic>{axis: '1'};
    return finderMatches({'families': items, 'date': date}, locks, _axisValue).cast<Map<String, dynamic>>();
  }

  // ═══ ייצוא (23-ג) = toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport — שורות מהחוזה-עמודות ═══
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> rows, String date) {
    final cols = [for (final c in columnDefs(date)) if (colShown(c, rows)) c];
    return [
      [for (final c in cols) c['label']],
      for (final s in rows) [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(s) : '${s[c['key']] ?? ''}'],
    ];
  }
  static String csvOf(List<Map<String, dynamic>> rows, String date) => toCsv(csvRows(rows, date), csvEscape) as String;
  // ═══ תקשורת-הורים: תור-הודעות אוטו (חיסור לא-מוצדק ללא-אישור ⇒ הודעה) + שליחות ידניות; שקע-שליחה = מקום-שמור ═══
  static final Set<String> sent = {}; // מפתחות-סימון שנשלחה עליהם הודעה (חלון-תגובה נפתח)
  static final List<Map<String, dynamic>> manualQueue = []; // הודעות-כיתה/ידניות
  static List<Map<String, dynamic>> get notificationQueue => [
        for (final m in marks)
          if (unjustified(m) && m['parentOk'] != true && _Placement.parents[m['sid']] != null)
            {'key': keyOf(m['date'] as String, m['lesson'] as int, m['sid'] as String), 'sid': m['sid'], 'date': m['date'], 'lesson': m['lesson'], 'to': _Placement.parents[m['sid']]!['name'], 'phone': _Placement.parents[m['sid']]!['phone'], 'text': 'חיסור לא-מוצדק בשיעור ${m['lesson']} ב-${fmtDate(m['date'] as String)} — נא לאשר/לנמק', 'auto': true},
        ...manualQueue,
      ];
  static void send(String key) { sent.add(key); _log('notify', key); }
  static List<Map<String, dynamic>> marksInRange(String from, String to, {String? cls}) =>
      (marks.where((m) => dateInRange(m['date'] as String, from, to) && (cls == null || studentById(m['sid'] as String)['cls'] == cls)).toList()
        ..sort((a, b) => '${b['date']}${b['lesson']}'.compareTo('${a['date']}${a['lesson']}')));

  static List<Map<String, dynamic>> get groupAbsences => [
        for (final d in lastSchoolDays(30))
          for (final c in classes)
            if (() {
              final r = studentsOf(c['id'] as String);
              final n = r.where((s) => absentDay(d, s['id'] as String)).length;
              return r.isNotEmpty && n >= _Placement.groupAbsenceMin && n * 2 >= r.length;
            }())
              {'date': d, 'cls': c['id'], 'absent': studentsOf(c['id'] as String).where((s) => absentDay(d, s['id'] as String)).length, 'total': studentsOf(c['id'] as String).length},
      ];
  // 10) סנכרון-לוח מקדים: חגים-קרובים (upcomingHolidays מהמדף על holidayOf) ⇒ ימים שלא ייספרו
  static List<Map<String, dynamic>> get upcoming => upcomingHolidays(_Placement.today, (d) => holidayName(iso(d)), iso, 30);
  // 8) נעילה-אוטומטית: autoLocked (nowHm ≥ lockHm) — מוצג כמצב

  // ═══ שקעי-הצבה · מקום-שמור (חוק-7 · מבחן-הקונכייה): כל יכולת חסרת-נתון = שקע מוצהר, מאיר כשמחובר ═══
  static const reservedSockets = <Map<String, String>>[
    {'key': 'photo', 'label': 'תמונת-תלמיד', 'where': 'students[].photo ⇒ עמודה "תמונה"'},
    {'key': 'medicalDoc', 'label': 'אישור-רפואי (קובץ)', 'where': 'mark.medicalDoc ⇒ עמודה + כפתור "צרף-אישור"'},
    {'key': 'online', 'label': 'נוכחות-מקוונת (היברידי)', 'where': 'mark.online ⇒ עמודה "מקוון"'},
    {'key': 'transportLate', 'label': 'הסעה-איחור', 'where': 'mark.transportLate ⇒ עמודה "איחור-הסעה"'},
    {'key': 'cardIn', 'label': 'ביומטרי/כרטיס-כניסה', 'where': 'mark.cardIn ⇒ עמודה + arrival אוטומטי'},
    {'key': 'gpsIn', 'label': 'GPS-הגעה', 'where': 'mark.gpsIn (מקור: AttendanceDay.inLat/inLng)'},
    {'key': 'riskExternal', 'label': 'ציון-סיכון חיצוני (מודול-תלמידים)', 'where': 'students[].riskExternal ⇒ max(פנימי,חיצוני)'},
    {'key': 'noticeHrs', 'label': 'שעות-הודעה-מראש (ביטול-מוקדם)', 'where': 'mark.noticeHrs ⇒ makeupEligibility rawHrs'},
    {'key': 'notifySink', 'label': 'שקע-שליחה SMS/וואטסאפ (מודול-הורים)', 'where': 'send(key) ⇒ תור בלבד עד חיבור'},
    {'key': 'auditSink', 'label': 'אחסון-אודיט (pushAuditRing/pullAuditRing)', 'where': 'audit[] בזיכרון עד חיבור fs'},
    {'key': 'pdfPrint', 'label': 'PDF/הדפסה', 'where': 'CSV זמין; PDF/מדפסת = שקע'},
    {'key': 'substituteTeacher', 'label': 'מורה-מחליף מוקצה (מודול-מורים)', 'where': 'roleDefs[מחליף].classes מוזרק בהצבה'},
    {'key': 'dashboardCounters', 'label': 'מוני-לוח-הנהלה', 'where': 'KPI getters — המנהל מחווט למסך-הבית'},
    {'key': 'loader', 'label': 'חיבור-אסינק (fetch/Firestore)', 'where': 'AttendanceScreen(loader:) ⇒ טעינה/שגיאה אמיתיות; null ⇒ הדגמה'},
  ];

  static List<Map<String, dynamic>> lessonsStarted(String date) {
    final now = timeToMin(_Placement.nowHm);
    if (date != _Placement.today) return lessonsOf(date);
    return lessonsOf(date).where((l) => (timeToMin(l['time']) as num) <= (now as num)).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// 🧮 _FeesData — לוגיקה-טהורה + חוזה-דאטה (אפס-DOM). מקורות-אמת (§20-ג · אפס-זיוף):
//   משפחה   → maor Family (name·father·mother·phone·email·discount·status·members) · Member (first·grade·idNum)
//   חיוב    → maor PlannedCharge (id·date·amount·cur·method·cat·installmentOf·cancelledAt·note) + Enrollment.memberId/dueDate
//   תשלום   → maor Payment (rid·date·amount·method) · Enrollment.totalDue/carryBalance/paidFull ⇒ payBal/payCredit
//   הו״ק    → maor Hok (amount·cur·day·method·active·startedAt·kevaId) + Supporter.hist (d·a·c·clearer) ⇒ hokEffectivelyActive
//   תזכורת  → Supporter.calls (CallEntry: at·outcome) + Supporter.nextDate/nextNote
//   הנחה    → קריטריוני-הנחה {id·discountPct} (max-discount-pct.contract) · Family.discount
//   ⛔ ללא-מקור-אמת ⇒ מקום-שמור, לא זיוף: receiptNo · clearingRef · invoiceNo · payUrl (שער-חיצוני)
// ═══════════════════════════════════════════════════════════════════════════════════════
class _FeesData {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (אין Date.now במנוע)
  static const year = '2026';
  static const orgName = 'תיכון עתיד';
  static const oldDebtDays = 90; // סף חוב-ותיק (המפרט: >90 יום)
  static const gentleDays = 14; // סף תזכורת-ראשונה (עדינה)

  // ─── מדיניות-הנחה (מנוע max-discount-pct: הגבוה-מנצח, לא מצטבר · צורת-הקלט {id,discountPct}) ───
  static const criteria = <Map<String, dynamic>>[
    {'id': 'sib2', 'discountPct': 10, 'label': 'אח/ות שני/ה'},
    {'id': 'sib3', 'discountPct': 20, 'label': 'שלושה אחים+'},
    {'id': 'socio', 'discountPct': 50, 'label': 'סוציו-אקונומי'},
    {'id': 'full', 'discountPct': 100, 'label': 'מלגה מלאה'},
  ];
  static const chargeTypes = ['שכר-לימוד', 'חוג', 'טיול', 'ציוד'];
  static const arrangementType = 'הסדר'; // תשלומי-פריסה — נגזרים מיתרה-נטו ⇒ לא-ברי-הנחה (discountableTypes לא כולל)
  static const discountableTypes = {'שכר-לימוד'}; // ההנחה חלה על שכ״ל בלבד (מדיניות)
  static const payMethodsSchool = ['הו״ק', 'אשראי', 'מזומן', 'העברה']; // המפרט: אמצעי (הו״ק/אשראי/מזומן/העברה)

  // ─── דאטה-בסיס (const · מקור-האמת) — 8 משפחות ריאליסטיות, רק שדות-עם-מקור ───
  static const families = <Map<String, dynamic>>[
    {
      'id': 'f1', 'name': 'משפחת כהן', 'payer': 'דוד כהן', 'phone': '050-1111111', 'email': 'cohen@family', 'idNum': '012345678',
      'members': [{'first': 'נועה', 'grade': 'י\'-3'}, {'first': 'איתי', 'grade': 'ח\'-1'}],
      'charges': [
        {'id': 'c1', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'נועה'},
        {'id': 'c2', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'איתי'},
        {'id': 'c3', 'date': '2026-09-01', 'amount': 350, 'cur': '₪', 'cat': 'טיול', 'method': '', 'memberId': 'נועה', 'note': 'טיול שנתי י\''},
      ],
      'payments': [
        {'rid': 'p1', 'date': '2026-08-05', 'amount': 700, 'method': 'הו״ק'},
        {'rid': 'p2', 'date': '2026-09-03', 'amount': 700, 'method': 'הו״ק'},
      ],
      'hok': {'amount': 700, 'cur': '₪', 'day': 5, 'method': 'bank', 'active': true, 'startedAt': '2025-09-05'},
      'criteria': ['sib2'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f2', 'name': 'משפחת לוי', 'payer': 'רחל לוי', 'phone': '052-2222222', 'email': 'levi@family', 'idNum': '023456789',
      'members': [{'first': 'יונתן', 'grade': 'ט\'-2'}],
      'charges': [
        {'id': 'c4', 'date': '2026-05-10', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'יונתן'},
        {'id': 'c5', 'date': '2026-06-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'יונתן', 'note': 'רובוטיקה'},
      ],
      'payments': [
        {'rid': 'p3', 'date': '2026-05-20', 'amount': 1000, 'method': 'אשראי'},
      ],
      'hok': {'amount': 350, 'cur': '₪', 'day': 10, 'method': 'card', 'active': true, 'startedAt': '2026-01-10', 'kevaId': 'kv-77'},
      'hist': [
        {'d': '2026-04-10', 'a': 350, 'c': '₪', 'clearer': 'נדרים', 'kevaId': 'kv-77'},
        {'d': '2026-05-10', 'a': 350, 'c': '₪', 'clearer': 'נדרים', 'kevaId': 'kv-77'},
      ],
      'criteria': <String>[],
      'calls': [
        {'at': '2026-07-01', 'outcome': 'reminder', 'grade': 'עדינה'},
        {'at': '2026-08-01', 'outcome': 'reminder', 'grade': 'רגילה'},
        {'at': '2026-08-25', 'outcome': 'reminder', 'grade': 'הנהלה'},
      ],
      'nextDate': '2026-09-02', 'nextNote': 'שיחת-הסדר עם רחל',
      'carryBalance': 600,
    },
    {
      'id': 'f3', 'name': 'משפחת מזרחי', 'payer': 'יוסי מזרחי', 'phone': '054-3333333', 'email': 'mizrahi@family', 'idNum': '034567890',
      'members': [{'first': 'שירה', 'grade': 'יא\'-1'}, {'first': 'עומר', 'grade': 'ט\'-1'}, {'first': 'טל', 'grade': 'ז\'-2'}],
      'charges': [
        {'id': 'c6', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'שירה'},
        {'id': 'c7', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'עומר'},
        {'id': 'c8', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'טל'},
        {'id': 'c9', 'date': '2026-09-01', 'amount': 220, 'cur': '₪', 'cat': 'ציוד', 'method': '', 'memberId': 'טל', 'note': 'ערכת מעבדה'},
      ],
      'payments': [
        {'rid': 'p4', 'date': '2026-08-22', 'amount': 3000, 'method': 'העברה'},
      ],
      'criteria': ['sib3'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f4', 'name': 'משפחת אברהם', 'payer': 'מרים אברהם', 'phone': '053-4444444', 'email': 'avraham@family', 'idNum': '045678901',
      'members': [{'first': 'אליה', 'grade': 'י\'-1'}],
      'charges': [
        {'id': 'c10', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'אליה'},
      ],
      'payments': <Map<String, dynamic>>[],
      'criteria': ['full'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f5', 'name': 'משפחת פרץ', 'payer': 'אבי פרץ', 'phone': '058-5555555', 'email': 'peretz@family', 'idNum': '056789012',
      'members': [{'first': 'ליאור', 'grade': 'ח\'-2'}],
      'charges': [
        {'id': 'c12', 'date': '2026-08-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/1'},
        {'id': 'c13', 'date': '2026-09-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/2'},
        {'id': 'c14', 'date': '2026-10-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/3'},
        {'id': 'c15', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'ליאור', 'cancelledAt': '2026-08-21', 'note': 'הוחלף בהסדר-פריסה'},
      ],
      'payments': <Map<String, dynamic>>[],
      'criteria': <String>[],
      'calls': [
        {'at': '2026-09-03', 'outcome': 'reminder', 'grade': 'עדינה'},
      ],
      'carryBalance': 0,
    },
    {
      'id': 'f6', 'name': 'משפחת שמעוני', 'payer': 'גלית שמעוני', 'phone': '050-6666666', 'email': 'shimoni@family', 'idNum': '067890123',
      'members': [{'first': 'רון', 'grade': 'י\'-1'}],
      'charges': [
        {'id': 'c16', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'רון'},
        {'id': 'c17', 'date': '2026-09-01', 'amount': 350, 'cur': '₪', 'cat': 'טיול', 'method': '', 'memberId': 'רון', 'note': 'טיול שנתי י\''},
      ],
      'payments': [
        {'rid': 'p5', 'date': '2026-08-21', 'amount': 4200, 'method': 'אשראי'},
        {'rid': 'p6', 'date': '2026-09-02', 'amount': 350, 'method': 'אשראי'},
      ],
      'criteria': <String>[],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f7', 'name': 'משפחת ביטון', 'payer': 'שלומי ביטון', 'phone': '052-7777777', 'email': 'biton@family', 'idNum': '078901234',
      'members': [{'first': 'מאיה', 'grade': 'י\'-2'}, {'first': 'עידו', 'grade': 'ז\'-1'}],
      'charges': [
        {'id': 'c18', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'מאיה'},
        {'id': 'c19', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'עידו'},
        {'id': 'c20', 'date': '2026-09-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'עידו', 'note': 'כדורסל'},
        {'id': 'c21', 'date': '2026-09-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'עידו', 'note': 'כדורסל'},
      ],
      'payments': [
        {'rid': 'p7', 'date': '2026-08-25', 'amount': 5000, 'method': 'העברה'},
      ],
      'hok': {'amount': 600, 'cur': '₪', 'day': 15, 'method': 'bank', 'active': true, 'startedAt': '2026-09-01'},
      'criteria': ['sib2', 'socio'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f8', 'name': 'משפחת נחום', 'payer': 'הדס נחום', 'phone': '054-8888888', 'email': 'nahum@family', 'idNum': '089012345',
      'members': [{'first': 'הדר', 'grade': 'ח\'-2'}],
      'charges': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'criteria': <String>[],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
  ];

  // ─── פנקס-פעולות (state · חוק-1: מצב=חיווט): הבסיס const, הפעולות רושמות תוספות/דגלים + אודיט ───
  static final Map<String, List<Map<String, dynamic>>> extraCharges = {};
  static final Map<String, List<Map<String, dynamic>>> extraPayments = {};
  static final Map<String, List<Map<String, dynamic>>> extraCalls = {};
  static final Set<String> cancelledIds = {}; // ביטול-חיוב (סיבה ב-audit)
  static final Map<String, String> cancelReason = {};
  static final Map<String, List<String>> extraCriteria = {}; // הענקת-הנחה/מלגה
  static final Map<String, bool> hokOverride = {}; // הפעל/הפסק-הו״ק
  static final Set<String> writtenOff = {}; // סומן-כחוב-אבוד (הנהלה)
  static final List<Map<String, dynamic>> audit = []; // יומן-אודיט (מי·מה·מתי — role מוזרק)
  static int _seq = 100;
  static String _nid(String p) => '$p${_seq++}';

  // איפוס-פנקס (רתמת-בדיקה · דטרמיניזם): מחזיר את המצב לבסיס-ה-const — אפס-תלות בסדר-הבדיקות
  static void reset() {
    extraCharges.clear(); extraPayments.clear(); extraCalls.clear(); cancelledIds.clear(); cancelReason.clear();
    extraCriteria.clear(); hokOverride.clear(); writtenOff.clear(); audit.clear(); _seq = 100;
  }
  static void _log(String role, String fid, String what) =>
      audit.insert(0, {'date': today, 'role': role, 'family': fid, 'what': what});

  // ─── גישה מאוחדת: בסיס + תוספות ───
  static List<Map<String, dynamic>> chargesOf(Map<String, dynamic> f) =>
      [...(f['charges'] as List).cast<Map<String, dynamic>>(), ...(extraCharges[f['id']] ?? const [])];
  static List<Map<String, dynamic>> liveCharges(Map<String, dynamic> f) =>
      chargesOf(f).where((c) => c['cancelledAt'] == null && !cancelledIds.contains(c['id'])).toList();
  static List<Map<String, dynamic>> paymentsOf(Map<String, dynamic> f) =>
      [...(f['payments'] as List).cast<Map<String, dynamic>>(), ...(extraPayments[f['id']] ?? const [])];
  static List<Map<String, dynamic>> callsOf(Map<String, dynamic> f) =>
      [...(f['calls'] as List).cast<Map<String, dynamic>>(), ...(extraCalls[f['id']] ?? const [])];
  static List<String> criteriaOf(Map<String, dynamic> f) =>
      [...(f['criteria'] as List).cast<String>(), ...(extraCriteria[f['id']] ?? const [])];
  static int studentsN(Map<String, dynamic> f) => (f['members'] as List).length;
  static String gradesOf(Map<String, dynamic> f) => (f['members'] as List).map((m) => (m as Map)['grade']).join(' · ');
  static String studentsOf(Map<String, dynamic> f) => (f['members'] as List).map((m) => (m as Map)['first']).join(', ');

  // ─── הנחה (הכרעה 23-ג): הנחת-אחים-אוטו (נגזרת ממספר-התלמידים) ⊕ קריטריונים-ידניים ⇒ maxDiscountPct ───
  static List<String> effectiveCriteria(Map<String, dynamic> f) {
    final n = studentsN(f);
    return {if (n >= 3) 'sib3' else if (n == 2) 'sib2', ...criteriaOf(f)}.toList();
  }
  static num discountPct(Map<String, dynamic> f) => maxDiscountPct(effectiveCriteria(f), criteria);
  static bool fullScholarship(Map<String, dynamic> f) => discountPct(f) >= 100;
  static String discountLabel(Map<String, dynamic> f) {
    final ids = effectiveCriteria(f);
    final best = criteria.where((c) => ids.contains(c['id'])).fold<Map<String, dynamic>?>(null, (b, c) => b == null || (c['discountPct'] as num) > (b['discountPct'] as num) ? c : b);
    return best == null ? '' : '${best['label']} ${best['discountPct']}%';
  }
  // סכום-חיוב-נטו: שכ״ל אחרי-הנחה (effectivePrice⊕maxDiscountPct), שאר-הסוגים מלא
  static int netOf(Map<String, dynamic> f, Map<String, dynamic> c) => discountableTypes.contains(c['cat'])
      ? effectivePrice(c['amount'] as num, effectiveCriteria(f), criteria, maxDiscountPct)
      : (c['amount'] as num).toInt();
  static int grossOf(Map<String, dynamic> f, Map<String, dynamic> c) => (c['amount'] as num).toInt();

  // ─── הערכת-מצב (פעולת-יסוד): חיוב · שולם · יתרה (payBal) · זכות (payCredit) · סטטוס ───
  static int charged(Map<String, dynamic> f) => grandTotal(liveCharges(f), (c) => netOf(f, c as Map<String, dynamic>)).toInt();
  static int grossCharged(Map<String, dynamic> f) => grandTotal(liveCharges(f), (c) => grossOf(f, c as Map<String, dynamic>)).toInt();
  static int scholarshipOf(Map<String, dynamic> f) => grossCharged(f) - charged(f);
  static int paid(Map<String, dynamic> f) => grandTotal(paymentsOf(f), (p) => (p as Map)['amount'] as num).toInt();
  static num _paidOf(Map e) => paid(e['__f'] as Map<String, dynamic>);
  // שיבוץ-בצורת-Enrollment (totalDue·carryBalance) — הקלט האמיתי של payBal/payCredit/enrollmentPaidStatus
  static Map<String, dynamic> enrollmentOf(Map<String, dynamic> f) =>
      {'totalDue': charged(f), 'carryBalance': f['carryBalance'] ?? 0, '__f': f};
  static int balance(Map<String, dynamic> f) => writtenOff.contains(f['id']) ? 0 : payBal(enrollmentOf(f), _paidOf).toInt();
  static int credit(Map<String, dynamic> f) => payCredit(enrollmentOf(f), (e) => _paidOf(e)).toInt();
  static String paidStatus(Map<String, dynamic> f) =>
      enrollmentPaidStatus(enrollmentOf(f), (e) => payBal(e, _paidOf), (e) => _paidOf(e));

  // ותק-החוב: החיוב הפתוח הוותיק-ביותר (הקצאת-FIFO: תשלומים מכסים חיובים לפי-תאריך) ⇒ dayDiff מול today
  static String? oldestOpenDate(Map<String, dynamic> f) {
    if (balance(f) <= 0) return null;
    final cs = [...liveCharges(f)]..sort((a, b) => '${a['date']}'.compareTo('${b['date']}'));
    var cover = paid(f) - ((f['carryBalance'] as num?) ?? 0);
    for (final c in cs) {
      cover -= netOf(f, c);
      if (cover < 0) return c['date'] as String;
    }
    return cs.isEmpty ? null : cs.last['date'] as String;
  }
  static int agingDays(Map<String, dynamic> f) {
    final d = oldestOpenDate(f);
    if (d == null) return 0;
    final n = dayDiff(d, today);
    return n.isFinite ? n.toInt().clamp(0, 1 << 20) : 0;
  }
  static bool oldDebt(Map<String, dynamic> f) => balance(f) > 0 && agingDays(f) > oldDebtDays;
  static int agingBand(Map<String, dynamic> f) { // 0=אין-חוב · 1=טרי(≤14) · 2=בפיגור(≤90) · 3=ותיק(>90)
    if (balance(f) <= 0) return 0;
    final d = agingDays(f);
    return d > oldDebtDays ? 3 : d > gentleDays ? 2 : 1;
  }

  // ─── תשלומים: אחרון · אמצעי · חודש ───
  static String lastPaymentDate(Map<String, dynamic> f) => supLast({'last': '', 'hist': [for (final p in paymentsOf(f)) {'d': p['date']}]}) as String;
  static String lastMethod(Map<String, dynamic> f) {
    final ps = paymentsOf(f);
    if (ps.isEmpty) return '';
    final s = [...ps]..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return s.first['method'] as String;
  }
  static int paidInMonth(Map<String, dynamic> f, String ym) =>
      grandTotal(paymentsOf(f).where((p) => monthKey(p['date'] as String) == ym).toList(), (p) => (p as Map)['amount'] as num).toInt();

  // ─── הו״ק (מנועי-מדף): sp בצורת-Supporter (hok·donations·hist) ───
  static Map<String, Object?> spOf(Map<String, dynamic> f) {
    final h = f['hok'] as Map?;
    final active = hokOverride[f['id']] ?? (h?['active'] == true);
    return {
      'id': f['id'], 'name': f['name'], 'phone': f['phone'], 'email': f['email'],
      'hok': h == null ? null : {...h, 'active': active},
      'donations': [for (final p in paymentsOf(f)) {'date': p['date'], 'amount': p['amount'], 'cur': '₪', 'cat': p['method'] == 'הו״ק' ? hokCat : 'תשלום'}],
      'hist': (f['hist'] as List?) ?? const [],
    };
  }
  static bool hasHok(Map<String, dynamic> f) => f['hok'] != null;
  static bool hokFlag(Map<String, dynamic> f) => hasHok(f) && (hokOverride[f['id']] ?? ((f['hok'] as Map)['active'] == true));
  static bool hokActive(Map<String, dynamic> f) => hokEffectivelyActive(spOf(f), today, skHokActive.hokEffectivelyActive_T);
  static bool hokFailed(Map<String, dynamic> f) => hokFlag(f) && !hokActive(f); // מסומנת-פעילה אך הסליקה פסקה (>2 חודשים)
  static bool hokRecorded(Map<String, dynamic> f) => hokRecordedThisMonth(spOf(f), today, hokCat, skHokRec.hokRecordedThisMonth_T);
  static String hokMethod(Map<String, dynamic> f) => hasHok(f) ? hokMethodLabel('${(f['hok'] as Map)['method'] ?? ''}', term: (k) => tdHokMethod.kTerms[k] ?? k) : '';
  static bool _active(Map<String, Object?> sp, String t) => hokEffectivelyActive(sp, t, skHokActive.hokEffectivelyActive_T);
  static bool _recorded(Map<String, Object?> sp, String t) => hokRecordedThisMonth(sp, t, hokCat, skHokRec.hokRecordedThisMonth_T);
  // רשימת-הו״ק-לרישום-החודש (ממוינת לפי יום-חיוב) — הבסיס לרישום-מרוכז דו-שלבי
  static List<Map<String, dynamic>> hokDueList(List<Map<String, dynamic>> fs) {
    final sps = [for (final f in fs) spOf(f)];
    final due = hokDue(sps, today, _active, _recorded);
    return [for (final sp in due) fs.firstWhere((f) => f['id'] == sp['id'])];
  }
  // צפוי-מהו״ק-החודש = hokDue (טרם-נרשמו) ⊕ hokMonthlyTotal (Σ סכומי-ההו״ק-הפעילות) — הרכבת שני מנועים
  static int hokExpected(List<Map<String, dynamic>> fs) =>
      hokMonthlyTotal([for (final f in hokDueList(fs)) spOf(f)], 1, today, (sp, t) => _active((sp as Map).cast<String, Object?>(), t as String));

  // ─── סיכון-גבייה (23-ד · חיבור-מודלים בהחלטה): ותק ⊕ דפוס-תשלום-RFM (supScore⊕tierOf) ⊕ מגמה (trendFromScan) ───
  static Map<String, dynamic> _rfmSp(Map<String, dynamic> f) =>
      {'ils': paid(f), 'usd': 0, 'count': paymentsOf(f).where((p) => (p['amount'] as num) > 0).length, 'last': lastPaymentDate(f), 'hist': const []};
  static int rfm(Map<String, dynamic> f) => supScore(_rfmSp(f),
      rate: 1, nowMs: DateTime.parse('${today}T12:00:00').millisecondsSinceEpoch,
      supTotalIls: (sp, r) => supTotalIls(sp, rate: r, supIls: supIls, supUsd: supUsd),
      supLast: (sp) => supLast(sp as Map), supCount: supCount);
  static String tierKey(Map<String, dynamic> f) => (tierOf(rfm(f), 500, term: (k) => tdTier.kTerms[k] ?? k) as Map)['key'] as String;
  static String tierLabel(Map<String, dynamic> f) => (tierOf(rfm(f), 500, term: (k) => tdTier.kTerms[k] ?? k) as Map)['label'] as String;
  static List<num> monthly(Map<String, dynamic> f, [int months = 6]) { // Σתשלומים פר-חודש, 6 חודשים אחרונים
    final t = DateTime.parse('${today}T12:00:00');
    return [for (var i = months - 1; i >= 0; i--) paidInMonth(f, _ym(DateTime(t.year, t.month - i, 1)))];
  }
  static String _ym(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
  static String ymOf(DateTime d) => _ym(d);
  static Map<String, dynamic> trend(Map<String, dynamic> f) => trendFromScan({'monthly': monthly(f)});
  // 0=נמוך · 1=בינוני · 2=גבוה. חוב-ותיק או דרגת-red ⇒ גבוה; בפיגור/pale/מגמה-יורדת ⇒ בינוני.
  static int risk(Map<String, dynamic> f) {
    if (balance(f) <= 0 || fullScholarship(f) || writtenOff.contains(f['id'])) return 0;
    final band = agingBand(f), tier = tierKey(f), dir = trend(f)['dir'];
    if (band == 3 || tier == 'red' || hokFailed(f)) return 2;
    if (hokFlag(f) && hokActive(f) && hokRecorded(f)) return 0; // הו״ק חיה ונרשמה החודש = משלמים-בקצב ⇒ לא-בסיכון
    if (band == 2 || tier == 'pale' || dir == 'down' || arrangementLate(f)) return 1;
    return 0;
  }
  static String riskLabel(int r) => r == 2 ? 'גבוה' : r == 1 ? 'בינוני' : 'נמוך';

  // ─── הסדר-תשלומים: תשלומי-הסדר (installmentOf) · פיגור = תשלום-הסדר שמועדו עבר ולא-מכוסה ───
  static List<Map<String, dynamic>> installments(Map<String, dynamic> f) => liveCharges(f).where((c) => c['installmentOf'] != null).toList();
  static bool hasArrangement(Map<String, dynamic> f) => installments(f).isNotEmpty;
  static bool arrangementLate(Map<String, dynamic> f) {
    if (!hasArrangement(f) || balance(f) <= 0) return false;
    final od = oldestOpenDate(f);
    return od != null && installments(f).any((c) => c['date'] == od) && dayDiff(od, today) > 0;
  }

  // ─── חיוב-כפול-חשוד (chargeDedupKey על אסמכתא-פנימית: סוג|סכום|תאריך|עבור-מי) ───
  static String _refOf(Map<String, dynamic> c) => '${c['cat']}|${c['amount']}|${c['date']}|${c['memberId']}';
  static List<Map<String, dynamic>> duplicateCharges(Map<String, dynamic> f) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final c in liveCharges(f)) {
      final k = chargeDedupKey({'txnId': '', 'reference': _refOf(c)});
      if (!seen.add(k)) out.add(c);
    }
    return out;
  }

  // ─── תזכורת-מדורגת (segulaReminders: התחלה=חיוב-פתוח-ותיק, דילוגים=דרגות) · מגן-כבוד: פרטית, לא חוסמת ───
  static const gradeOffsets = [14, 45, 90]; // עדינה · רגילה · הנהלה
  static const gradeNames = ['עדינה', 'רגילה', 'הנהלה'];
  static List<Map<String, dynamic>> reminderPlan(Map<String, dynamic> f) {
    final start = oldestOpenDate(f);
    if (start == null) return const [];
    final plan = segulaReminders(start, gradeOffsets) as List;
    return [for (var i = 0; i < plan.length; i++) {'grade': gradeNames[i], 'date': (plan[i] as Map)['date'], 'final': (plan[i] as Map)['final']}];
  }
  static List<Map<String, dynamic>> remindersSent(Map<String, dynamic> f) => callsOf(f).where((c) => c['outcome'] == 'reminder').toList();
  static Map<String, dynamic>? nextReminder(Map<String, dynamic> f) {
    if (balance(f) <= 0 || fullScholarship(f) || (hokFlag(f) && hokActive(f) && hokRecorded(f))) return null;
    final plan = reminderPlan(f), sent = remindersSent(f).length;
    for (var i = sent; i < plan.length; i++) {
      if ('${plan[i]['date']}'.compareTo(today) <= 0) return plan[i];
    }
    return null;
  }
  static String _tpl(dynamic cfg, String key, Map vars) { // שקע-renderTemplate (תבנית-לפי-דרגה מוזרקת ב-cfg)
    var t = ((cfg as Map)['templates'] as Map)[key] as String;
    vars.forEach((k, v) => t = t.split('{$k}').join('$v'));
    return t;
  }
  static const _templates = {
    'עדינה': 'שלום {org}: תזכורת ידידותית — יתרה פתוחה עבור {what} בסך ₪{amount}. אם כבר שולם, נא להתעלם. תודה 🌷',
    'רגילה': 'שלום, מ{org}: יתרה לתשלום עבור {what} — ₪{amount}. נשמח לתיאום הסדר נוח. תודה רבה!',
    'הנהלה': 'שלום, מהנהלת {org}: יתרה פתוחה עבור {what} — ₪{amount}. נבקש ליצור קשר לתיאום. בברכה.',
  };
  static String reminderText(Map<String, dynamic> f, String grade) => waPaymentText(orgName, 'שכר-לימוד ${year}', balance(f),
      {'templates': {'wa.payment': _templates[grade] ?? _templates['רגילה']!}}, _tpl, (o) => '$o') as String;

  // ─── הפעולה-הנכונה (23-ד · הכרעה מאוחדת): מלגה? הסדר? תזכורת? — נגזרת מהסיכון+הותק+הו״ק ───
  static Map<String, dynamic> rightAction(Map<String, dynamic> f) {
    if (writtenOff.contains(f['id'])) return {'glyph': '🗂', 'tone': 0, 'text': 'סומן כחוב-אבוד — מעקב הנהלה בלבד'};
    if (balance(f) <= 0 && liveCharges(f).isEmpty) return {'glyph': '📭', 'tone': 0, 'text': 'אין חיובים — לרשום חיוב-שנה'};
    if (fullScholarship(f)) return {'glyph': '🎓', 'tone': 1, 'text': 'מלגה מלאה — אפס-חוב, אין תזכורות'};
    if (balance(f) <= 0) return {'glyph': '✅', 'tone': 1, 'text': credit(f) > 0 ? 'הכל שולם · זכות ${shekel(credit(f))} להחזר/קיזוז' : 'הכל שולם — תודה'};
    if (hokFailed(f)) return {'glyph': '⚠️', 'tone': 2, 'text': 'הו״ק נכשלה — התרעה + ניסיון-חיוב-חוזר לפני תזכורת'};
    if (arrangementLate(f)) return {'glyph': '📆', 'tone': 3, 'text': 'הסדר בפיגור — שיחה עדינה לעדכון-פריסה'};
    final r = risk(f), nr = nextReminder(f);
    if (r == 2) return {'glyph': '🤝', 'tone': 2, 'text': 'חוב-ותיק/סיכון-גבוה — להציע הסדר או לבחון מלגה (הנהלה)'};
    if (hokFlag(f) && hokActive(f) && hokRecorded(f)) return {'glyph': '💳', 'tone': 1, 'text': 'הו״ק פעילה ונרשמה החודש — היתרה נגבית בהדרגה, אין צורך בתזכורת'};
    if (nr != null) return {'glyph': '🔔', 'tone': 3, 'text': 'תזכורת ${nr['grade']} מועדה הגיע (${fmtDate(nr['date'] as String?)}) — לשלוח בפרטיות'};
    if (hokFlag(f) && hokActive(f)) return {'glyph': '💳', 'tone': 1, 'text': 'הו״ק פעילה — ממתינה לרישום החודש'};
    return {'glyph': '⏳', 'tone': 0, 'text': 'חוב טרי — להמתין למועד התזכורת הראשונה'};
  }

  // ─── סטטוס-משפחה (המפרט: תקין/בפיגור/הסדר/מלגה-מלאה) ───
  static String statusOf(Map<String, dynamic> f) => writtenOff.contains(f['id'])
      ? 'חוב-אבוד'
      : fullScholarship(f)
          ? 'מלגה-מלאה'
          : hasArrangement(f) && balance(f) > 0
              ? (arrangementLate(f) ? 'הסדר-בפיגור' : 'הסדר')
              : balance(f) <= 0
                  ? 'תקין'
                  : agingBand(f) >= 2
                      ? 'בפיגור'
                      : 'תקין';

  // ─── פירוק-לפי-סוג (countBy⊕grandTotal) ───
  static Map<String, int> byType(Map<String, dynamic> f) {
    final m = <String, int>{};
    for (final c in liveCharges(f)) {
      m[c['cat'] as String] = (m[c['cat'] as String] ?? 0) + netOf(f, c);
    }
    return m;
  }

  // ─── ביצוע (פעולות = state + אודיט) ───
  static void addCharge(Map<String, dynamic> f, String role, {required String cat, required int amount, required String date, required String memberId, String note = '', String? installmentOf}) {
    if (amount <= 0) return;
    (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': date, 'amount': amount, 'cur': '₪', 'cat': cat, 'method': '', 'memberId': memberId, 'note': note, if (installmentOf != null) 'installmentOf': installmentOf});
    _log(role, f['id'] as String, 'חיוב $cat ${shekel(amount)} עבור $memberId${note.isEmpty ? '' : ' · $note'}');
  }
  static void addPayment(Map<String, dynamic> f, String role, {required int amount, required String method, required String date, String note = ''}) {
    if (amount <= 0) return;
    (extraPayments[f['id']] ??= []).add({'rid': _nid('p'), 'date': date, 'amount': amount, 'method': method, if (note.isNotEmpty) 'note': note});
    _log(role, f['id'] as String, 'תשלום ${shekel(amount)} ב$method${note.isEmpty ? '' : ' · $note'}');
  }
  static void refund(Map<String, dynamic> f, String role) { // 💸 החזר-זכות: תשלום-שלילי (הפחתת-שולם) בגובה-הזכות
    final c = credit(f);
    if (c <= 0) return;
    (extraPayments[f['id']] ??= []).add({'rid': _nid('r'), 'date': today, 'amount': -c, 'method': 'החזר', 'note': 'החזר-זכות'});
    _log(role, f['id'] as String, 'החזר-זכות ${shekel(c)}');
  }
  static void cancelCharge(Map<String, dynamic> f, String role, Map<String, dynamic> c, String reason) {
    cancelledIds.add(c['id'] as String);
    cancelReason[c['id'] as String] = reason;
    _log(role, f['id'] as String, 'ביטול-חיוב ${c['cat']} ${shekel(c['amount'] as num)} · סיבה: $reason');
  }
  static void grantDiscount(Map<String, dynamic> f, String role, String criterionId) {
    if (criteriaOf(f).contains(criterionId)) return;
    (extraCriteria[f['id']] ??= []).add(criterionId);
    _log(role, f['id'] as String, 'הענקת-הנחה/מלגה: ${criteria.firstWhere((c) => c['id'] == criterionId)['label']}');
  }
  static void setArrangement(Map<String, dynamic> f, String role, int parts) { // פריסת-היתרה ל-N תשלומים חודשיים (הסדר)
    final bal = balance(f);
    if (bal <= 0 || parts < 2) return;
    final arr = _nid('arr');
    final per = (bal / parts).ceil();
    final t = DateTime.parse('${today}T12:00:00');
    // מבטלים את החיובים הפתוחים ומחליפים בפריסה — כמו f5 במקור (cancelledAt + installmentOf)
    for (final c in liveCharges(f)) {
      cancelledIds.add(c['id'] as String);
      cancelReason[c['id'] as String] = 'הוחלף בהסדר $arr';
    }
    final already = paid(f) - ((f['carryBalance'] as num?) ?? 0);
    if (already > 0) (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': today, 'amount': already, 'cur': '₪', 'cat': arrangementType, 'method': '', 'memberId': studentsOf(f), 'note': 'שולם עד ההסדר'});
    for (var i = 0; i < parts; i++) {
      final d = DateTime(t.year, t.month + i, 20);
      (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': '${_ym(d)}-20', 'amount': i == parts - 1 ? bal - per * (parts - 1) : per, 'cur': '₪', 'cat': arrangementType, 'method': '', 'memberId': studentsOf(f), 'installmentOf': arr, 'note': 'הסדר $parts/${i + 1}'});
    }
    _log(role, f['id'] as String, 'הסדר-תשלומים: ${shekel(bal)} ב-$parts תשלומים');
  }
  static void toggleHok(Map<String, dynamic> f, String role) {
    if (!hasHok(f)) return;
    hokOverride[f['id'] as String] = !hokFlag(f);
    _log(role, f['id'] as String, hokFlag(f) ? 'הפעלת-הו״ק' : 'הפסקת-הו״ק');
  }
  static void sendReminder(Map<String, dynamic> f, String role, String grade) {
    (extraCalls[f['id']] ??= []).add({'at': today, 'outcome': 'reminder', 'grade': grade});
    _log(role, f['id'] as String, 'תזכורת $grade נשלחה (פרטית)');
  }
  static void writeOff(Map<String, dynamic> f, String role) {
    writtenOff.add(f['id'] as String);
    _log(role, f['id'] as String, 'סומן כחוב-אבוד (${shekel(payBal(enrollmentOf(f), _paidOf))})');
  }
  // רישום-הו״ק-חודשי-מרוכז (השלב-השני של האישור-הדו-שלבי): תשלום פר-משפחה-בתור בסכום-ההו״ק
  static int runHokBatch(List<Map<String, dynamic>> fs, String role) {
    final due = hokDueList(fs);
    for (final f in due) {
      addPayment(f, role, amount: ((f['hok'] as Map)['amount'] as num).toInt(), method: 'הו״ק', date: today, note: 'רישום-מרוכז');
    }
    if (due.isNotEmpty) _log(role, '*', 'רישום-הו״ק-מרוכז: ${due.length} משפחות');
    return due.length;
  }

  // ─── התאמת-תשלום-לחיוב (matching · strongMatchForCharge): תשלומים-נכנסים משער-חיצוני ⇒ משפחה ───
  //   הצורה = תשלום-נכנס (phone/email/zeout/amount). זה המקום-השמור לשער-הסליקה; הדוגמה מדגימה את המנוע.
  static const incoming = <Map<String, dynamic>>[
    {'id': 'in1', 'date': '2026-09-04', 'amount': 1000, 'phone': '052-2222222', 'email': '', 'zeout': '', 'toremId': '', 'name': 'רחל לוי'},
    {'id': 'in2', 'date': '2026-09-04', 'amount': 480, 'phone': '', 'email': 'unknown@family', 'zeout': '', 'toremId': '', 'name': 'לא ידוע'},
  ];
  static List<String> _keysOf(Map<String, dynamic> m) => [
        if ('${m['extId'] ?? ''}'.isNotEmpty) 'ext:${m['extId']}',
        if ('${m['idNum'] ?? m['zeout'] ?? ''}'.isNotEmpty) 'id:${m['idNum'] ?? m['zeout']}',
        if ('${m['phone'] ?? ''}'.replaceAll('-', '').isNotEmpty) 'ph:${'${m['phone']}'.replaceAll('-', '')}',
        if ('${m['email'] ?? ''}'.isNotEmpty) 'em:${'${m['email']}'.toLowerCase()}',
      ];
  static Map<String, dynamic>? matchIncoming(Map<String, dynamic> inc, List<Map<String, dynamic>> fs) =>
      strongMatchForCharge(inc, fs, (m) => _keysOf((m as Map).cast<String, dynamic>())) as Map<String, dynamic>?;

  // ─── קישור-תשלום (שער-חיצוני · מקום-שמור · חוק-7): payUrl = קונפיגורציית-הצבה (חוק-6). ריק ⇒ null ⇒ הכפתור שמור ───
  static const String payUrl = ''; // מוזרק בהצבה (למשל https://…/pay/{amount}/{name}); כאן ריק במכוון
  static String? _safeHttps(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final u = Uri.tryParse(t);
    return u != null && u.scheme == 'https' && u.host.isNotEmpty ? u.toString() : null;
  }
  static String? payLinkOf(Map<String, dynamic> f) => payLink(payUrl, balance(f), f['payer'] as String, _safeHttps);

  // ═══ איתור (23-ג · תובנה) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — משפחה/הורה/תלמיד/טלפון ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> f) =>
      ['${f['name']}', '${f['payer']}', '${f['phone']}', ...(f['members'] as List).map((m) => '${(m as Map)['first']}'), gradesOf(f)];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> fs, String q) =>
      (smartFilter(q, fs, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה/פילטרים (23-ג) = FilterChipPill/DsEnumField ⊕ finderMatches (AND על נעילות-צירים) ═══
  //   13 צירי-המפרט: כיתה · חוג · סוג-חיוב · סטטוס · יתרה>0 · ותק>N · הו״ק · מלגה · ללא-תזכורת · תזכורת>2 · אמצעי · חודש/שנה · טקסט(=search)
  static String axisValue(Map<dynamic, dynamic> db, dynamic x, dynamic axis) {
    final f = x as Map<String, dynamic>;
    switch ('$axis') {
      case 'debt': return balance(f) > 0 ? '1' : '0';
      case 'old': return oldDebt(f) ? '1' : '0';
      case 'hok': return hokFlag(f) ? '1' : '0';
      case 'scholar': return discountPct(f) > 0 ? '1' : '0';
      case 'noremind': return balance(f) > 0 && remindersSent(f).isEmpty ? '1' : '0';
      case 'remind2': return remindersSent(f).length > 2 ? '1' : '0';
      case 'arr': return hasArrangement(f) ? '1' : '0';
      case 'risk': return risk(f) >= 1 ? '1' : '0';
      case 'status': return statusOf(f);
      case 'grade': return (f['members'] as List).any((m) => '${(m as Map)['grade']}'.startsWith('${db['grade']}')) ? '1' : '0';
      case 'type': return liveCharges(f).any((c) => c['cat'] == db['type']) ? '1' : '0';
      case 'course': return liveCharges(f).any((c) => c['cat'] == 'חוג' && '${c['note'] ?? ''}' == '${db['course']}') ? '1' : '0';
      case 'method': return paymentsOf(f).any((p) => p['method'] == db['method']) || (db['method'] == 'הו״ק' && hokFlag(f)) ? '1' : '0';
      case 'year': return liveCharges(f).any((c) => dateInRange(c['date'] as String, '${db['year']}-01-01', '${db['year']}-12-31')) || paymentsOf(f).any((p) => dateInRange(p['date'] as String, '${db['year']}-01-01', '${db['year']}-12-31')) ? '1' : '0';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> fs, Map<dynamic, dynamic> locks, Map<String, String> ctx) =>
      finderMatches({'families': fs, ...ctx}, locks, axisValue).cast<Map<String, dynamic>>();
  static List<String> grades(List<Map<String, dynamic>> fs) =>
      {for (final f in fs) for (final m in f['members'] as List) '${(m as Map)['grade']}'.split('-').first}.toList()..sort();
  static List<String> years(List<Map<String, dynamic>> fs) =>
      donationYears([for (final f in fs) for (final p in paymentsOf(f)) {'date': p['date']}, for (final f in fs) for (final c in liveCharges(f)) {'date': c['date']}]);

  static int kOpen(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => balance(f as Map<String, dynamic>)).toInt();
  static List<List<Object>> statusCounts(List<Map<String, dynamic>> fs) => countBy(fs, (f) => statusOf(f as Map<String, dynamic>));

  // ═══ ייצוא (23-ג) = toCsv ⊕ csvEscape ⊕ exportAllowed ═══
  static const csvHeader = ['משפחה', 'תלמידים', 'כיתות', 'חיובים', 'שולם', 'יתרה', 'ותק', 'תשלום-אחרון', 'אמצעי', 'הו״ק', 'הנחה', 'תזכורות', 'סיכון', 'סטטוס', 'הורה-משלם', 'טלפון'];
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> fs) => [
        csvHeader,
        for (final f in fs)
          [f['name'], studentsN(f), gradesOf(f), charged(f), paid(f), balance(f), agingDays(f), lastPaymentDate(f), lastMethod(f), hokFlag(f) ? (hokActive(f) ? 'פעילה' : 'נכשלה') : '', discountLabel(f), remindersSent(f).length, riskLabel(risk(f)), statusOf(f), f['payer'], f['phone']],
      ];
  static String csvOf(List<Map<String, dynamic>> fs) => toCsv(csvRows(fs), csvEscape) as String;
  static const paymentMeta = <Map<String, String>>[
    {'key': 'receiptNo', 'prefix': '🧾 קבלה ', 'suffix': ''},
    {'key': 'clearingRef', 'prefix': '🔐 סליקה ', 'suffix': ''},
    {'key': 'invoiceNo', 'prefix': '📄 חשבונית ', 'suffix': ''},
    {'key': 'note', 'prefix': '', 'suffix': ''},
  ];

  // ═══ הרשאות (חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction · סכומים = הרשאת-כספים (מחנך: דגל בלבד) ═══
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '💼 גזבר/ת', 'email': 'gizbar@school', 'config': {'adminEmails': ['gizbar@school']}}, // admin ⇒ הכל
    {'label': '🗂 מזכירות', 'email': 'office@school', 'config': {'features': {'fees.amounts': true, 'fees.pay': true, 'fees.charge': true, 'fees.remind': true, 'fees.export': true, 'fees.hok': true}}},
    {'label': '🏛 הנהלה', 'email': 'mgmt@school', 'config': {'features': {'fees.amounts': true, 'fees.scholarship': true, 'fees.arrangement': true, 'fees.writeoff': true, 'fees.export': true, 'fees.remind': true}}},
    {'label': '🧑‍🏫 מחנך/ת', 'email': 'teacher@school', 'config': {'features': {'fees.flag': true}}}, // דגל-חוב בלבד, ללא-סכומים
    {'label': '👨‍👩‍👧 הורה', 'email': 'cohen@family', 'config': {'features': {'fees.self': true, 'fees.amounts': true}}}, // החוב-שלי + תשלום
    {'label': '👁 צפייה', 'email': 'view@school', 'config': {'features': {'fees.amounts': true}}}, // תמונה בלבד, אפס-פעולות
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static bool amounts(int role) => can(role, 'fees.amounts');
  static String roleName(int role) => roleDefs[role]['label'] as String;
  // הורה רואה רק את משפחתו (זהות-מוזרקת: המייל של התפקיד = המייל של המשפחה)
}


class AttFeeScreen extends StatefulWidget {
  const AttFeeScreen({super.key});
  @override
  State<AttFeeScreen> createState() => _AttFeeScreenState();
}

class _AttFeeScreenState extends State<AttFeeScreen> {
  // ── att · schoolos_attendance.dart ──
  String _date = _Placement.today; // תאריך-נבחר (בורר-תאריך)
  int? _lesson; // שיעור-נבחר (null ⇒ השיעור-הנוכחי)
  int _mode = 0; // 0=📋 גיליון (טאפ-מחזורי) · 1=🗂 טבלה (DsTable כל-העמודות)
  int _range = 1; // טווח-היסטוריה: 0=7 · 1=30 · 2=90 ימים (dateInRange)
  String? _notice; // הודעת-מערכת אחרונה (רישום-כפול · כולם-נוכחים · שקעים)
  int get _lessonN => _lesson ?? _AttData.currentLesson(_date);
  static const _rangeDays = [7, 30, 90];

  Widget _loadingView() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          SizedBox(height: 14),
          Text('טוען נוכחות…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // שורת-תלמיד (גיליון): זהות (MediaRow) ⊕ מצב-בשיעור (StatusChip/SoftButton-cycle) ⊕ פאנל (שברון)
  //   הטאפ-המחזורי: נוכח→חסר→איחור→שחרור→נוכח (מודל-הפוך: "נוכח" = מחיקת-הסימון). אידמפוטנטי. מגודר-הרשאה.
  Widget _row_att(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    final m = _AttData.markOf(_date, _lessonN, sid);
    final st = m?['status'] as String? ?? 'present';
    final dayst = _AttData.dayStatus(_date, sid);
    final arr = m?['arrival'] as String?;
    final rb = _AttData.riskBand(sid);
    final sub = [
      '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']}',
      if (arr != null) 'הגעה $arr (+${_AttData.lateMinutes(m!)}׳)',
      if (m?['reason'] != null) '${m!['reason']}${m['justified'] == true ? ' · מוצדק' : ''}',
      if (dayst != st) 'היום: ${_AttData.statusLabel[dayst]}',
      if (_AttData.streak(sid) >= _Placement.streakAlert) '🚨 רצף ${_AttData.streak(sid)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: MediaRow(glyph: rb == 2 ? '🚨' : rb == 1 ? '⚠️' : '🎓', title: s['name'] as String, subtitle: sub)),
        const SizedBox(width: 6),
        if (_AttData.canMarkOn(_date))
          SoftButton(label: _AttData.statusLabel[st]!, tone: _AttData.statusTone[st]!, onTap: () => setState(() => _AttData.cycle(_date, _lessonN, sid)))
        else
          StatusChip(label: _AttData.statusLabel[st]!, tone: _AttData.statusTone[st]!),
        IconButton(onPressed: () => _openPanel_att(s), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פרטים ופעולות'),
      ]),
    );
  }

  // 🗂 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid.
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _AttData.columnDefs(_date)) if (_AttData.colShown(c, rows)) c];
    final labels = [for (final c in cols) c['label'] as String];
    final data = <List<String>>[
      for (final s in rows)
        [for (final c in cols) if (c['get'] != null) (c['get'] as String Function(Map<String, dynamic>))(s) else '${s[c['key']] ?? '—'}'],
    ];
    return DsTable(labels: labels, rows: data);
  }

  // 🗓 חודש (לוח-חום): DsCalendar עם תפר-דאטה אמיתי — רשומה=חיסור, התא סופר חיסורים-פר-יום · חגים כרשומות-לוח
  Widget _monthTab(String cls) {
    final recs = <Map<String, String>>[
      for (final m in _AttData.marks)
        if (_AttData.studentById(m['sid'] as String)['cls'] == cls && m['status'] == 'absent') {'date': m['date'] as String, 'title': _AttData.studentById(m['sid'] as String)['name'] as String},
    ];
    final days = _AttData.schoolDaysInMonth(_date);
    final hols = [for (var i = 1; i <= 31; i++) if (DateTime.parse('${monthKey(_date)}-01T12:00:00').add(Duration(days: i - 1)).month == int.parse(_date.substring(5, 7))) _AttData.shift('${monthKey(_date)}-01', i - 1)].where((d) => _AttData.holidayName(d) != null).toList();
    return DsSection(title: '🗓 ${_AttData.className(cls)} · ${recs.length} חיסורים החודש · ${days.length} ימי-לימודים', children: [
      DsCalendar(records: recs, dateOf: (r) => r['date']!, titleOf: (r) => r['title']!),
      _gap(8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final d in hols) StatusChip(label: '🕎 ${fmtDate(d)} ${_AttData.holidayName(d)} · לא-נספר', tone: 3),
        if (hols.isEmpty) const StatusChip(label: 'אין חגים החודש', tone: 1),
      ]),
    ]);
  }

  // 📜 היסטוריה: סימונים-בטווח (dateInRange) · TimelineItem פר-סימון (מי-רשם+מתי = אודיט-שדה)
  Widget _historyTab(String cls) {
    final from = _AttData.shift(_Placement.today, -_rangeDays[_range]);
    final rows = _AttData.marksInRange(from, _Placement.today, cls: cls);
    return DsSection(
      title: '📜 היסטוריה · ${_AttData.className(cls)} · ${rows.length} סימונים',
      trailing: SegmentedSwitch(items: const ['7 י׳', '30 י׳', '90 י׳'], selected: _range, onSelect: (i) => setState(() => _range = i)),
      children: [
        if (rows.isEmpty) const EmptyState(glyph: '📜', message: 'אין סימונים בטווח') else
          for (final m in rows)
            TimelineItem(
              title: '${_AttData.statusLabel[m['status']]} · ${_AttData.studentById(m['sid'] as String)['name']} · שיעור ${m['lesson']}',
              time: '${fmtDate(m['date'] as String)}${m['arrival'] != null ? ' ${m['arrival']}' : ''}',
              body: '${m['reason'] ?? ''}${m['justified'] == true ? ' · מוצדק' : ''}${m['parentOk'] == true ? ' · אישור-הורה' : ''} · רשם/ה ${m['by']} ב-${(m['at'] as String).replaceFirst('T', ' ')}',
            ),
      ],
    );
  }

  // 🔁 השלמות: pendingMakeups (לא-מתוזמנות קודם) ⊕ makeupEligibility · תזמון/בוצע מגודר-הרשאה
  Widget _makeupsTab(String cls) {
    final pend = _AttData.pendingMakeupList.where((p) => p['courseId'] == cls).toList();
    return DsSection(title: '🔁 השלמות · ${_AttData.className(cls)} · ${pend.length} ממתינות', children: [
      if (pend.isEmpty) const EmptyState(glyph: '🔁', message: 'אין השלמות ממתינות') else
        for (final p in pend)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: TimelineItem(title: '${_AttData.studentById(p['memberId'] as String)['name']} · ${p['makeupDate'] == null ? 'ממתין לתזמון' : 'מתוזמן ${fmtDate(p['makeupDate'] as String)}'}', time: fmtDate(p['date'] as String), body: '${p['reason'] ?? ''}')),
            if (_AttData.can('att.makeup') && p['makeupDate'] == null)
              SoftButton(label: '📅 תזמן', tone: 1, onTap: () => setState(() => _patchAbsence(p, {'makeupDate': _AttData.nextSchoolDay(_Placement.today)}))),
            if (_AttData.can('att.makeup') && p['makeupDate'] != null)
              SoftButton(label: '✅ בוצע', tone: 1, onTap: () => setState(() => _patchAbsence(p, {'makeup': false, 'makeupDone': true}))),
          ])),
    ]);
  }
  void _patchAbsence(Map<String, Object?> p, Map<String, dynamic> fields) {
    final date = p['date'] as String, sid = p['memberId'] as String;
    for (final m in _AttData.marksOn(date, sid)) {
      if (m['status'] == 'absent' && m['makeup'] == true) {
        final saved = _AttData.role; _AttData.setRole(2); // רכז: השלמה מותרת גם לאחור (חלון-365)
        _AttData.patch(date, m['lesson'] as int, sid, fields);
        _AttData.setRole(saved);
        break;
      }
    }
  }

  // 📊 סיבות (פילוח): countBy על חיסורי-הכיתה החודש ⇒ NeonBars · מוצדק/לא ⇒ BareStat×2
  Widget _parentsTab(String cls) {
    final q = _AttData.notificationQueue.where((n) => _AttData.studentById(n['sid'] as String)['cls'] == cls && (_AttData.roleDef['child'] == null || n['sid'] == _AttData.roleDef['child'])).toList();
    return DsSection(title: '👪 תקשורת-הורים · ${q.length} הודעות · ${q.where((n) => _AttData.sent.contains(n['key'])).length} נשלחו', children: [
      const AlertBanner(glyph: '📨', tone: 0, message: 'שקע-שליחה (מודול-הורים · SMS/וואטסאפ) לא מחובר בהצבה — ההודעות מנוהלות בתור (מקום-שמור)'),
      _gap(8),
      if (q.isEmpty) const EmptyState(glyph: '👪', message: 'אין הודעות ממתינות') else
        for (final n in q)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: TimelineItem(title: '${n['auto'] == true ? '🤖 אוטו' : '✍️ ידני'} · ${n['to']} (${n['phone']})', time: fmtDate(n['date'] as String), body: '${n['text']}')),
            if (_AttData.sent.contains(n['key'])) const StatusChip(label: 'נשלח · חלון-תגובה', tone: 1)
            else if (_AttData.can('att.notify')) SoftButton(label: '📨 שלח', tone: 0, onTap: () => setState(() => _AttData.send(n['key'] as String))),
            if (_AttData.can('att.parentOk') && n['lesson'] != 0) SoftButton(label: '✔ אשר-חיסור', tone: 1, onTap: () => setState(() { final saved = _AttData.role; _AttData.setRole(2); _AttData.patch(n['date'] as String, n['lesson'] as int, n['sid'] as String, {'parentOk': true}); _AttData.setRole(saved); })),
          ])),
    ]);
  }

  // 🚨 בסיכון (טריאז'): קיבוץ-פר-band (DsSection tone) · StatRow ציון · StatusChip אות+התערבות (חיבור-מודלים)
  Widget _riskTab(List<Map<String, dynamic>> rows) {
    final ranked = [...rows]..sort((a, b) => _AttData.risk(b['id'] as String).compareTo(_AttData.risk(a['id'] as String)));
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: []};
    for (final s in ranked) {
      buckets[_AttData.riskBand(s['id'] as String)]!.add(s);
    }
    const title = {2: '🔴 בסיכון-נשירה', 1: '🟠 מעקב', 0: '🟢 תקין'};
    const tone = {2: 2, 1: 3, 0: 1};
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final b in const [2, 1, 0])
        if (buckets[b]!.isNotEmpty)
          DsSection(title: '${title[b]} · ${buckets[b]!.length}', tone: tone[b]!, children: [
            for (final s in buckets[b]!)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                StatRow(label: '${s['name']} · ${_AttData.className(s['cls'] as String)}', value: 'סיכון ${_AttData.risk(s['id'] as String)}', fraction: _AttData.risk(s['id'] as String) / 100),
                if (b > 0)
                  Padding(padding: const EdgeInsets.only(top: 6, right: 4), child: Wrap(spacing: 8, runSpacing: 6, children: [
                    StatusChip(label: _AttData.riskWhy(s['id'] as String), tone: tone[b]!),
                    StatusChip(label: _AttData.riskAction(s['id'] as String), tone: tone[b]!),
                    for (final p in _AttData.patterns(s['id'] as String).entries) StatusChip(label: '${p.key} (${p.value})', tone: 3),
                    if ((s['riskExternal'] as int?) != null) StatusChip(label: 'ציון-חיצוני ${s['riskExternal']}', tone: 0), // מקום-שמור (מודול-תלמידים)
                  ])),
              ])),
          ]),
    ]);
  }

  // 🧾 אודיט-רישום: פעולות-הסשן (audit) + סימוני-הבסיס (by/at) — TimelineItem · מגודר att.audit
  Widget _auditTab() {
    if (!_AttData.can('att.audit')) return const AlertBanner(glyph: '🔒', tone: 2, message: 'אודיט — רכז/ת והנהלה בלבד');
    final base = [..._AttData.baseMarks]..sort((a, b) => '${b['at']}'.compareTo('${a['at']}'));
    return DsSection(title: '🧾 אודיט-רישום · ${_AttData.audit.length} פעולות-סשן · ${base.length} סימוני-בסיס', children: [
      const AlertBanner(glyph: '🗄', tone: 0, message: 'שקע-אחסון (pushAuditRing/pullAuditRing · Firestore) לא מחובר בהצבה — הטבעת בזיכרון (מקום-שמור)'),
      _gap(8),
      for (final a in _AttData.audit) TimelineItem(title: '${a['action']} · ${a['key']}', time: '${(a['at'] as String).replaceFirst('T', ' ')} #${a['seq']}', body: 'רשם/ה ${a['by']}'),
      for (final m in base.take(12)) TimelineItem(title: '${m['status']} · ${_AttData.studentById(m['sid'] as String)['name']} · שיעור ${m['lesson']}', time: '${(m['at'] as String).replaceFirst('T', ' ')}', body: 'רשם/ה ${m['by']}'),
      _gap(12),
      // 🔌 שקעי-הצבה (מקום-שמור · חוק-7): מוצהרים, לא מזויפים — מאירים כשמחובר נתון
      Text('🔌 שקעי-הצבה · ${_AttData.reservedSockets.length} מקומות-שמורים (לא-מחוברים)', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
      _gap(6),
      for (final r in _AttData.reservedSockets) TimelineItem(title: '${r['label']}', time: r['key']!, body: r['where']),
    ]);
  }

  // ═══ ייצוא (23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport ⊕ GlassCard-preview ═══
  void _openExport_att(List<Map<String, dynamic>> rows) => _openCsv('ייצוא CSV · נוכחות · ${fmtDate(_date)}', _AttData.csvRows(rows, _date), _AttData.csvOf(rows, _date));
  void _openCsv(String title, List<List<Object?>> rows, String csv) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(
          child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
            MediaRow(glyph: '⬇', title: title, subtitle: '${rows.length - 1} שורות · ${rows.first.length} עמודות'),
            _gap(10),
            const Text('תצוגה מקדימה (BOM + חסימת-הזרקה):', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            _gap(8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
              child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6))),
          ]),
        )),
      ),
    );
  }

  // ═══ פאנל תלמיד-נבחר (GlassCard) · פעולת-יסוד "ביצוע"+"הערכה": זהות · סטטוס-היום · פר-שיעור · ציר-30-יום ·
  //   סיבות (NeonBars⊕countBy) · מגמה+סיכון (TrendStat⊕StatRow⊕StatusChip) · השלמות · קשר-הורה · הערות · פעולות (מגודרות) ═══
  void _openPanel_att(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
          final m = _AttData.markOf(_date, _lessonN, sid);
          final st = m?['status'] as String? ?? 'present';
          final days = _AttData.lastSchoolDays(30);
          final reasons = _AttData.reasonsOf(sid);
          final pend = _AttData.pendingMakeupsOf(sid);
          final r = _AttData.risk(sid), rb = _AttData.riskBand(sid);
          final t = _AttData.trend(sid);
          final pct = _AttData.attendancePct(s);
          final parent = _Placement.parents[sid];
          final elig = m == null || m['status'] != 'absent' ? null : _AttData.eligibility(m);
          final canMark = _AttData.canMarkOn(_date);
          return DraggableScrollableSheet(
            initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
            builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                AvatarTile(initials: _AttData.initials(s['name'] as String), title: s['name'] as String, subtitle: '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']} · ${_AttData.summaryOf(s)['statusLabel']}'),
                _gap(10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  StatusChip(label: 'היום: ${_AttData.statusLabel[_AttData.dayStatus(_date, sid)]}', tone: _AttData.statusTone[_AttData.dayStatus(_date, sid)]!),
                  StatusChip(label: 'שיעור $_lessonN: ${_AttData.statusLabel[st]}', tone: _AttData.statusTone[st]!),
                  if (m?['arrival'] != null) StatusChip(label: 'הגעה ${m!['arrival']} · +${_AttData.lateMinutes(m)}׳', tone: _AttData.isLate(m) ? 3 : 1),
                ]),
                _gap(8),
                // שיעורים-מרובים-ביום (פר-שיעור, לא פר-יום): כפתור פר-שיעור — טאפ מחזורי על אותו שיעור (מגודר)
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final l in _AttData.lessonsOf(_date))
                    if (canMark)
                      SoftButton(label: 'ש${l['n']} ${_AttData.statusLabel[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']}', tone: _AttData.statusTone[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']!, onTap: () => act(() => _AttData.cycle(_date, l['n'] as int, sid)))
                    else
                      StatusChip(label: 'ש${l['n']} ${_AttData.statusLabel[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']}', tone: _AttData.statusTone[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']!),
                ]),
                _gap(12),
                Text('ציר 30 ימי-לימודים · ${_AttData.presentsThisMonth(s)}/${_AttData.schoolDaysSoFar()} נוכח החודש', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                Wrap(spacing: 2, runSpacing: 4, children: [
                  for (final d in days)
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      StatusDot(tone: _AttData.statusTone[_AttData.dayStatus(d, sid)]!, size: 9),
                      Text(d.substring(8), style: TextStyle(color: d == _date ? _ink : _muted, fontSize: 9)),
                    ]),
                ]),
                _gap(12),
                StatRow(label: 'נוכחות% החודש (סף ${_Placement.minAttendancePct}%)', value: '${(pct * 100).round()}%', fraction: pct),
                if (pct * 100 < _Placement.minAttendancePct) ...[_gap(6), AlertBanner(glyph: '⚖️', tone: pct * 100 < _Placement.minAttendancePct - 5 ? 2 : 3, message: 'מתחת לסף-הרגולטורי ${_Placement.minAttendancePct}% (זכאות/תעודה) — התרעה-מקדימה')],
                _gap(8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: TrendStat(value: '${_AttData.absencesThisMonth(sid)}', delta: -((t['pct'] as num).toDouble()), label: 'חיסורים החודש · מגמת-נוכחות (↓=מחמיר)')),
                  const SizedBox(width: 8),
                  Expanded(child: Column(children: [
                    StatRow(label: 'ציון-סיכון-נשירה', value: '$r', fraction: r / 100),
                    _gap(6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      StatusChip(label: _AttData.riskWhy(sid), tone: rb == 2 ? 2 : rb == 1 ? 3 : 1),
                      StatusChip(label: _AttData.riskAction(sid), tone: rb == 2 ? 2 : rb == 1 ? 3 : 1),
                      for (final p in _AttData.patterns(sid).entries) StatusChip(label: '${p.key} (${p.value})', tone: 3),
                    ]),
                  ])),
                ]),
                if (reasons.isNotEmpty) ...[
                  _gap(12),
                  const Text('חיסורים לפי סיבה', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  _gap(6),
                  NeonBars(labels: [for (final e in reasons) '${e[0]}'], values: [for (final e in reasons) (e[1] as int).toDouble()], tone: 3),
                ],
                _gap(12),
                Text('השלמות · ${pend.length}', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                if (pend.isEmpty) const Align(alignment: Alignment.centerRight, child: StatusChip(label: 'אין השלמות ממתינות', tone: 1)) else
                  for (final p in pend)
                    TimelineItem(title: p['makeupDate'] == null ? '🔁 ממתין לתזמון' : '📅 מתוזמן ל-${fmtDate(p['makeupDate'] as String)}', time: fmtDate(p['date'] as String), body: '${p['reason'] ?? ''}'),
                _gap(12),
                const Text('קשר-הורה', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                if (parent == null)
                  const AlertBanner(glyph: '👪', tone: 3, message: 'אין קשר-הורה מוזרק (בלוק-הצבה) — הודעות לא יישלחו')
                else
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    for (final f in _AttData.metaFields) if (parent[f['key']] != null) StatusChip(label: '${f['prefix']}${parent[f['key']]}${f['suffix']}', tone: 0),
                    if (m != null) StatusChip(label: m['parentOk'] == true ? 'אישור-הורה ✓' : 'ללא אישור-הורה', tone: m['parentOk'] == true ? 1 : 3),
                  ]),
                _gap(12),
                Text('הערות · ${(_AttData.notes[sid] ?? const []).length}', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                for (final n in _AttData.notes[sid] ?? const <String>[]) TimelineItem(title: n, time: '${fmtDate(_Placement.today)} ${_Placement.nowHm}'),
                _gap(12),
                const Text('פעולות-מהירות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                _gap(8),
                Builder(builder: (_) {
                  final acts = <Widget>[
                    if (canMark) SoftButton(label: '⛔ סמן-חיסור', tone: 2, onTap: () => act(() => _mark(sid, 'absent'))),
                    if (canMark) SoftButton(label: '⏰ סמן-איחור', tone: 3, onTap: () => act(() => _mark(sid, 'late'))),
                    if (canMark) SoftButton(label: '🚪 סמן-שחרור', tone: 0, onTap: () => act(() => _mark(sid, 'released'))),
                    if (canMark && m != null) SoftButton(label: '↩ בטל', tone: 0, onTap: () => act(() => _mark(sid, 'present'))),
                    if (_AttData.can('att.justify') && m != null && m['justified'] != true) SoftButton(label: '✔ סמן-מוצדק', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'justified': true}))),
                    if (canMark && m != null) SoftButton(label: '📎 צרף-אישור', tone: 0, onTap: () => act(() => _notice = 'צרף-אישור: שקע-קובץ (medicalDoc) לא מחובר בהצבה — מקום-שמור')),
                    if (_AttData.can('att.makeup') && m != null && m['status'] == 'absent' && elig!['eligible'] == true && m['makeupDate'] == null)
                      SoftButton(label: '📅 תזמן-השלמה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': true, 'makeupDate': _AttData.nextSchoolDay(_Placement.today)}))),
                    if (_AttData.can('att.makeup') && m != null && m['makeupDate'] != null) SoftButton(label: '✅ השלמה-בוצעה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': false, 'makeupDone': true}))),
                    if (_AttData.can('att.notify') && m != null && m['parentOk'] != true && parent != null) SoftButton(label: '📨 הודעה-להורה', tone: 0, onTap: () => act(() { _AttData.send(_AttData.keyOf(_date, _lessonN, sid)); _notice = 'הודעה ל-${parent['name']} (${parent['phone']}) נרשמה בתור — שקע-שליחה (מודול-הורים) מקום-שמור'; })),
                    if (_AttData.can('att.parentOk') && m != null && m['parentOk'] != true) SoftButton(label: '✔ אשר-חיסור (הורה)', tone: 1, onTap: () => act(() { final saved = _AttData.role; _AttData.setRole(2); _AttData.patch(_date, _lessonN, sid, {'parentOk': true}); _AttData.setRole(saved); })),
                    if (_AttData.can('att.mark') || _AttData.can('att.justify')) SoftButton(label: '📝 הוסף-הערה', tone: 0, onTap: () => act(() => (_AttData.notes[sid] ??= []).insert(0, 'הערה ${(_AttData.notes[sid]?.length ?? 0) + 1} · ${_AttData.riskWhy(sid)}'))),
                  ];
                  return acts.isEmpty ? AlertBanner(message: 'צפייה-בלבד — ${_AttData.whyCannot(_date) ?? 'אין הרשאת-פעולה'}', glyph: '🔒', tone: 2) : Wrap(spacing: 8, runSpacing: 8, children: acts);
                }),
                if (m != null && m['status'] == 'absent') ...[
                  _gap(10),
                  if (elig!['eligible'] != true) const AlertBanner(glyph: '🔁', tone: 3, message: 'לא-זכאי להשלמה (חיסור לא-מוצדק = no-show · makeupEligibility)'),
                  if (canMark) DsEnumField(label: 'סיבה (מובנית)', options: _AttData.reasons, value: '${m['reason'] ?? ''}', onChanged: (v) => act(() => _AttData.patch(_date, _lessonN, sid, {'reason': v}))),
                ],
              ]),
            )),
          );
        },
      ),
    );
  }

  void _mark(String sid, String status) {
    final ok = _AttData.mark(_date, _lessonN, sid, status);
    _notice = ok ? null : (_AttData.whyCannot(_date) ?? 'רישום-כפול חסום (אידמפוטנטי): ${_AttData.studentById(sid)['name']} כבר ${_AttData.statusLabel[status]} בשיעור $_lessonN');
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
  // ── fee · schoolos_fees.dart ──
  int _role = 0; // 0=גזבר · 1=מזכירות · 2=הנהלה · 3=מחנך · 4=הורה · 5=צפייה
  bool _hokArmed = false; // אישור-דו-שלבי לרישום-הו״ק-מרוכז
  String get _roleName => _FeesData.roleName(_role);
  bool get _amounts => _FeesData.amounts(_role);
  String _m(num v) => _amounts ? shekel(v) : '🔒'; // נעילת-הרשאה-כספית: סכום ⇒ מנעול

  Widget _enum(String label, List<String> options, String value, void Function(String) on) => SizedBox(
        width: 170,
        child: DsEnumField(label: label, options: options, value: value, onChanged: on),
      );

  // ═══ שורת-משפחה (טריאז'): זהות ⊕ יחס-שולם (StatRow) ⊕ BareStat×3 ⊕ facts ⊕ הפעולה-הנכונה (AlertBanner) ═══
  Widget _row_fee(Map<String, dynamic> f) {
    final charged = _FeesData.charged(f), paid = _FeesData.paid(f), bal = _FeesData.balance(f);
    final band = _FeesData.agingBand(f);
    final act = _FeesData.rightAction(f);
    final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${_FeesData.studentsOf(f)} · ${_FeesData.gradesOf(f)}')),
            IconButton(onPressed: () => _openPanel_fee(f), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פאנל משפחה'),
          ]),
          _gap(8),
          if (_amounts) ...[
            StatRow(label: 'שולם מתוך חיובים', value: '${shekel(paid)} / ${shekel(charged)}', fraction: charged == 0 ? (paid > 0 ? 1 : 0) : paid / charged),
            _gap(8),
            Row(children: [
              BareStat(value: shekel(charged), label: 'חיובים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: shekel(paid), label: 'שולם', inkColor: _ok, mutedColor: _muted),
              BareStat(value: shekel(bal), label: bal > 0 ? '= יתרה · ${_FeesData.agingDays(f)} י׳' : '= יתרה', inkColor: balColor, mutedColor: _muted),
            ]),
          ] else
            Row(children: [
              BareStat(value: bal > 0 ? '🚩' : '✅', label: bal > 0 ? 'דגל-חוב (ללא-סכום)' : 'תקין', inkColor: bal > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          if (_amounts) ...[
            _wrap(_facts(f)),
            _gap(8),
            AlertBanner(glyph: act['glyph'] as String, tone: act['tone'] as int, message: act['text'] as String),
          ],
        ]),
      ),
    );
  }

  // עובדות-שבב (אטום-יחיד לגיטימי): סטטוס · הו״ק · הנחה · תזכורות · סיכון · אמצעי
  List<Widget> _facts(Map<String, dynamic> f) {
    final r = _FeesData.risk(f);
    return [
      StatusChip(label: _FeesData.statusOf(f), tone: _FeesData.statusOf(f) == 'תקין' || _FeesData.statusOf(f) == 'מלגה-מלאה' ? 1 : _FeesData.statusOf(f).contains('פיגור') ? 2 : 3),
      if (_FeesData.hasHok(f)) StatusChip(label: _FeesData.hokFlag(f) ? (_FeesData.hokActive(f) ? '💳 הו״ק ${_amounts ? shekel((f['hok'] as Map)['amount'] as num) : ''} · יום ${(f['hok'] as Map)['day']}' : '⚠️ הו״ק נכשלה') : '⏸ הו״ק מופסקת', tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 0),
      if (_FeesData.discountLabel(f).isNotEmpty) StatusChip(label: '🎓 ${_FeesData.discountLabel(f)}', tone: 0),
      if (_FeesData.remindersSent(f).isNotEmpty) StatusChip(label: '🔔 ${_FeesData.remindersSent(f).length} תזכורות', tone: _FeesData.remindersSent(f).length > 2 ? 3 : 0),
      if (_FeesData.balance(f) > 0) StatusChip(label: 'סיכון ${_FeesData.riskLabel(r)} · ${_FeesData.tierLabel(f)}', tone: r == 2 ? 2 : r == 1 ? 3 : 1),
      if (_FeesData.lastMethod(f).isNotEmpty) StatusChip(label: '${_FeesData.lastMethod(f)} · ${fmtDate(_FeesData.lastPaymentDate(f))}', tone: 0),
      if (f['nextNote'] != null) StatusChip(label: '📝 ${f['nextNote']}', tone: 0),
    ];
  }

  // ═══ 💳 מבט-הו״ק: תור-לרישום-החודש (hokDue) + רישום-מרוכז דו-שלבי + מצב-כל-ההו״ק ═══
  Widget _hokView(List<Map<String, dynamic>> all, List<Map<String, dynamic>> due) {
    final withHok = all.where(_FeesData.hasHok).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DsSection(title: '💳 הו״ק לרישום החודש · ${due.length} · ${_m(_FeesData.hokExpected(all))}', tone: 0, children: [
        if (due.isEmpty)
          const EmptyState(glyph: '✅', message: 'כל ההו״ק הפעילות נרשמו החודש')
        else ...[
          for (final f in due)
            TimelineItem(title: '${f['name']} · יום ${(f['hok'] as Map)['day']}', time: _FeesData.hokMethod(f), body: '${_m((f['hok'] as Map)['amount'] as num)} — טרם נרשם החודש'),
          if (_FeesData.can(_role, 'fees.hok')) ...[
            _gap(8),
            // אישור-דו-שלבי: שלב-1 חימוש (הצגת-סיכום) · שלב-2 ביצוע (SoftButton danger) · ביטול
            if (!_hokArmed)
              _wrap([SoftButton(label: '🧾 רישום-הו״ק-חודשי-מרוכז', tone: 0, onTap: () => setState(() => _hokArmed = true))], top: 0)
            else ...[
              AlertBanner(glyph: '⚠️', tone: 3, message: 'שלב 2/2: יירשמו ${due.length} תשלומי-הו״ק בסך ${_m(_FeesData.hokExpected(all))} (${due.map((f) => f['name']).join(' · ')}). לאשר?'),
              _wrap([
                SoftButton(label: '✅ אשר ורשום ${due.length}', tone: 2, onTap: () => setState(() { _FeesData.runHokBatch(all, _roleName); _hokArmed = false; })),
                SoftButton(label: 'בטל', tone: 0, onTap: () => setState(() => _hokArmed = false)),
              ], top: 8),
            ],
          ],
        ],
      ]),
      DsSection(title: '📇 כל הוראות-הקבע · ${withHok.length}', children: [
        for (final f in withHok)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              StatusDot(tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 3),
              const SizedBox(width: 10),
              Expanded(child: MediaRow(glyph: '💳', title: f['name'] as String, subtitle: '${_m((f['hok'] as Map)['amount'] as num)} · יום ${(f['hok'] as Map)['day']} · ${_FeesData.hokMethod(f)} · מ-${fmtDate((f['hok'] as Map)['startedAt'] as String?)}')),
              StatusChip(label: _FeesData.hokFailed(f) ? 'נכשלה' : _FeesData.hokFlag(f) ? (_FeesData.hokRecorded(f) ? 'נרשמה החודש' : 'ממתינה') : 'מופסקת', tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 0),
              if (_FeesData.can(_role, 'fees.hok')) ...[
                const SizedBox(width: 8),
                SoftButton(label: _FeesData.hokFlag(f) ? '⏸ הפסק' : '▶ הפעל', tone: _FeesData.hokFlag(f) ? 2 : 1, onTap: () => setState(() => _FeesData.toggleHok(f, _roleName))),
              ],
            ]),
          ),
        if (withHok.isEmpty) const EmptyState(glyph: '💳', message: 'אין הוראות-קבע'),
      ]),
    ]);
  }

  Widget _reminderCard(Map<String, dynamic> f) {
    final nr = _FeesData.nextReminder(f)!;
    final grade = nr['grade'] as String;
    final plan = _FeesData.reminderPlan(f);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MediaRow(glyph: '🔔', title: '${f['name']} · דרגה: $grade', subtitle: 'יתרה ${_m(_FeesData.balance(f))} · ותק ${_FeesData.agingDays(f)} י׳ · נשלחו ${_FeesData.remindersSent(f).length}'),
        _wrap([for (final p in plan) StatusChip(label: '${p['grade']} · ${fmtDate(p['date'] as String?)}', tone: p['grade'] == grade ? 3 : 0)]),
        if (_amounts) ...[
          _gap(6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
            child: SelectableText(_FeesData.reminderText(f, grade), style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.5)),
          ),
        ],
        if (_FeesData.can(_role, 'fees.remind'))
          _wrap([SoftButton(label: '📨 שלח תזכורת $grade (פרטי)', tone: 3, onTap: () => setState(() => _FeesData.sendReminder(f, _roleName, grade)))], top: 8),
      ]),
    );
  }

  // ═══ 📊 דוחות: מגמת-גבייה (TrendStat⊕trendFromScan) · פירוק-סטטוס (DsBars⊕countBy) · דוח-גזבר-שבועי · סוף-שנה ═══
  Widget _reportsView(List<Map<String, dynamic>> all, Map<String, dynamic> trend, int thisMonth) {
    final counts = _FeesData.statusCounts(all);
    final t = DateTime.parse('${_FeesData.today}T12:00:00');
    final wa = DateTime(t.year, t.month, t.day - 7); // חשבון-תאריך אמיתי (חוצה-חודש) — לא clamp בתוך החודש
    final weekAgo = '${_FeesData.ymOf(wa)}-${wa.day.toString().padLeft(2, '0')}';
    final weekPaid = grandTotal([for (final f in all) for (final p in _FeesData.paymentsOf(f)) if (dateInRange(p['date'] as String, weekAgo, _FeesData.today)) p['amount']], (x) => x as num).toInt();
    final weekRem = grandTotal([for (final f in all) for (final c in _FeesData.remindersSent(f)) if (dateInRange(c['at'] as String, weekAgo, _FeesData.today)) 1], (x) => x as num).toInt();
    final byType = <String, int>{};
    for (final f in all) {
      _FeesData.byType(f).forEach((k, v) => byType[k] = (byType[k] ?? 0) + v);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: TrendStat(value: _m(thisMonth), delta: (trend['pct'] as num).toDouble(), label: 'נגבה החודש · מגמה מול חצי-שנה')),
      ]),
      _gap(10),
      if (_amounts) DsBars(title: 'חיובים לפי-סוג', labels: byType.keys.toList(), values: [for (final v in byType.values) v.toDouble()]),
      _gap(10),
      DsBars(title: 'משפחות לפי-סטטוס', labels: [for (final c in counts) c[0] as String], values: [for (final c in counts) (c[1] as int).toDouble()]),
      _gap(10),
      DsSection(title: '🗓 דוח-גזבר שבועי · מ-${fmtDate(weekAgo)} עד ${fmtDate(_FeesData.today)}', children: [
        Row(children: [
          BareStat(value: _m(weekPaid), label: 'נגבה השבוע', inkColor: _ok, mutedColor: _muted),
          BareStat(value: '$weekRem', label: 'תזכורות השבוע', inkColor: _ink, mutedColor: _muted),
          BareStat(value: '${all.where(_FeesData.hokFailed).length}', label: 'הו״ק נכשלו', inkColor: all.any(_FeesData.hokFailed) ? _danger : _ok, mutedColor: _muted),
          BareStat(value: '${all.where(_FeesData.oldDebt).length}', label: 'חוב-ותיק', inkColor: all.any(_FeesData.oldDebt) ? _danger : _ok, mutedColor: _muted),
        ]),
      ]),
      DsSection(title: '🏁 סוף-שנה · סגירת-חשבונות', children: [
        Row(children: [
          BareStat(value: '${all.where((f) => _FeesData.balance(f) <= 0).length}/${all.length}', label: 'משפחות סגורות', inkColor: _ink, mutedColor: _muted),
          BareStat(value: _m(_FeesData.kOpen(all)), label: 'יתרה להעברה (carryBalance)', inkColor: _FeesData.kOpen(all) > 0 ? _warning : _ok, mutedColor: _muted),
          BareStat(value: _m(grandTotal(all, (f) => _FeesData.credit(f as Map<String, dynamic>))), label: 'זכויות להחזר', inkColor: _acc, mutedColor: _muted),
        ]),
        const AlertBanner(glyph: '🔒', tone: 0, message: 'סגירת-שנה = העברת-יתרות ל-carryBalance של השנה-הבאה (מקום-שמור: פעולת-סוף-שנה נעולה עד אישור-הנהלה)'),
      ]),
      // מקום-שמור: התאמת-תשלומים-נכנסים (matching · strongMatchForCharge) — השער-החיצוני יזין את הרשימה
      DsSection(title: '🔗 התאמת-תשלומים-נכנסים לחיוב (שער-חיצוני · מקום-שמור)', children: [
        for (final inc in _FeesData.incoming)
          () {
            final m = _FeesData.matchIncoming(inc, all);
            return TimelineItem(title: m == null ? '❓ ${inc['name']} — ללא-התאמה (ידני)' : '✅ ${inc['name']} — הותאם: ${m['name']}', time: fmtDate(inc['date'] as String?), body: '${_m(inc['amount'] as num)} · מפתח: ${inc['phone'] != '' ? 'טלפון' : 'מייל'}');
          }(),
      ]),
    ]);
  }

  // ═══ פאנל משפחה-נבחרת (GlassCard · bottom-sheet): זהות · יתרה (צבועה-לפי-ותק) · פירוק · טאבים-9 · הפעולה-הנכונה · פעולות ═══
  void _openPanel_fee(Map<String, dynamic> f) {
    var tab = 0;
    if (!_amounts) { // דגל-בלבד: פאנל מצומצם (זהות + דגל + הפניה) — אפס-פרטי-חוב
      showModalBottomSheet<void>(
        context: context, backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${_FeesData.studentsOf(f)} · ${_FeesData.gradesOf(f)}'),
              _gap(10),
              AlertBanner(glyph: _FeesData.balance(f) > 0 ? '🚩' : '✅', tone: _FeesData.balance(f) > 0 ? 3 : 1, message: _FeesData.balance(f) > 0 ? 'דגל-חוב — פרטים וסכומים בגזברות בלבד. לא לפנות לתלמיד/ה (מגן-כבוד).' : 'תקין — אין דגל-חוב'),
            ]),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() fn) { fn(); setSheet(() {}); setState(() {}); }
        final charged = _FeesData.charged(f), paid = _FeesData.paid(f), bal = _FeesData.balance(f), band = _FeesData.agingBand(f);
        final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
        final actn = _FeesData.rightAction(f);
        return DraggableScrollableSheet(
          initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.97, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${f['payer']} · ${f['phone']} · ${_FeesData.studentsOf(f)} (${_FeesData.gradesOf(f)})'),
                _gap(10),
                Row(children: [
                  BareStat(value: _m(bal), label: bal > 0 ? 'יתרה · ותק ${_FeesData.agingDays(f)} י׳' : 'יתרה', inkColor: balColor, mutedColor: _muted),
                  BareStat(value: _m(charged), label: 'חיובים', inkColor: _ink, mutedColor: _muted),
                  BareStat(value: _m(paid), label: 'שולם', inkColor: _ok, mutedColor: _muted),
                  if (_FeesData.credit(f) > 0) BareStat(value: _m(_FeesData.credit(f)), label: 'זכות', inkColor: _acc, mutedColor: _muted),
                ]),
                _gap(8),
                AlertBanner(glyph: actn['glyph'] as String, tone: actn['tone'] as int, message: 'הפעולה-הנכונה: ${actn['text']}'),
                _gap(10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedSwitch(items: const ['סקירה', 'חיובים', 'תשלומים', 'הו״ק', 'תזכורות', 'הנחות', 'הסדר', 'דוחות', 'אודיט'], selected: tab, onSelect: (i) => setSheet(() => tab = i)),
                ),
                _gap(10),
                ...switch (tab) {
                  1 => _tabCharges(f, act),
                  2 => _tabPayments(f),
                  3 => _tabHok(f, act),
                  4 => _tabReminders(f, act),
                  5 => _tabDiscounts(f, act),
                  6 => _tabArrangement(f, act),
                  7 => _tabStatement(f),
                  8 => _tabAudit(f),
                  _ => _tabOverview(f, charged, paid, bal),
                },
                _gap(14),
                const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                _gap(8),
                Builder(builder: (_) {
                  final acts = <Widget>[
                    if (_FeesData.can(_role, 'fees.charge')) SoftButton(label: '➕ חיוב', tone: 0, onTap: () => _openChargeForm(f, [f], onDone: () => setSheet(() {}))),
                    if (_FeesData.can(_role, 'fees.pay')) SoftButton(label: '💳 רשום תשלום', tone: 1, onTap: () => _openPaymentForm(f, [f], onDone: () => setSheet(() {}))),
                    if (_FeesData.can(_role, 'fees.pay') && bal > 0) SoftButton(label: '➗ תשלום-חלקי (½)', tone: 1, onTap: () => act(() => _FeesData.addPayment(f, _roleName, amount: (bal / 2).ceil(), method: 'מזומן', date: _FeesData.today, note: 'תשלום-חלקי'))),
                    if (_FeesData.can(_role, 'fees.remind') && _FeesData.nextReminder(f) != null) SoftButton(label: '📨 תזכורת ${_FeesData.nextReminder(f)!['grade']}', tone: 3, onTap: () => act(() => _FeesData.sendReminder(f, _roleName, _FeesData.nextReminder(f)!['grade'] as String))),
                    if (_FeesData.can(_role, 'fees.arrangement') && bal > 0 && !_FeesData.hasArrangement(f)) SoftButton(label: '📆 הסדר 3 תשלומים', tone: 0, onTap: () => act(() => _FeesData.setArrangement(f, _roleName, 3))),
                    if (_FeesData.can(_role, 'fees.hok') && _FeesData.hasHok(f)) SoftButton(label: _FeesData.hokFlag(f) ? '⏸ הפסק הו״ק' : '▶ הפעל הו״ק', tone: _FeesData.hokFlag(f) ? 2 : 1, onTap: () => act(() => _FeesData.toggleHok(f, _roleName))),
                    if (_FeesData.can(_role, 'fees.writeoff') && bal > 0 && _FeesData.oldDebt(f)) SoftButton(label: '🗂 סמן חוב-אבוד', tone: 2, onTap: () => act(() => _FeesData.writeOff(f, _roleName))),
                    if (_FeesData.can(_role, 'fees.refund') && _FeesData.credit(f) > 0) SoftButton(label: '💸 החזר-זכות ${_m(_FeesData.credit(f))}', tone: 1, onTap: () => act(() => _FeesData.refund(f, _roleName))),
                    if ((_FeesData.can(_role, 'fees.pay') || _FeesData.can(_role, 'fees.self')) && bal > 0)
                      // שער-חיצוני (מקום-שמור): payLink מחזיר null כש-payUrl ריק ⇒ הכפתור שמור, לא מזייף קישור
                      SoftButton(label: _FeesData.payLinkOf(f) == null ? '🔗 קישור-תשלום (שער לא-מוגדר)' : '🔗 שלח קישור-תשלום', tone: 0, onTap: _FeesData.payLinkOf(f) == null ? null : () {}),
                    SoftButton(label: '🖨 מצב-חשבון', tone: 0, onTap: () => setSheet(() => tab = 7)),
                  ];
                  return acts.isEmpty
                      ? const AlertBanner(message: 'צפייה-בלבד — אין הרשאת-פעולה', glyph: '🔒', tone: 2)
                      : Wrap(spacing: 8, runSpacing: 8, children: acts);
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // סקירה: השוואה (NeonBars) · יחס (StatRow) · פירוק-לפי-סוג (DsBars) · תלמידים · מדדי-דפוס (RFM·מגמה)
  List<Widget> _tabOverview(Map<String, dynamic> f, int charged, int paid, int bal) => [
        if (_amounts) ...[
          NeonBars(labels: const ['חיובים', 'שולם', 'יתרה'], values: [charged.toDouble(), paid.toDouble(), bal.toDouble()], tone: bal > 0 ? (_FeesData.agingBand(f) == 3 ? 2 : 3) : 1),
          _gap(8),
          StatRow(label: 'שולם מתוך חיובים', value: '${shekel(paid)} / ${shekel(charged)}', fraction: charged == 0 ? 0 : paid / charged),
          _gap(8),
          if (_FeesData.byType(f).isNotEmpty) DsBars(title: 'פירוק-חיובים לפי-סוג', labels: _FeesData.byType(f).keys.toList(), values: [for (final v in _FeesData.byType(f).values) v.toDouble()]),
        ],
        _wrap([for (final m in f['members'] as List) StatusChip(label: '🎓 ${(m as Map)['first']} · ${m['grade']}', tone: 0)]),
        _wrap(_facts(f)),
        _gap(8),
        Row(children: [
          BareStat(value: '${_FeesData.rfm(f)}', label: 'דפוס-תשלום (RFM) · ${_FeesData.tierLabel(f)}', inkColor: _FeesData.tierKey(f) == 'red' ? _danger : _ink, mutedColor: _muted),
          BareStat(value: '${_FeesData.trend(f)['dir'] == 'up' ? '↑' : _FeesData.trend(f)['dir'] == 'down' ? '↓' : '→'} ${_FeesData.trend(f)['pct']}%', label: 'מגמת-תשלומים (6 חודשים)', inkColor: _FeesData.trend(f)['dir'] == 'down' ? _danger : _ok, mutedColor: _muted),
          BareStat(value: _FeesData.riskLabel(_FeesData.risk(f)), label: 'סיכון-גבייה (ותק · דפוס · מגמה)', inkColor: _FeesData.risk(f) == 2 ? _danger : _FeesData.risk(f) == 1 ? _warning : _ok, mutedColor: _muted),
        ]),
      ];

  // חיובים: פירוט (סוג/סכום/תאריך/עבור-מי) + ביטול (סיבה) + כפולים
  List<Widget> _tabCharges(Map<String, dynamic> f, void Function(void Function()) act) {
    final cs = _FeesData.chargesOf(f);
    final dups = _FeesData.duplicateCharges(f).map((c) => c['id']).toSet();
    return [
      if (cs.isEmpty) const EmptyState(glyph: '📭', message: 'אין חיובים למשפחה — לרשום חיוב-שנה'),
      for (final c in cs)
        () {
          final cancelled = c['cancelledAt'] != null || _FeesData.cancelledIds.contains(c['id']);
          final net = _FeesData.netOf(f, c), gross = _FeesData.grossOf(f, c);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TimelineItem(
              title: '${cancelled ? '🚫 ' : dups.contains(c['id']) ? '👯 ' : ''}${c['cat']} · ${c['memberId']}${c['installmentOf'] != null ? ' · הסדר' : ''}',
              time: fmtDate(c['date'] as String?),
              body: '${cancelled ? 'בוטל: ${_FeesData.cancelReason[c['id']] ?? c['note'] ?? ''}' : _amounts ? (net != gross ? '${shekel(net)} (ברוטו ${shekel(gross)}, הנחה)' : shekel(net)) : '🔒'}${c['note'] != null && !cancelled ? ' · ${c['note']}' : ''}',
            ),
            if (!cancelled && _FeesData.can(_role, 'fees.writeoff'))
              _wrap([SoftButton(label: '✖ בטל חיוב', tone: 2, onTap: () => act(() => _FeesData.cancelCharge(f, _roleName, c, dups.contains(c['id']) ? 'חיוב-כפול' : 'ביטול-ידני')))], top: 2),
          ]);
        }(),
    ];
  }

  // תשלומים: ציר (TimelineItem) + שדות-מטא-שמורים (קבלה/סליקה/חשבונית — מאירים כשיש)
  List<Widget> _tabPayments(Map<String, dynamic> f) {
    final ps = [..._FeesData.paymentsOf(f)]..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return [
      if (ps.isEmpty) const EmptyState(glyph: '💳', message: 'אין תשלומים רשומים'),
      for (final p in ps)
        TimelineItem(
          title: '${p['method']}${p['method'] == 'הו״ק' ? ' 💳' : ''}',
          time: fmtDate(p['date'] as String?),
          body: '${_m(p['amount'] as num)}${[for (final m in _FeesData.paymentMeta) if (p[m['key']] != null) ' · ${m['prefix']}${p[m['key']]}${m['suffix']}'].join()}',
        ),
      const AlertBanner(glyph: '🧾', tone: 0, message: 'קבלת-מס / אישור-סליקה / חשבונית = שער-חיצוני (מקום-שמור: מס׳-קבלה יואר כאן כשיגיע מהשער; המסך אינו מנפיק)'),
    ];
  }

  // הו״ק: מצב-החודש (hokEffectivelyActive⊕hokRecordedThisMonth) + היסטוריית-סליקה + הפעל/הפסק
  List<Widget> _tabHok(Map<String, dynamic> f, void Function(void Function()) act) {
    if (!_FeesData.hasHok(f)) return [const EmptyState(glyph: '💳', message: 'אין הוראת-קבע למשפחה (מקום-שמור: תוגדר בשער-הסליקה)')];
    final h = f['hok'] as Map;
    final hist = (f['hist'] as List?) ?? const [];
    return [
      Row(children: [
        StatusDot(tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 3),
        const SizedBox(width: 10),
        Expanded(child: MediaRow(glyph: '💳', title: '${_m(h['amount'] as num)} · יום ${h['day']} בחודש', subtitle: '${_FeesData.hokMethod(f)} · מ-${fmtDate(h['startedAt'] as String?)}${h['kevaId'] != null ? ' · סליקה ${h['kevaId']}' : ' · ידנית'}')),
      ]),
      _wrap([
        StatusChip(label: _FeesData.hokFlag(f) ? 'מסומנת פעילה' : 'מופסקת', tone: _FeesData.hokFlag(f) ? 1 : 0),
        StatusChip(label: _FeesData.hokActive(f) ? 'סליקה חיה' : 'סליקה פסקה >2 חודשים', tone: _FeesData.hokActive(f) ? 1 : 2),
        StatusChip(label: _FeesData.hokRecorded(f) ? 'נרשמה החודש ✅' : 'טרם נרשמה החודש', tone: _FeesData.hokRecorded(f) ? 1 : 3),
      ]),
      if (_FeesData.hokFailed(f)) ...[
        _gap(6),
        const AlertBanner(glyph: '⚠️', tone: 2, message: 'הו״ק נכשלה — התרעה נשלחה; ניסיון-חיוב-חוזר = שער-הסליקה (מקום-שמור). בינתיים: תזכורת עדינה'),
      ],
      _gap(6),
      Text('היסטוריית-סליקה · ${hist.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final e in hist) TimelineItem(title: '${(e as Map)['clearer']}', time: fmtDate(e['d'] as String?), body: _m(e['a'] as num)),
      if (hist.isEmpty) const EmptyState(glyph: '📭', message: 'אין היסטוריית-סליקה (הו״ק ידנית)'),
    ];
  }

  // תזכורות: לוח-מדורג + היסטוריה + תגובה (nextNote)
  List<Widget> _tabReminders(Map<String, dynamic> f, void Function(void Function()) act) {
    final plan = _FeesData.reminderPlan(f), sent = _FeesData.remindersSent(f), nr = _FeesData.nextReminder(f);
    return [
      if (_FeesData.fullScholarship(f)) const AlertBanner(glyph: '🎓', tone: 1, message: 'מלגה מלאה — אפס-תזכורות (מגן-כבוד)') else if (plan.isEmpty) const EmptyState(glyph: '🕊', message: 'אין חוב פתוח — אין לוח-תזכורות') else ...[
        Text('לוח מדורג (מהחיוב-הפתוח-הוותיק ${fmtDate(_FeesData.oldestOpenDate(f))})', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
        _wrap([for (var i = 0; i < plan.length; i++) StatusChip(label: '${i < sent.length ? '✅' : '${plan[i]['date']}'.compareTo(_FeesData.today) <= 0 ? '⏰' : '⏳'} ${plan[i]['grade']} · ${fmtDate(plan[i]['date'] as String?)}', tone: i < sent.length ? 1 : nr != null && nr['grade'] == plan[i]['grade'] ? 3 : 0)]),
        if (nr != null && _FeesData.can(_role, 'fees.remind')) _wrap([SoftButton(label: '📨 שלח תזכורת ${nr['grade']} (פרטי)', tone: 3, onTap: () => act(() => _FeesData.sendReminder(f, _roleName, nr['grade'] as String)))], top: 8),
      ],
      _gap(8),
      Text('היסטוריה · ${sent.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final c in sent) TimelineItem(title: 'תזכורת ${c['grade'] ?? ''}', time: fmtDate(c['at'] as String?), body: 'נשלחה בפרטיות'),
      if (f['nextNote'] != null) AlertBanner(glyph: '📝', tone: 0, message: 'תגובה/מעקב: ${f['nextNote']} (${fmtDate(f['nextDate'] as String?)})'),
    ];
  }

  // הנחות-ומלגות: מדיניות (maxDiscountPct הגבוה-מנצח) · הענקה (הנהלה)
  List<Widget> _tabDiscounts(Map<String, dynamic> f, void Function(void Function()) act) {
    final ids = _FeesData.effectiveCriteria(f);
    return [
      Row(children: [
        BareStat(value: '${_FeesData.discountPct(f)}%', label: 'הנחה אפקטיבית (הגבוהה מנצחת)', inkColor: _acc, mutedColor: _muted),
        BareStat(value: _m(_FeesData.scholarshipOf(f)), label: 'שווי-ההנחה השנה', inkColor: _ink, mutedColor: _muted),
        BareStat(value: '${_FeesData.studentsN(f)}', label: 'אחים (הנחת-אחים אוטו)', inkColor: _ink, mutedColor: _muted),
      ]),
      _wrap([for (final c in _FeesData.criteria) StatusChip(label: '${ids.contains(c['id']) ? '✅ ' : ''}${c['label']} ${c['discountPct']}%', tone: ids.contains(c['id']) ? 1 : 0)]),
      if (_FeesData.can(_role, 'fees.scholarship'))
        _wrap([for (final c in _FeesData.criteria) if (!ids.contains(c['id'])) SoftButton(label: '🎓 הענק ${c['label']}', tone: 0, onTap: () => act(() => _FeesData.grantDiscount(f, _roleName, c['id'] as String)))], top: 8)
      else
        const AlertBanner(glyph: '🔒', tone: 0, message: 'הענקת-מלגה/הנחה = הרשאת-הנהלה'),
    ];
  }

  // הסדר: פריסה (installmentOf) · מצב-כל-תשלום · פיגור
  List<Widget> _tabArrangement(Map<String, dynamic> f, void Function(void Function()) act) {
    final ins = _FeesData.installments(f);
    return [
      if (ins.isEmpty) ...[
        const EmptyState(glyph: '📆', message: 'אין הסדר-תשלומים'),
        if (_FeesData.can(_role, 'fees.arrangement') && _FeesData.balance(f) > 0)
          _wrap([for (final n in const [2, 3, 6]) SoftButton(label: '📆 פריסה ל-$n', tone: 0, onTap: () => act(() => _FeesData.setArrangement(f, _roleName, n)))], top: 4),
      ] else ...[
        if (_FeesData.arrangementLate(f)) const AlertBanner(glyph: '📆', tone: 3, message: 'הסדר בפיגור — תשלום שמועדו עבר לא כוסה'),
        for (final c in ins)
          TimelineItem(title: '${c['note'] ?? 'תשלום-הסדר'}', time: fmtDate(c['date'] as String?), body: '${_m(_FeesData.netOf(f, c))} · ${'${c['date']}'.compareTo(_FeesData.today) <= 0 ? (_FeesData.oldestOpenDate(f) != null && '${c['date']}'.compareTo(_FeesData.oldestOpenDate(f)!) >= 0 ? 'פתוח' : 'כוסה') : 'עתידי'}'),
      ],
    ];
  }

  // מצב-חשבון (הדפסה = מקום-שמור): שורות-אמת להעתקה
  List<Widget> _tabStatement(Map<String, dynamic> f) {
    final lines = <String>[
      'מצב-חשבון · ${f['name']} · ${_FeesData.orgName} · ${fmtDate(_FeesData.today)}',
      'הורה-משלם: ${f['payer']} · ${f['phone']}',
      'תלמידים: ${_FeesData.studentsOf(f)} (${_FeesData.gradesOf(f)})',
      '',
      'חיובים:',
      for (final c in _FeesData.liveCharges(f)) '  ${fmtDate(c['date'] as String?)}  ${c['cat']}  ${c['memberId']}  ${shekel(_FeesData.netOf(f, c))}',
      'תשלומים:',
      for (final p in _FeesData.paymentsOf(f)) '  ${fmtDate(p['date'] as String?)}  ${p['method']}  ${shekel(p['amount'] as num)}',
      '',
      'סך-חיובים ${shekel(_FeesData.charged(f))} · שולם ${shekel(_FeesData.paid(f))} · יתרה ${shekel(_FeesData.balance(f))}',
    ];
    return [
      if (!_amounts) const AlertBanner(glyph: '🔒', tone: 2, message: 'מצב-חשבון דורש הרשאת-כספים') else
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
          child: SelectableText(lines.join('\n'), style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
        ),
      const AlertBanner(glyph: '🖨', tone: 0, message: 'הדפסה/PDF = שער-חיצוני (מקום-שמור) — הטקסט לעיל ניתן להעתקה'),
    ];
  }

  List<Widget> _tabAudit(Map<String, dynamic> f) {
    final rows = _FeesData.audit.where((a) => a['family'] == f['id']).toList();
    return [
      if (rows.isEmpty) const EmptyState(glyph: '🧾', message: 'אין פעולות למשפחה זו עדיין') else
        for (final a in rows) TimelineItem(title: '${a['role']}', time: fmtDate(a['date'] as String?), body: a['what'] as String),
    ];
  }

  // ═══ טפסים (DsEnumField⊕DsNumberField⊕DsDateField⊕DsField⊕DsPrimaryButton): חיוב-חדש / חיוב-מרוכז · רישום-תשלום ═══
  void _openChargeForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var cat = _FeesData.chargeTypes.first, amount = '', date = _FeesData.today, note = '', member = '', bulk = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _FeesData.families.firstWhere((x) => x['id'] == fam, orElse: () => _FeesData.families.first);
        final members = [for (final m in f['members'] as List) '${(m as Map)['first']}'];
        if (!members.contains(member)) member = members.first;
        final grades = _FeesData.grades(_FeesData.families);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  const MediaRow(glyph: '➕', title: 'חיוב חדש / חיוב-מרוכז', subtitle: 'סוג · סכום · תאריך · עבור-מי — או מרוכז לכל כיתה'),
                  _gap(8),
                  DsEnumField(label: 'משפחה', options: [for (final x in _FeesData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _FeesData.families.firstWhere((x) => x['name'] == v)['id'] as String)),
                  DsEnumField(label: 'עבור-מי', options: members, value: member, onChanged: (v) => setSheet(() => member = v)),
                  DsEnumField(label: 'סוג-חיוב', options: _FeesData.chargeTypes, value: cat, onChanged: (v) => setSheet(() => cat = v)),
                  DsNumberField(label: 'סכום (₪)', value: amount, onChanged: (v) => amount = v),
                  DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v)),
                  DsField(label: 'הערה', hint: 'למשל: טיול שנתי / שם-חוג', value: note, onChanged: (v) => note = v),
                  _gap(6),
                  DsEnumField(label: 'חיוב-מרוכז לכיתה (אופציונלי)', options: ['', ...grades], value: bulk, onChanged: (v) => setSheet(() => bulk = v)),
                  _gap(10),
                  DsPrimaryButton(label: bulk.isEmpty ? 'שמור חיוב' : 'חיוב-מרוכז לכל $bulk', onTap: () {
                    final a = int.tryParse(amount.trim()) ?? 0;
                    if (a <= 0) return;
                    if (bulk.isEmpty) {
                      _FeesData.addCharge(f, _roleName, cat: cat, amount: a, date: date, memberId: member, note: note);
                    } else {
                      for (final x in _FeesData.families) {
                        for (final m in x['members'] as List) {
                          if ('${(m as Map)['grade']}'.startsWith(bulk)) _FeesData.addCharge(x, _roleName, cat: cat, amount: a, date: date, memberId: '${m['first']}', note: note.isEmpty ? 'חיוב-מרוכז $bulk' : note);
                        }
                      }
                    }
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openPaymentForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var method = 'אשראי', amount = '', date = _FeesData.today, note = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _FeesData.families.firstWhere((x) => x['id'] == fam, orElse: () => _FeesData.families.first);
        final bal = _FeesData.balance(f);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  MediaRow(glyph: '💳', title: 'רישום תשלום', subtitle: 'יתרה נוכחית ${_m(bal)} · המסך רושם — אינו סולק'),
                  _gap(8),
                  DsEnumField(label: 'משפחה', options: [for (final x in _FeesData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _FeesData.families.firstWhere((x) => x['name'] == v)['id'] as String)),
                  DsEnumField(label: 'אמצעי', options: _FeesData.payMethodsSchool, value: method, onChanged: (v) => setSheet(() => method = v)),
                  DsNumberField(label: 'סכום (₪) · ריק = מלוא-היתרה', value: amount, onChanged: (v) => amount = v),
                  DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v)),
                  DsField(label: 'הערה / אסמכתא', hint: 'אסמכתת-העברה (לא מס׳-קבלה)', value: note, onChanged: (v) => note = v),
                  _gap(10),
                  DsPrimaryButton(label: 'רשום תשלום', onTap: () {
                    final a = amount.trim().isEmpty ? bal : (int.tryParse(amount.trim()) ?? 0);
                    if (a <= 0) return;
                    _FeesData.addPayment(f, _roleName, amount: a, method: method, date: date, note: note);
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ═══ ייצוא (toCsv⊕csvEscape⊕exportAllowed) — הרשימה-הנראית; בסנדבוקס ההורדה חסומה ⇒ תצוגה+העתקה ═══
  void _openExport_fee(List<Map<String, dynamic>> fs) {
    final csv = _FeesData.csvOf(fs);
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              MediaRow(glyph: '⬇', title: 'ייצוא CSV', subtitle: '${fs.length} משפחות · ${_FeesData.csvHeader.length} עמודות (PDF = שער-חיצוני, מקום-שמור)'),
              _gap(10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(
        padding: EdgeInsets.only(top: top, right: 4),
        child: Wrap(spacing: 8, runSpacing: 6, children: kids),
      );
  @override
  Widget build(BuildContext context) => DsScaffold(title: 'AttFee', subtitle: 'att ⊕ fee · הרכבה חוצת-מודולים מחוללת', icon: '🧬', children: [
    _loadingView(),
    _auditTab(),
  ]);
}
