// ⚛️ אטום-Dart (דרגת-חוזה) · deliveriesCsvRows — שורות-CSV של מסירות-החלוקה (SHOP7).
// מוצא: maor/src/components/shop7/lib.ts:114-135 · המקור: new/atoms/deliveries-csv-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        termOf(config, key, fallback) · statusLabel(status).
//
// תפקיד: שורת-כותרת ['תאריך', <מונח-משפחה>, 'כתובת', 'מתנדב', 'סטטוס', 'הערה'] ואז שורה
//        פר-מסירה בסדר db.deliveries. פתירת-מזהים מקומית; מזהה-שלא-נמצא ⇒ '' (לא קריסה).
//        כתובת = [address, city] כל אחד ב-trim, ריקים מסוננים, מחוברים ב-', '. הערה חסרה ⇒ ''.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness של config (DART-PORTING §7): JS `config ? termOf(...) : fb` — undefined⇒falsy.
//    ב-Dart config הוא dynamic ו-undefined⇒null, לכן `config != null` בדיוק. השקע לא מופעל
//    כש-config חסר (חוזה §4) — התנאי מקצר-מעגל לפני הקריאה.
//  • `?.date ?? ''` / `?.name ?? ''`: find שלא-מצא ⇒ null ⇒ '' (firstWhere+orElse:null).
//  • `s || ''` (address/city אולי null/'') → `(s as String?) ?? ''` לפני trim (DART-PORTING §7).
//  • `.filter(Boolean)` על מחרוזות = הסרת מחרוזות-ריקות ⇒ `.where((s) => s.isNotEmpty)`.
//  • `d.note ?? ''`: מפתח-חסר ⇒ null (Map access) ⇒ '' (§2 null-מפורש≡היעדר כאן, שניהם '').
//  • מוטביליות: `rows` final (מוטבל דרך add); בדיוק כמו `const rows` שמקבל push במקור.
//  • אין locale/פורמט/getMonth/מיון — פורמט/סטטוס חיים בשקעים.

/// CSV rows for all distribution deliveries (SHOP7): a header row
/// ['תאריך', <family-term>, 'כתובת', 'מתנדב', 'סטטוס', 'הערה'] then one row per
/// delivery in db.deliveries order. Ids are resolved locally; an unresolved id ⇒ ''
/// (never a crash). The address joins trimmed, non-empty [address, city] with ', '.
/// Verbatim port of new/atoms/deliveries-csv-rows.mjs; termOf and statusLabel are
/// injected as sockets (Law 1/3). termOf is called ONLY when config is provided.
List<List<String>> deliveriesCsvRows(
  Map<String, dynamic> db,
  dynamic config,
  String Function(dynamic config, String key, String fallback) termOf,
  String Function(dynamic status) statusLabel,
 {required String Function(String) term}) {
  String t(String k, String fb) => config != null ? termOf(config, k, fb) : fb;

  Map<String, dynamic>? _find(String coll, String id) {
    for (final e in (db[coll] as List)) {
      if ((e as Map)['id'] == id) return e.cast<String, dynamic>();
    }
    return null;
  }

  String dayDate(dynamic id) => (_find('distributionDays', id as String)?['date'] as String?) ?? '';
  String famName(dynamic id) => (_find('families', id as String)?['name'] as String?) ?? '';
  String famAddr(dynamic id) {
    final f = _find('families', id as String);
    if (f == null) return '';
    return [f['address'], f['city']]
        .map((s) => ((s as String?) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  String volName(dynamic id) => (_find('volunteers', id as String)?['name'] as String?) ?? '';

  // גל ב׳: עמודת כתובת (שדרוג-פורמט מתועד)
  final rows = <List<String>>[
    [term('taryk'), t('entity.family', term('mshpchh')), term('ktvbt'), term('mtndb'), term('sttvs'), term('harh')],
  ];
  for (final d in (db['deliveries'] as List)) {
    final dm = (d as Map);
    rows.add([
      dayDate(dm['dayId']),
      famName(dm['familyId']),
      famAddr(dm['familyId']),
      volName(dm['volunteerId']),
      statusLabel(dm['status']),
      (dm['note'] as String?) ?? '',
    ]);
  }
  return rows;
}
