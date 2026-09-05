// ⚛️ אטום-Dart (דרגת-חוזה) · explodeSupporter — פירוק תרומות-תומך למסמכי-ענן (מסלול-B).
// מוצא: maor/src/lib/donationPartition.ts:56-80 · המקור: new/atoms/explode-supporter.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן purposeKeyOf הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: כל תרומה של התומך ⇒ מסמך-ענן {id, supporterId, pkey, donation}, כש-id=rid
//        (מקור-האמת של רציפות D-) והתרומה נשמרת שלמה וב**זהות-הפניה** תחת donation.
//        hist אינו נכלל (אינווריאנט-קדוש). אין מיון — הסדר נקבע בהרכבה-חזרה.
// קלט:  sp (תומך: id · donations?[]) · השקע purposeKeyOf(d)⇒String (נקרא פעם-אחת פר-תרומה).
//        פלט: List של מסמכי-DonationDoc (בדיוק 4 שדות פר-מסמך).
//
// הערות-המרה (מקור→Dart):
//  • `sp.donations ?? []` → `(sp['donations'] as List?) ?? const <dynamic>[]` — ה-`??` של JS
//    (nullish) תופס גם מפתח-חסר (null בגישת-Map) וגם null-מפורש; זהה כאן (אין הבחנה
//    null/undefined בחוזה — לכן לא נדרש containsKey; כלל-המרה 2 לא-רלוונטי). מגן תומך-ישן.
//  • `.map(d => ({...}))` → `.map((d) => <String,dynamic>{...}).toList()` — סדר-המקור נשמר,
//    אפס מיון (כלל-המרה 1 לא-רלוונטי — אין sort). `d.rid`→`d['rid']`, `sp.id`→`sp['id']`.
//  • זהות-הפניה: `donation: d` → `'donation': d` — ה-cast `as Map` אינו משכפל; המסמך מצביע
//    לאותה תרומה מקורית (identical). אין locale/פורמט/getMonth/truthiness להמיר.
//  • מוטביליות: הכול final; אין var מוקצה-מחדש.

/// Explodes a supporter's donations into per-donation cloud docs (route-B):
/// each donation ⇒ {id: rid, supporterId, pkey: purposeKeyOf(d), donation: <same ref>}.
/// `hist` is never included; source order preserved, no sort.
/// Verbatim port of new/atoms/explode-supporter.mjs (`explodeSupporter`).
/// The neighbour call `purposeKeyOf` is injected as a socket (Law 1/3).
List<Map<String, dynamic>> explodeSupporter(
  Map<String, dynamic> sp,
  String Function(Map<String, dynamic>) purposeKeyOf,
) {
  final donations = (sp['donations'] as List?) ?? const <dynamic>[];
  return donations.map((dRaw) {
    final d = dRaw as Map<String, dynamic>;
    return <String, dynamic>{
      'id': d['rid'],
      'supporterId': sp['id'],
      'pkey': purposeKeyOf(d),
      'donation': d,
    };
  }).toList();
}
