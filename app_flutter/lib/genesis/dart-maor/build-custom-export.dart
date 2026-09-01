// ⚛️ אטום-Dart (דרגת-חוזה) · buildCustomExport — בונה "דו"ח מותאם"
// (חוגים/אירועים/תומכות) לפי טווח-תאריכים ורשימת שדות נבחרים ⇒ שורות CSV
// (כותרת + נתונים). מוצא: maor/src/lib/customExport.ts:159-323 · המקור-הקדוש:
// new/atoms/build-custom-export.mjs (חולץ כלשונו) · חוזה: build-custom-export.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1/3): אובייקט-השקעים ExportSockets — 17 שקעים (expFieldDefs · featureOn ·
//   termOf · sessionsOf · enrollCount · hebParts · hebAnnualEq · hebDateFull · supCount ·
//   supIls · supUsd · supScore · supTier · stageLabel · evMeta · hebrewRecurring · dayNames).
//   העוזרים הפרטיים inR/isoOf/fmtD נשארו בקובץ — עוזרי-פנים (לא אטום-שכן).
//
// הערות-המרה (מקור→Dart, חוק-4):
//   • getMonth 0↔1: JS getMonth()+1 → ב-Dart DateTime.month כבר 1-מבוסס ⇒ בלי +1 ב-isoOf.
//   • תאריכי-האיטרציה נבנים ב-UTC-צהריים (T12:00) ⇒ הוספת-יום עקבית, בלי DST; מקביל ל-setDate.
//   • locale/פורמט: fmtD/isoOf שקעי-פורמט מפורשים, בלי Intl.
//   • truthiness: JS ‏|| ‏/‏&& על מחרוזות-ריקות/0/null ⇒ העוזר _truthy.
//   • ‏+x || 0 (המרת-מספר-סלחנית) ⇒ _plus; ‏x || 0 על מספר ⇒ _orZero.
//   • מוטביליות: משתני-הצבירה var; הקבועים final.

/// אובייקט-השקעים — כל 17 השכנים שהחוט קורא להם, מוזרקים כפרמטרים (חוק-3).
class ExportSockets {
  final List<Map<String, String>> Function(dynamic cfg, String target) expFieldDefs;
  final bool Function(dynamic cfg, String key) featureOn;
  final String Function(dynamic cfg, String key, String fallback) termOf;
  final List Function(dynamic course) sessionsOf;
  final int Function(dynamic db, dynamic courseId) enrollCount;
  final Map Function(DateTime d) hebParts;
  final bool Function(dynamic anchor, dynamic query) hebAnnualEq;
  final String Function(String iso) hebDateFull;
  final num Function(dynamic sp) supCount;
  final num Function(dynamic sp) supIls;
  final num Function(dynamic sp) supUsd;
  final num Function(dynamic sp, dynamic usdRate) supScore;
  final Map Function(num score) supTier;
  final String Function(dynamic cfg, dynamic stage) stageLabel;
  final Map evMeta; // EV_META
  final Set hebrewRecurring; // HEBREW_RECURRING
  final List dayNames; // DAY_NAMES

  const ExportSockets({
    required this.expFieldDefs,
    required this.featureOn,
    required this.termOf,
    required this.sessionsOf,
    required this.enrollCount,
    required this.hebParts,
    required this.hebAnnualEq,
    required this.hebDateFull,
    required this.supCount,
    required this.supIls,
    required this.supUsd,
    required this.supScore,
    required this.supTier,
    required this.stageLabel,
    required this.evMeta,
    required this.hebrewRecurring,
    required this.dayNames,
  });
}

// ---------- עוזרי-truthiness/מספר (סמנטיקת-JS) ----------

bool _truthy(dynamic x) {
  if (x == null) return false;
  if (x is bool) return x;
  if (x is num) return x != 0 && !(x is double && x.isNaN);
  if (x is String) return x.isNotEmpty;
  return true;
}

/// מקביל ל-`+x || 0` של JS — המרת-מספר סלחנית (מחרוזת ⇒ מספר; כישלון/NaN ⇒ 0).
num _plus(dynamic x) {
  if (x is num) return (x is double && x.isNaN) ? 0 : x;
  if (x is bool) return x ? 1 : 0;
  if (x is String) {
    final v = num.tryParse(x.trim());
    return v ?? 0;
  }
  return 0;
}

/// מקביל ל-`x || 0` של JS כשהערך מספרי (מספר ⇒ עצמו; אחר/null ⇒ 0).
num _orZero(dynamic x) => x is num ? x : 0;

// ---------- עוזרי-פנים (inR · isoOf · fmtD) — חולצו כלשונם מהמקור ----------

bool _inR(String? iso, Map r) {
  if (iso == null || iso.isEmpty) return false; // JS: !iso ('' falsy)
  final from = r['from'];
  final to = r['to'];
  if (_truthy(from) && iso.compareTo(from as String) < 0) return false;
  if (_truthy(to) && iso.compareTo(to as String) > 0) return false;
  return true;
}

String _p2(int n) => n.toString().padLeft(2, '0');

// getMonth-fix: DateTime.month כבר 1-מבוסס ⇒ בלי +1 (בניגוד ל-JS getMonth()+1).
String _isoOf(DateTime d) => '${d.year}-${_p2(d.month)}-${_p2(d.day)}';

String _fmtD(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final p = iso.split('-');
  return '${p[2]}/${p[1]}/${p[0]}';
}

/// בונה DateTime-UTC בצהריים מתוך iso 'YYYY-MM-DD' (מקביל ל-`new Date(iso+'T12:00:00')`,
/// אך ב-UTC כדי שהוספת-יום תהיה עקבית-קלנדרית בלי DST).
DateTime _parseIso(String iso) {
  final p = iso.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]), 12);
}

// ---------- החוט ----------

/// בונה שורות-CSV לדו"ח-מותאם. פלט: List של שורות; שורה[0]=כותרות, השאר=נתונים.
/// התנהגות זהה-ביט למקור-ה-JS `buildCustomExport`.
List<List<String>> buildCustomExport(dynamic cfg,
  Map db,
  String target,
  Map range,
  List<String> selectedKeys,
  ExportSockets s, Map<String, dynamic> T) {
  final defs = s
      .expFieldDefs(cfg, target)
      .where((f) => selectedKeys.contains(f['key']))
      .toList();

  final List<List<String>> rows = [
    defs.map((f) => f['label'] as String).toList()
  ];
  if (defs.isEmpty) return rows;

  List<String> pick(Map obj) => defs.map((f) {
        final v = obj[f['key']];
        return v == null ? '' : v.toString();
      }).toList();

  if (target == 'courses') {
    // אינדקס בני-משפחה לשמות התלמידים; טלפון — של הילד/ה, fallback לטלפון-המשפחה.
    final memberInfo = <dynamic, Map>{};
    for (final fam in (db['families'] as List)) {
      for (final m in (fam['members'] as List)) {
        final phone =
            _truthy(m['phone']) ? m['phone'] : (_truthy(fam['phone']) ? fam['phone'] : '');
        memberInfo[m['id']] = {'first': m['first'], 'phone': phone};
      }
    }
    final roomName = <dynamic, dynamic>{};
    for (final r in (db['rooms'] as List)) {
      roomName[r['id']] = r['name'];
    }

    for (final c in (db['courses'] as List)) {
      final ens = (db['enrollments'] as List).where((e) => e['courseId'] == c['id']).toList();
      var payN = 0;
      num paySum = 0;
      var absN = 0;
      num revenue = 0;
      for (final e in ens) {
        for (final p in (e['payments'] as List)) {
          revenue += _orZero(p['amount']);
          if (_inR(((p['date']) as String?), range)) {
            payN++;
            paySum += _orZero(p['amount']);
          }
        }
        for (final ab in (e['absences'] as List)) {
          if (_inR(((ab['date']) as String?), range)) absN++;
        }
      }
      dynamic t;
      for (final x in (db['teachers'] as List)) {
        if (x['id'] == c['teacherId']) {
          t = x;
          break;
        }
      }

      final gmin = c['gradeMin'];
      final gmax = c['gradeMax'];
      final grade = (_truthy(gmin) || _truthy(gmax))
          ? [gmin, gmax].where(_truthy).join('–')
          : '';

      final schedule = s
          .sessionsOf(c)
          .map((ss) => ((T['k2'] as String) +
                  (s.dayNames[((ss['day']) as int)] as String) +
                  (_truthy(ss['time']) ? ' ' + (ss['time'] as String) : ''))
              .trim())
          .join(' · ');

      final modelWord = c['model'] == 'punch'
          ? (T['k4'] as String)
          : c['model'] == 'half_year'
              ? (T['k6'] as String)
              : c['model'] == 'year'
                  ? (T['k8'] as String)
                  : (T['k9'] as String);

      final teacher = (_truthy(t?['name']) ? (t['name'] as String) : '') +
          (_truthy(t?['phone']) ? ' ' + (t['phone'] as String) : '');

      final students = ens
          .map((e) {
            final mi = memberInfo[e['memberId']];
            return _truthy(mi?['first']) ? mi!['first'] as String : '';
          })
          .where((x) => _truthy(x))
          .join(' · ');

      final studentsFull = ens
          .map((e) {
            final mi = memberInfo[e['memberId']];
            if (mi == null) return '';
            num paid = 0;
            for (final p in (e['payments'] as List? ?? const [])) {
              paid += _orZero(p['amount']);
            }
            final due = _orZero(e['totalDue']) - paid;
            final bal = due < 0 ? 0 : due;
            return (mi['first'] as String) +
                (_truthy(mi['phone']) ? ' ' + (mi['phone'] as String) : '') +
                (T['k10'] as String) +
                bal.toString();
          })
          .where((x) => _truthy(x))
          .join(' | ');

      final occ = '${s.enrollCount(db, c['id'])}/${_truthy(c['maxStudents']) ? c['maxStudents'] : '—'}';

      rows.add(pick({
        'name': c['name'],
        'teacher': teacher,
        'grade': grade,
        'audience': _truthy(c['audience']) ? c['audience'] : '',
        'room': _truthy(roomName[c['roomId']]) ? roomName[c['roomId']] : '',
        'schedule': schedule,
        'model': '$modelWord · ₪${_truthy(c['price']) ? c['price'] : 0}',
        'occ': occ,
        'students': students,
        'studentsFull': studentsFull,
        'pays': '$payN${(T['k11'] as String)}$paySum',
        'revenue': '₪$revenue',
        'abs': '$absN${(T['k12'] as String)}',
        'notes': _truthy(c['notes']) ? c['notes'] : '',
      }));
    }
    return rows;
  }

  if (target == 'events') {
    final bounded = _truthy(range['from']) && _truthy(range['to']);
    final List<Map> occ = [];
    for (final ev in (db['events'] as List)) {
      if (!_truthy(ev['date'])) continue;

      String famName = '';
      for (final fa in (db['families'] as List)) {
        if (fa['id'] == ev['famId']) {
          famName = _truthy(fa['name']) ? fa['name'] as String : '';
          break;
        }
      }

      final rec = {
        'title': ev['title'],
        'type': _truthy(ev['customType'])
            ? ev['customType']
            : (s.evMeta[ev['type']] as Map)['label'],
        'time': _truthy(ev['time']) ? ev['time'] : '',
        'fam': famName,
        'notes': _truthy(ev['notes']) ? ev['notes'] : '',
        'done': ev['done'],
      };

      if (s.hebrewRecurring.contains(ev['type']) && bounded) {
        final oh = s.hebParts(_parseIso(ev['date'] as String));
        final d0 = _parseIso(range['from'] as String);
        final d1raw = _parseIso(range['to'] as String);
        // תקרת-ימים (עקבי עם courseDaily MAX_DAYS) — טעות בשנת "עד" הקפיאה לולאה יום-יום.
        const capDays = 4000;
        final capped = d0.add(const Duration(days: capDays));
        final d1 = d1raw.isBefore(capped) ? d1raw : capped;
        for (var dd = d0; !dd.isAfter(d1); dd = dd.add(const Duration(days: 1))) {
          // חסם תחתון iso≥ev.date (מניעת-רפאים) + נרמול-אדר דרך hebAnnualEq (עוגן=oh, נסרק=dd).
          if (_isoOf(dd).compareTo(ev['date'] as String) >= 0 &&
              s.hebAnnualEq(oh, s.hebParts(dd))) {
            occ.add({...rec, 'date': _isoOf(dd)});
          }
        }
      } else if (_inR(((ev['date']) as String?), range) ||
          (!_truthy(range['from']) && !_truthy(range['to']))) {
        occ.add({...rec, 'date': ev['date']});
      }
    }
    occ.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    for (final o in occ) {
      rows.add(pick({
        'title': o['title'],
        'type': o['type'],
        'hdate': s.hebDateFull(o['date'] as String),
        'gdate': _fmtD(o['date'] as String),
        'time': o['time'],
        'fam': o['fam'],
        'notes': o['notes'],
        'done': _truthy(o['done']) ? (T['k14'] as String) : (T['k15'] as String),
      }));
    }
    return rows;
  }

  // supporters
  final ayinOn = s.featureOn(cfg, 'supporters.ayin');
  for (final sp in (db['supporters'] as List)) {
    final dons = (sp['donations'] as List).where((d) => _inR(((d['date']) as String?), range)).toList();
    final a = sp['ayin'];
    final answers = a != null
        ? (a['answers'] as List).where((x) => _inR(((x['date']) as String?), range)).toList()
        : const [];
    final touchedInRange = ayinOn &&
        a != null &&
        (_inR(((a['lastTouch']) as String?), range) ||
            (a['log'] as List).any((l) => _inR(((l['date']) as String?), range)));
    if (!(dons.isNotEmpty || answers.isNotEmpty || touchedInRange)) continue;

    num ils = 0;
    num usd = 0;
    for (final d in dons) {
      if (d['cur'] != '\$') {
        ils += _plus(d['amount']);
      } else {
        usd += _plus(d['amount']);
      }
    }

    final donationsTerm = s.termOf(cfg, 'entity.donations', (T['k18'] as String));
    final Map obj = {
      'name': sp['name'],
      'phone': _truthy(sp['phone']) ? sp['phone'] : '',
      'email': _truthy(sp['email']) ? sp['email'] : '',
      'address': _truthy(sp['address']) ? sp['address'] : '',
      'city': _truthy(sp['city']) ? sp['city'] : '',
      'cat': _truthy(sp['cat']) ? sp['cat'] : '',
      'forWho': _truthy(sp['forWho']) ? sp['forWho'] : '',
      'dons': '${dons.length} $donationsTerm · ₪$ils${_truthy(usd) ? ' + \$$usd' : ''}',
      // "כל-הזמן" = הצבירה המוצגת (קבלות + היסטוריה) — הכרעת-בעלים 9.8 "לכולל".
      'donsAll':
          '${s.supCount(sp)} $donationsTerm · ₪${s.supIls(sp)}${_truthy(s.supUsd(sp)) ? ' + \$${s.supUsd(sp)}' : ''}',
      'tier': s.supTier(s.supScore(sp, db['usdRate']))['label'],
      'notes': _truthy(sp['notes']) ? sp['notes'] : '',
    };
    if (ayinOn && a != null) {
      obj['stage'] = s.stageLabel(cfg, a['stage']);
      obj['names'] = (a['names'] as List).map((n) {
        final eyes = n['eyes'];
        final eyesPart = (eyes != '' && eyes != null) ? ' ·$eyes' : '';
        final donePart = _truthy(n['done']) ? ' ✓' : '';
        return '${n['name']}$eyesPart$donePart';
      }).join(' · ');
      obj['eyesTotal'] =
          (a['names'] as List).fold<num>(0, (x, n) => x + _plus(n['eyes'])).toString();
      obj['paid'] = _truthy(a['paid']) ? (T['k14'] as String) : (T['k15'] as String);
      obj['answers'] = answers.map((x) => x['note']).join(' | ');
      obj['next'] = _truthy(a['nextTalk'])
          ? _fmtD(a['nextTalk'] as String) +
              (_truthy(a['nextTalkTime']) ? ' ' + (a['nextTalkTime'] as String) : '')
          : '';
    }
    rows.add(pick(obj));
  }
  return rows;
}
