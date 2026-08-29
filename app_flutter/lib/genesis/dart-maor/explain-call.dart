// ⚛️ אטום-Dart (דרגת-חוזה) · explainCall — תיאור-אנושי בעברית של מה שמתקשר יחווה
//    (item 16, סימולטור-שיחה חי). מוצא: maor/telephony/lib/simulate.mjs:231-302
//    (המקור הטהור). המקור: new/atoms/explain-call.mjs · חוזה: explain-call.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS (המקור קדוש). השכנים simulateCall + featureOn הוזרקו כשקעי-פונקציה
//        (חוק-1/חוק-3). העוזרים הפרטיים DOW_HE + _closedTag נשארו בקובץ (חלק מהיחידה).
//
// תפקיד: מריץ את שקע-הסימולציה ומתרגם את המסלול (path/outcome/reason) לסיפור עברי
//        קריא (אימוג'י + שורות). מכסה חיוג-יוצא/כשר · מוקד-מצוקה · שבעה · הכרזה ·
//        שעות/חג · IVR · תור · חסימה · אחרי-שעות (F11: מודע-voicemail — כבוי ⇒ צליל-תפוס).
// פלט: Map {outcome, reason, summary, lines, sim} — sim הוא **אותו אובייקט** שהשקע
//        החזיר (זהות-הפניה: identical ≡ === של JS); summary = lines.join(' ').
//
// הערות-המרה (מקור→Dart — הנקודות שמנוע-AST נוטה לפספס; DART-PORTING-RULES):
//  • truthiness (כלל 7): כל `x || fallback` על מחרוזת = `_orStr` — null/'' ⇒ fallback,
//    אחרת הערך. כך `ext?.join(', ') || '—'`, `did || ''`, `hhmm || ''`, `reason || ''`.
//  • `if (call.callerId)` / `call.date ?` / `when ?` = בדיקת-truthy מפורשת (_truthy / isNotEmpty).
//  • null≠undefined (כלל 2): `call.dow != null` — JS-loose תופס null+undefined; ב-Map של
//    Dart מפתח-חסר וגם null שניהם `== null` ⇒ `call['dow'] != null` שקול-ביט. dow=0 (ראשון)
//    עובר (0 != null), בדיוק כמו המקור.
//  • `.replace('via:','')` = replaceFirst (JS-string-replace מחליף מופע-ראשון בלבד).
//  • `.slice(4)` על 'ivr:…' = substring(4) — הקידומת באורך 4, בטוח (כלל 5, אין substring שלילי).
//  • `.find(p=>p.startsWith('resp:'))?.slice(5) || manager` = `_pathValue` — מופע-ראשון,
//    slice באורך-הקידומת (בטוח), ריק/לא-נמצא ⇒ fallback. אין locale/getMonth/מיון מעורבים.
//  • sim/lines מוחזרים כהפניות (המקור בונה lines חדש; sim נשמר כמו-שהוא) — זהות נשמרת.
//  • הערת-חתימה: ב-JS ל-call/opts יש ברירת-מחדל {}; כאן הם positional-required (בכל
//    דוגמאות-החוזה הם נמסרים במפורש ⇒ זהה-התנהגות לכל קלט-נבדק).

const List<String> _dowHe = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

// truthiness של JS: null/false/''/0/NaN ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

// `value || fallback` על מחרוזת: מחזיר את הערך אם truthy, אחרת fallback.
String _orStr(dynamic v, String fallback) {
  if (v == null) return fallback;
  if (v is String) return v.isEmpty ? fallback : v;
  if (v is bool) return v ? v.toString() : fallback;
  if (v is num) return (v == 0) ? fallback : v.toString();
  return v.toString();
}

// `dest?.<node>?.ext?.join(', ')` ⇒ מחרוזת או null (כשחסר).
String? _extJoin(dynamic node) {
  if (node is Map) {
    final ext = node['ext'];
    if (ext is List) return ext.join(', ');
  }
  return null;
}

// `dest?.<node>?.<key>` (ext/box) ⇒ הערך או null.
dynamic _leaf(dynamic node, String key) => node is Map ? node[key] : null;

// סיבת-סגירה להצגה — רק ספציפית (חג/שבת/dnd/חירום), לא הגנרית "מחוץ-לשעות".
String _closedTag(dynamic reason) {
  if (reason != null &&
      reason != '' &&
      reason != 'מחוץ-לשעות' &&
      reason != 'שעות-פעילות') {
    return ' (' + reason.toString() + ')';
  }
  return '';
}

// `path.find(p=>p.startsWith(prefix))?.slice(cut) || fallback` — מופע-ראשון, בטוח.
String _pathValue(List path, String prefix, int cut, String fallback) {
  for (final p in path) {
    final s = p.toString();
    if (s.startsWith(prefix)) {
      final v = s.substring(cut);
      return v.isEmpty ? fallback : v;
    }
  }
  return fallback;
}

/// Human Hebrew narration (item 16) of what a caller experiences. Runs the injected
/// [simulateCall] socket and translates its route to emoji lines. Verbatim behaviour
/// of the JS source new/atoms/explain-call.mjs (`explainCall`). Returns a map
/// {outcome, reason, summary, lines, sim} — [sim] is the exact object the socket
/// returned (identity), summary = lines.join(' '). [simulateCall] and [featureOn]
/// are injected sockets (Law 1/3 — no internal imports).
Map<String, dynamic> explainCall(
  dynamic tenant,
  Map<String, dynamic> call,
  Map<String, dynamic> opts,
  Map<String, dynamic> Function(dynamic tenant, Map<String, dynamic> call, Map<String, dynamic> opts) simulateCall,
  bool Function(dynamic tenant, String key) featureOn,
) {
  final sim = simulateCall(tenant, call, opts); // R6-8: אופק-חלון מושחל
  final lines = <String>[];

  final dest = tenant is Map ? tenant['destinations'] : null;
  final office = _orStr(_extJoin(_leaf(dest, 'office')), '—');
  final manager = _orStr(_leaf(_leaf(dest, 'manager'), 'ext'), '—');
  final vm = _orStr(_leaf(_leaf(dest, 'voicemail'), 'box'), '—');

  final String when;
  if (call['dow'] != null) {
    when = 'יום ' + _dowHe[call['dow'] as int] + ' ' + _orStr(call['hhmm'], '');
  } else if (_truthy(call['date'])) {
    when = '${call['date']} ' + _orStr(call['hhmm'], '');
  } else {
    when = '';
  }

  if (call['direction'] == 'outbound') {
    lines.add('📞 חיוג-יוצא: ' + _orStr(call['did'], ''));
    final o = sim['outcome'];
    if (o == 'non-kosher-blocked') {
      lines.add('⛔ מצב-כשר: ניסיון-יציאה דרך SIM לא-כשר — נחסם.');
    } else if (o == 'no-such-sim') {
      lines.add('⚠️ הערוץ שנבחר לא-קיים.');
    } else if (o == 'no-default') {
      lines.add('⚠️ אין SIM ליציאת-ברירת-מחדל.');
    } else {
      lines.add('✅ יוצא דרך: ' + o.toString().replaceFirst('via:', ''));
    }
    return {
      'outcome': sim['outcome'],
      'reason': '',
      'summary': lines.join(' '),
      'lines': lines,
      'sim': sim,
    };
  }

  if (_truthy(call['callerId'])) {
    lines.add('📲 מתקשר ' +
        call['callerId'].toString() +
        (when.isNotEmpty ? ' · ' + when : ''));
  }

  final outcome = sim['outcome'];
  switch (outcome) {
    case 'unknown-did':
      lines.add('❓ המספר שחויג אינו מוכר למרכזייה — לא ינותב.');
      break;
    case 'blocked':
      lines.add((sim['path'] as List).contains('allowlist')
          ? '⛔ המתקשר אינו ברשימת-ההיתר (או חסוי) — נותק.'
          : '⛔ המתקשר ברשימת-החסומים — נותק.');
      break;
    case 'priority':
      lines.add('🆘 מוקד-מצוקה: מתקשר-בסיכון — מנותב ישירות לאחראי (' +
          _pathValue(sim['path'] as List, 'resp:', 5, manager) +
          '), עוקף שעות/חג.');
      break;
    case 'mourning':
      lines.add('🕯️ מצב-שבעה פעיל: מנותב למחליף (' +
          _pathValue(sim['path'] as List, 'sub:', 4, manager) +
          ').');
      break;
    case 'announcement':
      lines.add('📢 קו-הכרזה: משמיע הודעה מוקלטת ומנתק.');
      break;
    case 'office':
      lines.add('✅ בשעות-פעילות → מצלצל במשרד (' + office + ').');
      break;
    case 'ivr-menu':
      lines.add('✅ בשעות → תפריט-קולי (IVR) ממתין לבחירה.');
      break;
    case 'queue':
      lines.add('✅ בשעות → תור-המתנה עד שנציג מושך את השיחה.');
      break;
    case 'voicemail':
      lines.add('🌙 מחוץ-לשעות' +
          _closedTag(sim['reason']) +
          ' → מנהל (' +
          manager +
          ') → תא-קולי (' +
          vm +
          ').');
      break;
    case 'manager':
      lines.add('🌙 מחוץ-לשעות' +
          _closedTag(sim['reason']) +
          ' → מנהל (' +
          manager +
          ') (בלי תא-קולי).');
      break;
    case 'afterhours':
      // F11: מודע-voicemail — כשהתא-הקולי כבוי, אחרי-שעות מנגן צליל-תפוס ומנתק.
      final trg = (sim['path'] as List).contains('ivr-invalid')
          ? 'בחירה לא-תקינה ב-IVR'
          : 'אין-מענה במשרד';
      lines.add(featureOn(tenant, 'voicemail')
          ? '🌙 ' + trg + ' → מנהל (' + manager + ') → תא-קולי.'
          : '🌙 ' + trg + ' → מנהל (' + manager + ') → צליל-תפוס (אין תא-קולי).');
      break;
    default:
      final os = '${sim['outcome']}';
      if (os.startsWith('ivr:')) {
        lines.add('✅ בחירת-IVR → ' + os.substring(4) + '.');
      } else {
        lines.add('תוצאה: ' + os);
      }
  }

  return {
    'outcome': sim['outcome'],
    'reason': _orStr(sim['reason'], ''),
    'summary': lines.join(' '),
    'lines': lines,
    'sim': sim,
  };
}
