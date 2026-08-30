// ⚛️ אטום-Dart (דרגת-חוזה) · needsCare — רשימת-הטיפול המרוכזת של מודול-החנות.
// מוצא: maor/src/components/shop/lib.ts:249-374 (SHOP2/6/10 + תיקון-swarm-audit לגידור-תפוגה).
// המקור: new/atoms/needs-care-shop.mjs · החוזה: new/atoms/needs-care-shop.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). כל 11 השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        upcomingHolidays · itemRemaining · componentRemaining · beneficiaryLabel · itemOf ·
//        holidayAllowed · assignmentRedeemed · couponExpiry · featureOn · expiringIntakes ·
//        הקבוע shopHolidayDueDays.
//
// תפקיד: סורק db (shopItems/shopProducts/shopAssignments) ומחזיר התרעות-לפעולה בסדר קבוע —
//        [holidayDue…, meetingPending…, couponPending…, couponExpired…,
//         מלאי (stockOut/restock/waitingRestocked)…, expiring…]. תצוגה-בלבד, אפס כתיבה.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness של JS (`!item.active`, `if(comp.itemId)`, `if(!product)`, `!config`,
//    `x.expired ?`) → שקע `_falsy` מפורש (DART-RULE 7). null/false/0/''/NaN = falsy.
//  • `rem === 0` → `rem == 0` (null==0 ⇒ false בשתי השפות); `rem !== 0` → `rem != 0`
//    (null!=0 ⇒ true בשתיהן) — מדויק כמו המקור.
//  • שרשור-מספר-במחרוזת: JS `'…' + rem + '…'` — Dart אינו מרשה String+int ⇒ אינטרפולציה
//    (`'…$rem…'`), פלט-מחרוזת זהה ('2','5' וכו').
//  • השוואת-מחרוזת `expiry < todayIso`: JS מילוני; Dart למחרוזת אין `<` ⇒
//    `expiry.compareTo(todayIso) < 0` (ISO אותו-אורך ⇒ מילוני≡כרונולוגי).
//  • `expiry &&` (מחרוזת ריקה=falsy) → `expiry.isNotEmpty` — בדיוק סמנטיקת-ה-JS.
//  • `db.shopProducts.find(...)` (מחזיר undefined אם אין) → לולאת-lookup שמחזירה null,
//    ואז `if (_falsy(product)) continue` — לא firstWhere (זורק על היעדר).
//  • מוטביליות: כל המצטברים `final` (מוטבלים דרך add/addAll); `rem`/`expiry` הם final
//    מקומיים בכל איטרציה — כמו `const` בלולאות-ה-JS.
//  • אין locale/פורמט/getMonth — הפורמט חי בשקעים; האטום עיוור לחשבון-הלוח (חוק-5).

bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// The shop module's consolidated care-list: scans the DB and returns action alerts in a
/// fixed order — holidayDue…, meetingPending…, couponPending…, couponExpired…, stock
/// (stockOut/restock/waitingRestocked)…, expiring…. Each alert: {kind, assignmentId,
/// componentId, label, hint}. Read-only; expiry alerts are gated shop.expiry (no config ⇒
/// bit-identical, on). Verbatim port of new/atoms/needs-care-shop.mjs; all 11 neighbours
/// are injected as sockets (Law 1/3).
List<Map<String, dynamic>> needsCare(
  Map<String, dynamic> db,
  String todayIso,
  dynamic config,
  List<dynamic> Function(String todayIso, int dueDays) upcomingHolidays,
  int? Function(Map<String, dynamic> db, dynamic itemId) itemRemaining,
  int? Function(dynamic compId, dynamic productId, dynamic assignments, dynamic stock)
      componentRemaining,
  String Function(Map<String, dynamic> db, dynamic a, dynamic config) beneficiaryLabel,
  dynamic Function(Map<String, dynamic> db, dynamic comp) itemOf,
  bool Function(dynamic ri, dynamic name) holidayAllowed,
  bool Function(dynamic a, dynamic componentId, [dynamic holiday]) assignmentRedeemed,
  String Function(dynamic a, dynamic ri) couponExpiry,
  bool Function(dynamic config, String key) featureOn,
  List<dynamic> Function(Map<String, dynamic> db, String todayIso) expiringIntakes,
  int shopHolidayDueDays,
) {
  final holidays = upcomingHolidays(todayIso, shopHolidayDueDays);
  final due = <Map<String, dynamic>>[];
  final meetings = <Map<String, dynamic>>[];
  final coupons = <Map<String, dynamic>>[];
  final expired = <Map<String, dynamic>>[];
  final stock = <Map<String, dynamic>>[];

  // מלאי משותף (הכרעה 18): התרעת אזל פר-פריט — הנותר נספר על-פני כל החבילות
  for (final item in (db['shopItems'] as List)) {
    if (_falsy(item['active'])) continue;
    final rem = itemRemaining(db, item['id']);
    if (rem == 0) {
      stock.add({
        'kind': 'stockOut',
        'assignmentId': '',
        'componentId': item['id'],
        'label': '${item['name']} — המלאי אזל',
        'hint': 'לחדש מלאי או לעדכן את הפריט',
      });
    } else if (item['minStock'] != null && rem != null && rem < ((item['minStock']) as num)) {
      // מלאי מינימום (SHOP6 חנות 25): מתחת לסף — "להצטייד" לפני שאוזל
      stock.add({
        'kind': 'restock',
        'assignmentId': '',
        'componentId': item['id'],
        'label': '${item['name']} — המלאי נמוך',
        'hint': 'להצטייד: נותרו $rem מתחת ל-${item['minStock']}',
      });
    }
    // רשימת המתנה (SHOP6 חנות 27): ממתינים + מלאי חזר (>0 או בלי-מעקב) —
    // הגיע הזמן לחלק; במלאי 0 אין התרעה (עדיין אין מה לתת)
    final waiting = (item['waits'] ?? const []) as List;
    if (waiting.isNotEmpty && rem != 0) {
      stock.add({
        'kind': 'waitingRestocked',
        'assignmentId': '',
        'componentId': item['id'],
        'label': '${waiting.length} ממתינים ל${item['name']}',
        'hint': 'המלאי חזר — אפשר לחלק לרשימת ההמתנה',
      });
    }
  }

  // תאימות לנתונים טרום-מיגרציה: רכיב בלי itemId עם מלאי משלו
  for (final p in (db['shopProducts'] as List)) {
    if (_falsy(p['active'])) continue;
    for (final comp in (p['components'] as List)) {
      if (!_falsy(comp['itemId'])) continue;
      final rem = componentRemaining(comp['id'], p['id'], db['shopAssignments'], comp['stock']);
      if (rem == 0) {
        stock.add({
          'kind': 'stockOut',
          'assignmentId': '',
          'componentId': comp['id'],
          'label': '${comp['label']} (${p['name']}) — המלאי אזל',
          'hint': 'לחדש מלאי או לעדכן את הרכיב במוצר',
        });
      }
    }
  }

  for (final a in (db['shopAssignments'] as List)) {
    if (a['status'] != 'active') continue;
    Map<String, dynamic>? product;
    for (final p in (db['shopProducts'] as List)) {
      if (p['id'] == a['productId']) {
        product = p as Map<String, dynamic>;
        break;
      }
    }
    if (_falsy(product)) continue;
    final who = beneficiaryLabel(db, a, config);
    for (final comp in (product!['components'] as List)) {
      final ri = itemOf(db, comp);
      if (ri['kind'] == 'holidayGift') {
        for (final h in holidays) {
          // חגים נבחרים (הכרעה 17): "מה מגיע" רק לחגים שסומנו על הפריט
          if (!holidayAllowed(ri, h['name'])) continue;
          if (!assignmentRedeemed(a, comp['id'], h)) {
            due.add({
              'kind': 'holidayDue',
              'assignmentId': a['id'],
              'componentId': comp['id'],
              'label': '$who — ${ri['name']}',
              'hint': '${h['name']} ב-${h['iso']} — טרם נמסרה',
            });
          }
        }
      } else if (ri['kind'] == 'meeting' && !assignmentRedeemed(a, comp['id'])) {
        meetings.add({
          'kind': 'meetingPending',
          'assignmentId': a['id'],
          'componentId': comp['id'],
          'label': '$who — ${ri['name']}',
          'hint': 'פגישת ליווי טרם התקיימה',
        });
      } else if (ri['kind'] == 'coupon' && !assignmentRedeemed(a, comp['id'])) {
        final expiry = couponExpiry(a, ri);
        if (expiry.isNotEmpty && expiry.compareTo(todayIso) < 0) {
          expired.add({
            'kind': 'couponExpired',
            'assignmentId': a['id'],
            'componentId': comp['id'],
            'label': '$who — ${ri['name']}',
            'hint': 'הקופון פג בתוקף ב-$expiry וטרם מומש',
          });
        } else {
          coupons.add({
            'kind': 'couponPending',
            'assignmentId': a['id'],
            'componentId': comp['id'],
            'label': '$who — ${ri['name']}',
            'hint': expiry.isNotEmpty ? 'קופון טרם מומש · בתוקף עד $expiry' : 'קופון טרם מומש',
          });
        }
      }
    }
  }

  // אצוות/תפוגה (SHOP10) — קליטות מתכלות שפגו או עומדות לפוג (≤7 ימים).
  // תיקון (swarm-audit): עם config הדגל shop.expiry נאכף; בלי config — ביט-זהה (דולק).
  final bool expiryOn = _falsy(config) || featureOn(config, 'shop.expiry');
  final raw = expiryOn ? expiringIntakes(db, todayIso) : const <dynamic>[];
  final expiring = raw.map<Map<String, dynamic>>((x) {
    final intake = x['intake'];
    final isExpired = !_falsy(x['expired']);
    return {
      'kind': 'expiring',
      'assignmentId': '',
      'componentId': intake['itemId'],
      'label': '${x['itemName']}${isExpired ? ' — פג תוקף' : ' — עומד לפוג'}',
      'hint': '${isExpired ? 'פג ב-' : 'בתוקף עד '}${intake['expiry']} · אצווה ${intake['qty']} יח׳',
    };
  }).toList();

  return [...due, ...meetings, ...coupons, ...expired, ...stock, ...expiring];
}
