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
String _closedTag(dynamic reason, Map<String, String> T) {
  if (reason != null &&
      reason != '' &&
      reason != T['k1']! &&
      reason != T['k2']!) {
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
Map<String, dynamic> explainCall(dynamic tenant,
  Map<String, dynamic> call,
  Map<String, dynamic> opts,
  Map<String, dynamic> Function(dynamic tenant, Map<String, dynamic> call, Map<String, dynamic> opts) simulateCall,
  bool Function(dynamic tenant, String key) featureOn, List<String> DOW_HE, Map<String, String> T) {
  final sim = simulateCall(tenant, call, opts); // R6-8: אופק-חלון מושחל
  final lines = <String>[];

  final dest = tenant is Map ? tenant['destinations'] : null;
  final office = _orStr(_extJoin(_leaf(dest, 'office')), '—');
  final manager = _orStr(_leaf(_leaf(dest, 'manager'), 'ext'), '—');
  final vm = _orStr(_leaf(_leaf(dest, 'voicemail'), 'box'), '—');

  final String when;
  if (call['dow'] != null) {
    when = T['k32']! + DOW_HE[call['dow'] as int] + ' ' + _orStr(call['hhmm'], '');
  } else if (_truthy(call['date'])) {
    when = '${call['date']} ' + _orStr(call['hhmm'], '');
  } else {
    when = '';
  }

  if (call['direction'] == 'outbound') {
    lines.add(T['k33']! + _orStr(call['did'], ''));
    final o = sim['outcome'];
    if (o == 'non-kosher-blocked') {
      lines.add(T['k5']!);
    } else if (o == 'no-such-sim') {
      lines.add(T['k7']!);
    } else if (o == 'no-default') {
      lines.add(T['k9']!);
    } else {
      lines.add(T['k34']! + o.toString().replaceFirst('via:', ''));
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
    lines.add(T['k36']! +
        call['callerId'].toString() +
        (when.isNotEmpty ? ' · ' + when : ''));
  }

  final outcome = sim['outcome'];
  switch (outcome) {
    case 'unknown-did':
      lines.add(T['k11']!);
      break;
    case 'blocked':
      lines.add((sim['path'] as List).contains('allowlist')
          ? T['k14']!
          : T['k15']!);
      break;
    case 'priority':
      lines.add(T['k37']! +
          _pathValue(sim['path'] as List, 'resp:', 5, manager) +
          T['k39']!);
      break;
    case 'mourning':
      lines.add(T['k40']! +
          _pathValue(sim['path'] as List, 'sub:', 4, manager) +
          ').');
      break;
    case 'announcement':
      lines.add(T['k19']!);
      break;
    case 'office':
      lines.add(T['k42']! + office + ').');
      break;
    case 'ivr-menu':
      lines.add(T['k22']!);
      break;
    case 'queue':
      lines.add(T['k24']!);
      break;
    case 'voicemail':
      lines.add(T['k43']! +
          _closedTag(sim['reason'], T) +
          T['k44']! +
          manager +
          T['k45']! +
          vm +
          ').');
      break;
    case 'manager':
      lines.add(T['k43']! +
          _closedTag(sim['reason'], T) +
          T['k44']! +
          manager +
          T['k46']!);
      break;
    case 'afterhours':
      // F11: מודע-voicemail — כשהתא-הקולי כבוי, אחרי-שעות מנגן צליל-תפוס ומנתק.
      final trg = (sim['path'] as List).contains('ivr-invalid')
          ? T['k29']!
          : T['k30']!;
      lines.add(featureOn(tenant, 'voicemail')
          ? '🌙 ' + trg + T['k44']! + manager + T['k47']!
          : '🌙 ' + trg + T['k44']! + manager + T['k48']!);
      break;
    default:
      final os = '${sim['outcome']}';
      if (os.startsWith('ivr:')) {
        lines.add(T['k49']! + os.substring(4) + '.');
      } else {
        lines.add(T['k50']! + os);
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
