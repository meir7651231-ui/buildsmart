/// Maintenance module — room templates, the generic spare-parts catalog and the
/// mandatory-inspection rules, plus a demo seed.
///
/// Counts per room are TEMPLATE DEFAULTS (a field survey corrects them per
/// unit). Legal intervals are the ones verified in research
/// (siach-sod-apartment-catalog.md): elevator 6 months, lifting machines
/// 14 months, gas 5 years, RCD monthly test, mezuzot ~3.5 years.
library;

import 'package:buildsmart/features/maintenance/mx_model.dart';

/// One line of a room template: [type, loc, count, spec, sku, pm].
typedef MxTemplateLine = (String, String, int, String, String, String);

const Map<String, List<MxTemplateLine>> kMxRoomTemplates = {
  'מטבח': [
    (
      'שקע',
      'מעל משטח',
      5,
      'שקע 16A מוגן מים',
      'EL-SK16',
      'בדיקה ויזואלית חודשית',
    ),
    (
      'שקע',
      'ייעודי – מקרר / תנור / מדיח / מיקרו',
      5,
      'שקע 16A מעגל נפרד',
      'EL-SK16',
      'בדיקת התחממות שנתית',
    ),
    ('מתג', 'תאורה', 2, 'מתג יחיד', 'EL-SW1', ''),
    ('גוף תאורה', 'תקרה', 2, 'פלורסנט LED T8', 'EL-T8', ''),
    (
      'ברז',
      'כיור בשרי',
      1,
      'ברז מטבח, קרטוש 40 מ"מ',
      'PL-CRT40',
      'מסננת – רבעוני',
    ),
    (
      'ברז',
      'כיור חלבי',
      1,
      'ברז מטבח, קרטוש 40 מ"מ',
      'PL-CRT40',
      'מסננת – רבעוני',
    ),
    ('ברז ניל', 'מתחת לכיורים', 4, 'ברז ניל ½"', 'PL-NIL12', 'הפעלה שנתית'),
    ('סיפון', 'כיור', 2, 'סיפון כיור 1½"', 'PL-SIF', 'ניקוי רבעוני'),
    (
      'מנעול',
      'ארון סכינים / חומרים',
      2,
      'מנעול ארון',
      'HW-LOCK',
      'ביקורת מפתחות שבועית',
    ),
    ('גלאי עשן', 'תקרה', 1, 'גלאי 10 שנים', 'SF-SMK', 'בדיקה חודשית'),
  ],
  'חדר רחצה': [
    (
      'אסלה',
      '',
      1,
      'מושב אסלה + מערכת שטיפה',
      'PL-FLUSH',
      'בדיקת דליפה חודשית',
    ),
    ('ברז', 'כיור', 1, 'ברז כיור, קרטוש 35 מ"מ', 'PL-CRT35', 'מסננת – רבעוני'),
    ('סוללת מקלחת', '', 1, 'סוללה + ראש מקלחת', 'PL-SHWR', 'אבנית – רבעוני'),
    (
      'מגביל טמפרטורה',
      'TMV מקלחת',
      1,
      'קרטוש TMV',
      'PL-TMV',
      'מדידה חודשית · טיפול שנתי',
    ),
    ('מאחז יד', 'אסלה / מקלחת', 3, 'מאחז נירוסטה', 'HW-GRAB', 'חיזוק רבעוני'),
    ('מחסום רצפה', '', 1, 'מחסום רצפה', 'PL-FLR', 'ניקוי חודשי'),
    ('מאוורר', 'וונטה', 1, 'מאוורר 100 מ"מ', 'EL-FAN', 'ניקוי רבעוני'),
  ],
  'חדר שינה': [
    ('שקע', '', 4, 'שקע 16A עם מכסה מוגן', 'EL-SK16', 'בדיקה חודשית'),
    (
      'מזגן',
      'מאייד',
      1,
      'מזגן עילי 1.25 כ"ס',
      'AC-FLT',
      'מסננים חודשי · טכנאי חצי-שנתי',
    ),
    ('מעצור חלון', '', 2, 'מעצור 10 ס"מ', 'HW-WSTOP', 'בדיקה חודשית'),
    ('תריס', '', 2, 'רצועת תריס', 'HW-STRAP', 'חצי-שנתי'),
    ('מזוזה', '', 1, 'מזוזה', 'JD-MZ', 'בדיקת סופר כל 3.5 שנים'),
  ],
  'כביסה ודוד': [
    ('ברז ניל', 'מכונת כביסה', 1, 'ברז ניל ½"', 'PL-NIL12', ''),
    ('שקע', 'מכונה / מייבש', 2, 'שקע 16A מוגן מים', 'EL-SK16', ''),
    (
      'דוד שמש',
      '',
      1,
      "דוד 150 ל' + אנודה",
      'PL-ANODE',
      'אנודה ואבנית כל שנתיים',
    ),
    ('שעון שבת', 'לדוד', 1, 'שעון שבת DIN', 'EL-SHAB', 'לפני חגים ושינוי שעון'),
  ],
  'כניסה ולוח חשמל': [
    (
      'ממסר פחת',
      'לוח ראשי',
      2,
      'ממסר פחת 30mA',
      'EL-RCD',
      'לחיצת בדיקה חודשית',
    ),
    ('מאמ"ת', 'לוח ראשי', 12, 'מאמ"ת 16A', 'EL-MCB16', ''),
    ('חיישן יציאה', 'דלת כניסה', 1, 'חיישן מגנטי', 'SF-DOOR', 'בדיקה שבועית'),
    ('תאורת חירום', 'מסדרון', 1, 'גוף חירום LED', 'SF-EML', 'בדיקה חודשית'),
    ('מטף', '', 1, 'מטף אבקה 6 ק"ג', 'SF-EXT', 'בדיקה שנתית'),
  ],
};

/// Generic parts catalog. Prices are reference values (agorot) until a store's
/// price list is imported.
const List<MxPart> kMxParts = [
  MxPart(
    sku: 'EL-SK16',
    name: 'מנגנון שקע 16A',
    storeType: 'חשמל',
    min: 10,
    priceAgorot: 1800,
  ),
  MxPart(
    sku: 'EL-SW1',
    name: 'מתג יחיד',
    storeType: 'חשמל',
    min: 5,
    priceAgorot: 1400,
  ),
  MxPart(
    sku: 'EL-T8',
    name: 'פלורסנט LED T8 120 ס"מ',
    storeType: 'חשמל',
    min: 10,
    priceAgorot: 2200,
  ),
  MxPart(
    sku: 'EL-FAN',
    name: 'מאוורר וונטה 100 מ"מ',
    storeType: 'חשמל',
    min: 2,
    priceAgorot: 8500,
  ),
  MxPart(
    sku: 'EL-RCD',
    name: 'ממסר פחת 30mA',
    storeType: 'חשמל',
    min: 2,
    priceAgorot: 16000,
  ),
  MxPart(
    sku: 'EL-MCB16',
    name: 'מאמ"ת 16A',
    storeType: 'חשמל',
    min: 6,
    priceAgorot: 2400,
  ),
  MxPart(
    sku: 'EL-SHAB',
    name: 'שעון שבת DIN',
    storeType: 'חשמל',
    min: 3,
    priceAgorot: 9500,
  ),
  MxPart(
    sku: 'PL-CRT40',
    name: 'קרטוש 40 מ"מ',
    storeType: 'אינסטלציה',
    min: 4,
    priceAgorot: 4500,
  ),
  MxPart(
    sku: 'PL-CRT35',
    name: 'קרטוש 35 מ"מ',
    storeType: 'אינסטלציה',
    min: 4,
    priceAgorot: 4200,
  ),
  MxPart(
    sku: 'PL-NIL12',
    name: 'ברז ניל ½"',
    storeType: 'אינסטלציה',
    min: 6,
    priceAgorot: 2800,
  ),
  MxPart(
    sku: 'PL-SIF',
    name: 'סיפון כיור 1½"',
    storeType: 'אינסטלציה',
    min: 4,
    priceAgorot: 3500,
  ),
  MxPart(
    sku: 'PL-FLUSH',
    name: 'מנגנון הדחה',
    storeType: 'אינסטלציה',
    min: 4,
    priceAgorot: 8900,
  ),
  MxPart(
    sku: 'PL-SHWR',
    name: 'ראש מקלחת + צינור',
    storeType: 'אינסטלציה',
    min: 3,
    priceAgorot: 6500,
  ),
  MxPart(
    sku: 'PL-TMV',
    name: 'קרטוש TMV',
    storeType: 'אינסטלציה',
    min: 2,
    priceAgorot: 18000,
  ),
  MxPart(
    sku: 'PL-FLR',
    name: 'מכסה מחסום רצפה',
    storeType: 'אינסטלציה',
    min: 2,
    priceAgorot: 3000,
  ),
  MxPart(
    sku: 'PL-ANODE',
    name: 'אנודת מגנזיום לדוד',
    storeType: 'אינסטלציה',
    min: 2,
    priceAgorot: 7000,
  ),
  MxPart(
    sku: 'HW-LOCK',
    name: 'מנעול ארון',
    storeType: 'פרזול',
    min: 4,
    priceAgorot: 2500,
  ),
  MxPart(
    sku: 'HW-GRAB',
    name: 'מאחז יד נירוסטה 60 ס"מ',
    storeType: 'פרזול',
    min: 2,
    priceAgorot: 12000,
  ),
  MxPart(
    sku: 'HW-WSTOP',
    name: 'מעצור חלון 10 ס"מ',
    storeType: 'פרזול',
    min: 8,
    priceAgorot: 3500,
  ),
  MxPart(
    sku: 'HW-STRAP',
    name: "רצועת תריס 6 מ'",
    storeType: 'פרזול',
    min: 4,
    priceAgorot: 2000,
  ),
  MxPart(
    sku: 'AC-FLT',
    name: 'מסנן מזגן',
    storeType: 'מיזוג',
    min: 8,
    priceAgorot: 1500,
  ),
  MxPart(
    sku: 'SF-SMK',
    name: 'גלאי עשן 10 שנים',
    storeType: 'בטיחות',
    min: 4,
    priceAgorot: 11000,
  ),
  MxPart(
    sku: 'SF-DOOR',
    name: 'חיישן דלת מגנטי',
    storeType: 'בטיחות',
    min: 2,
    priceAgorot: 7500,
  ),
  MxPart(
    sku: 'SF-EML',
    name: 'גוף תאורת חירום',
    storeType: 'בטיחות',
    min: 2,
    priceAgorot: 14000,
  ),
  MxPart(
    sku: 'SF-EXT',
    name: 'מטף אבקה 6 ק"ג',
    storeType: 'בטיחות',
    min: 2,
    priceAgorot: 19000,
  ),
  MxPart(
    sku: 'JD-MZ',
    name: 'מזוזה כשרה 12 ס"מ',
    storeType: 'יודאיקה',
    min: 3,
    priceAgorot: 15000,
  ),
];

/// Mandatory / recurring inspections: (id, title, intervalDays, legal basis).
/// An empty basis ⇒ good practice, not a legal duty.
const List<(String, String, int, String)> kMxPmCatalog = [
  (
    'elevator',
    'בדיקת מעלית – בודק מוסמך',
    182,
    'פקודת הבטיחות בעבודה · כל 6 חודשים',
  ),
  ('rcd', 'לחיצת בדיקה – ממסרי פחת', 30, 'תקנות הבטיחות בעבודה (חשמל) · חודשי'),
  ('hotwater', 'מדידת טמפרטורת מים חמים (TMV)', 30, 'חוזר משרד הבריאות 2/2016'),
  (
    'hoist',
    'בדיקת מנוף הרמה – בודק מוסמך',
    425,
    'פקודת הבטיחות בעבודה · כל 14 חודשים',
  ),
  ('gas', 'בדיקת מתקן גז תקופתית', 1826, 'חוק הגז (בטיחות ורישוי) · כל 5 שנים'),
  ('extinguisher', 'בדיקת מטפים שנתית', 365, 'ת"י 129 חלק 1'),
  ('mezuza', 'בדיקת מזוזות – סופר', 1278, 'שו"ע יו"ד רצ"א · פעמיים בשבע שנים'),
  ('windows', 'בדיקת מעצורי חלונות', 30, ''),
  ('ac', 'טיפול מזגנים עונתי', 182, ''),
];

/// Build every point of one unit from the templates. Ids are deterministic
/// (`<unitId>/<roomIdx>/<pointIdx>`) so a re-seed never duplicates.
(List<MxRoom>, List<MxPoint>) mxBuildUnit(
  String unitId, {
  Map<String, List<MxTemplateLine>> templates = kMxRoomTemplates,
}) {
  final rooms = <MxRoom>[];
  final points = <MxPoint>[];
  var r = 0;
  for (final entry in templates.entries) {
    final roomId = '$unitId/$r';
    rooms.add(MxRoom(id: roomId, unitId: unitId, name: entry.key));
    final perType = <String, int>{};
    var p = 0;
    for (final (type, loc, count, spec, sku, pm) in entry.value) {
      for (var i = 0; i < count; i++) {
        final num = perType[type] = (perType[type] ?? 0) + 1;
        points.add(
          MxPoint(
            id: '$roomId/$p',
            roomId: roomId,
            type: type,
            num: num,
            loc: loc,
            spec: spec,
            sku: sku,
            pm: pm,
          ),
        );
        p++;
      }
    }
    r++;
  }
  return (rooms, points);
}

/// A small, clearly fictional demo organization: 2 sites, 5 units, 2 stores.
MxDb mxDemoSeed(DateTime now) {
  const sites = [
    MxSite(id: 'jrs', name: 'מסגרת דיור א׳', city: 'ירושלים'),
    MxSite(id: 'bsh', name: 'מסגרת דיור ב׳', city: 'בית שמש'),
  ];
  const units = [
    MxUnit(id: 'jrs-1', siteId: 'jrs', name: 'דירה 1'),
    MxUnit(id: 'jrs-2', siteId: 'jrs', name: 'דירה 2'),
    MxUnit(id: 'jrs-3', siteId: 'jrs', name: 'דירה 3'),
    MxUnit(id: 'bsh-1', siteId: 'bsh', name: 'דירה 1'),
    MxUnit(id: 'bsh-2', siteId: 'bsh', name: 'דירה 2'),
  ];
  final rooms = <MxRoom>[];
  final points = <MxPoint>[];
  for (final u in units) {
    final (r, p) = mxBuildUnit(u.id);
    rooms.addAll(r);
    points.addAll(p);
  }
  const stores = [
    MxStore(
      id: 'st-tambur',
      name: 'טמבור השכונה (דוגמה)',
      types: {'חשמל', 'אינסטלציה', 'פרזול', 'בטיחות', 'מיזוג'},
      phone: '050-0000000',
    ),
    MxStore(
      id: 'st-judaica',
      name: 'סת"ם ויודאיקה (דוגמה)',
      types: {'יודאיקה'},
      phone: '052-0000000',
      channel: MxStoreChannel.whatsapp,
    ),
  ];
  // Stock: a realistic mix — some lines below their reorder point.
  const qty = {
    'EL-SK16': 14,
    'EL-SW1': 8,
    'EL-T8': 3,
    'EL-FAN': 2,
    'EL-RCD': 2,
    'EL-MCB16': 10,
    'EL-SHAB': 1,
    'PL-CRT40': 6,
    'PL-CRT35': 5,
    'PL-NIL12': 9,
    'PL-SIF': 4,
    'PL-FLUSH': 1,
    'PL-SHWR': 5,
    'PL-TMV': 2,
    'PL-FLR': 4,
    'PL-ANODE': 2,
    'HW-LOCK': 6,
    'HW-GRAB': 3,
    'HW-WSTOP': 4,
    'HW-STRAP': 7,
    'AC-FLT': 12,
    'SF-SMK': 3,
    'SF-DOOR': 2,
    'SF-EML': 2,
    'SF-EXT': 2,
    'JD-MZ': 4,
  };
  // Each rule's lastDone is set so the dashboard shows a mix of overdue /
  // due-soon / fine (offsets in days relative to its interval).
  const lastDoneDaysAgo = {
    'elevator': 177,
    'rcd': 28,
    'hotwater': 31,
    'hoist': 404,
    'gas': 1766,
    'extinguisher': 331,
    'mezuza': 1233,
    'windows': 21,
    'ac': 170,
  };
  const scopes = {
    'elevator': 'ירושלים · כל הבניין',
    'rcd': 'כל הדירות',
    'hotwater': 'כל חדרי הרחצה',
    'hoist': 'בית שמש · דירה 2',
    'gas': 'ירושלים · דירה 2',
    'extinguisher': 'כל הדירות',
    'mezuza': 'בית שמש · דירה 1',
    'windows': 'ירושלים · דירות 1–3',
    'ac': 'כל הדירות',
  };
  final pm = [
    for (final (id, title, days, legal) in kMxPmCatalog)
      MxPmRule(
        id: id,
        title: title,
        scope: scopes[id] ?? '',
        intervalDays: days,
        lastDone: now.subtract(Duration(days: lastDoneDaysAgo[id] ?? 0)),
        legalBasis: legal,
      ),
  ];
  return MxDb(
    sites: sites,
    units: units,
    rooms: rooms,
    points: points,
    parts: kMxParts,
    stock: qty,
    stores: stores,
    pmRules: pm,
    seq: 1000,
  );
}
