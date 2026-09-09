import '../dart-data-maor/norm-search-sockets.dart' as skb_ns;
import '../dart-data-maor/with-nedarim-hok-sockets.dart' as skb_wnh;
import '../dart-data-maor/detect-recurring-hok-sockets.dart' as skb_drh;
import '../dart-data-maor/provider-clearer-terms.dart';
// 📦 קופסת-חיבורים · lib-nedarim-sync (Dart) — מנוע-סנכרון נדרים→מאור (כיוון-נכנס).
// מקבילה ל-new/boxes/lib-nedarim-sync.mjs · חוזה משותף: lib-nedarim-sync.contract.md.
// מקור-האמת: maor/src/lib/nedarimSync.ts. זהו ההוכחה ש-מאור(JS) ובנייה-חכמה(Dart)
// מתחברות לאותה קופסה: אותם קלטים ⇒ אותו פלט (ראה lib-nedarim-sync-proof.dart).
//
// 15 חוטי-הסנכרון נפגשים כאן (חוקי-החשמלאי). הקופסה מחווטת אטומי-Dart בלבד; החיווט
// (גרף-הקריאות, סדר-ההזרקות, ברירות-המחדל, מילון-התוויות NAME_TITLES, ומספר עוזרי-glue
// module-private שלא קודמו כאטומים: curOf/keysOf/histDedupKey/hokDayFromDate/monthsAgo/
// modeOf/modeStr/supFromDonor/supFromCharge) חי כאן, לא בחוטים — ידע-קופסה (חוק-5).
// מתאמי-הטיפוס (Dart קשיח-טיפוס) מגשרים בין חתימות-האטומים (Object?/dynamic/Map).
import '../dart-maor/norm-id.dart' as _ni;
import '../dart-maor/norm-phone.dart' as _np;
import '../dart-maor/norm-search.dart' as _ns;
import '../dart-maor/name-sort-key.dart' as _nsk;
import '../dart-maor/clearing-providers.dart' as _cp;
import '../dart-maor/provider-clearer.dart' as _pc;
import '../dart-maor/charge-to-hist.dart' as _cth;
import '../dart-maor/charge-dedup-key.dart' as _cdk;
import '../dart-maor/with-nedarim-hok.dart' as _wnh;
import '../dart-maor/detect-recurring-hok.dart' as _drh;
import '../dart-maor/candidate-supporters-for-charge.dart' as _csfc;
import '../dart-maor/fill-card-from-charge.dart' as _fcfc;
import '../dart-maor/attach-charge-to.dart' as _act;
import '../dart-maor/relabel-hist-by-txn.dart' as _rhbt;
import '../dart-maor/repair-cards-from-rows.dart' as _rcfr;
import '../dart-maor/strong-match-for-charge.dart' as _smfc;
import '../dart-maor/auto-match-charges.dart' as _amc;
import '../dart-maor/attach-charges-bulk.dart' as _acb;
import '../dart-maor/plan-nedarim-sync.dart' as _pns;

// ── מילון-החיווט (הכרעה שחיה בקופסה, verbatim מהמקור; ידע-קופסה — חוק-5) ──
// תארים/כינויי-כבוד עבריים למפתח-שם חסין-סדר (validate.ts:73-80). מוזרק ל-name-sort-key.
const Set<String> _nameTitles = {
  'ר', 'רבי', 'הרב', 'הרבנית', 'הרהג', 'הרהח', 'הגר', 'מוהרר', 'אדמור', 'מרת', 'מר', 'גב', 'הגב',
  'דר', 'פרופ', 'הבחור', 'הבהח', 'הת', 'משפ', 'משפחת',
  'שליטא', 'זצל', 'זצוקל', 'זקל', 'זל', 'עה', 'היד', 'נרו', 'ניו', 'ני', 'היו',
};

// ── שקעי-שפה (מחקים סמנטיקת-JS; פרטיים, אינם אטומים) ──
/// חיקוי `!!v` של JS: null/''/0/NaN/false ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// משקף `v || ''` לתחום-המחרוזתי (עם String() מרומז): falsy ⇒ '', אחרת toString().
String _s(dynamic v) => _truthy(v) ? v.toString() : '';

/// מחקה שרשרת `a || b || c || ''` של JS: ראשון-truthy, אחרת האחרון.
dynamic _or(List<dynamic> xs) {
  for (final x in xs) {
    if (_truthy(x)) return x;
  }
  return xs.isEmpty ? null : xs.last;
}

/// מחקה String.prototype.slice(start,end) של JS: קליפינג-טווח, לעולם לא זורק.
String _slice(String s, int start, int end) {
  final len = s.length;
  var st = start < 0 ? (len + start < 0 ? 0 : len + start) : (start > len ? len : start);
  var en = end < 0 ? (len + end < 0 ? 0 : len + end) : (end > len ? len : end);
  if (en < st) return '';
  return s.substring(st, en);
}

// ── שקעי-הצמדה (glue) — עוזרים module-private במקור שלא קודמו כאטומים ──
// nedarimSync.ts:88-104 — מפתחות-שיוך של רשומה (ext/id/ph/em/namecity) — עקבי עם מנוע-הדדופ.
List<String> keysOf(Map<String, dynamic> o) {
  final ks = <String>[];
  final ext = _s(o['extId']).trim();
  if (ext.isNotEmpty) ks.add('ext:$ext');
  final idSrc = _truthy(o['idNum']) ? o['idNum'] : o['zeout'];
  final id = _ni.normId(idSrc as String?);
  if (id.isNotEmpty) ks.add('id:$id');
  for (final p in [o['phone'], o['phone2'], o['phone3']]) {
    final ph = _np.normPhone(_s(p));
    if (ph.length >= 7) ks.add('ph:$ph');
  }
  final em = _s(o['email']).trim().toLowerCase();
  if (em.isNotEmpty) ks.add('em:$em');
  final n = _ns.normSearch(_s(o['name']), skb_ns.normSearch_T);
  final c = _ns.normSearch(_s(o['city']), skb_ns.normSearch_T);
  if (n.isNotEmpty && c.isNotEmpty) ks.add('nc:$n|$c');
  return ks;
}

// nedarimSync.ts:107-110 — מטבע מנורמל מעסקה (תומך '₪'/'$' וגם קידוד-נדרים '1'/'2').
String curOf(Map<String, dynamic> charge) {
  final raw = _s(charge['currency']).trim();
  return raw == r'$' ||
          raw == '2' ||
          RegExp(r'usd|\$|דולר', caseSensitive: false).hasMatch(raw)
      ? r'$'
      : '₪';
}

// nedarimSync.ts:153-158 — מפתח-דדופ מרשומת-hist קיימת (מקביל ל-chargeDedupKey).
String histDedupKey(Map<String, dynamic> h) {
  final txn = _s(h['txn']).trim();
  if (txn.isNotEmpty) return 'txn:$txn';
  final ref = _s(h['ref']).trim();
  return ref.isNotEmpty ? 'ref:$ref' : '';
}

// nedarimSync.ts:165-168 — יום-החיוב מתאריך-העסקה (1–28 — כך קיים בכל חודש). ברירת-מחדל 1.
num hokDayFromDate(String iso) {
  final sub = _slice(iso, 8, 10);
  final num dv = sub.isEmpty ? 0 : (num.tryParse(sub) ?? double.nan); // Number('')===0
  if (dv.isFinite && dv >= 1) {
    final fl = dv.floor();
    return fl < 28 ? fl : 28;
  }
  return 1;
}

// nedarimSync.ts:200-205 — מספר-החודשים מ-dateIso עד todayIso (0=אותו חודש).
int monthsAgo(String dateIso, String todayIso) {
  final p1 = _slice(dateIso, 0, 7).split('-');
  final p2 = _slice(todayIso, 0, 7).split('-');
  final y1 = num.tryParse(p1.isNotEmpty ? p1[0] : '');
  final m1 = num.tryParse(p1.length > 1 ? p1[1] : '');
  final y2 = num.tryParse(p2.isNotEmpty ? p2[0] : '');
  final m2 = num.tryParse(p2.length > 1 ? p2[1] : '');
  if (!_truthy(y1) || !_truthy(m1) || !_truthy(y2) || !_truthy(m2)) return 999;
  return ((y2! - y1!) * 12 + (m2! - m1!)).toInt();
}

// nedarimSync.ts:208-218 — הערך-השכיח במערך (mode) — ליום-החיוב הטיפוסי.
num modeOf(List<num> nums) {
  final c = <num, int>{};
  num best = nums.isNotEmpty ? nums[0] : 1;
  var bestN = 0;
  for (final n in nums) {
    final k = (c[n] ?? 0) + 1;
    c[n] = k;
    if (k > bestN) {
      bestN = k;
      best = n;
    }
  }
  return best;
}

// nedarimSync.ts:221-231 — המחרוזת-השכיחה (mode) — לסכום|מטבע הטיפוסי של ההו"ק.
String modeStr(List<String> strs) {
  final c = <String, int>{};
  String best = strs.isNotEmpty ? strs[0] : '';
  var bestN = 0;
  for (final s in strs) {
    final k = (c[s] ?? 0) + 1;
    c[s] = k;
    if (k > bestN) {
      bestN = k;
      best = s;
    }
  }
  return best;
}

// מפתח-שם חסין-סדר: name-sort-key מוזרק normSearch (אטום) + NAME_TITLES (מילון-קופסה).
String nameSortKey(dynamic t) => _nsk.nameSortKey(t, (x) => _ns.normSearch(x, skb_ns.normSearch_T), _nameTitles);

// nedarimSync.ts:471-498 — כרטיס-תומך חדש מרשומת-תורם נדרים (מזהה דטרמיניסטי).
Map<String, dynamic> supFromDonor(Map<String, dynamic> d) {
  final phone = _or([d['phone'], d['phone2'], d['phone3'], '']).toString().trim();
  final extraPhones = [d['phone2'], d['phone3']]
      .map((p) => _s(p).trim())
      .where((p) => p.isNotEmpty && p != phone)
      .toList();
  final notes = [
    d['notes'],
    extraPhones.isNotEmpty ? 'טל׳ נוספים: ${extraPhones.join(', ')}' : '',
  ].map((s) => _s(s).trim()).where((s) => s.isNotEmpty).join(' · ');
  final zeoutId = _ni.normId(_s(d['zeout']));
  return <String, dynamic>{
    'id': 'sup-ned-${d['toremId']}',
    'name': _s(d['name']).trim(),
    'phone': phone,
    'email': _s(d['email']).trim(),
    'address': _s(d['address']).trim(),
    'city': '',
    'idNum': _truthy(zeoutId) ? _s(d['zeout']).replaceAll(RegExp(r'\D'), '') : '',
    'extId': d['toremId'],
    'cat': '',
    'forWho': '',
    'notes': notes,
    'count': 0,
    'ils': 0,
    'usd': 0,
    'first': '',
    'last': '',
    'nextDate': '',
    'donations': <dynamic>[],
  };
}

// nedarimSync.ts:504-531 — כרטיס-תומך חדש מעסקה (כשאין תורם/כרטיס תואם) — אפס-אובדן-חיוב.
Map<String, dynamic> supFromCharge(Map<String, dynamic> c, int seq) {
  final anon = !_truthy(c['toremId']) && nameSortKey(_s(c['name'])).isEmpty;
  final String id = _truthy(c['toremId'])
      ? 'sup-ned-${c['toremId']}'
      : anon
          ? 'sup-ned-unassigned'
          : 'sup-ned-txn-${_truthy(c['txnId']) ? c['txnId'] : seq.toString()}';
  final zeoutId = _ni.normId(_s(c['zeout']));
  // סדר-הכנסה verbatim מהמקור (extId מוכנס אחרי idNum, לפני cat — כמו spread ה-JS).
  final m = <String, dynamic>{
    'id': id,
    'name': _or([c['name'], anon ? 'תרומות נדרים ללא שיוך' : 'תורם נדרים'])
        .toString()
        .trim(),
    'phone': _s(c['phone']).trim(),
    'email': _s(c['email']).trim(),
    'address': '',
    'city': '',
    'idNum': _truthy(zeoutId) ? _s(c['zeout']).replaceAll(RegExp(r'\D'), '') : '',
  };
  if (_truthy(c['toremId'])) m['extId'] = c['toremId'];
  m['cat'] = _s(c['category']).trim();
  m['forWho'] = '';
  m['notes'] = '';
  m['count'] = 0;
  m['ils'] = 0;
  m['usd'] = 0;
  m['first'] = '';
  m['last'] = '';
  m['nextDate'] = '';
  m['donations'] = <dynamic>[];
  return m;
}

// ── החיווט (גרף-הקריאות של nedarimSync.ts, סוקטים מוזרקים · מתאמי-טיפוס לאטומי-Dart) ──

/// שני ספקי-הסליקה הקבועים ('נדרים','סולה') — re-export מהאטום.
List<String> get clearingProviders => _cp.clearingProviders;

/// תווית-סליקה לפי ספק-העסקה — re-export מהאטום (String? provider).
String providerClearer(String? provider) => _pc.providerClearer(provider, term: (k)=>kTerms[k]!);

/// מפתח-דדופ לעסקת-סליקה — האטום מקבל Map<String,String?>; הקופסה מיישרת מ-Map<String,dynamic>.
String chargeDedupKey(Map<String, dynamic> charge) =>
    _cdk.chargeDedupKey(charge.cast<String, String?>());

/// ריפוי-תוויות רטרואקטיבי ב-hist לפי txn/ref — re-export מהאטום (בלי סוקטים).
_rhbt.RelabelResult relabelHistByTxn(List<dynamic> supporters, List<dynamic> txns, String label) =>
    _rhbt.relabelHistByTxn(supporters, txns, label);

/// רשומת-hist מעסקה — מוזרק curOf + providerClearer (מתאם dynamic).
Map<String, dynamic> chargeToHist(Map<String, dynamic> charge) => _cth.chargeToHist(
      charge,
      curOf,
      (dynamic p) => _pc.providerClearer(p as String?, term: (k)=>kTerms[k]!),
    );

/// מילוי משבצת-ההו"ק מחיוב-נדרים חוזר — האטום ב-Object?; הקופסה ממירה הלוך-ושוב.
Map<String, dynamic> withNedarimHok(Map<String, dynamic> sp, Map<String, dynamic> charge) {
  final r = _wnh.withNedarimHok(
    sp.cast<String, Object?>(),
    charge.cast<String, Object?>(),
    (Map<String, Object?> ch) => curOf(ch.cast<String, dynamic>()),
    hokDayFromDate,
    skb_wnh.withNedarimHok_T,
  );
  return r.cast<String, dynamic>();
}

/// זיהוי הוראות-קבע מתבנית-ה-hist — מוזרק CLEARING_PROVIDERS/modeStr/modeOf/monthsAgo.
Map<String, Object?> detectRecurringHok(
  List<Map<String, dynamic>> supporters,
  String todayIso, [
  int minMonths = 3,
]) =>
    _drh.detectRecurringHok(
      [for (final s in supporters) s.cast<String, Object?>()],
      todayIso,
      minMonths,
      _cp.clearingProviders,
      modeStr,
      modeOf,
      monthsAgo,
      skb_drh.detectRecurringHok_T,
    );

/// מועמדים לשיוך עסקה לכרטיס-תורם — מוזרק keysOf + nameSortKey (מתאמי Object?).
List<Map<String, Object?>> candidateSupportersForCharge(
  Map<String, dynamic> charge,
  List<Map<String, dynamic>> supporters, [
  int limit = 8,
]) =>
    _csfc.candidateSupportersForCharge(
      charge.cast<String, Object?>(),
      [for (final s in supporters) s.cast<String, Object?>()],
      (Map<String, Object?> o) => keysOf(o.cast<String, dynamic>()),
      (Object? n) => nameSortKey(n),
      limit: limit,
    );

/// מילוי-אם-ריק של פרטי-קשר מהעסקה לכרטיס — מוזרק normPhone/normId (String? עולה ל-String).
Map<String, dynamic> fillCardFromCharge(Map<String, dynamic> sp, Map<String, dynamic> charge) =>
    _fcfc.fillCardFromCharge(sp, charge, _np.normPhone, _ni.normId);

/// חיבור-ידני של עסקה לכרטיס-תומך (דדופ-גלובלי C2, מגן-ביטול C10) — חמשת השכנים מוזרקים.
Map<String, Object?> attachChargeTo(List<dynamic> supporters, Object? supId, Map<String, dynamic> charge) =>
    _act.attachChargeTo(
      supporters,
      supId,
      charge,
      (Map c) => _cdk.chargeDedupKey(c.cast<String, String?>()),
      (Map h) => histDedupKey(h.cast<String, dynamic>()),
      (Map c) => chargeToHist(c.cast<String, dynamic>()),
      (Map sp, Map c) => fillCardFromCharge(sp.cast<String, dynamic>(), c.cast<String, dynamic>()),
      (Map sp, Map c) => withNedarimHok(sp.cast<String, dynamic>(), c.cast<String, dynamic>()),
    );

/// ריפוי-כרטיסים מרשומות-ספק — מוזרק fillCardFromCharge; משמר זהות-הפניה כשאין-העשרה
/// (האטום סופר enriched דרך identical — לכן מחזירים את sp המקורי כשלא-נגע).
Map<String, dynamic> repairCardsFromRows(List<dynamic> supporters, List<dynamic> rows, String label) =>
    _rcfr.repairCardsFromRows(
      supporters,
      rows,
      label,
      (dynamic sp, dynamic row) {
        final spMap = (sp as Map).cast<String, dynamic>();
        final r = _fcfc.fillCardFromCharge(
            spMap, (row as Map).cast<String, dynamic>(), _np.normPhone, _ni.normId);
        return identical(r, spMap) ? sp : r; // אין-מילוי ⇒ ה-sp המקורי (שימור-זהות)
      },
    );

/// ההתאמה-החזקה-ביותר של עסקה לכרטיס — מוזרק keysOf (dynamic socket).
dynamic strongMatchForCharge(dynamic charge, dynamic supporters) =>
    _smfc.strongMatchForCharge(charge, supporters, keysOf);

/// שיוך אוטומטי של חיובי-סנכרון לתומכים — מוזרק keysOf (מתאם Object?).
List<Map<String, Object?>> autoMatchCharges(
  List<Map<String, dynamic>> charges,
  List<Map<String, dynamic>> supporters,
) =>
    _amc.autoMatchCharges(
      [for (final c in charges) c.cast<String, Object?>()],
      [for (final s in supporters) s.cast<String, Object?>()],
      (Map<String, Object?> o) => keysOf(o.cast<String, dynamic>()),
    );

/// חיבור-אצווה של עסקאות לכרטיסים ממופים (דדופ גלובלי C2, מגן C10) — חמשת השכנים מוזרקים.
Map<String, dynamic> attachChargesBulk(
  List<Map<String, dynamic>> supporters,
  List<Map<String, dynamic>> items,
) =>
    _acb.attachChargesBulk(
      supporters,
      items,
      histDedupKey,
      chargeDedupKey,
      chargeToHist,
      fillCardFromCharge,
      withNedarimHok,
    );

/// מנוע-הסנכרון המלא (תוכנית טהורה) — עשרת השכנים מוזרקים כסוקטים פוזיציוניים.
Map<String, dynamic> planNedarimSync(
  List<Map<String, dynamic>> existing,
  List<Map<String, dynamic>> donors,
  List<Map<String, dynamic>> charges, [
  Map<String, dynamic> opts = const <String, dynamic>{},
]) =>
    _pns.planNedarimSync(
      existing,
      donors,
      charges,
      opts,
      nameSortKey,
      keysOf,
      (dynamic s) => _ni.normId(s as String?),
      supFromDonor,
      supFromCharge,
      histDedupKey,
      chargeDedupKey,
      chargeToHist,
      withNedarimHok,
      curOf,
    );
