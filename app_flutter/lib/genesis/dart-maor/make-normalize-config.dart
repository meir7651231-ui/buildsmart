// ⚛️ חוט-מפעל · make-normalize-config — מחטא-הקונפיג הראשי (לב ה-White-label).
// המרה מ-JS (new/atoms/make-normalize-config.mjs) — התנהגות זהה-לחלוטין (חוק-4).
// מוצא: maor/src/lib/config.ts:515-631 + normalizeFirebase הפרטי (128-145).
// טוהר: top-level, אפס import (רק dart-core). התלויות שוקעו כפרמטרים (חוק-1).
//
// deps (שקעים): DEFAULT_CONFIG · INTEGRATION_KEYS · INTEGRATION_SETTING_KEYS ·
//   MOTION_KEYS · TEMPLATE_KEYS · normalizeSite · normalizeTelephony.
// makeNormalizeConfig(...) ⇒ normalizeConfig(raw) ⇒ Map<String,dynamic>? (null=זבל).
//
// הערות-המרה (DART-PORTING-RULES):
//  · כלל 2 (null≠undefined): "delete cfg.x" של JS ⇒ cfg.remove('x'); "in" ⇒ containsKey.
//  · כלל 5 (substring שלילי/גלישה): slice(0,N) של JS סלחן ⇒ שקע _sliceMax בטוח-אורך.
//  · כלל 7 (truthiness): `!raw`/`c.slug &&`/`v.trim()` ⇒ תנאים-מפורשים (is/isNotEmpty).
//  · `typeof x==='object' && !Array.isArray` ⇒ `x is Map` (List/null אינם Map).
//  · spread `{...m}` ⇒ Map.from (עותק-רדוד, טוהר-קלט).
//  · אין locale/getMonth/תאריך/מודולו באטום הזה.

/// slice(0,n) בטוח — JS `str.slice(0,n)` לא-זורק גם כש-len<n; Dart substring כן (כלל 5).
String _sliceMax(String s, int n) => s.length <= n ? s : s.substring(0, n);

/// נרמול שדה firebase — נשמר רק אם ארבעת שדות-החובה מחרוזות לא-ריקות. null=undefined.
Map<String, dynamic>? _normalizeFirebase(dynamic raw) {
  if (raw is! Map) return null;
  final f = raw;
  final req = [f['apiKey'], f['authDomain'], f['projectId'], f['appId']];
  final ok = req.every((v) => v is String && v.isNotEmpty);
  if (!ok) return null;
  final out = <String, dynamic>{
    'apiKey': f['apiKey'],
    'authDomain': f['authDomain'],
    'projectId': f['projectId'],
    'appId': f['appId'],
  };
  final sb = f['storageBucket'];
  if (sb is String && sb.isNotEmpty) out['storageBucket'] = sb;
  final ms = f['messagingSenderId'];
  if (ms is String && ms.isNotEmpty) out['messagingSenderId'] = ms;
  return out;
}

/// צבע-CSS בטוח בלבד (hex/rgb/hsl/keyword) — חוסם הזרקת url() ל-`--accent`.
/// מוצא: maor/src/lib/config.ts:866-872 כלשונו (מוטמע, חוק-1).
bool _isSafeAccent(String a) {
  return RegExp(r'^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(a) ||
      RegExp(r'^(?:rgb|rgba|hsl|hsla)\([0-9.,%\s/]+\)$', caseSensitive: false).hasMatch(a) ||
      RegExp(r'^[a-zA-Z]{3,20}$').hasMatch(a);
}

/// עותק-רדוד של Map אם v הוא Map (לא-List, לא-null); אחרת {}.
Map<String, dynamic> _objCopyOrEmpty(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// יצרן חוט-המפעל — מחזיר את normalizeConfig המחווט לשקעיו.
Map<String, dynamic>? Function(dynamic) makeNormalizeConfig({
  required Map<String, dynamic> DEFAULT_CONFIG,
  required List<String> INTEGRATION_KEYS,
  required Map<String, List<String>> INTEGRATION_SETTING_KEYS,
  required List<String> MOTION_KEYS,
  required List<String> TEMPLATE_KEYS,
  required Map<String, dynamic>? Function(dynamic) normalizeSite,
  required Map<String, dynamic>? Function(dynamic) normalizeTelephony,
}) {
  Map<String, dynamic>? normalizeConfig(dynamic raw) {
    if (raw is! Map) return null;
    final c = Map<String, dynamic>.from(raw);
    if (c['slug'] is! String && c['orgName'] is! String && c['theme'] is! String) {
      return null;
    }

    // cfg = { ...DEFAULT_CONFIG, ...c, <דריסות-מפורשות> }
    final cfg = <String, dynamic>{}
      ..addAll(DEFAULT_CONFIG)
      ..addAll(c);

    cfg['slug'] =
        (c['slug'] is String && (c['slug'] as String).isNotEmpty) ? c['slug'] : DEFAULT_CONFIG['slug'];
    cfg['orgName'] = c['orgName'] is String ? c['orgName'] : DEFAULT_CONFIG['orgName'];
    cfg['theme'] =
        (c['theme'] is String && (c['theme'] as String).isNotEmpty) ? c['theme'] : DEFAULT_CONFIG['theme'];
    cfg['modules'] = _objCopyOrEmpty(c['modules']);
    cfg['features'] = _objCopyOrEmpty(c['features']);
    cfg['terms'] = _objCopyOrEmpty(c['terms']);

    final fb = _normalizeFirebase(c['firebase']);
    if (fb != null) {
      cfg['firebase'] = fb;
    } else {
      cfg.remove('firebase');
    }

    // דגלי true-מפורש — רק true נשמר; כל השאר מוסר (spread היה מעביר ערך-זר).
    if (c['cloudRoot'] == true) {
      cfg['cloudRoot'] = true;
    } else {
      cfg.remove('cloudRoot');
    }
    if (c['donationSplit'] == true) {
      cfg['donationSplit'] = true;
    } else {
      cfg.remove('donationSplit');
    }
    if (c['supporterEnforce'] == true) {
      cfg['supporterEnforce'] = true;
    } else {
      cfg.remove('supporterEnforce');
    }

    // הרחבות — allowlist בלבד; רשומת {enabled:bool}; הגדרות-מחרוזת מ-SETTING_KEYS (trim).
    final intsRaw = c['integrations'];
    if (intsRaw is Map) {
      final ints = <String, dynamic>{};
      intsRaw.forEach((k, v) {
        if (!INTEGRATION_KEYS.contains(k)) return;
        if (v is Map && v['enabled'] is bool) {
          final entry = <String, dynamic>{'enabled': v['enabled']};
          for (final s in (INTEGRATION_SETTING_KEYS[k] ?? const <String>[])) {
            final sv = v[s];
            if (sv is String && sv.trim().isNotEmpty) entry[s] = sv.trim();
          }
          ints['$k'] = entry;
        }
      });
      if (ints.isNotEmpty) {
        cfg['integrations'] = ints;
      } else {
        cfg.remove('integrations');
      }
    } else {
      cfg.remove('integrations');
    }

    // תבניות-הודעה — allowlist, מחרוזות בלבד, תקרת-אורך 500.
    final tplRaw = c['templates'];
    if (tplRaw is Map) {
      final tpl = <String, dynamic>{};
      tplRaw.forEach((k, v) {
        if (!TEMPLATE_KEYS.contains(k)) return;
        if (v is String && v.trim().isNotEmpty) tpl['$k'] = _sliceMax(v.trim(), 500);
      });
      if (tpl.isNotEmpty) {
        cfg['templates'] = tpl;
      } else {
        cfg.remove('templates');
      }
    } else {
      cfg.remove('templates');
    }

    // מיילי-אדמין — מחרוזות לא-ריקות בלבד; ריק/לא-מערך ⇒ מוסר.
    if (c['adminEmails'] is List) {
      final admins = (c['adminEmails'] as List)
          .where((e) => e is String && e.trim() != '')
          .toList();
      if (admins.isNotEmpty) {
        cfg['adminEmails'] = admins;
      } else {
        cfg.remove('adminEmails');
      }
    } else {
      cfg.remove('adminEmails');
    }

    // תפקידים — מפת מורות מייל→teacherId, זוגות-מחרוזת לא-ריקים בלבד.
    final rolesRaw = c['roles'];
    final teachersRaw = (rolesRaw is Map && rolesRaw['teachers'] is Map) ? rolesRaw['teachers'] as Map : null;
    if (teachersRaw != null) {
      final teachers = <String, dynamic>{};
      teachersRaw.forEach((k, v) {
        if (k is String && k.trim().isNotEmpty && v is String && v.trim().isNotEmpty) {
          teachers[k.trim()] = v.trim();
        }
      });
      if (teachers.isNotEmpty) {
        cfg['roles'] = {'teachers': teachers};
      } else {
        cfg.remove('roles');
      }
    } else {
      cfg.remove('roles');
    }

    // טלפוניה — דרך השקע; חסר/לא-אובייקט ⇒ מוסר.
    final tel = normalizeTelephony(c['telephony']);
    if (tel != null) {
      cfg['telephony'] = tel;
    } else {
      cfg.remove('telephony');
    }

    // אימוג'י-ארגון — מחרוזת קצרה (≤12); ריק/לא-מחרוזת ⇒ מוסר.
    final emoji = c['emoji'];
    if (emoji is String && emoji.trim().isNotEmpty) {
      cfg['emoji'] = _sliceMax(emoji.trim(), 12);
    } else {
      cfg.remove('emoji');
    }

    // סגנון-תנועה — allowlist בלבד.
    final motion = c['motion'];
    if (motion is String && MOTION_KEYS.contains(motion)) {
      cfg['motion'] = motion;
    } else {
      cfg.remove('motion');
    }

    // צבע-מותאם-ידני — רק true.
    if (c['accentCustom'] == true) {
      cfg['accentCustom'] = true;
    } else {
      cfg.remove('accentCustom');
    }

    // חיטוי accent (נחיל-אבטחה 16.8) — נקרא מ-cfg (spread של c/DEFAULT), צבע-CSS בלבד.
    final accent = cfg['accent'];
    if (accent is String && _isSafeAccent(accent.trim())) {
      cfg['accent'] = accent.trim();
    } else {
      cfg.remove('accent');
    }

    // אתר-ציבורי — דרך השקע; חסר/לא-אובייקט ⇒ מוסר.
    final site = normalizeSite(c['site']);
    if (site != null) {
      cfg['site'] = site;
    } else {
      cfg.remove('site');
    }

    // הגנת-מקור — allowlist מארחים (עד 12, כ"א ≤120).
    if (c['allowedHosts'] is List) {
      final hosts = (c['allowedHosts'] as List)
          .where((h) => h is String && h.trim().isNotEmpty)
          .map((h) => _sliceMax((h as String).trim(), 120))
          .take(12)
          .toList();
      if (hosts.isNotEmpty) {
        cfg['allowedHosts'] = hosts;
      } else {
        cfg.remove('allowedHosts');
      }
    } else {
      cfg.remove('allowedHosts');
    }

    return cfg;
  }

  return normalizeConfig;
}
