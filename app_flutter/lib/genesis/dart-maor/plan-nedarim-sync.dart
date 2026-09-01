// ⚛️ אטום-Dart (דרגת-חוזה) · planNedarimSync — מנוע-הסנכרון נדרים→מאור (תוכנית טהורה).
// מוצא: maor/src/lib/nedarimSync.ts:541-694 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/plan-nedarim-sync.mjs · החוזה: plan-nedarim-sync.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core/dart:math). עשרת השכנים
//        (nameSortKey/keysOf/normId/supFromDonor/supFromCharge/histDedupKey/chargeDedupKey/
//         chargeToHist/withNedarimHok/curOf) = שקעי-פרמטר (חוק-1 — אפס import פנימי).
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//  • truthiness של JS (`if(!nk)`, `if(v && ...)`, `d.toremId||d.name`) מומר ל-`_truthy`/`_falsy`
//    (null/false/0/''/NaN ⇒ falsy) ולשרשרת-`_or` (מחזירה ראשון-truthy כמו `a||b||''`).
//  • `Map.get(k)` שמחזיר undefined כשחסר ⇒ `map[k]` שמחזיר null; `i != null`/`prev == null`
//    נשמרים כי אינדקסים תמיד ≥0 (ואף פעם לא null-מפורש) — 0 חוקי, -1 = עמום.
//  • spread `{...s}` ⇒ `Map.from`; `s.hist ? [...s.hist] : undefined` ⇒ שכפול-רשימה כשלא-null.
//  • `c.amount === 0`/`< 0` נשמרים מספרית; refund מחייב `amt is num` (null<0 של JS = false).
//  • `[...(hist||[]), x]` ⇒ שכפול-רשימה + הוספה (spread), אפס-מוטציה על הרשימה-הקיימת.
//  • אין locale/פורמט/getMonth/מודולו-שלילי בגוף-הזה — הם חיים בשקעים (בדיקת-הזהב).

/// Pure sync-plan engine (Nedarim → Maor). Verbatim of the JS source
/// new/atoms/plan-nedarim-sync.mjs. Ten neighbours are injected as sockets (Law 1).
/// Returns { supporters, summary, newNames, updatedNames, handledChargeIds }.
Map<String, dynamic> planNedarimSync(
  List<Map<String, dynamic>> existing,
  List<Map<String, dynamic>> donors,
  List<Map<String, dynamic>> charges,
  Map<String, dynamic> opts,
  String Function(dynamic s) nameSortKey,
  List<String> Function(Map<String, dynamic> o) keysOf,
  String Function(dynamic s) normId,
  Map<String, dynamic> Function(Map<String, dynamic> d) supFromDonor,
  Map<String, dynamic> Function(Map<String, dynamic> c, int seq) supFromCharge,
  String Function(Map<String, dynamic> h) histDedupKey,
  String Function(Map<String, dynamic> c) chargeDedupKey,
  Map<String, dynamic> Function(Map<String, dynamic> c) chargeToHist,
  Map<String, dynamic> Function(Map<String, dynamic> sp, Map<String, dynamic> c)
      withNedarimHok,
  String Function(Map<String, dynamic> c) curOf,
) {
  // `existing.map(s => ({...s, hist: s.hist ? [...s.hist] : undefined}))`
  final List<Map<String, dynamic>> out = existing.map((s) {
    final m = Map<String, dynamic>.from(s);
    final h = s['hist'];
    m['hist'] = h != null ? List<dynamic>.from(h as List) : null;
    return m;
  }).toList();

  final Map<String, int> keyIndex = {}; // key → index ב-out
  final Map<String, int> nameIndex = {}; // -1 = שם עמום (>1 כרטיס)

  String nkey(dynamic s) => nameSortKey(s ?? '');

  void registerName(int idx) {
    final nk = nkey(out[idx]['name']);
    if (nk.isEmpty) return; // JS `if(!nk)`
    final prev = nameIndex[nk];
    if (prev == null) {
      nameIndex[nk] = idx;
    } else if (prev != idx) {
      nameIndex[nk] = -1;
    }
  }

  void register(int idx) {
    for (final k in keysOf(out[idx])) {
      if (!keyIndex.containsKey(k)) keyIndex[k] = idx;
    }
    registerName(idx);
  }

  for (var i = 0; i < out.length; i++) {
    register(i);
  }

  int findIdx(List<String> keys) {
    for (final k in keys) {
      final i = keyIndex[k];
      if (i != null) return i;
    }
    return -1;
  }

  int findByName(dynamic name) {
    final i = nameIndex[nkey(name)];
    return (i != null && i >= 0) ? i : -1;
  }

  final Map<String, dynamic> summary = {
    'existing': existing.length,
    'donorsIn': donors.length,
    'chargesIn': charges.length,
    'newSupporters': 0,
    'updatedSupporters': 0,
    'chargesAdded': 0,
    'chargesDup': 0,
    'chargesNoTxn': 0,
    'chargesSkipped': 0,
    'chargesNonPositive': 0,
    'refundsApplied': 0,
    'recurring': 0,
    'ilsAdded': 0,
    'usdAdded': 0,
  };
  void inc(String k, [num by = 1]) {
    summary[k] = (summary[k] as num) + by;
  }

  final List<dynamic> newNames = [];
  final List<dynamic> updatedNames = [];

  // ── שלב 1: תורמים → כרטיסים (התאמה/העשרה/יצירה) ──
  for (final d in donors) {
    if (_falsy(d['toremId']) && _falsy(d['name'])) continue;
    var idx = findIdx(keysOf({
      'extId': d['toremId'],
      'zeout': d['zeout'],
      'phone': d['phone'],
      'phone2': d['phone2'],
      'phone3': d['phone3'],
      'email': d['email'],
      'name': d['name'],
    }));
    if (idx < 0) idx = findByName(d['name']);
    if (idx >= 0) {
      final sp = out[idx];
      var changed = false;
      void fill(String k, dynamic v) {
        if (_truthy(v) && (sp[k] ?? '').toString().trim().isEmpty) {
          sp[k] = v;
          changed = true;
        }
      }

      fill('extId', d['toremId']);
      fill('phone',
          _or([d['phone'], d['phone2'], d['phone3'], '']).toString().trim());
      fill('email', _or([d['email'], '']).toString().trim());
      fill('address', _or([d['address'], '']).toString().trim());
      fill('idNum',
          _truthy(normId(d['zeout'])) ? _digits(d['zeout']) : '');
      if (changed) {
        register(idx); // מפתחות-חדשים ⇒ עסקאות עתידיות יתאימו
        inc('updatedSupporters');
        if (updatedNames.length < 40) updatedNames.add(sp['name']);
      }
    } else {
      final sp = supFromDonor(d);
      out.add(sp);
      register(out.length - 1);
      inc('newSupporters');
      if (newNames.length < 40) newNames.add(sp['name']);
    }
  }

  // ── שלב 2: עסקאות → hist[] של הכרטיס התואם (דדופ txn/ref; יצירה אם אין) ──
  final Map<int, Set<String>> seenKeys = {};
  Set<String> keySetFor(int idx) {
    var s = seenKeys[idx];
    if (s == null) {
      s = ((out[idx]['hist'] ?? []) as List)
          .map((h) => histDedupKey(h as Map<String, dynamic>))
          .where((x) => _truthy(x))
          .cast<String>()
          .toSet();
      seenKeys[idx] = s;
    }
    return s;
  }

  final List<dynamic> handledChargeIds = [];
  var chargeSeq = 0;
  for (final c in charges) {
    chargeSeq++;
    // ביטול (Amount 0) — אין-כסף, מסמנים טופל בלבד (לא ל-hist).
    if (c['amount'] == 0) {
      inc('chargesNonPositive');
      if (_truthy(c['id'])) handledChargeIds.add(c['id']);
      continue;
    }
    final amt = c['amount'];
    final refund = amt is num && amt < 0; // זיכוי — שורת-hist שלילית
    var idx = findIdx(keysOf({
      'extId': c['toremId'],
      'zeout': c['zeout'],
      'phone': c['phone'],
      'email': c['email'],
      'name': c['name'],
    }));
    // קישור-לפי-שם רק בסנכרון-המלא (attachOnly ⇒ כבוי).
    if (idx < 0 && !_truthy(opts['attachOnly'])) idx = findByName(c['name']);
    if (idx < 0) {
      if (_truthy(opts['attachOnly'])) {
        inc('chargesSkipped');
        continue;
      }
      if (refund) {
        inc('chargesSkipped');
        continue;
      }
      final sp = supFromCharge(c, chargeSeq);
      final same = out.indexWhere((s) => s['id'] == sp['id']);
      if (same >= 0) {
        idx = same;
      } else {
        out.add(sp);
        idx = out.length - 1;
        register(idx);
        inc('newSupporters');
        if (newNames.length < 40) newNames.add(sp['name']);
      }
    }
    final key = chargeDedupKey(c);
    final seen = keySetFor(idx);
    if (_truthy(key) && seen.contains(key)) {
      inc('chargesDup');
      if (_truthy(c['id'])) handledChargeIds.add(c['id']);
      continue;
    }
    if (_truthy(key)) {
      seen.add(key);
    } else {
      inc('chargesNoTxn');
    }
    // זיכוי = שורת-hist שלילית **בלי** withNedarimHok ובלי מונה-recurring.
    final List<dynamic> nextHist = [
      ...((out[idx]['hist'] ?? []) as List),
      chargeToHist(c),
    ];
    if (refund) {
      final m = Map<String, dynamic>.from(out[idx]);
      m['hist'] = nextHist;
      out[idx] = m;
    } else {
      final m = Map<String, dynamic>.from(out[idx]);
      m['hist'] = nextHist;
      out[idx] = withNedarimHok(m, c);
    }
    if (refund) {
      inc('refundsApplied');
    } else {
      if (_truthy(c['kevaId'])) inc('recurring');
      inc('chargesAdded');
    }
    if (_truthy(c['id'])) handledChargeIds.add(c['id']);
    // c.amount שלילי בזיכוי ⇒ מקזז את הצבירה (נטו).
    if (curOf(c) == r'$') {
      inc('usdAdded', amt as num);
    } else {
      inc('ilsAdded', amt as num);
    }
  }

  return {
    'supporters': out,
    'summary': summary,
    'newNames': newNames,
    'updatedNames': updatedNames,
    'handledChargeIds': handledChargeIds,
  };
}

// ── שקעי-שפה (מחקים סמנטיקת-JS; פרטיים, אינם אטומים) ──
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    v == 0 ||
    v == '' ||
    (v is num && v.isNaN);
bool _truthy(dynamic v) => !_falsy(v);

/// מחקה שרשרת `a || b || c || ''` של JS: ראשון-truthy, אחרת האחרון.
dynamic _or(List<dynamic> xs) {
  for (final x in xs) {
    if (_truthy(x)) return x;
  }
  return xs.isEmpty ? null : xs.last;
}

String _digits(dynamic v) =>
    (v?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
