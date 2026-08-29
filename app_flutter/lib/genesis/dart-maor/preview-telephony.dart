// ⚛️ אטום-Dart (דרגת-חוזה) · previewTelephony — תצוגה-מקדימה חיה לקונפיג-טלפוניה
//    (סימולטור-שיחה על 3 תרחישים + דוח-אמון). downstream, קריאה-בלבד, אפס PBX.
// מוצא: maor/src/components/telephony/lib.ts:133-185 · המקור: new/atoms/preview-telephony.mjs
// חוזה: new/atoms/preview-telephony.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1 — קריאות-השכן הוזרקו כפרמטרים, בסדר הזה):
//   telephonyToTenant(tc, orgName, tenantId) ⇒ raw · anchorToday() ⇒ ISO-string
//   validateTenant(raw) ⇒ {ok,errors,warnings,tenant?} · buildTenant(raw,opts) ⇒ {ok,warnings?,files?}
//   explainCall(tenant,call,opts) ⇒ {summary,outcome} · trustReport(built) ⇒ {grade,score,ready,failing}
//
// הערות-המרה (JS→Dart, לפי DART-PORTING-RULES כלל-7 truthiness · כלל-2 null≠undefined):
//   • `!v.ok`, `if (built.ok)` ו-`a || b || c` הם truthiness של JS ⇒ שקע `_truthy`/`_jsOr`
//     (undefined ו-null שניהם falsy כמו ב-`||`; מערך/מפה ריקים truthy כמו ב-JS).
//   • אין locale/פורמט/getMonth/מוטביליות/תאריכים כאן — anchorToday הוא שקע.

/// תצוגה-מקדימה של קונפיג-טלפוניה. ולידציה-נכשלת ⇒ יציאה-מוקדמת (build/explain/trust לא נקראים).
/// התנהגות זהה-ביט למקור-ה-JS previewTelephony.
Map<String, dynamic> previewTelephony(
  Map<String, dynamic> tc,
  String orgName,
  String tenantId,
  dynamic Function(Map<String, dynamic>, String, String) telephonyToTenant,
  String Function() anchorToday,
  Map<String, dynamic> Function(dynamic) validateTenant,
  Map<String, dynamic> Function(dynamic, Map<String, dynamic>) buildTenant,
  Map<String, dynamic> Function(dynamic, Map<String, dynamic>, Map<String, dynamic>)
      explainCall,
  Map<String, dynamic> Function(dynamic) trustReport,
 {required String Function(String) term}) {
  final raw = telephonyToTenant(tc, orgName, tenantId);
  final anchor = anchorToday();
  final opts = <String, dynamic>{'anchorDate': anchor, 'calendarWindow': 400};

  final v = validateTenant(raw);
  if (!_truthy(v['ok'])) {
    return <String, dynamic>{
      'ok': false,
      'errors': v['errors'],
      'warnings': v['warnings'],
      'rows': <dynamic>[],
      'trust': null,
      'files': null,
    };
  }
  final tenant = v['tenant'];
  final built = buildTenant(raw, opts);

  // מספר-הקול: הראשון מסוג sim/virtual, ואם אין — המספר הראשון; ואם אין e164 ⇒ '' (JS `?.e164 || ''`).
  final numbers = (tc['numbers'] as List?) ?? const [];
  dynamic found;
  for (final n in numbers) {
    final kind = (n as Map)['kind'];
    if (kind == 'sim' || kind == 'virtual') {
      found = n;
      break;
    }
  }
  final picked = found ?? (numbers.isNotEmpty ? numbers[0] : null);
  final e164 = picked == null ? null : (picked as Map)['e164'];
  final String voiceDid = _truthy(e164) ? e164 as String : '';

  const caller = '050-1234567';
  // תרחישים מייצגים: יום-חול בשעות · יום-חול אחרי-שעות · שבת.
  final scenarios = <Map<String, dynamic>>[
    {
      'when': term('yvm-shlyshy-bshavt'),
      'call': {'did': voiceDid, 'callerId': caller, 'dow': 2, 'hhmm': '10:00'},
    },
    {
      'when': term('yvm-shlyshy-achryshavt'),
      'call': {'did': voiceDid, 'callerId': caller, 'dow': 2, 'hhmm': '20:00'},
    },
    {
      'when': term('shbt'),
      'call': {'did': voiceDid, 'callerId': caller, 'dow': 6, 'hhmm': '11:00'},
    },
  ];
  final rows = <Map<String, dynamic>>[];
  for (final s in scenarios) {
    final e = explainCall(tenant, s['call'] as Map<String, dynamic>, opts);
    rows.add(<String, dynamic>{
      'when': s['when'],
      'caller': caller,
      'summary': e['summary'],
      'outcome': e['outcome'],
    });
  }

  Map<String, dynamic>? trust;
  if (_truthy(built['ok'])) {
    final tr = trustReport(built);
    final failing = (tr['failing'] as List).map((c) {
      final cm = c as Map;
      return <String, dynamic>{
        'label': cm['label'],
        'detail': cm['detail'],
        'severity': cm['severity'],
      };
    }).toList();
    trust = <String, dynamic>{
      'grade': tr['grade'],
      'score': tr['score'],
      'ready': tr['ready'],
      'failing': failing,
    };
  }

  return <String, dynamic>{
    'ok': true,
    'errors': <dynamic>[],
    'warnings': _jsOr(built['warnings'], _jsOr(v['warnings'], <dynamic>[])),
    'rows': rows,
    'trust': trust,
    'files': _jsOr(built['files'], null),
  };
}

/// truthiness של JS: null/undefined/false/0/NaN/'' ⇒ false; מערך/מפה (גם ריקים) ⇒ true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// `a || b` של JS — הערך-הראשון ה-truthy.
dynamic _jsOr(dynamic a, dynamic b) => _truthy(a) ? a : b;
