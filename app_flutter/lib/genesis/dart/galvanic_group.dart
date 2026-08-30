// ⚛️ אטום-Dart (דרגת-חוזה) · galvanicGroup
// תפקיד: קיבוץ-חומר גלווני — נחושת/פליז ⇒ 'copper-group' · פלדה/נירוסטה ⇒ 'iron-group' · אחר ⇒ null.
// מוצא: buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:46-69 (‏_galvanicGroup; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). שתי ה-const-האחיות (copper/iron)
//        הוטבעו inline verbatim מגוף-הטיוטה. `Set.contains` = שפה/סטנדרט. פרטי-במקור (`_`) ⇒ פורסם public.
//        האחים ב-seed (_systemOfEndType, kUncategorizedCategoryId, מטמונים) — לא נקראים ⇒ לא-הוטבעו.
//
// קלט:  m — שם-חומר עברי.
// פלט:  String? — מזהה-קבוצה גלווני, או null אם החומר אינו באחת הקבוצות.

/// The galvanic group of a plumbing material. Verbatim of plumbing_trade_seed.dart:46-69.
String? galvanicGroup(String m, {required String Function(String) term}) {
  final copper = {term('nchvsht'), term('plyz')};
  final iron = {term('pldh'), term('nyrvsth')};
  if (copper.contains(m)) return 'copper-group';
  if (iron.contains(m)) return 'iron-group';
  return null;
}
