// ⚛️ אטום-Dart (דרגת-חוזה) · roleFloorBlock
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:226-249 (‏_roleFloorBlock; חוק-4).
//        פרטי-במקור → נחשף כ-top-level. הקובץ אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: פרדיקט-חסימה טהור. שקעים (חוק-3):
//        · `ElementDescriptor` (טיפוס-שכן גדול) ⇒ מפורק לשני-השדות שהאטום נוגע בהם:
//          `labelHe` (‏d.labelHe) ו-`roleFloor` (‏d.kRoleFloor).
//        · `_isNavStructural(d)` (עוזר-שכן) ⇒ שקע-בוליאני `isNavStructural`.
//        · `_kRoleContractor` (const-שכן לא-ניתן-לשחזור) ⇒ שקע `contractorRole`; ברירת-המחדל
//          `'contractor'` נסמכת על עדות-מחצב (plumbing_trade_seed: `personaId: 'contractor'`)
//          ומתועדת ככזו.
//
// פלט:  סיבת-חסימה עברית (‏String) אם ההסתרה אסורה, אחרת `null`.

/// The step-78 role-visibility FLOOR: returns a Hebrew block reason, or `null`
/// when hiding is allowed. GLOBAL (persona null/empty): a nav-structural element
/// or one whose [roleFloor] isn't the contractor may never be hidden app-wide.
/// SINGLE persona: illegal only when hiding it from the very role it is critical
/// for (`persona == roleFloor`, roleFloor not the contractor).
/// Verbatim behaviour of edit_safety.dart:226-249 with the descriptor fields,
/// the nav-structural helper, and the contractor constant injected as sockets.
String? roleFloorBlock({required String Function(String) term, 
  required String labelHe,
  required String roleFloor,
  required bool isNavStructural,
  required String? persona,
  String contractorRole = 'contractor',
}) {
  final floor = roleFloor;
  final isGlobal = persona == null || persona.isEmpty; // null = every persona
  if (isGlobal) {
    if (isNavStructural) {
      return '${term('xi_ayapshr-lhstyr')}$labelHe${term('xi_mkl-hprsvnvt-kvll-kbln')}'
          '${term('xi_rkyb-nyvvt-chyyb-lhyshar-glvy')}';
    }
    if (floor != contractorRole) {
      return '${term('xi_ayapshr-lhstyr')}$labelHe${term('xi_mkl-hprsvnvt')}'
          '${term('xi_hrkyb-chyyb-lhyshar-glvy-ltpkyd')}$floor»';
    }
    return null; // a mundane, non-structural element MAY be hidden app-wide.
  }
  // SINGLE persona: legal unless we hide it from the very role it is critical for.
  if (persona == floor && floor != contractorRole) {
    return '${term('xi_ayapshr-lhstyr')}$labelHe${term('xi_mhtpkyd')}$floor${term('xi_kryty-ltpkyd-zh')}';
  }
  return null;
}
