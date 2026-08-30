/// חוט · telephony-to-tenant — תצורת-אשף-טלפוניה ⇒ raw-tenant למנוע (config-as-data);
/// ערוצי-שער מוקצים אוטומטית ל-SIM-ים.
/// חוזה: telephony-to-tenant.contract.md
/// Port זהה-ביט של new/atoms/telephony-to-tenant.mjs. אפס import של אטום אחר.

/// מפות-קבע (חלק מהמכונה) — kind→onramp · kind→channels.
const Map<String, String> _onramp = {
  'sim': 'sim-in-gateway',
  'virtual': 'customer-forward',
  'whatsapp': 'device-link',
};

/// כמו ב-JS: אותה רשימה משותפת-רפרנס לכל הקווים מאותו kind.
const Map<String, List<String>> _channels = {
  'sim': ['voice'],
  'virtual': ['voice'],
  'whatsapp': ['whatsapp'],
};

/// truthiness של JS (חוק 7): null/false/0/-0/NaN/'' כוזבים.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    (v is String && v.isEmpty);

/// קבוצת-הרווחים של ES (חוק 16): WhiteSpace + LineTerminator בלבד —
/// U+0085/U+180E אינם נגזמים (בניגוד ל-String.trim של Dart).
const String _esWs = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680'
    '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A'
    '\u2028\u2029\u202F\u205F\u3000\uFEFF';

String _jsTrim(String s) {
  var start = 0;
  var end = s.length;
  while (start < end && _esWs.contains(s[start])) {
    start++;
  }
  while (end > start && _esWs.contains(s[end - 1])) {
    end--;
  }
  return s.substring(start, end);
}

Map<String, dynamic> telephonyToTenant(dynamic tc, dynamic orgName, dynamic tenantId, Map<String, dynamic> T) {
  var gw = 0;
  final rawNumbers = (tc['numbers'] ?? []) as List;
  final numbers = <Map<String, dynamic>>[];
  for (final n in rawNumbers) {
    // JS: .filter((n) => n.e164 && n.e164.trim())
    final e164 = n['e164'];
    if (_falsy(e164)) continue;
    final trimmed = _jsTrim(e164 as String);
    if (trimmed.isEmpty) continue;
    final base = <String, dynamic>{
      'id': n['id'],
      'e164': trimmed,
      'label': _falsy(n['label']) ? n['id'] : n['label'],
      'type': n['kind'],
      'onramp': _onramp[n['kind']],
      'channels': _channels[n['kind']],
    };
    // JS: ...(n.kosher ? { kosher: true } : {}) — מפתח קיים רק כש-truthy.
    if (!_falsy(n['kosher'])) base['kosher'] = true;
    if (n['kind'] == 'sim') {
      gw += 1;
      base['gatewayChannel'] = gw;
    }
    numbers.add(base);
  }

  Map<String, dynamic>? firstSim;
  for (final n in numbers) {
    if (n['onramp'] == 'sim-in-gateway') {
      firstSim = n;
      break;
    }
  }

  final features = <String, dynamic>{
    'voice.kosher': tc['kosherMode'],
    'calendar.hebrew': tc['hebrewCalendar'],
    'calendar.shabbat': tc['shabbat'],
    'calendar.fasts': tc['fasts'],
    'calendar.zmanim': tc['zmanim'],
    'voicemail': tc['voicemail'],
  };

  // JS: [...tc.officeDays].sort((a, b) => a - b) — עותק, קומפרטור a-b מדויק.
  final days = List<dynamic>.from(tc['officeDays'] as List)
    ..sort((a, b) {
      final num d = (a as num) - (b as num);
      return d < 0 ? -1 : (d > 0 ? 1 : 0);
    });

  final dynamic defaultNumberId = firstSim != null
      ? firstSim['id']
      : (numbers.isNotEmpty ? (numbers[0]['id'] ?? 'n1') : 'n1');

  final result = <String, dynamic>{
    'tenantId': tenantId,
    'orgName': _falsy(orgName) ? T['k7']! : orgName,
    'timezone': 'Asia/Jerusalem',
  };
  // JS: ...(tc.city ? { city: tc.city } : {}) — בין timezone ל-officeHours.
  if (!_falsy(tc['city'])) result['city'] = tc['city'];
  result['officeHours'] = <String, dynamic>{
    'days': days,
    'start': tc['officeStart'],
    'end': tc['officeEnd'],
  };
  result['numbers'] = numbers;
  result['destinations'] = <String, dynamic>{
    'office': <String, dynamic>{
      'ext': [tc['officeExt']],
      'ringSeconds': 25,
    },
    'manager': <String, dynamic>{
      'ext': tc['managerExt'],
      'ringSeconds': 30,
    },
    'voicemail': <String, dynamic>{'box': tc['vmBox']},
  };
  result['outbound'] = <String, dynamic>{'defaultNumberId': defaultNumberId};
  result['cti'] = <String, dynamic>{'org': tenantId, 'mode': 'directory'};
  result['features'] = features;
  return result;
}
