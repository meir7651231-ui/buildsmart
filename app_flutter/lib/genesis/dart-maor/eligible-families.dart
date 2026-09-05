// ⚛️ אטום-Dart (דרגת-חוזה) · eligibleFamilies — משפחות זכאיות לשיוך-חנות המוני.
// מוצא: maor/src/components/shop/lib.ts:610-626 · המקור: new/atoms/eligible-families.mjs —
//   db.families.filter(f=>f.status==='active').filter(f=>{ theirs=shopAssignments where famId===f.id;
//     if(theirs.some(a=>a.productId===excludeProductId && a.status==='active')) false;
//     if(criterionIds.length===0) true; held=Set(theirs.flatMap(a=>a.criterionIds));
//     return criterionIds.every(c=>held.has(c)); }).map(f=>{famId,name,memberIds}).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הקלט לבורר-החלוקה-ההמונית (SHOP6) — משפחות פעילות שמחזיקות באיחוד על-פני
//        שיוכיהן את כל הקריטריונים שנבחרו (או כולן כשאין קריטריון), מסוננות ממי
//        שכבר מחזיקה שיוך active לאותה חבילה. כל תוצאה מצומצמת ל-{famId,name,memberIds}.
// שקע (חוק-1): db {families:[{id,name,status,members:[{id}]}],
//        shopAssignments:[{famId,productId,status,criterionIds:[]}]} · criterionIds · excludeProductId.
// קלט: db (Map) · criterionIds (List) · excludeProductId. פלט: List של Map {famId,name,memberIds}.
//
// הערת-המרה (מקור→Dart): המנוע פספס — .has של Set-JS ⇒ .contains ב-Dart · db.families
// על dynamic ⇒ אינדוקס-מפתח db['families'] (הדאטה = Maps) · flatMap ⇒ expand ·
// where עצל ⇒ .toList(). אין locale/פורמט/getMonth/truthiness/מוטביליות — האיחוד נבנה
// מכל שיוכי-המשפחה (גם לא-active), רק סינון-הכפל מוגבל ל-active; כך במקור (חוזה §הערת-קריאה).

/// Families eligible for a bulk shop-assignment. Verbatim behaviour of the JS
/// source `eligibleFamilies`: active families that hold — unioned across all
/// their assignments — every selected criterion (all active families when no
/// criterion is selected), excluding families already holding an active
/// assignment to `excludeProductId`. Each result narrows to {famId,name,memberIds}.
List<Map<String, dynamic>> eligibleFamilies(
    Map db, List criterionIds, dynamic excludeProductId) {
  final families = (db['families'] as List);
  final shopAssignments = (db['shopAssignments'] as List);
  return families
      .where((f) => (f as Map)['status'] == 'active')
      .where((f) {
        final theirs = shopAssignments
            .where((a) => (a as Map)['famId'] == (f as Map)['id'])
            .toList();
        if (theirs.any((a) =>
            (a as Map)['productId'] == excludeProductId &&
            a['status'] == 'active')) {
          return false;
        }
        if (criterionIds.length == 0) return true;
        final held = <dynamic>{
          ...theirs.expand((a) => ((a as Map)['criterionIds'] as List))
        };
        return criterionIds.every((c) => held.contains(c));
      })
      .map((f) => <String, dynamic>{
            'famId': (f as Map)['id'],
            'name': f['name'],
            'memberIds':
                ((f['members'] as List)).map((m) => (m as Map)['id']).toList(),
          })
      .toList();
}
